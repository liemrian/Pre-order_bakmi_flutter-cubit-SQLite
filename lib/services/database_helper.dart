import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DbHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    String databasePath = await getDatabasesPath();
    String path = p.join(databasePath, 'bakmi_naga_cubit_v2.db'); // Ganti nama DB biar fresh blay

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT,
            nama_lengkap TEXT,
            role TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE menus (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_makanan TEXT,
            harga INTEGER,
            ikon TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_pembeli TEXT,
            alamat TEXT,       
            no_whatsapp TEXT,  
            nama_makanan TEXT,
            jumlah INTEGER,
            total_harga INTEGER,
            status TEXT        
          )
        ''');
        
        await db.insert('users', {'username': 'rian', 'password': 'password123', 'nama_lengkap': 'Rian', 'role': 'Pembeli'});
        // UPDATE: Akun diubah jadi admin blay!
        await db.insert('users', {'username': 'admin', 'password': 'admin123', 'nama_lengkap': 'Owner Bakmi Naga', 'role': 'Admin'});

        await db.insert('menus', {'nama_makanan': 'Mie Ayam Biasa', 'harga': 13000, 'ikon': '🍜'});
        await db.insert('menus', {'nama_makanan': 'Mie Ayam Pangsit', 'harga': 15000, 'ikon': '🥟'});
        await db.insert('menus', {'nama_makanan': 'Mie Ayam Bakso', 'harga': 17000, 'ikon': '🧆'});
        await db.insert('menus', {'nama_makanan': 'Mie Ayam Pangsit Bakso', 'harga': 20000, 'ikon': '🍲'});
        await db.insert('menus', {'nama_makanan': 'Pangsit Rebus', 'harga': 10000, 'ikon': '🥣'});
      },
    );
  }
}