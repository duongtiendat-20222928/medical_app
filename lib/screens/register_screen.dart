import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Các bộ điều khiển để lấy dữ liệu từ ô nhập
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Trạng thái đang tải (hiện vòng xoay)

  // Hàm gọi API Đăng ký
  Future<void> _register() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải
    });

    try {
      // Gọi lên máy chủ Laravel
      final response = await http.post(
        Uri.parse('http://192.168.189.1:8000/api/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Chuẩn form API
        },
        body: jsonEncode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      // Nếu HTTP status là 200 (thành công)
      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Hãy đăng nhập.')),
        );
        Navigator.pop(context); // Quay lại màn hình đăng nhập
      } else {
        // Lấy thông báo lỗi trực tiếp từ Laravel gửi về
        String errorMessage = 'Lỗi: Nhập thiếu thông tin hoặc SĐT đã tồn tại';
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print('Lỗi chi tiết: $e'); // In lỗi ra Terminal của VS Code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể kết nối tới máy chủ! Vui lòng kiểm tra lại.',
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Tắt vòng xoay
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đăng Ký Tài Khoản',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Nút hủy quay lại Đăng nhập
                },
                child: const Text('Đã có tài khoản? Quay lại đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
