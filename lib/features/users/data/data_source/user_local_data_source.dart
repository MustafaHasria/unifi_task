import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

@injectable
class UserLocalDataSource {
  final DatabaseHelper _databaseHelper;

  UserLocalDataSource(this._databaseHelper);

  Future<void> cacheUsers(List<UserModel> users) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    // Clear old data
    batch.delete('users');

    // Insert new data
    for (final user in users) {
      batch.insert(
        'users',
        {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'gender': user.gender,
          'status': user.status,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    await _updateCacheMetadata('last_sync', DateTime.now().toIso8601String());
  }

  Future<List<UserModel>> getCachedUsers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'id ASC',
    );

    return maps.map((map) => UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String,
      status: map['status'] as String,
    )).toList();
  }

  Future<void> clearCache() async {
    final db = await _databaseHelper.database;
    await db.delete('users');
    await db.delete('metadata');
  }

  Future<bool> hasCachedData() async {
    final db = await _databaseHelper.database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty;
  }

  Future<DateTime?> getLastSyncTime() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'metadata',
      where: 'key = ?',
      whereArgs: ['last_sync'],
    );

    if (result.isEmpty) return null;
    
    return DateTime.parse(result.first['value'] as String);
  }

  Future<void> _updateCacheMetadata(String key, String value) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'metadata',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

