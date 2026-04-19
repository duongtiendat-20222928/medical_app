<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Doctor;

class DoctorAdminController extends Controller
{
    // 1. THÊM BÁC SĨ (Create)
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'specialty' => 'required|string|max:255',
            'price' => 'required|numeric',
            // Có thể thêm validate cho image, description nếu cần
        ]);

        $doctor = Doctor::create($request->all());

        return response()->json([
            'status' => 'success',
            'message' => 'Đã thêm bác sĩ thành công!',
            'data' => $doctor
        ]);
    }

    // 2. SỬA BÁC SĨ (Update)
    public function update(Request $request, $id)
    {
        $doctor = Doctor::find($id);

        if (!$doctor) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy bác sĩ!']);
        }

        // Cập nhật các trường được gửi lên
        $doctor->update($request->all());

        return response()->json([
            'status' => 'success',
            'message' => 'Cập nhật thông tin thành công!',
            'data' => $doctor
        ]);
    }

    // 3. XÓA BÁC SĨ (Delete)
    public function destroy($id)
    {
        $doctor = Doctor::find($id);

        if (!$doctor) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy bác sĩ!']);
        }

        // Lưu ý: Thường hệ thống y tế không xóa hẳn, mà chỉ đổi trạng thái (ẩn đi). 
        // Nhưng ở đây ta cứ làm chức năng xóa cứng cho bạn dễ hiểu.
        $doctor->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Đã xóa bác sĩ khỏi hệ thống!'
        ]);
    }
}
