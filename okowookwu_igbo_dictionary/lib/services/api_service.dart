import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';
import 'database_helper.dart';
import 'error_report_service.dart';
import 'search_result_ranker.dart';

class IgboApiService {
  static const String _proxyUrl =
      'https://your-project-id.supabase.co/functions/v1/search-proxy'; // REPLACE THIS

  Future<List<WordModel>> searchWords(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final englishQueryFuture = _isEnglishWord(cleanQuery);
    final isEnglishQuery = await englishQueryFuture;

    final url = Uri.parse(_proxyUrl).replace(
      queryParameters: {
        'keyword': cleanQuery,
        'isEnglish': isEnglishQuery.toString(),
      },
    );

    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw HttpException(
        'Proxy returned HTTP ${response.statusCode}. Check connection and request.',
      );
    }

    final dynamic decodedBody = jsonDecode(response.body);
    final List<dynamic> items;
    if (decodedBody is List) {
      items = decodedBody;
    } else if (decodedBody is Map && decodedBody['data'] is List) {
      items = decodedBody['data'] as List<dynamic>;
    } else {
      throw const FormatException(
        'Proxy returned an unexpected response format.',
      );
    }

    final results = items.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Proxy returned an invalid word entry.');
      }
      return WordModel.fromJson(item);
    }).toList();

    if (results.isNotEmpty) {
      try {
        await DatabaseHelper.instance.cacheWords(results);
      } catch (error) {
        ErrorReportService.recordError(
          context: 'api.cache_search_results',
          error: error,
          stackTrace: StackTrace.current,
        );
      }
    }

    return _sortResultsByRelevance(results, cleanQuery, isEnglishQuery);
  }

  Future<bool> _isEnglishWord(String query) async {
    try {
      final url = Uri.parse(
        'https://api.dictionaryapi.dev/api/v2/entries/en/${query.toLowerCase()}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'api.detect_english_query',
        error: error,
        stackTrace: stackTrace,
      );
      return _containsIgboAccents(query);
    }
  }

  List<WordModel> _sortResultsByRelevance(
    List<WordModel> results,
    String query,
    bool isEnglishQuery,
  ) {
    return SearchResultRanker.sort(
      results,
      query,
      isEnglishQuery: isEnglishQuery,
    );
  }

  bool _containsIgboAccents(String query) {
    final igboChars = RegExp(r'[ịọụỤỌỊ́̀̂]');
    return igboChars.hasMatch(query);
  }
}
