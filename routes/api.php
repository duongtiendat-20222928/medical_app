<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Khai báo các Controller
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DoctorController;
use App\Http\Controllers\Api\AppointmentController;

// 1. Cổng Đăng ký / Đăng nhập
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// 2. Cổng lấy danh sách Bác sĩ (Đây chính là dòng đang bị thiếu khiến nó báo lỗi 404)
Route::get('/doctors', [DoctorController::class, 'index']);

// 3. Cổng Đặt lịch khám
Route::post('/appointments', [AppointmentController::class, 'store']);
Route::get('/appointments', [AppointmentController::class, 'index']); // Lấy lịch hẹn
Route::post('/update-profile', [App\Http\Controllers\Api\AuthController::class, 'updateProfile']);
Route::post('/change-password', [App\Http\Controllers\Api\AuthController::class, 'changePassword']);
