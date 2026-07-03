import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bakmi_telug_naga/cubit/bakmi_cubit.dart';
import 'package:bakmi_telug_naga/cubit/bakmi_state.dart';
import 'package:bakmi_telug_naga/pages/login_page.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  Future<void> _hubungiWhatsApp(String noWa, String pesan) async {
    String formatWa = noWa.replaceAll('+', '').replaceAll(' ', '');
    if (formatWa.startsWith('0')) formatWa = '62' + formatWa.substring(1);
    final Uri url = Uri.parse("https://wa.me/$formatWa?text=${Uri.encodeComponent(pesan)}");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Gagal buka WA");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BakmiCubit, BakmiState>(
      builder: (context, state) {
        bool isPembeli = state.role == 'Pembeli';

        // JIKA ADMIN: Berikan Tampilan Tab (Pesanan & Kelola Menu)
        if (!isPembeli) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('🐉 Panel Admin - Bakmi Naga', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                backgroundColor: const Color(0xFF1E3A8A),
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()))),
                ],
                bottom: const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon: Icon(Icons.shopping_bag), text: "Pesanan Masuk"),
                    Tab(icon: Icon(Icons.restaurant_menu), text: "Kelola Menu"),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildPenjual(context, state),     // Tab 1
                  _buildKelolaMenu(context, state), // Tab 2 Fitur Baru Lu Blay!
                ],
              ),
            ),
          );
        }

        // JIKA PEMBELI: Tampilan Standard biasa
        return Scaffold(
          appBar: AppBar(
            title: const Text('🐲 Order Bakmi Telug Naga', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFF1E3A8A),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()))),
            ],
          ),
          body: _buildPembeli(context, state),
        );
      },
    );
  }

  // ==========================================
  // TAMPILAN PEMBELI (ALUR PICK-UP MANDIRI)
  // ==========================================
  Widget _buildPembeli(BuildContext context, BakmiState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(16.0), child: Text('Halo, ${state.namaUser}! Silakan pesan, nanti ambil ke toko ya!', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)))),
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.menus.length,
            itemBuilder: (context, index) {
              final menu = state.menus[index];
              return Card(
                color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: Text(menu.ikon, style: const TextStyle(fontSize: 28)),
                  title: Text(menu.namaMakanan, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${menu.harga}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                    onPressed: () => _showDialogPesan(context, menu.namaMakanan, menu.harga),
                    child: const Text('Pesan', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Status Antrean Ambil Bakmi:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)))),
        Expanded(
          flex: 1,
          child: state.orders.where((o) => o.namaPembeli == state.namaUser).isEmpty
              ? const Center(child: Text('Belum ada pesanan.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.orders.where((o) => o.namaPembeli == state.namaUser).length,
                  itemBuilder: (context, index) {
                    final ord = state.orders.where((o) => o.namaPembeli == state.namaUser).toList()[index];
                    
                    // Ganti teks info status biar cocok ama alur pickup
                    String statusText = ord.status;
                    if(ord.status == 'Sedang Diantar') statusText = 'Siap Diambil 🍜';

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text('${ord.namaMakanan} (${ord.jumlah}x)', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Total Bayar: Rp ${ord.totalHarga}\nStatus: $statusText'),
                        trailing: Icon(
                          ord.status == 'Menunggu Konfirmasi' ? Icons.hourglass_top_rounded : ord.status == 'Sedang Diantar' ? Icons.breakfast_dining : Icons.check_circle_rounded, 
                          color: ord.status == 'Menunggu Konfirmasi' ? Colors.orange : ord.status == 'Sedang Diantar' ? Colors.blue : Colors.green
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDialogPesan(BuildContext context, String menu, int harga) {
    final waCtrl = TextEditingController();
    int jumlah = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text('Pesan $menu', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Jumlah Porsi:'), Row(children: [IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => jumlah > 1 ? setModalState(() => jumlah--) : null), Text('$jumlah', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setModalState(() => jumlah++)),])]),
              const SizedBox(height: 12),
              // Cuma minta Nomor WA buat notif pickup blay, alamat diapus!
              TextFormField(controller: waCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor WhatsApp Aktif', border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              onPressed: () {
                if (waCtrl.text.isEmpty) return;
                context.read<BakmiCubit>().buatPesanan(menu, harga, waCtrl.text, jumlah);
                Navigator.pop(ctx);
              },
              child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1 ADMIN: MONITORING & HAPUS PESANAN
  // ==========================================
  Widget _buildPenjual(BuildContext context, BakmiState state) {
    return state.orders.isEmpty
        ? const Center(child: Text('Belum ada pesanan masuk dari pelanggan, Coach.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              final ord = state.orders[index];
              
              String buttonText = 'Konfirmasi & Masak';
              if(ord.status == 'Sedang Diantar') buttonText = 'Set Siap Diambil';

              return Card(
                color: Colors.white, margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Pelanggan: ${ord.namaPembeli}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), 
                          decoration: BoxDecoration(color: ord.status == 'Menunggu Konfirmasi' ? Colors.orange.withOpacity(0.1) : ord.status == 'Sedang Diantar' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), 
                          child: Text(ord.status == 'Sedang Diantar' ? 'Siap Diambil' : ord.status, style: TextStyle(color: ord.status == 'Menunggu Konfirmasi' ? Colors.orange : ord.status == 'Sedang Diantar' ? Colors.blue : Colors.green, fontSize: 11, fontWeight: FontWeight.bold))
                        )
                      ]),
                      const Divider(),
                      Text('Pesanan : ${ord.namaMakanan} (${ord.jumlah} porsi)'),
                      Text('Total Tagihan : Rp ${ord.totalHarga}', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // KONDISI JIKA SELESAI: Kasih Tombol HAPUS DATA (Request UAS Lu!) 🗑️
                          if (ord.status == 'Selesai')
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => context.read<BakmiCubit>().hapusOrderanSelesai(ord.id!),
                            ),
                          
                          if (ord.status != 'Selesai') ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                              icon: const Icon(Icons.chat, color: Colors.white, size: 16), label: const Text('Kabar Wa', style: TextStyle(color: Colors.white, fontSize: 12)),
                              onPressed: () {
                                String msg = "Halo ${ord.namaPembeli}, pesanan *${ord.namaMakanan}* mu di *Bakmi Telug Naga* sudah SIAP DIAMBIL nih, bre! Silakan merapat ke toko ya. Total: *Rp ${ord.totalHarga}*. Ditunggu! 🐉🍜";
                                _hubungiWhatsApp(ord.noWhatsapp, msg);
                              },
                            ),
                            const SizedBox(width: 8),
                            if (ord.status == 'Menunggu Konfirmasi')
                              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)), onPressed: () => context.read<BakmiCubit>().updateStatus(ord.id!, 'Sedang Diantar'), child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 12))),
                            if (ord.status == 'Sedang Diantar')
                              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => context.read<BakmiCubit>().updateStatus(ord.id!, 'Selesai'), child: const Text('Selesai Diambil', style: TextStyle(color: Colors.white, fontSize: 12))),
                          ]
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
  }

  // ==========================================
  // TAB 2 ADMIN: KELOLA MENU (CRUD TAMBAH & EDIT HARGA)
  // ==========================================
  Widget _buildKelolaMenu(BuildContext context, BakmiState state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Menu Baru', style: TextStyle(color: Colors.white)),
        onPressed: () => _showDialogTambahMenu(context),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.menus.length,
        itemBuilder: (context, index) {
          final menu = state.menus[index];
          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: Text(menu.ikon, style: const TextStyle(fontSize: 28)),
              title: Text(menu.namaMakanan, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Harga: Rp ${menu.harga}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_note, color: Color(0xFF1E3A8A), size: 28),
                onPressed: () => _showDialogEditHarga(context, menu.id!, menu.namaMakanan, menu.harga),
              ),
            ),
          );
        },
      ),
    );
  }

  // Dialog Admin Nambah Menu Baru 🆕
  void _showDialogTambahMenu(BuildContext context) {
    final namaCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();
    final ikonCtrl = TextEditingController(text: '🍜');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Menu Bakmi', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Bakmi / Pangsit')),
            TextFormField(controller: hargaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Jual (Rp)')),
            TextFormField(controller: ikonCtrl, decoration: const InputDecoration(labelText: 'Emoji Ikon (Contoh: 🍜, 🥟, 🥣)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty) return;
              context.read<BakmiCubit>().tambahMenu(namaCtrl.text, int.parse(hargaCtrl.text), ikonCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan Menu', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Dialog Admin Edit Harga 💸
  void _showDialogEditHarga(BuildContext context, int id, String nama, int hargaLama) {
    final hargaCtrl = TextEditingController(text: hargaLama.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah Harga $nama', style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextFormField(controller: hargaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Input Harga Baru (Rp)', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              if (hargaCtrl.text.isEmpty) return;
              context.read<BakmiCubit>().updateHargaMenu(id, int.parse(hargaCtrl.text));
              Navigator.pop(ctx);
            },
            child: const Text('Update Harga', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}