import 'package:flutter_test/flutter_test.dart';
import 'package:igbo_dictionary/models/word_model.dart';

void main() {
  test('parses definitions and associated example sentences from the API', () {
    final word = WordModel.fromJson({
      'id': 'word-id',
      'word': 'ụlọ',
      'definitions': [
        {
          'wordClass': 'NNC',
          'definitions': ['house', 'home'],
        },
      ],
      'dialects': [
        {
          'dialects': ['AFI', 'OWE'],
        },
      ],
      'examples': [
        {
          'id': 'example-id',
          'igbo': 'Ụlọ m dị mma.',
          'english': 'My house is beautiful.',
        },
        {
          'id': 'example-id-2',
          'igbo': 'Ụlọ ahụ buru ibu.',
          'english': 'That house is large.',
        },
      ],
    });

    expect(word.definitions, ['house', 'home']);
    expect(word.wordClass, 'NNC');
    expect(word.dialect, 'AFI, OWE');
    expect(word.examples, [
      'Ụlọ m dị mma.\nMy house is beautiful.',
      'Ụlọ ahụ buru ibu.\nThat house is large.',
    ]);
  });

  test('parses alternate word class and definition field formats', () {
    final word = WordModel.fromJson({
      'id': 'word-id',
      'word': 'ụlọ',
      'word_class': 'NNC',
      'definitions': [
        {'meaning': 'building for habitation'},
      ],
    });

    expect(word.wordClass, 'NNC');
    expect(word.definitions, ['building for habitation']);
  });

  test('parses the direct fields documented in the word schema', () {
    final word = WordModel.fromJson({
      'id': 'word-id',
      'word': 'ụlọ',
      'wordClass': 'NNC',
      'definitions': ['house'],
      'dialects': [
        {
          'dialects': ['AFI'],
        },
      ],
    });

    expect(word.wordClass, 'NNC');
    expect(word.definitions, ['house']);
    expect(word.dialect, 'AFI');
  });
}
