class MenuModel {
  final int? id;
  final String namaMakanan;
  final int harga;
  final String ikon;

  MenuModel({this.id, required this.namaMakanan, required this.harga, required this.ikon});

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(id: map['id'], namaMakanan: map['nama_makanan'], harga: map['harga'], ikon: map['ikon']);
  }
}