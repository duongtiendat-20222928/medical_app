<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Doctor; // Lấy dữ liệu từ Model Bác sĩ

class DoctorController extends Controller
{
    // Hàm lấy danh sách tất cả bác sĩ
    public function index()
    {
        $doctors = Doctor::all();

        return response()->json([
            'status' => 'success',
            'data' => $doctors
        ]);
    }
}
