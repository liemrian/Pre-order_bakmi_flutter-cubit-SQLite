import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bakmi_telug_naga/cubit/bakmi_cubit.dart';
import 'package:bakmi_telug_naga/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BakmiCubit(), // Daftarin Cubit ke sistem utama
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bakmi Telug Naga',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1E3A8A), // Warna Biru Naga 🐉🔵
          scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        ),
        home: LoginPage(), // Pintu gerbang utama langsung ke halaman Login
      ),
    );
  }
}