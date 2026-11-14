import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../services/audio_service.dart';
import '../../services/database_helper.dart';
import '../../config/grammar_tags.dart';
import '../../config/dialect_tags.dart';
import '../../services/error_report_service.dart';
import '../../theme/app_theme.dart';

class WordDetailView extends StatefulWidget {
  final WordModel word;

  const WordDetailView({super.key, required this.word});

  @override
  State<WordDetailView> createState() => _WordDetailViewState();
}

class _WordDetailViewState extends State<WordDetailView> {
  final AudioService _audioService = AudioService();
  bool _isFavorite = false;
  bool _isUpdatingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status = await DatabaseHelper.instance.isFavorite(widget.word.id);
      if (mounted) setState(() => _isFavorite = status);
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'favorites.check_status',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isUpdatingFavorite) return;
    setState(() => _isUpdatingFavorite = true);

    try {
      final isFavorite =
          await DatabaseHelper.instance.toggleFavorite(widget.word);
      if (mounted) setState(() => _isFavorite = isFavorite);
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'favorites.toggle',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apụghị ibunye mmasị gị. Biko nwàgharịa.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingFavorite = false);
    }
  }

  Future<void> _handleAudioPlayback(String? url) async {
    if (url == null || url.trim().isEmpty) {
      _showAudioSnackBar('Ngeretụ adịghị');
      return;
    }

    final success = await _audioService.playAudio(url);
    if (!success && mounted) {
      _showAudioSnackBar('Apụghị ịkpọ ngeretụ a');
    }
  }

  void _showAudioSnackBar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.volume_off_rounded,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.onSurface)),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Title + Audio + Favorite Button
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.word.word,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
                onPressed: () =>
                    _handleAudioPlayback(widget.word.pronunciationUrl),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  size: 28,
                ),
                onPressed: _isUpdatingFavorite ? null : _toggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Word Class Tag (Decoded)
          if (widget.word.wordClass.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                GrammarTags.decode(widget.word.wordClass),
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Dialect Tag (Decoded)
          if (widget.word.dialect.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.7),
                ),
              ),
              child: Text(
                widget.word.dialect
                    .split(',')
                    .map((dialect) => DialectTags.decode(dialect.trim()))
                    .take(2)
                    .join(', '),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Definitions Section
          Text(
            'Nkọwa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.word.definitions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${entry.key + 1}. ${entry.value}',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Example Sentences Section
          if (widget.word.examples.isNotEmpty) ...[
            Text(
              'Ọmụmaatụ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.word.examples.take(2).map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  example,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
