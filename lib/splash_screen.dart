import 'dart:async';
import 'main.dart'; // Gantilah dengan nama file main.dart Anda
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Tambahkan delay untuk simulasi tampilan splash selama beberapa detik
    Timer(
      Duration(seconds: 3), // Ganti sesuai kebutuhan
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen()), // Gantilah dengan nama MyApp() Anda
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(
          75, 28, 254, 1), // Atur warna latar belakang sesuai keinginan
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tambahkan logo atau gambar splash screen
            Image.asset(
              'assets/3.png', // Ganti dengan path gambar Anda
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            // Tambahkan teks atau judul splash screen
            Text(
              'ChatBot App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ganti dengan nama halaman berikutnya setelah splash screen

void main() {
  runApp(MaterialApp(
    title: 'Splash Screen Example',
    home: SplashScreen(),
  ));
}
