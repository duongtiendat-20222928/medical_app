import 'package:flutter/material.dart';
import 'patient_form_screen.dart';

class BookingScreen extends StatefulWidget {
  final dynamic doctor; // Nhận thông tin bác sĩ từ Trang chủ truyền sang
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now(); // Mặc định là ngày hôm nay
  String _selectedTime = "08:00"; // Mặc định khung giờ đầu tiên

  // Danh sách các khung giờ khám bệnh
  final List<String> _timeSlots = [
    "08:00",
    "09:00",
    "10:00",
    "14:00",
    "15:00",
    "16:00",
  ];

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
                    onDateChanged: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "2. Chọn giờ khám:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                // Các nút bấm chọn giờ
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _timeSlots.map((time) {
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientFormScreen(
                            doctor: widget.doctor,
                            date: _selectedDate.toString().split(' ')[0],
                            time: _selectedTime,
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
