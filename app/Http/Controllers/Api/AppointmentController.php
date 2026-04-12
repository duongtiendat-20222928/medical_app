<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Appointment;

class AppointmentController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'doctor_id' => 'required',
            'appointment_date' => 'required|date',
            'appointment_time' => 'required',
            'patient_name' => 'required', // Bắt buộc nhập tên
            'patient_phone' => 'required', // Bắt buộc nhập SĐT
        ]);

        $appointment = Appointment::create([
            'user_id' => $request->user_id,
            'doctor_id' => $request->doctor_id,
            'appointment_date' => $request->appointment_date,
            'appointment_time' => $request->appointment_time,
            'patient_name' => $request->patient_name,
            'gender' => $request->gender,
            'patient_phone' => $request->patient_phone,
            'birth_year' => $request->birth_year,
            'address' => $request->address,
            'reason' => $request->reason,
            'status' => 'pending',
        ]);

        return response()->json(['status' => 'success', 'data' => $appointment]);
    } // Hàm lấy danh sách lịch hẹn của một User cụ thể
    public function index(Request $request)
    {
        // Yêu cầu phải gửi kèm user_id lên
        $request->validate([
            'user_id' => 'required'
        ]);

        // Lấy các lịch hẹn của user này, nối thêm thông tin bác sĩ để app hiển thị tên bác sĩ
        $appointments = Appointment::where('user_id', $request->user_id)
            ->join('doctors', 'appointments.doctor_id', '=', 'doctors.id')
            ->select('appointments.*', 'doctors.name as doctor_name', 'doctors.specialty')
            ->orderBy('appointment_date', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $appointments
        ]);
    }
    protected $fillable = [
        'user_id',
        'doctor_id',
        'appointment_date',
        'appointment_time',
        'status',
        'patient_name',
        'gender',
        'patient_phone',
        'birth_year',
        'address',
        'reason' // Thêm dòng này
    ];
}
