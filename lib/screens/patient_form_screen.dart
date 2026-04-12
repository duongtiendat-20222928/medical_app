import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PatientFormScreen extends StatefulWidget {
  final dynamic doctor;
  final String date;
  final String time;

  const PatientFormScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  @override
  State<PatientFormScreen> createState() => PatientFormScreenState();
}

class PatientFormScreenState extends State<PatientFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();

  String _gender = 'Nam';
  bool _isLoading = false;

  // Đã sửa lại tên hàm cho đúng và gom thành 1 cục duy nhất
  Future<void> _submitForm() async {
    // 1. Validation
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đủ Tên và SĐT!')),
      );
      return;
    }

    if (_birthYearController.text.isNotEmpty &&
        _birthYearController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Năm sinh không hợp lệ (VD: 1990)!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập lại!')),
        );
        return;
      }

      // 2. Gọi API
      final response = await http
          .post(
            Uri.parse('http://192.168.189.1:8000/api/appointments'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'user_id': userId,
              'doctor_id': widget.doctor['id'],
              'appointment_date': widget.date,
              'appointment_time': widget.time,
              'patient_name': _nameController.text,
              'gender': _gender,
              'patient_phone': _phoneController.text,
              'birth_year': _birthYearController.text,
              'address': _addressController.text,
              'reason': _reasonController.text,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Máy chủ không phản hồi!'),
          );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Đặt lịch thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Đóng Form và màn hình trước đó
        Navigator.of(context)
          ..pop()
          ..pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Lỗi từ máy chủ!')),
        );
      }
    } catch (e) {
      print("Lỗi Form Đặt Lịch: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi kết nối! Vui lòng kiểm tra mạng.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin bệnh nhân'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bác sĩ: ${widget.doctor['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Thời gian: ${widget.time} | ${widget.date}',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _nameController,
                'Họ tên bệnh nhân (bắt buộc)',
                Icons.person,
              ),
              Row(
                children: [
                  const Text('Giới tính: '),
                  Radio(
                    value: 'Nam',
                    groupValue: _gender,
                    onChanged: (val) =>
                        setState(() => _gender = val.toString()),
                  ),
                  const Text('Nam'),
                  Radio(
                    value: 'Nữ',
                    groupValue: _gender,
                    onChanged: (val) =>
                        setState(() => _gender = val.toString()),
                  ),
                  const Text('Nữ'),
                ],
              ),
              _buildTextField(
                _phoneController,
                'Số điện thoại liên hệ (bắt buộc)',
                Icons.phone,
                isNumber: true,
              ),
              _buildTextField(
                _birthYearController,
                'Năm sinh (VD: 1990)',
                Icons.calendar_today,
                isNumber: true,
              ),
              _buildTextField(
                _addressController,
                'Địa chỉ (Tỉnh/Thành, Quận/Huyện...)',
                Icons.location_on,
              ),
              const SizedBox(height: 10),
              TextField(
                controller:
                    _reasonController, // Đã sửa lỗi thiếu gạch dưới ở đây
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Lý do khám',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_information),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'XÁC NHẬN ĐẶT LỊCH',
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
