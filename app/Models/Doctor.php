<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Doctor extends Model
{
    use HasFactory;

    // Cấp phép cho các cột này được nhận dữ liệu tự động từ Seeder/API
    protected $fillable = [
        'name',
        'specialty',
        'price',
        'image',
        'description',
    ];
}
