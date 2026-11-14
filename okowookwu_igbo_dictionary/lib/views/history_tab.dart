import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/database_helper.dart';
import '../services/error_report_service.dart';

class HistoryTab extends StatefulWidget {
  final Function(String query)? onSelectQuery;

  const HistoryTab({super.key, this.onSelectQuery});

  @override
  State<HistoryTab> createState() => HistoryTabState();
}

class HistoryTabState extends State<HistoryTab> {
  List<HistoryItem> _history = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final historyData = await DatabaseHelper.instance.getSearchHistory();
      if (mounted) {
        setState(() {
          _history = historyData;
          _isLoading = false;
        });
      }
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'history.load',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _loadError = 'Enweghị ike ibunye ncheta. Biko nwagharịa.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearHistory() async {
    try {
      await DatabaseHelper.instance.clearHistory();
      await loadHistory();
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'history.clear',
        error: error,
        stackTrace: stackTrace,
      );
      _showOperationError();
    }
  }

  Future<void> _deleteItem(int? id) async {
    if (id == null) return;
    try {
      await DatabaseHelper.instance.deleteHistoryItem(id);
      await loadHistory();
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'history.delete_item',
        error: error,
        stackTrace: stackTrace,
      );
      await loadHistory();
      _showOperationError();
    }
  }

  void _showOperationError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enweghị ike ime nke a. Biko nwagharịa.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ncheta',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_history.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                    label: Text('Clear', style: TextStyle(color: colors.error)),
                  ),
              ],
            ),
          ),
          // Offline availability header message
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Apụrụ ihụ ihe dị na ncheta mgbe enweghị ngabasị ịntanetị',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  )
                : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: loadHistory,
                          child: const Text('Nwà ọzọ'),
                        ),
                      ],
                    ),
                  )
                : _history.isEmpty
                    ? Center(
                        child: Text(
                          'Enwebeghị achọcha',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder: (_, _) => Divider(
                          color: theme.dividerColor,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return Dismissible(
                            key: Key(item.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              color: colors.error,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _deleteItem(item.id ?? 0);
                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.history,
                                color: colors.onSurfaceVariant,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: colors.onSurfaceVariant,
                                  size: 18,
                                ),
                                onPressed: () => _deleteItem(item.id ?? 0),
                              ),
                              title: Text(
                                item.query,
                                style: theme.textTheme.bodyLarge,
                              ),
                              onTap: () {
                                if (widget.onSelectQuery != null) {
                                  widget.onSelectQuery!(item.query);
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}