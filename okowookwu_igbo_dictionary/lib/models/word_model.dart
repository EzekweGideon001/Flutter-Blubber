import 'dart:convert';

class WordModel {
  final String id;
  final String word;
  final String wordClass;
  final List<String> definitions;
  final List<String> examples;
  final String? pronunciationUrl;
  final String dialect;

  WordModel({
    required this.id,
    required this.word,
    required this.wordClass,
    required this.definitions,
    required this.examples,
    this.pronunciationUrl,
    this.dialect = '',
  });

  // Parse JSON from API response
  factory WordModel.fromJson(Map<String, dynamic> json) {
    final definitionsValue =
        json['definitions'] ?? json['definition'] ?? json['meanings'];
    final parsedDefinitions = _parseDefinitions(definitionsValue);
    final wordClass = _parseWordClass(json, definitionsValue);
    final dialect = _parseDialects(json['dialects'] ?? json['dialect']);

    List<String> parsedExamples = [];
    if (json['examples'] is List) {
      for (var e in (json['examples'] as List)) {
        if (e is Map) {
          final igbo = (e['igbo'] ?? e['sentence'] ?? '').toString();
          final english = (e['english'] ?? e['translation'] ?? '').toString();
          if (igbo.isNotEmpty && english.isNotEmpty) {
            parsedExamples.add('$igbo\n$english');
          } else if (igbo.isNotEmpty) {
            parsedExamples.add(igbo);
          } else if (english.isNotEmpty) {
            parsedExamples.add(english);
          }
        } else if (e != null) {
          final str = e.toString();
          if (str.isNotEmpty) parsedExamples.add(str);
        }
      }
    }

    return WordModel(
      id: json['id']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      wordClass: wordClass,
      definitions: parsedDefinitions,
      examples: parsedExamples,
      pronunciationUrl:
          json['pronunciation']?.toString() ?? json['media']?.toString(),
      dialect: dialect,
    );
  }

  static String _parseWordClass(
    Map<String, dynamic> json,
    dynamic definitions,
  ) {
    final directValue =
        json['wordClass'] ?? json['word_class'] ?? json['wordclass'];
    if (directValue != null && directValue.toString().trim().isNotEmpty) {
      return directValue.toString();
    }

    if (definitions is List) {
      for (final item in definitions) {
        if (item is Map) {
          final value = item['wordClass'] ?? item['word_class'];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString();
          }
        }
      }
    }
    return '';
  }

  static String _parseDialects(dynamic value) {
    final dialects = <String>{};

    void addDialectValues(dynamic dialectValue) {
      if (dialectValue is List) {
        for (final item in dialectValue) {
          if (item is String && item.trim().isNotEmpty) {
            dialects.add(item.trim());
          }
        }
      } else if (dialectValue is String && dialectValue.trim().isNotEmpty) {
        dialects.add(dialectValue.trim());
      }
    }

    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          addDialectValues(item['dialects'] ?? item['dialect']);
        } else {
          addDialectValues(item);
        }
      }
    } else {
      addDialectValues(value);
    }
    return dialects.join(', ');
  }

  static List<String> _parseDefinitions(dynamic value) {
    if (value is String) {
      return value.trim().isEmpty ? [] : [value];
    }
    if (value is! List) return [];

    final definitions = <String>[];
    for (final item in value) {
      if (item is String) {
        if (item.trim().isNotEmpty) definitions.add(item);
      } else if (item is Map) {
        final nestedDefinitions = item['definitions'];
        if (nestedDefinitions != null) {
          definitions.addAll(_parseDefinitions(nestedDefinitions));
        } else {
          final text = item['definition'] ?? item['meaning'] ?? item['english'];
          if (text is String && text.trim().isNotEmpty) {
            definitions.add(text);
          }
        }
      }
    }
    return definitions;
  }

  // Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'word_class': wordClass,
      'definitions': jsonEncode(definitions),
      'examples': jsonEncode(examples),
      'pronunciation_url': pronunciationUrl,
      'dialect': dialect,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Parse Map from SQLite database
  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      wordClass: map['word_class'],
      definitions: List<String>.from(jsonDecode(map['definitions'])),
      examples: List<String>.from(jsonDecode(map['examples'])),
      pronunciationUrl: map['pronunciation_url'],
      dialect: map['dialect'] ?? '',
    );
  }
}
