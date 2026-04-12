<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasFactory;

    // Cấp phép cho các cột này được nhận dữ liệu
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
        'reason'
    ];
}
