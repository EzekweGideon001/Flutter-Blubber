class DialectTags {
  static final Map<String, String> _dialectMap = {
    'IBO-ABI': 'Abịrịba',
    'IBO-ACH': 'Achala',
    'IBO-AFI': 'Afiikpo',
    'IBO-AJA': 'Ajalị',
    'IBO-AMA': 'Amaifeke',
    'IBO-ANA': 'Anam',
    'IBO-ANI': 'Anịọcha',
    'IBO-AWK': 'Ọkụzụ',
    'IBO-BON': 'Ụbanị',
    'IBO-ECH': 'Echee',
    'IBO-EGB': 'Egbema',
    'IBO-EKP': 'Ẹkpẹyẹ',
    'IBO-EZA': 'Ezaa',
    'IBO-EZE': 'Ezeagu',
    'IBO-EZM': 'Ezzamgbo',
    'IBO-IHU': 'Ihuoma',
    'IBO-IQW': 'Ikwo',
    'IBO-ISU': 'Isuama',
    'IBO-IZZ': 'Izii',
    'IBO-MBA': 'Mbaise',
    'IBO-NDL': 'Ndele',
    'IBO-NGW': 'Ngwa',
    'IBO-NKA': 'Nkanụ',
    'IBO-NKP': 'Mkpọọ',
    'IBO-NSA': 'Nsa',
    'IBO-NSU': 'Nsụka',
    'IBO-OGA': 'Ọgba',
    'IBO-OGK': 'Ọgbakịrị',
    'IBO-OGU': 'Ugwuta',
    'IBO-OHU': 'Ọhụhụ',
    'IBO-OKA': 'Ọka',
    'IBO-ONI': 'Ọnịcha',
    'IBO-ORL': 'Ọlụ',
    'IBO-OWE': 'Owere',
    'IBO-OBO': 'Obosi',
    'IBO-OGI': 'Ogidi',
    'IBO-UDI': 'Udi',
    'IBO-UKW': 'Ụkwụanị',
    'IBO-UMU': 'Ụmụahịa',
    'IBO-UNW': 'Unwana; Ungwana Lordji',
  };

  static String decode(String? code) {
    if (code == null || code.trim().isEmpty) return '';
    final formattedKey = code.trim().toUpperCase();
    
    // Check direct match or stripped 'IBO-' match
    if (_dialectMap.containsKey(formattedKey)) {
      return _dialectMap[formattedKey]!;
    }
    
    final prefixedKey = 'IBO-$formattedKey';
    if (_dialectMap.containsKey(prefixedKey)) {
      return _dialectMap[prefixedKey]!;
    }

    return code;
  }
}