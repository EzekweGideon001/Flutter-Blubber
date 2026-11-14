import '../models/word_model.dart';

class SearchResultRanker {
  static const int _exactMatchScore = 3000000;
  static const int _startsWithScore = 2000000;
  static const int _containsScore = 1000000;
  static const int _headwordMatchWeight = 10000000;
  static const int _tieBreakerScoreLimit = 10000;

  static List<WordModel> sort(
    List<WordModel> results,
    String query, {
    required bool isEnglishQuery,
  }) {
    final cleanQuery = _normalize(query);
    if (cleanQuery.isEmpty) return results;

    final scoredResults = [
      for (var index = 0; index < results.length; index++)
        _scoreResult(results[index], index, cleanQuery, isEnglishQuery),
    ];

    scoredResults.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;

      final lengthComparison = a.normalizedWord.length.compareTo(
        b.normalizedWord.length,
      );
      if (lengthComparison != 0) return lengthComparison;

      final wordComparison = a.normalizedWord.compareTo(b.normalizedWord);
      if (wordComparison != 0) return wordComparison;
      return a.originalIndex.compareTo(b.originalIndex);
    });

    return scoredResults.map((item) => item.result).toList();
  }

  static _ScoredResult _scoreResult(
    WordModel result,
    int originalIndex,
    String query,
    bool isEnglishQuery,
  ) {
    final normalizedWord = _normalize(result.word);
    final bestDefinitionScore = result.definitions
        .map(_normalize)
        .map((definition) => _definitionScore(definition, query))
        .fold(0, (best, score) => score > best ? score : best);

    final headwordScore = isEnglishQuery
        ? 0
        : normalizedWord == query
        ? _exactMatchScore
        : normalizedWord.startsWith(query)
        ? _startsWithScore
        : 0;

    return _ScoredResult(
      result: result,
      normalizedWord: normalizedWord,
      score: headwordScore * _headwordMatchWeight + bestDefinitionScore,
      originalIndex: originalIndex,
    );
  }

  static int _definitionScore(String definition, String query) {
    final matchPosition = definition.indexOf(query);
    if (matchPosition < 0) return 0;

    final matchScore = definition == query
        ? _exactMatchScore
        : matchPosition == 0
        ? _startsWithScore
        : _containsScore;
    final positionBonus =
        _tieBreakerScoreLimit -
        matchPosition.clamp(0, _tieBreakerScoreLimit).toInt();
    final lengthBonus =
        _tieBreakerScoreLimit -
        definition.length.clamp(0, _tieBreakerScoreLimit).toInt();
    return matchScore + positionBonus + lengthBonus;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('ị', 'i')
        .replaceAll('ọ', 'o')
        .replaceAll('ụ', 'u')
        .replaceAll(RegExp(r'[́̀̂̄]'), '')
        .replaceAll(RegExp(r'[.,/#!$%^&*;:{}=\-_`~()]'), '')
        .trim();
  }
}

class _ScoredResult {
  final WordModel result;
  final String normalizedWord;
  final int score;
  final int originalIndex;

  const _ScoredResult({
    required this.result,
    required this.normalizedWord,
    required this.score,
    required this.originalIndex,
  });
}
