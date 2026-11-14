import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/word_model.dart';
import '../models/history_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('igbo_dictionary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_words (
        id TEXT PRIMARY KEY,
        word TEXT,
        word_class TEXT,
        definitions TEXT,
        examples TEXT,
        pronunciation_url TEXT,
        dialect TEXT,
        cached_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT,
        timestamp INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id TEXT PRIMARY KEY,
        word TEXT,
        word_class TEXT,
        definitions TEXT,
        examples TEXT,
        pronunciation_url TEXT,
        dialect TEXT,
        cached_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_word_ngrams (
        word_id TEXT NOT NULL,
        gram TEXT NOT NULL,
        PRIMARY KEY (gram, word_id)
      ) WITHOUT ROWID
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await _createDB(db, newVersion);

    await _addDialectColumnIfMissing(db, 'cached_words');
    await _addDialectColumnIfMissing(db, 'favorites');

    if (oldVersion < 3) {
      final words = await db.query('cached_words');
      final batch = db.batch();
      for (final word in words) {
        _addNgrams(batch, word['id'] as String, word['word'] as String? ?? '',
            word['definitions'] as String? ?? '');
      }
      await batch.commit(noResult: true);
    }
  }

  Future<void> _addDialectColumnIfMissing(Database db, String table) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    if (!columns.any((column) => column['name'] == 'dialect')) {
      await db.execute('ALTER TABLE $table ADD COLUMN dialect TEXT DEFAULT ""');
    }
  }

  // --- CACHE METHODS ---

  Future<void> cacheWords(List<WordModel> words) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var word in words) {
      final values = word.toMap();
      batch.insert('cached_words', values,
          conflictAlgorithm: ConflictAlgorithm.replace);
      batch.delete('cached_word_ngrams', where: 'word_id = ?', whereArgs: [word.id]);
      _addNgrams(
        batch,
        word.id,
        word.word,
        values['definitions'] as String,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<WordModel>> searchCachedWords(String query) async {
    final db = await instance.database;
    final grams = _ngrams(query.toLowerCase());
    final indexedSearch = grams.isNotEmpty &&
        !query.contains('%') &&
        !query.contains('_') &&
        grams.length < 900;
    final results = await db.query(
      'cached_words',
      where: indexedSearch
          ? '''(word LIKE ? OR definitions LIKE ?)
              AND id IN (
                SELECT word_id FROM cached_word_ngrams
                WHERE gram IN (${List.filled(grams.length, '?').join(',')})
                GROUP BY word_id HAVING COUNT(*) = ?
              )'''
          : 'word LIKE ? OR definitions LIKE ?',
      whereArgs: indexedSearch
          ? [
              '%$query%',
              '%$query%',
              ...grams,
              grams.length,
            ]
          : ['%$query%', '%$query%'],
    );
    return results.map((map) => WordModel.fromMap(map)).toList();
  }

  void _addNgrams(
    Batch batch,
    String wordId,
    String word,
    String definitions,
  ) {
    for (final gram in {..._ngrams('$word $definitions'.toLowerCase())}) {
      batch.insert('cached_word_ngrams', {
        'word_id': wordId,
        'gram': gram,
      });
    }
  }

  Set<String> _ngrams(String value) {
    final characters = value.runes.toList();
    if (characters.length < 3) return {};
    return {
      for (var i = 0; i <= characters.length - 3; i++)
        String.fromCharCodes(characters.skip(i).take(3)),
    };
  }

  // --- HISTORY METHODS ---

  Future<void> addSearchHistory(String query) async {
    final db = await instance.database;
    await db.insert(
      'history',
      {
        'query': query.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryItem>> getSearchHistory() async {
    final db = await instance.database;
    final results = await db.query(
      'history',
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    return results.map((map) => HistoryItem.fromMap(map)).toList();
  }

  Future<void> clearHistory() async {
    final db = await instance.database;
    await db.delete('history');
  }

  Future<int> deleteHistoryItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- FAVOURITES METHODS ---

  Future<bool> toggleFavorite(WordModel word) async {
    final db = await instance.database;

    return db.transaction<bool>((txn) async {
      final deleted = await txn.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [word.id],
      );
      if (deleted > 0) return false;

      await txn.insert(
        'favorites',
        word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    });
  }

  Future<bool> isFavorite(String wordId) async {
    final db = await instance.database;
    final results = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [wordId],
    );
    return results.isNotEmpty;
  }

  Future<List<WordModel>> getFavorites() async {
    final db = await instance.database;
    final results = await db.query('favorites', orderBy: 'cached_at DESC'); 
    return results.map((map) => WordModel.fromMap(map)).toList();
  }
}