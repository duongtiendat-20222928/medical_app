import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'booking_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const AppointmentsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> _allDoctors = [];
  List<dynamic> _filteredDoctors = [];
  List<String> _specialties = ['Tất cả'];

  String _selectedSpecialty = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      print('🔵 Đang gọi API: http://192.168.189.1:8000/api/doctors');
      final response = await http
          .get(Uri.parse('http://192.168.189.1:8000/api/doctors'))
          .timeout(const Duration(seconds: 10));

      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ JSON Decoded: $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> doctorsData = jsonResponse['data'];
          print('👨‍⚕️ Tìm thấy ${doctorsData.length} bác sĩ');

          Set<String> uniqueSpecialties = {};
          for (var doc in doctorsData) {
            uniqueSpecialties.add(doc['specialty']);
          }

          setState(() {
            _allDoctors = doctorsData;
            _filteredDoctors = doctorsData;
            _specialties = ['Tất cả', ...uniqueSpecialties.toList()];
            _isLoading = false;
          });
        } else {
          print('❌ Status không phải success: ${jsonResponse['status']}');
          setState(() => _isLoading = false);
        }
      } else {
        print('❌ HTTP Error: Status ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } on TimeoutException catch (e) {
      print('⏱️ Lỗi timeout: $e');
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Lỗi: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterData() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        final matchesSpecialty =
            _selectedSpecialty == 'Tất cả' ||
            doc['specialty'] == _selectedSpecialty;
        final matchesSearch =
            doc['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doc['specialty'].toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesSpecialty && matchesSearch;
      }).toList();
    });
  }

  // ==========================================================
  // HÀM HIỂN THỊ POPUP THÔNG TIN CHI TIẾT BÁC SĨ (BOTTOM SHEET)
  // ==========================================================
  void _showDoctorDetails(BuildContext context, dynamic doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép popup cao lên
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75, // Chiếm 75% màn hình
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Thanh gạt nhỏ ở trên cùng
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh Avatar to
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          doctor['image'] ??
                              'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 120,
                                width: 120,
                                color: Colors.blue[50],
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blue[300],
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'BS. ${doctor['name']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          doctor['specialty'],
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Phần thông tin chi tiết
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      // Kiểm tra nếu có dữ liệu từ Database thì hiện, không thì hiện câu mặc định
                      (doctor['description'] != null &&
                              doctor['description']
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                          ? doctor['description'].toString()
                          : 'Bác sĩ chuyên khoa giàu kinh nghiệm, tận tâm với bệnh nhân. Chuyên khám và điều trị các bệnh lý liên quan đến ${doctor['specialty'].toLowerCase()}.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const Text(
                      'Thông tin khám',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.payments, color: Colors.red[400]),
                      ),
                      title: const Text(
                        'Giá khám',
                        style: TextStyle(color: Colors.grey),
                      ),
                      subtitle: Text(
                        '${doctor['price']} VNĐ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Nút Đặt lịch dưới cùng của Popup
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng popup
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(doctor: doctor),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'ĐẶT LỊCH KHÁM NGAY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            color: Colors.grey[50],
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. HEADER
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: statusBarHeight > 0 ? statusBarHeight + 10 : 40,
                      left: 24,
                      right: 24,
                      bottom: 30,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[800]!, Colors.blue[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào 👋',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tìm bác sĩ của bạn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              _searchQuery = value;
                              _filterData();
                            },
                            decoration: InputDecoration(
                              hintText: 'Tên bác sĩ, chuyên khoa...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 15, right: 10),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. CHUYÊN KHOA
                if (!_isLoading) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chuyên khoa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Xem tất cả',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _specialties.length,
                        itemBuilder: (context, index) {
                          final specialty = _specialties[index];
                          final isSelected = _selectedSpecialty == specialty;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(specialty),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 14,
                              ),
                              selected: isSelected,
                              selectedColor: Colors.blue[600],
                              backgroundColor: Colors.white,
                              showCheckmark: false,
                              elevation: isSelected ? 3 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.blue[600]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSpecialty = specialty;
                                  _filterData();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // 3. DANH SÁCH BÁC SĨ (THIẾT KẾ MỚI CÓ ẢNH VÀ 2 NÚT)
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_filteredDoctors.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 70,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Không tìm thấy bác sĩ nào!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final doctor = _filteredDoctors[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ẢNH AVATAR BÁC SĨ MỚI
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        // Ưu tiên lấy link ảnh từ database, nếu rỗng thì dùng ảnh mặc định
                                        doctor['image'] ??
                                            'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                        // Xử lý lỗi nếu link ảnh bị hỏng
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                height: 70,
                                                width: 70,
                                                color: Colors.blue[50],
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.blue[300],
                                                  size: 35,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${doctor['name']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            doctor['specialty'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.payments_outlined,
                                                size: 16,
                                                color: Colors.grey[500],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${doctor['price']} VNĐ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(
                                    color: Colors.black12,
                                    height: 1,
                                  ),
                                ),

                                // HÀNG 2 NÚT BẤM (XEM CHI TIẾT & ĐẶT KHÁM)
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: OutlinedButton(
                                          onPressed: () => _showDoctorDetails(
                                            context,
                                            doctor,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blue[700],
                                            side: BorderSide(
                                              color: Colors.blue[200]!,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Xem chi tiết',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookingScreen(
                                                      doctor: doctor,
                                                    ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[600],
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Đặt khám',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _filteredDoctors.length),
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
