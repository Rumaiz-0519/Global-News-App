import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:news_app/models/categories_news_model.dart';

class BookmarkDatabase {
  static final BookmarkDatabase instance = BookmarkDatabase._init();
  static Database? _database;

  BookmarkDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookmarks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      author TEXT,
      description TEXT,
      url TEXT UNIQUE,
      urlToImage TEXT,
      publishedAt TEXT,
      content TEXT,
      isBookmarked INTEGER
    )
    ''');
  }

  Future<void> insertArticle(Articles article) async {
    final db = await instance.database;
    try {
      await db.insert(
        'bookmarks',
        article.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the article is already there
      );
    } catch (e) {
      print("Error inserting article: $e");
    }
  }

  Future<List<Articles>> getBookmarkedArticles() async {
    final db = await instance.database;
    final result = await db.query('bookmarks');

    return result.map((json) => Articles.fromJson(json)).toList();
  }

  Future<void> deleteArticle(String url) async {
    final db = await instance.database;
    try {
      await db.delete(
        'bookmarks',
        where: 'url = ?',
        whereArgs: [url],
      );
    } catch (e) {
      print("Error deleting article: $e");
    }
  }
}