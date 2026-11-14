import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/database_helper.dart';
import '../services/error_report_service.dart';
import 'word_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => FavoritesTabState();
}

class FavoritesTabState extends State<FavoritesTab> {
  List<WordModel> _favorites = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final favs = await DatabaseHelper.instance.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favs;
          _isLoading = false;
        });
      }
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'favorites.load',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _loadError = 'Enweghị ike ibunye mmasị gị';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(WordModel word) async {
    try {
      await DatabaseHelper.instance.toggleFavorite(word);
      await loadFavorites();
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'favorites.remove',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _loadError = 'Enweghị ike iwepụ ya na mmasị gị');
      }
    }
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
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Mmasị',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                          onPressed: loadFavorites,
                          child: const Text('Nwà ọzọ'),
                        ),
                      ],
                    ),
                  )
                : _favorites.isEmpty
                ? Center(
                    child: Text(
                      'Enwebeghị mmasị',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    itemCount: _favorites.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: theme.dividerColor, height: 1),
                    itemBuilder: (context, index) {
                      final word = _favorites[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          word.word,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          word.definitions.isNotEmpty
                              ? word.definitions.first
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: colors.error,
                          ),
                          onPressed: () => _removeFavorite(word),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WordDetailScreen(word: word),
                            ),
                          );
                          await loadFavorites();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
