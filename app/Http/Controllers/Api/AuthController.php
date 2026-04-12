<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // 1. API Đăng ký tài khoản
    public function register(Request $request)
    {
        // Yêu cầu phải nhập đủ thông tin
        $request->validate([
            'name' => 'required|string',
            'phone' => 'required|string|unique:users,phone',
            'password' => 'required|string|min:6'
        ]);

        // Tạo người dùng mới
        $user = User::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'password' => Hash::make($request->password) // Mã hóa mật khẩu
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Đăng ký thành công!',
            'user' => $user
        ]);
    }

    // 2. API Đăng nhập
    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string'
        ]);

        // Tìm người dùng theo số điện thoại
        $user = User::where('phone', $request->phone)->first();

        // Kiểm tra xem số điện thoại có tồn tại và mật khẩu có khớp không
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Số điện thoại hoặc mật khẩu không đúng!'
            ], 401);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Đăng nhập thành công!',
            'user' => $user
        ]);
    }
    // Nhớ đảm bảo có dòng này ở tít trên cùng file nhé

    // Hàm 1: Cập nhật thông tin (Tên, SĐT)
    public function updateProfile(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'name' => 'required',
            'phone' => 'required'
        ]);

        $user = User::find($request->user_id);
        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy người dùng']);
        }

        $user->name = $request->name;
        $user->phone = $request->phone;
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Cập nhật thành công',
            'user' => $user // Trả về user mới để Flutter lưu lại vào ví
        ]);
    }

    // Hàm 2: Đổi mật khẩu an toàn
    public function changePassword(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'old_password' => 'required',
            'new_password' => 'required|min:6' // Bắt buộc pass mới phải từ 6 ký tự
        ]);

        $user = User::find($request->user_id);

        // Kiểm tra xem mật khẩu cũ nhập vào có khớp với mật khẩu đang lưu trong máy chủ không
        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json(['status' => 'error', 'message' => 'Mật khẩu hiện tại không đúng!']);
        }

        // Băm (Mã hóa) mật khẩu mới và lưu lại
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json(['status' => 'success', 'message' => 'Đổi mật khẩu thành công!']);
    }
}
