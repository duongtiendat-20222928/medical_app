import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'patient_form_screen.dart';

class BookingScreen extends StatefulWidget {
  final dynamic doctor; // Nhận thông tin bác sĩ từ Trang chủ truyền sang
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime; // Đổi thành nullable
  List<String> _availableSlots = []; // Danh sách lấy từ API
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots(); // Load giờ cho ngày mặc định (hôm nay)
  }

  // Hàm gọi API lấy giờ trống
  Future<void> _fetchAvailableSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _selectedTime = null; // Reset giờ đã chọn khi đổi ngày
    });

    try {
      final dateStr = _selectedDate.toString().split(' ')[0];
      final response = await http.get(
        Uri.parse(
          'http://192.168.189.1:8000/api/available-slots?doctor_id=${widget.doctor['id']}&date=$dateStr',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _availableSlots = List<String>.from(data['data']);
        });
      }
    } catch (e) {
      print("Lỗi lấy slot: $e");
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Đặt lịch: ${widget.doctor['name']}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 500,
          // Bọc SingleChildScrollView để màn hình có thể vuốt lên xuống được
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin ngắn gọn về Bác sĩ
                Card(
                  color: Colors.blue[50],
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(
                      Icons.medical_services,
                      color: Colors.blue,
                    ),
                    title: Text('Chuyên khoa: ${widget.doctor['specialty']}'),
                    subtitle: Text(
                      'Giá khám: ${widget.doctor['price']} VNĐ',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "1. Chọn ngày khám:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Lịch chọn ngày
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 30),
                    ), // Cho phép đặt trước 30 ngày
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = date; // 1. Cập nhật ngày mới
                      });
                      _fetchAvailableSlots(); // 2. GỌI LẠI API ĐỂ LOAD GIỜ MỚI
                    },
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "2. Chọn giờ khám:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                // Hiển thị trạng thái loading
                if (_isLoadingSlots)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  // Các nút bấm chọn giờ
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return ChoiceChip(
                        label: Text(
                          time,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blue,
                        backgroundColor: Colors.grey[200],
                        onSelected: (selected) =>
                            setState(() => _selectedTime = time),
                      );
                    }).toList(),
                  ),

                // Đã xóa Spacer() và thay bằng SizedBox cố định
                const SizedBox(height: 32),

                // Nút chốt đơn chuyển sang trang Form
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _selectedTime == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientFormScreen(
                                  doctor: widget.doctor,
                                  date: _selectedDate.toString().split(' ')[0],
                                  time: _selectedTime!,
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      "TIẾP TỤC ĐIỀN THÔNG TIN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
