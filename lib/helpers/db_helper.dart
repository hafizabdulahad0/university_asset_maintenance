// File: lib/helpers/db_helper.dart

import 'dart:io' show File, Directory, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';
import '../models/complaint_model.dart';

class DBHelper {
  static late final Database _db;

  /// Initialize the database. On web this is a no-op.
  static Future<void> initDb() async {
    if (kIsWeb) return;

    // On desktop, tell sqflite to use the ffi implementation:
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'asset_maintenance.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT    NOT NULL,
            email TEXT   NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT    NOT NULL
          );
        ''');

        // Complaints table
        await db.execute('''
          CREATE TABLE complaints(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            mediaPath TEXT,
            mediaIsVideo INTEGER,
            status TEXT,
            teacherId INTEGER,
            staffId INTEGER,
            FOREIGN KEY(teacherId) REFERENCES users(id),
            FOREIGN KEY(staffId)  REFERENCES users(id)
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE complaints ADD COLUMN mediaPath TEXT;');
          await db.execute(
              'ALTER TABLE complaints ADD COLUMN mediaIsVideo INTEGER;');
        }
      },
    );

    // Seed supervisor account (won't overwrite if exists)
    await _db.insert(
      'users',
      {
        'name': 'Saira',
        'email': 'saira@app',
        'password': 'Pass123',
        'role': 'supervisor',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Export DB to project root (desktop) or external storage (mobile)
    await exportDatabase();
  }

  /// Copy the on-device DB into:
  ///  • project root as `asset_maintenance.db` (desktop)
  ///  • the device’s Downloads (mobile)
  static Future<void> exportDatabase() async {
    if (kIsWeb) return;

    final srcPath =
        await getDatabasesPath().then((p) => join(p, 'asset_maintenance.db'));
    final srcFile = File(srcPath);
    if (!await srcFile.exists()) return;

    String destPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Project root
      destPath = join(Directory.current.path, 'asset_maintenance.db');
    } else {
      // Android/iOS: put in Downloads so adb pull can find it
      final downloads = '/storage/emulated/0/Download';
      destPath = join(downloads, 'asset_maintenance.db');
    }

    await srcFile.copy(destPath);
  }

  // ─── USER METHODS ────────────────────────────────────────────────────────────

  static Future<int> insertUser(User user) => _db.insert('users', user.toMap());

  static Future<User?> getUserByEmail(String email) async {
    final maps =
        await _db.query('users', where: 'email = ?', whereArgs: [email]);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  static Future<User?> getUserById(int id) async {
    final maps = await _db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  static Future<List<User>> getAllUsers() async {
    final maps = await _db.query('users');
    return maps.map(User.fromMap).toList();
  }

  static Future<int> updateUser(User user) =>
      _db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);

  static Future<void> deleteUser(int id) =>
      _db.delete('users', where: 'id = ?', whereArgs: [id]);

  // ─── COMPLAINT METHODS ────────────────────────────────────────────────────────

  static Future<int> insertComplaint(Complaint c) =>
      _db.insert('complaints', c.toMap());

  static Future<List<Complaint>> getComplaintsByTeacher(int teacherId) async {
    final maps = await _db
        .query('complaints', where: 'teacherId = ?', whereArgs: [teacherId]);
    return maps.map(Complaint.fromMap).toList();
  }

  static Future<List<Complaint>> getUnassignedComplaints() async {
    final maps = await _db
        .query('complaints', where: 'status = ?', whereArgs: ['unassigned']);
    return maps.map(Complaint.fromMap).toList();
  }

  static Future<List<Complaint>> getAssignedComplaintsByStaff(
      int staffId) async {
    final maps = await _db.query(
      'complaints',
      where: 'staffId = ? AND status = ?',
      whereArgs: [staffId, 'assigned'],
    );
    return maps.map(Complaint.fromMap).toList();
  }

  static Future<List<Complaint>> getNeedsVerificationComplaints() async {
    final maps = await _db.query('complaints',
        where: 'status = ?', whereArgs: ['needs_verification']);
    return maps.map(Complaint.fromMap).toList();
  }

  static Future<List<Complaint>> getAllComplaints() async {
    final maps = await _db.query('complaints');
    return maps.map(Complaint.fromMap).toList();
  }

  static Future<int> updateComplaint(Complaint c) =>
      _db.update('complaints', c.toMap(), where: 'id = ?', whereArgs: [c.id]);

  static Future<void> deleteComplaint(int id) =>
      _db.delete('complaints', where: 'id = ?', whereArgs: [id]);
}
