<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Appointment;
use Illuminate\Support\Facades\DB;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class AppointmentController extends Controller
{
    // ==========================================
    // Hàm 1: Đặt lịch khám
    // ==========================================
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'doctor_id' => 'required',
            'appointment_date' => 'required|date',
            'appointment_time' => 'required',
            'patient_name' => 'required',
            'patient_phone' => 'required',
        ]);

        $maxPerSlot = 2; // Giới hạn 2 người/ca

        // Đếm lại trước khi lưu để chống spam
        $currentBookings = Appointment::where('doctor_id', $request->doctor_id)
            ->where('appointment_date', $request->appointment_date)
            ->where('appointment_time', $request->appointment_time)
            ->where('status', '!=', 'cancelled')
            ->count();

        if ($currentBookings >= $maxPerSlot) {
            return response()->json([
                'status' => 'error',
                'message' => 'Rất tiếc! Ca khám này vừa được người khác đặt kín chỗ.'
            ]);
        }

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
    }

    // ==========================================
    // Hàm 2: Lấy danh sách lịch hẹn của User
    // ==========================================
    public function index(Request $request)
    {
        $request->validate([
            'user_id' => 'required'
        ]);

        $appointments = Appointment::where('user_id', $request->user_id)
            ->join('doctors', 'appointments.doctor_id', '=', 'doctors.id')
            ->select('appointments.*', 'doctors.name as doctor_name', 'doctors.specialty')
            ->orderBy('appointment_date', 'desc')
            ->orderBy('appointment_time', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $appointments
        ]);
    }

    // ==========================================
    // Hàm 3: Lọc giờ trống cho giao diện Đặt lịch
    // ==========================================
    public function getAvailableSlots(Request $request)
    {
        $request->validate([
            'doctor_id' => 'required',
            'date' => 'required|date',
        ]);

        $allSlots = ["08:00", "09:00", "10:00", "14:00", "15:00", "16:00"];
        $maxPerSlot = 2; // Giới hạn 2 người/ca

        $bookedSlotsRaw = Appointment::where('doctor_id', $request->doctor_id)
            ->where('appointment_date', $request->date)
            ->where('status', '!=', 'cancelled')
            ->select('appointment_time', DB::raw('count(*) as total'))
            ->groupBy('appointment_time')
            ->get()
            ->pluck('total', 'appointment_time');

        $bookedSlots = [];
        foreach ($bookedSlotsRaw as $time => $count) {
            $shortTime = substr($time, 0, 5);
            $bookedSlots[$shortTime] = $count;
        }

        $availableSlots = array_values(array_filter($allSlots, function ($slot) use ($bookedSlots, $maxPerSlot) {
            $count = $bookedSlots[$slot] ?? 0;
            return $count < $maxPerSlot;
        }));

        return response()->json([
            'status' => 'success',
            'data' => $availableSlots
        ]);
    }

    // ==========================================
    // Hàm 4: Đổi trạng thái & Bắn thông báo Push
    // ==========================================
    public function changeStatus(Request $request)
    {
        $request->validate([
            'appointment_id' => 'required',
            'status' => 'required|in:pending,confirmed,cancelled'
        ]);

        $appointment = Appointment::with('doctor')->find($request->appointment_id);

        if (!$appointment) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy lịch hẹn']);
        }

        // 1. Lưu trạng thái mới vào Database
        $appointment->status = $request->status;
        $appointment->save();

        // 2. Soạn nội dung thông báo
        $title = "Cập nhật lịch khám";
        $body = "Lịch khám của bạn đang được xử lý.";

        $doctorName = $appointment->doctor ? $appointment->doctor->name : "Phòng khám";

        if ($request->status == 'confirmed') {
            $title = "✅ Lịch khám đã được xác nhận!";
            $body = "BS. {$doctorName} đã duyệt lịch khám của bạn vào ngày {$appointment->appointment_date}. Vui lòng đến đúng giờ!";
        } elseif ($request->status == 'cancelled') {
            $title = "❌ Lịch khám đã bị hủy";
            $body = "Rất tiếc, lịch khám của bạn vào ngày {$appointment->appointment_date} đã bị hủy.";
        }

        // 3. Gọi Firebase Bắn thông báo
        $deviceToken = "dGZnPqHoRUOPiPdHf6MQJb:APA91bG1EPdUDPtazJKumPaBy6bG6G9BT7zjtK7nSJXqxKxl_ulf9cRx753uXssgI2Id2cfGafeFKhLIBHS3icd2bi_egU9NH20QboJuJL9t8iUJMMiJsmg";

        try {
            if (!class_exists('Kreait\Firebase\Factory')) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'Đã cập nhật trạng thái. Cảnh báo: Chưa cài Firebase Library.'
                ]);
            }

            $firebase = (new Factory)
                ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')))
                ->createMessaging();

            $message = CloudMessage::withTarget('token', $deviceToken)
                ->withNotification(Notification::create($title, $body));

            $firebase->send($message);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'success',
                'message' => 'Đã cập nhật trạng thái Database, nhưng gửi thông báo thất bại: ' . $e->getMessage()
            ]);
        }

        return response()->json(['status' => 'success', 'message' => 'Đã cập nhật và gửi thông báo thành công!']);
    }
}
