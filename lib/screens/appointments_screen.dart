import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  // 1. Gọi API lấy danh sách lịch hẹn của User
  _fetchAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Chỗ này phải là 'userId' mới đúng với SharedPreferences bạn đã lưu
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.189.1:8000/api/appointments?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _appointments =
              data['data'] ?? []; // Thêm ?? [] để tránh lỗi nếu data rỗng
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. Hàm vẽ "Thẻ Trạng Thái" có màu sắc cực đẹp
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'confirmed':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        text = 'Đã xác nhận';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        text = 'Đã hủy';
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        text = 'Đang chờ duyệt';
        icon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Lịch sử khám bệnh',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có lịch hẹn nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final item = _appointments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dòng 1: Ngày và Giờ (Cắt 5 ký tự đầu để bỏ giây)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '📅 Ngày: ${item['appointment_date']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '⏰ ${item['appointment_time'].toString().substring(0, 5)}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Dòng 2: Thông tin chi tiết
                        Text(
                          '👨‍⚕️ Bác sĩ: ${item['doctor_name']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📌 Chuyên khoa: ${item['specialty'] ?? 'Đa khoa'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📝 Lý do khám: ${item['reason'] ?? 'Không có'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Dòng 3: Hiển thị Thẻ trạng thái
                        _buildStatusBadge(item['status']),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
