class OrderModel {
  final int? id;
  final String namaPembeli;
  final String alamat;
  final String noWhatsapp;
  final String namaMakanan;
  final int jumlah;
  final int totalHarga;
  final String status;

  OrderModel({this.id, required this.namaPembeli, required this.alamat, required this.noWhatsapp, required this.namaMakanan, required this.jumlah, required this.totalHarga, required this.status});

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      namaPembeli: map['nama_pembeli'] ?? '',
      alamat: map['alamat'] ?? '',
      noWhatsapp: map['no_whatsapp'] ?? '',
      namaMakanan: map['nama_makanan'] ?? '',
      jumlah: map['jumlah'] ?? 1,
      totalHarga: map['total_harga'] ?? 0,
      status: map['status'] ?? '',
    );
  }
}