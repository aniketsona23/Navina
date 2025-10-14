import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emergency_contact.dart';
import '../utils/logger_util.dart';

class EmergencyContactsDatabase {
  static final EmergencyContactsDatabase _instance = EmergencyContactsDatabase._internal();
  factory EmergencyContactsDatabase() => _instance;
  EmergencyContactsDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'emergency_contacts.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE emergency_contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relationship TEXT,
        is_primary INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    AppLogger.info('Emergency contacts database created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
    AppLogger.info('Emergency contacts database upgraded from $oldVersion to $newVersion');
  }

  // Insert a new emergency contact
  Future<int> insertEmergencyContact(EmergencyContact contact) async {
    try {
      final db = await database;
      final id = await db.insert(
        'emergency_contacts',
        contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      AppLogger.info('Emergency contact inserted with ID: $id');
      return id;
    } catch (e) {
      AppLogger.error('Error inserting emergency contact: $e');
      rethrow;
    }
  }

  // Get all emergency contacts
  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'emergency_contacts',
        orderBy: 'is_primary DESC, name ASC',
      );

      final contacts = maps.map((map) => EmergencyContact.fromMap(map)).toList();
      AppLogger.info('Retrieved ${contacts.length} emergency contacts');
      return contacts;
    } catch (e) {
      AppLogger.error('Error retrieving emergency contacts: $e');
      return [];
    }
  }

  // Get primary emergency contact
  Future<EmergencyContact?> getPrimaryEmergencyContact() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'emergency_contacts',
        where: 'is_primary = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final contact = EmergencyContact.fromMap(maps.first);
        AppLogger.info('Retrieved primary emergency contact: ${contact.name}');
        return contact;
      }
      
      AppLogger.info('No primary emergency contact found');
      return null;
    } catch (e) {
      AppLogger.error('Error retrieving primary emergency contact: $e');
      return null;
    }
  }

  // Update an emergency contact
  Future<int> updateEmergencyContact(EmergencyContact contact) async {
    try {
      final db = await database;
      final count = await db.update(
        'emergency_contacts',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [contact.id],
      );
      
      AppLogger.info('Updated emergency contact with ID: ${contact.id}');
      return count;
    } catch (e) {
      AppLogger.error('Error updating emergency contact: $e');
      rethrow;
    }
  }

  // Delete an emergency contact
  Future<int> deleteEmergencyContact(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'emergency_contacts',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      AppLogger.info('Deleted emergency contact with ID: $id');
      return count;
    } catch (e) {
      AppLogger.error('Error deleting emergency contact: $e');
      rethrow;
    }
  }

  // Set primary emergency contact (removes primary status from others)
  Future<void> setPrimaryEmergencyContact(int id) async {
    try {
      final db = await database;
      
      // Remove primary status from all contacts
      await db.update(
        'emergency_contacts',
        {'is_primary': 0},
        where: 'is_primary = ?',
        whereArgs: [1],
      );
      
      // Set the specified contact as primary
      await db.update(
        'emergency_contacts',
        {'is_primary': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      AppLogger.info('Set emergency contact with ID $id as primary');
    } catch (e) {
      AppLogger.error('Error setting primary emergency contact: $e');
      rethrow;
    }
  }

  // Check if phone number already exists
  Future<bool> phoneNumberExists(String phoneNumber, {int? excludeId}) async {
    try {
      final db = await database;
      String whereClause = 'phone_number = ?';
      List<dynamic> whereArgs = [phoneNumber];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        'emergency_contacts',
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking phone number existence: $e');
      return false;
    }
  }

  // Get contact count
  Future<int> getContactCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM emergency_contacts');
      final count = Sqflite.firstIntValue(result) ?? 0;
      
      AppLogger.info('Emergency contacts count: $count');
      return count;
    } catch (e) {
      AppLogger.error('Error getting contact count: $e');
      return 0;
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    AppLogger.info('Emergency contacts database closed');
  }

  // Delete the entire database (for testing/reset)
  Future<void> deleteDatabase() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'emergency_contacts.db');
      await databaseFactory.deleteDatabase(dbPath);
      _database = null;
      AppLogger.info('Emergency contacts database deleted');
    } catch (e) {
      AppLogger.error('Error deleting emergency contacts database: $e');
      rethrow;
    }
  }
}
