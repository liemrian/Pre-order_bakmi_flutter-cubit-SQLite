import '../models/menu_model.dart';
import '../models/order_model.dart';

enum BakmiStatus { initial, loading, success, error, loginSuccess }

class BakmiState {
  final BakmiStatus status;
  final String role;
  final String namaUser;
  final List<MenuModel> menus;
  final List<OrderModel> orders;
  final String errorMessage;

  BakmiState({
    this.status = BakmiStatus.initial,
    this.role = '',
    this.namaUser = '',
    this.menus = const [],
    this.orders = const [],
    this.errorMessage = '',
  });

  BakmiState copyWith({
    BakmiStatus? status,
    String? role,
    String? namaUser,
    List<MenuModel>? menus,
    List<OrderModel>? orders,
    String? errorMessage,
  }) {
    return BakmiState(
      status: status ?? this.status,
      role: role ?? this.role,
      namaUser: namaUser ?? this.namaUser,
      menus: menus ?? this.menus,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}