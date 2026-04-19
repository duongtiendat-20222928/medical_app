import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
// import 'appointments_screen.dart'; // Sau này bạn làm trang lịch hẹn
// import 'profile_screen.dart';     // Sau này bạn làm trang cá nhân

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Danh sách các trang để chuyển đổi
  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Trang Lịch Hẹn")), // Tạm thời
    const Center(child: Text("Trang Cá Nhân")), // Tạm thời
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Hiển thị trang tương ứng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
