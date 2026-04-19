<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\Api\DoctorAdminController;
use App\Models\Doctor;
use Illuminate\Http\Request;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/admin', [AdminController::class, 'index']);
Route::post('/admin/doctors', [DoctorAdminController::class, 'store']);       // Thêm mới
Route::put('/admin/doctors/{id}', [DoctorAdminController::class, 'update']);  // Sửa
Route::delete('/admin/doctors/{id}', [DoctorAdminController::class, 'destroy']); // Xóa
Route::get('/admin/doctors', function () {
    $doctors = Doctor::orderBy('id', 'desc')->get();
    return view('admin.doctors', compact('doctors'));
});

// 2. Xử lý Thêm Bác sĩ
Route::post('/admin/doctors', function (Request $request) {
    Doctor::create($request->all());
    return back()->with('success', 'Đã thêm Bác sĩ mới thành công!');
});

// 3. Xử lý Xóa Bác sĩ
Route::get('/admin/doctors/delete/{id}', function ($id) {
    Doctor::find($id)->delete();
    return back()->with('success', 'Đã xóa Bác sĩ khỏi hệ thống!');
});
// 4. Xử lý Cập nhật (Sửa) thông tin Bác sĩ
Route::post('/admin/doctors/update/{id}', function (Request $request, $id) {
    $doctor = Doctor::find($id);
    if ($doctor) {
        $doctor->update($request->all());
    }
    return back()->with('success', 'Đã cập nhật thông tin Bác sĩ thành công!');
});
