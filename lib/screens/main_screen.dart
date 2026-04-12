import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart'; // Đã thêm dòng import này

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0: Trang chủ, 1: Lịch hẹn, 2: Cá nhân

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const HomeScreen(),
    const AppointmentsScreen(),
    const ProfileScreen(), // Đã thêm màn hình Hồ sơ vào đây
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Hiện màn hình tương ứng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Chuyển tab khi bấm
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[400],
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Lịch hẹn',
          ),
          // Đã thêm tab thứ 3 vào thanh điều hướng
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
