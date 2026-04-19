<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Appointment;
use Carbon\Carbon;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class SendAppointmentReminders extends Command
{
    // Tên câu lệnh để bạn gọi robot chạy thử
    protected $signature = 'app:send-reminders';

    // Mô tả công việc của robot
    protected $description = 'Tự động gửi thông báo nhắc nhở lịch khám vào ngày mai';

    public function handle()
    {
        // 1. Lấy ngày mai
        $tomorrow = Carbon::tomorrow()->format('Y-m-d');

        $this->info("⏳ Đang quét lịch khám cho ngày mai: {$tomorrow}...");

        // 2. Tìm tất cả các lịch khám vào ngày mai và đã được Duyệt
        $appointments = Appointment::with(['user', 'doctor'])
            ->where('appointment_date', $tomorrow)
            ->where('status', 'confirmed')
            ->get();

        if ($appointments->isEmpty()) {
            $this->info("✅ Không có lịch khám nào vào ngày mai cần nhắc.");
            return;
        }

        // 3. Khởi tạo súng bắn Firebase
        $firebase = (new Factory)
            ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')))
            ->createMessaging();

        $count = 0;

        // 4. Lặp qua từng lịch hẹn và bắn thông báo
        foreach ($appointments as $app) {

            // ĐÃ THAY TOKEN CỦA BẠN VÀO ĐÂY ĐỂ TEST:
            $deviceToken = "dGZnPqHoRUOPiPdHf6MQJb:APA91bG1EPdUDPtazJKumPaBy6bG6G9BT7zjtK7nSJXqxKxl_ulf9cRx753uXssgI2Id2cfGafeFKhLIBHS3icd2bi_egU9NH20QboJuJL9t8iUJMMiJsmg";

            if ($deviceToken) {
                try {
                    $title = "⏰ Nhắc nhở lịch khám ngày mai";
                    $body = "Bạn có lịch khám với BS. {$app->doctor->name} vào lúc {$app->appointment_time} ngày mai. Hãy đến đúng giờ nhé!";

                    $message = CloudMessage::withTarget('token', $deviceToken)
                        ->withNotification(Notification::create($title, $body));

                    $firebase->send($message);
                    $count++;
                } catch (\Exception $e) {
                    $this->error("❌ Lỗi gửi cho User ID {$app->user_id}: " . $e->getMessage());
                }
            }
        }

        $this->info("🎉 Hoàn tất! Đã gửi thành công {$count} thông báo nhắc nhở.");
    }
}
