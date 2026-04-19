<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Bác Sĩ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>

<body class="bg-light">

    <div class="container mt-5">
        @if (session('success'))
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> {{ session('success') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        @endif

        <div class="card shadow-sm border-0">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center py-3">
                <h4 class="mb-0"><i class="bi bi-people-fill me-2"></i>Danh sách Bác sĩ</h4>
                <button class="btn btn-light text-primary fw-bold" data-bs-toggle="modal"
                    data-bs-target="#addDoctorModal">
                    <i class="bi bi-plus-lg"></i> Thêm Bác sĩ
                </button>
            </div>

            <div class="card-body p-0">
                <table class="table table-hover table-striped mb-0 text-center align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Ảnh</th>
                            <th>Tên Bác Sĩ</th>
                            <th>Chuyên Khoa</th>
                            <th>Giá Khám (VNĐ)</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($doctors as $doctor)
                            <tr>
                                <td>{{ $doctor->id }}</td>
                                <td>
                                    <img src="{{ $doctor->image ?? 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png' }}"
                                        alt="Avatar" class="rounded-circle object-fit-cover" width="50"
                                        height="50">
                                </td>
                                <td class="fw-bold text-primary">{{ $doctor->name }}</td>
                                <td><span class="badge bg-info text-dark">{{ $doctor->specialty }}</span></td>
                                <td class="text-danger fw-bold">{{ number_format($doctor->price) }} đ</td>
                                <td>
                                    <button class="btn btn-sm btn-warning text-dark me-1" data-bs-toggle="modal"
                                        data-bs-target="#editDoctorModal{{ $doctor->id }}">
                                        <i class="bi bi-pencil-square"></i> Sửa
                                    </button>

                                    <a href="/admin/doctors/delete/{{ $doctor->id }}" class="btn btn-sm btn-danger"
                                        onclick="return confirm('Bạn có chắc chắn muốn xóa bác sĩ này không?')">
                                        <i class="bi bi-trash"></i> Xóa
                                    </a>
                                </td>
                            </tr>

                            <div class="modal fade" id="editDoctorModal{{ $doctor->id }}" tabindex="-1"
                                aria-hidden="true">
                                <div class="modal-dialog modal-lg text-start">
                                    <div class="modal-content">
                                        <div class="modal-header bg-warning">
                                            <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i>Cập nhật
                                                thông tin</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                aria-label="Close"></button>
                                        </div>

                                        <form action="/admin/doctors/update/{{ $doctor->id }}" method="POST">
                                            @csrf
                                            <div class="modal-body row g-3">
                                                <div class="col-md-6">
                                                    <label class="form-label fw-bold">Tên Bác sĩ</label>
                                                    <input type="text" name="name" class="form-control"
                                                        value="{{ $doctor->name }}" required>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label fw-bold">Chuyên khoa</label>
                                                    <input type="text" name="specialty" class="form-control"
                                                        value="{{ $doctor->specialty }}" required>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label fw-bold">Giá khám (VNĐ)</label>
                                                    <input type="number" name="price" class="form-control"
                                                        value="{{ $doctor->price }}" required>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label fw-bold">Link Ảnh (URL)</label>
                                                    <input type="text" name="image" class="form-control"
                                                        value="{{ $doctor->image }}">
                                                </div>
                                                <div class="col-12">
                                                    <label class="form-label fw-bold">Giới thiệu chi tiết</label>
                                                    <textarea name="description" class="form-control" rows="4">{{ $doctor->description }}</textarea>
                                                </div>
                                            </div>
                                            <div class="modal-footer bg-light">
                                                <button type="button" class="btn btn-secondary"
                                                    data-bs-dismiss="modal">Hủy</button>
                                                <button type="submit" class="btn btn-dark"><i class="bi bi-save"></i>
                                                    Lưu Thay Đổi</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        @endforeach

                        @if (count($doctors) == 0)
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">Chưa có bác sĩ nào trong hệ
                                    thống.</td>
                            </tr>
                        @endif
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="modal fade" id="addDoctorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="bi bi-person-plus-fill me-2"></i>Thêm Bác Sĩ Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
                </div>

                <form action="/admin/doctors" method="POST">
                    @csrf <div class="modal-body row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Tên Bác sĩ</label>
                            <input type="text" name="name" class="form-control" placeholder="VD: Trần Văn A"
                                required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Chuyên khoa</label>
                            <input type="text" name="specialty" class="form-control"
                                placeholder="VD: Tim mạch, Thần kinh..." required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Giá khám (VNĐ)</label>
                            <input type="number" name="price" class="form-control" placeholder="VD: 200000"
                                required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Link Ảnh (URL)</label>
                            <input type="text" name="image" class="form-control"
                                placeholder="Dán link ảnh vào đây (bỏ trống sẽ dùng ảnh mặc định)">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-bold">Giới thiệu chi tiết</label>
                            <textarea name="description" class="form-control" rows="4"
                                placeholder="Nhập thông tin giới thiệu, kinh nghiệm công tác của bác sĩ..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Lưu thông
                            tin</button>
                    </div>
                </form>

            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
