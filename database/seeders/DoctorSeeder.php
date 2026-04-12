<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Doctor; // Nhớ import Model Doctor

class DoctorSeeder extends Seeder
{
    public function run(): void
    {
        $doctors = [
            ['name' => 'BS. Trần Văn A', 'specialty' => 'Tim mạch', 'price' => 200000],
            ['name' => 'BS. Nguyễn Thị B', 'specialty' => 'Da liễu', 'price' => 150000],
            ['name' => 'BS. Lê Hoàng C', 'specialty' => 'Nhi khoa', 'price' => 120000],
            ['name' => 'BS. Phạm Văn D', 'specialty' => 'Răng Hàm Mặt', 'price' => 300000],
            ['name' => 'BS. Hoàng Thị E', 'specialty' => 'Tai Mũi Họng', 'price' => 150000],
            ['name' => 'BS. Vũ Văn F', 'specialty' => 'Tiêu hóa', 'price' => 250000],
            ['name' => 'BS. Đặng Thị G', 'specialty' => 'Mắt (Nhãn khoa)', 'price' => 180000],
            ['name' => 'BS. Bùi Xuân H', 'specialty' => 'Thần kinh', 'price' => 350000],
            ['name' => 'BS. Ngô Khắc I', 'specialty' => 'Cơ Xương Khớp', 'price' => 200000],
            ['name' => 'BS. Lý Thu K', 'specialty' => 'Sản phụ khoa', 'price' => 250000],
        ];

        // Chạy vòng lặp để tự động lưu từng bác sĩ vào Database
        foreach ($doctors as $doctor) {
            Doctor::create($doctor);
        }
    }
}
