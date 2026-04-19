<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Appointment;

class AdminController extends Controller
{
    public function index()
    {
        // Lấy danh sách lịch hẹn, sắp xếp ngày khám gần nhất lên đầu
        $appointments = Appointment::orderBy('appointment_date', 'asc')
            ->orderBy('appointment_time', 'asc')
            ->get();

        return view('admin.appointments', compact('appointments'));
    }
}
