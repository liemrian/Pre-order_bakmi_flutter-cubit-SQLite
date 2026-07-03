import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bakmi_telug_naga/services/database_helper.dart';
import 'package:bakmi_telug_naga/models/menu_model.dart';
import 'package:bakmi_telug_naga/models/order_model.dart';
import 'package:bakmi_telug_naga/cubit/bakmi_state.dart';

class BakmiCubit extends Cubit<BakmiState> {
  BakmiCubit() : super(BakmiState());

  // 1. Fungsi Login
  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: BakmiStatus.loading));
    final db = await DbHelper.database;
    final hasil = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);

    if (hasil.isNotEmpty) {
      String role = hasil.first['role'] as String;
      String nama = hasil.first['nama_lengkap'] as String;
      
      emit(state.copyWith(status: BakmiStatus.loginSuccess, role: role, namaUser: nama));
      loadData();
    } else {
      emit(state.copyWith(status: BakmiStatus.error, errorMessage: 'Username atau Password Salah, Bre!'));
    }
  }

  // FITUR BARU: Registrasi User Umum (Pembeli) 🆕
  Future<void> daftarPembeliBaru(String username, String password, String namaLengkap) async {
    emit(state.copyWith(status: BakmiStatus.loading));
    final db = await DbHelper.database;

    // Cek dulu apakah username udah dipake orang lain
    final cekUser = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (cekUser.isNotEmpty) {
      emit(state.copyWith(status: BakmiStatus.error, errorMessage: 'Username sudah terpakai, blay! Cari nama lain.'));
      return;
    }

    // Masukin data baru dengan role otomatis 'Pembeli'
    await db.insert('users', {
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
      'role': 'Pembeli',
    });

    emit(state.copyWith(status: BakmiStatus.initial)); // Balikin ke state awal biar bisa login
  }

  // 3. Tarik data menu & orderan dari SQLite
  Future<void> loadData() async {
    final db = await DbHelper.database;
    final dataMenu = await db.query('menus');
    final dataOrder = await db.query('orders', orderBy: 'id DESC');

    final listMenu = dataMenu.map((m) => MenuModel.fromMap(Map<String, dynamic>.from(m))).toList();
    final listOrder = dataOrder.map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o))).toList();

    emit(state.copyWith(status: BakmiStatus.success, menus: listMenu, orders: listOrder));
  }

  // 4. Tambah pesanan via Cubit
  Future<void> buatPesanan(String menu, int harga, String wa, int jumlah) async {
    final db = await DbHelper.database;
    await db.insert('orders', {
      'nama_pembeli': state.namaUser,
      'alamat': 'Ambil di Toko (Dine In / Takeaway)', 
      'no_whatsapp': wa,
      'nama_makanan': menu,
      'jumlah': jumlah,
      'total_harga': harga * jumlah,
      'status': 'Menunggu Konfirmasi'
    });
    loadData();
  }

  // 5. Update status via Cubit
  Future<void> updateStatus(int id, String statusBaru) async {
    final db = await DbHelper.database;
    await db.update('orders', {'status': statusBaru}, where: 'id = ?', whereArgs: [id]);
    loadData();
  }

  // 6. Admin Nambah Menu Baru
  Future<void> tambahMenu(String nama, int harga, String ikon) async {
    final db = await DbHelper.database;
    await db.insert('menus', {'nama_makanan': nama, 'harga': harga, 'ikon': ikon});
    loadData(); 
  }

  // 7. Admin Ganti Harga Menu
  Future<void> updateHargaMenu(int id, int hargaBaru) async {
    final db = await DbHelper.database;
    await db.update('menus', {'harga': hargaBaru}, where: 'id = ?', whereArgs: [id]);
    loadData();
  }

  // 8. Admin Hapus Pesanan Selesai
  Future<void> hapusOrderanSelesai(int id) async {
    final db = await DbHelper.database;
    await db.delete('orders', where: 'id = ? AND status = ?', whereArgs: [id, 'Selesai']);
    loadData();
  }
}