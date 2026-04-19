<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Bảng Điều Khiển Bác Sĩ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

    <div class="container mt-5">
        <h2 class="mb-4 text-primary">Danh Sách Lịch Hẹn Khám</h2>

        <div class="card shadow-sm">
            <div class="card-body">
                <table class="table table-hover align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Bệnh nhân</th>
                            <th>SĐT</th>
                            <th>Ngày khám</th>
                            <th>Giờ khám</th>
                            <th>Lý do</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($appointments as $app)
                            <tr>
                                <td class="fw-bold">{{ $app->patient_name }}</td>
                                <td>{{ $app->patient_phone }}</td>
                                <td><span class="badge bg-info text-dark">{{ $app->appointment_date }}</span></td>
                                <td><span
                                        class="badge bg-warning text-dark">{{ substr($app->appointment_time, 0, 5) }}</span>
                                </td>
                                <td>{{ $app->reason }}</td>
                                <td>
                                    @if ($app->status == 'pending')
                                        <span class="badge bg-secondary">Đang chờ</span>
                                    @elseif($app->status == 'confirmed')
                                        <span class="badge bg-success">Đã duyệt</span>
                                    @else
                                        <span class="badge bg-danger">Đã hủy</span>
                                    @endif
                                </td>
                                <td>
                                    @if ($app->status == 'pending')
                                        <button onclick="changeStatus({{ $app->id }}, 'confirmed')"
                                            class="btn btn-sm btn-success">Duyệt</button>
                                        <button onclick="changeStatus({{ $app->id }}, 'cancelled')"
                                            class="btn btn-sm btn-danger">Hủy</button>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Hàm gọi API của bạn khi Bác sĩ bấm nút
        function changeStatus(id, newStatus) {
            if (!confirm('Bạn có chắc chắn muốn thay đổi trạng thái?')) return;

            fetch('/api/change-status', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        appointment_id: id,
                        status: newStatus
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'success') {
                        location.reload(); // Tự động load lại trang khi thành công
                    } else {
                        alert('Lỗi: ' + data.message);
                    }
                });
        }
    </script>

</body>

</html>
