import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_dashboard.dart';
import '../athlete/athlete_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final code = _codeController.text.trim().toUpperCase();

      // Önce athletes koleksiyonunda kodu ara
      final query = await FirebaseFirestore.instance
          .collection('athletes')
          .where('inviteCode', isEqualTo: code)
          .get();

      if (query.docs.isEmpty) {
        // Admin kontrolü (basit)
        if (code == 'ADMIN' && _passwordController.text == 'admin123') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Geçersiz kod!')));
        return;
      }

      // Sporcu bulundu
      final athlete = query.docs.first.data();

      // Şifre kontrolü (ilk girişte şifre boşsa yeni şifre kaydet)
      final savedPassword = athlete['password'];
      final enteredPassword = _passwordController.text;

      if (savedPassword == null || savedPassword.isEmpty) {
        // İlk giriş - şifreyi kaydet
        await FirebaseFirestore.instance
            .collection('athletes')
            .doc(query.docs.first.id)
            .update({'password': enteredPassword});
      } else if (savedPassword != enteredPassword) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Hatalı şifre!')));
        return;
      }

      // Giriş başarılı
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AthleteHome(athleteId: query.docs.first.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Color(0xFFE94560),
                ),
                const SizedBox(height: 20),
                const Text(
                  'COACH APP',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Davet Kodunuz',
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Şifreniz',
                    filled: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('GİRİŞ YAP'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
