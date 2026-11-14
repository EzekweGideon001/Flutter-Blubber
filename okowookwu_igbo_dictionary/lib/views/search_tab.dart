import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../services/error_report_service.dart';
import '../theme/app_theme.dart';
import 'widgets/app_state_view.dart';
import 'widgets/word_detail_view.dart';

enum SearchStatus { idle, searching, success, empty, noInternet, serverError }

class SearchTab extends StatefulWidget {
  final String? initialQuery;
  const SearchTab({super.key, this.initialQuery});

  @override
  State<SearchTab> createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final IgboApiService _apiService = IgboApiService();

  SearchStatus _status = SearchStatus.idle;
  List<WordModel> _results = [];
  bool _isShowingCachedResults = false;
  Timer? _debounce;
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  void executeSearch(String query) {
    _searchController.text = query;
    _performSearch(query, ++_searchGeneration);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final generation = ++_searchGeneration;
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _performSearch(query, generation);
    });
  }

  Future<void> _performSearch(String query, [int? generation]) async {
    final requestGeneration = generation ?? ++_searchGeneration;
    if (requestGeneration != _searchGeneration) return;

    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _status = SearchStatus.idle;
        _results = [];
        _isShowingCachedResults = false;
      });
      return;
    }

    setState(() {
      _status = SearchStatus.searching;
      _isShowingCachedResults = false;
    });

    try {
      var receivedNetworkResults = false;
      DatabaseHelper.instance
          .searchCachedWords(cleanQuery)
          .then(
            (cached) {
              if (cached.isNotEmpty &&
                  mounted &&
                  requestGeneration == _searchGeneration &&
                  !receivedNetworkResults) {
                setState(() {
                  _results = cached;
                  _isShowingCachedResults = true;
                  _status = SearchStatus.success;
                });
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              ErrorReportService.recordError(
                context: 'search.read_cached_results',
                error: error,
                stackTrace: stackTrace,
              );
            },
          );
      final results = await _apiService.searchWords(cleanQuery);
      receivedNetworkResults = true;

      if (mounted && requestGeneration == _searchGeneration) {
        setState(() {
          _results = results;
          _isShowingCachedResults = false;
          _status = results.isEmpty ? SearchStatus.empty : SearchStatus.success;
        });
      }
      try {
        await DatabaseHelper.instance.addSearchHistory(cleanQuery);
      } catch (error, stackTrace) {
        ErrorReportService.recordError(
          context: 'search.save_history',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'search.perform',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted && requestGeneration == _searchGeneration) {
        setState(() {
          _status = _isShowingCachedResults && _results.isNotEmpty
              ? SearchStatus.success
              : error is SocketException ||
                    error is TimeoutException ||
                    error is http.ClientException
              ? SearchStatus.noInternet
              : SearchStatus.serverError;
        });
      }
    }
  }

  Widget _buildStateDisplay() {
    final theme = Theme.of(context);
    switch (_status) {
      case SearchStatus.searching:
        return const AppStateView(
          title: 'Ana m achọ...',
          color: AppColors.green,
          loading: true,
        );
      case SearchStatus.empty:
        return const AppStateView(
          icon: Icons.search_off_rounded,
          title: 'Ihe ị na-achọ adịghị',
          message: 'Lee nsụpe ya nkeọma',
        );
      case SearchStatus.noInternet:
        return AppStateView(
          icon: Icons.wifi_off_rounded,
          color: AppColors.error,
          title: 'Ngabasị ịntanetị adịghị',
          message: 'Lee ngabasị ịntanetị gị ma nwàgharịa',
          action: TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: const Text('Nwà ọzọ'),
          ),
        );
      case SearchStatus.serverError:
        return AppStateView(
          icon: Icons.error_outline_rounded,
          color: theme.colorScheme.secondary,
          title: 'O nwe ihe ghara agha',
          message: 'Apụghị imecha achọcha a. Biko nwàgharịa.',
          action: TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: const Text('Nwà ọzọ'),
          ),
        );
      case SearchStatus.idle:
        return const AppStateView(title: 'Dee ihe ị na-achọ');
      case SearchStatus.success:
        return ListView.builder(
          itemCount: _results.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final color = _isShowingCachedResults
                  ? AppColors.error
                  : AppColors.green;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isShowingCachedResults
                      ? 'Azịza sitere na ncheta gị'
                      : "Azịza sitere n'ịntanetị",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return WordDetailView(word: _results[index - 1]);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Dee n\'asụsụ Igbo maọbụ Bekee...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildStateDisplay()),
        ],
      ),
    );
  }
}
