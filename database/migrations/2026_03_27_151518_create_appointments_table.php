<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            // Liên kết với bảng users và doctors
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('doctor_id')->constrained('doctors')->onDelete('cascade');
            $table->date('appointment_date'); // Ngày bệnh nhân chọn khám
            $table->time('appointment_time'); // Khung giờ khám (VD: 08:30:00)

            $table->string('patient_name'); // Tên người khám
            $table->string('gender')->nullable(); // Giới tính
            $table->string('patient_phone'); // SĐT liên hệ
            $table->string('birth_year')->nullable(); // Năm sinh
            $table->string('address')->nullable(); // Địa chỉ
            $table->text('reason')->nullable(); // Lý do khám

            $table->string('status')->default('pending'); // Trạng thái: pending (chờ), confirmed (đã chốt), cancelled (hủy)
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
