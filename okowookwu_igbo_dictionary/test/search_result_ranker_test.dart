import 'package:flutter_test/flutter_test.dart';
import 'package:igbo_dictionary/models/word_model.dart';
import 'package:igbo_dictionary/services/search_result_ranker.dart';

WordModel _word(String word, List<String> definitions) {
  return WordModel(
    id: word,
    word: word,
    wordClass: '',
    definitions: definitions,
    examples: const [],
  );
}

void main() {
  test('English search ranks exact and leading definitions first', () {
    final results = [
      _word('late-mention', ['A phrase that mentions a book']),
      _word('early-mention', ['The book-related item']),
      _word('akwukwo', ['book']),
      _word('akwukwo-ndetu', ['book, a written work']),
    ];

    final sorted = SearchResultRanker.sort(
      results,
      'book',
      isEnglishQuery: true,
    );

    expect(sorted.map((result) => result.word), [
      'akwukwo',
      'akwukwo-ndetu',
      'early-mention',
      'late-mention',
    ]);
  });

  test('shorter leading definition wins when match category is equal', () {
    final results = [
      _word('long', ['book, a long and detailed written account']),
      _word('short', ['book, written work']),
    ];

    final sorted = SearchResultRanker.sort(
      results,
      'book',
      isEnglishQuery: true,
    );

    expect(sorted.map((result) => result.word), ['short', 'long']);
  });

  test('best matching definition determines result relevance', () {
    final results = [
      _word('later', ['A thing related to a book']),
      _word('exact', ['a volume', 'book']),
    ];

    final sorted = SearchResultRanker.sort(
      results,
      'book',
      isEnglishQuery: true,
    );

    expect(sorted.map((result) => result.word), ['exact', 'later']);
  });

  test(
    'Igbo searches keep exact and prefix headwords ahead of other entries',
    () {
      final results = [
        _word('aka', ['a hand']),
        _word('akụkụ', ['side']),
        _word('aku', ['wealth']),
      ];

      final sorted = SearchResultRanker.sort(
        results,
        'aku',
        isEnglishQuery: false,
      );

      expect(sorted.map((result) => result.word), ['aku', 'akụkụ', 'aka']);
    },
  );

  test('empty query preserves the input ordering', () {
    final results = [
      _word('z', ['last']),
      _word('a', ['first']),
    ];

    final sorted = SearchResultRanker.sort(
      results,
      '   ',
      isEnglishQuery: true,
    );

    expect(sorted, same(results));
  });
}
