class GrammarTags {
  static final Map<String, String> _tagMap = {
    'ADJ': 'Adjective',
    'ADV': 'Adverb',
    'AV': 'Active Verb',
    'MV': 'Medial Verb',
    'PV': 'Passive Verb',
    'CJN': 'Conjunction',
    'CJ': 'Conjunction',
    'DEM': 'Demonstrative',
    'NM': 'Name',
    'NNC': 'Noun',
    'ND': 'Nominal Modifier',
    'NNP': 'Proper Noun',
    'CD': 'Number',
    'PREP': 'Preposition',
    'PRN': 'Pronoun',
    'FW': 'Foreign Word',
    'QTF': 'Quantifier',
    'WH': 'Interrogative',
    'INTJ': 'Interjection',
    'INT': 'Interjection',
    'ISUF': 'Inflectional Suffix',
    'ESUF': 'Extensional Suffix',
    'SYM': 'Punctuation',
  };

  static String decode(String? tag) {
    if (tag == null || tag.trim().isEmpty) return 'General';
    final upperTag = tag.trim().toUpperCase();
    return _tagMap[upperTag] ?? tag;
  }
}