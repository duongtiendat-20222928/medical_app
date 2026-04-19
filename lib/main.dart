import 'package:btl_cdtt3/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart'; // Màn hình Đăng nhập

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  final isLoggedIn = userId != null;

  // 1. CHẠY GIAO DIỆN APP NGAY LẬP TỨC
  runApp(MyApp(isLoggedIn: isLoggedIn));

  // 2. Gọi Firebase chạy ngầm
  _khoiTaoFirebaseNgam();
}

Future<void> _khoiTaoFirebaseNgam() async {
  try {
    print("⏳ Đang âm thầm kết nối Firebase (Kế hoạch B)...");

    // KHỞI TẠO FIREBASE BẰNG CODE TRỰC TIẾP (Bỏ qua file JSON)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCVRx46jhjf3s9z39EY5lev6h2HfbqWgoE",
        appId: "1:408128502317:android:f39a9783b9498d45d456a4",
        messagingSenderId: "408128502317",
        projectId: "dat-booking-app",
        storageBucket: "dat-booking-app.firebasestorage.app",
      ),
    );
    print("✅ Đã kết nối Firebase thành công!");

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    String? token = await messaging.getToken();
    print("=================================================");
    print("🔑 TOKEN ĐIỆN THOẠI LÀ: $token");
    print("=================================================");
  } catch (e) {
    print("=================================================");
    print("❌ LỖI FIREBASE KẾ HOẠCH B: $e");
    print("=================================================");
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đặt Lịch Khám',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
