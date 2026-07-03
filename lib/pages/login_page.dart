import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bakmi_telug_naga/cubit/bakmi_cubit.dart';
import 'package:bakmi_telug_naga/cubit/bakmi_state.dart';
import 'package:bakmi_telug_naga/pages/dashboard_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: BlocListener<BakmiCubit, BakmiState>(
        listener: (context, state) {
          if (state.status == BakmiStatus.loginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selamat Datang, ${state.namaUser}!'), backgroundColor: const Color(0xFF1E3A8A))
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard()));
          } else if (state.status == BakmiStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red)
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withOpacity(0.1), shape: BoxShape.circle), child: const Text("🐉", style: TextStyle(fontSize: 50))),
                  const SizedBox(height: 16),
                  const Text("Bakmi Telug Naga", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A))),
                  const Text("Sistem Antrean Ambil Mandiri & Cubit", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 32),
                  
                  TextFormField(controller: _usernameCtrl, decoration: InputDecoration(labelText: 'Username', prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E3A8A)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), validator: (v) => v!.isEmpty ? 'Wajib diisi!' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _passwordCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E3A8A)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white), validator: (v) => v!.isEmpty ? 'Wajib diisi!' : null),
                  const SizedBox(height: 32),
                  
                  // Tombol Login
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<BakmiCubit>().login(_usernameCtrl.text, _passwordCtrl.text);
                        }
                      },
                      child: const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // FITUR BARU: Tombol Buka Registrasi Akun Umum 🆕
                  TextButton(
                    onPressed: () => _showDialogDaftar(context),
                    child: const Text('Belum punya akun? Daftar Sekarang', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Pop-Up Form Registrasi Akun Umum (Pembeli) 📋
  void _showDialogDaftar(BuildContext context) {
    final regUserCtrl = TextEditingController();
    final regPassCtrl = TextEditingController();
    final regNamaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pendaftaran Akun Baru', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: regNamaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Kamu')),
            TextFormField(controller: regUserCtrl, decoration: const InputDecoration(labelText: 'Username Baru')),
            TextFormField(controller: regPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              if (regUserCtrl.text.isEmpty || regPassCtrl.text.isEmpty || regNamaCtrl.text.isEmpty) return;
              // Panggil fungsi cubit buat register blay
              context.read<BakmiCubit>().daftarPembeliBaru(regUserCtrl.text, regPassCtrl.text, regNamaCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pendaftaran Berhasil blay! Silakan Login.'), backgroundColor: Colors.green)
              );
            },
            child: const Text('Daftar Akun', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}