class ChiTietLoai {
  final int id;
  final String tenChiTiet;

  ChiTietLoai({required this.id, required this.tenChiTiet});

  factory ChiTietLoai.fromJson(Map<String, dynamic> json) {
    return ChiTietLoai(
      id: json['id'] as int,
      tenChiTiet: json['tenChiTiet'] as String,
    );
  }
}

class NhomChiTietLoai {
  final int id;
  final String tenNhom;
  final String hinhAnh;
  final int maLoaiCongviec;
  final List<ChiTietLoai> dsChiTietLoai;

  NhomChiTietLoai({
    required this.id,
    required this.tenNhom,
    required this.hinhAnh,
    required this.maLoaiCongviec,
    required this.dsChiTietLoai,
  });

  factory NhomChiTietLoai.fromJson(Map<String, dynamic> json) {
    var list = json['dsChiTietLoai'] as List<dynamic>?;
    List<ChiTietLoai> chiTietList = list != null
        ? list
              .map((i) => ChiTietLoai.fromJson(i as Map<String, dynamic>))
              .toList()
        : [];

    return NhomChiTietLoai(
      id: json['id'] as int,
      tenNhom: json['tenNhom'] as String,
      hinhAnh: json['hinhAnh'] as String,
      maLoaiCongviec: json['maLoaiCongviec'] as int,
      dsChiTietLoai: chiTietList,
    );
  }
}

class LoaiCongViec {
  final int id;
  final String tenLoaiCongViec;
  final List<NhomChiTietLoai> dsNhomChiTietLoai;

  LoaiCongViec({
    required this.id,
    required this.tenLoaiCongViec,
    required this.dsNhomChiTietLoai,
  });

  factory LoaiCongViec.fromJson(Map<String, dynamic> json) {
    var list = json['dsNhomChiTietLoai'] as List<dynamic>?;
    List<NhomChiTietLoai> nhomChiTietList = list != null
        ? list
              .map((i) => NhomChiTietLoai.fromJson(i as Map<String, dynamic>))
              .toList()
        : [];

    return LoaiCongViec(
      id: json['id'] as int,
      tenLoaiCongViec: json['tenLoaiCongViec'] as String,
      dsNhomChiTietLoai: nhomChiTietList,
    );
  }
}

class CongViec {
  final int id;
  final String tenCongViec;
  final int danhGia;
  final int giaTien;
  final int nguoiTao;
  final String hinhAnh;
  final String moTa;
  final int maChiTietLoaiCongViec;
  final String moTaNgan;
  final int saoCongViec;

  CongViec({
    required this.id,
    required this.tenCongViec,
    required this.danhGia,
    required this.giaTien,
    required this.nguoiTao,
    required this.hinhAnh,
    required this.moTa,
    required this.maChiTietLoaiCongViec,
    required this.moTaNgan,
    required this.saoCongViec,
  });

  factory CongViec.fromJson(Map<String, dynamic> json) {
    return CongViec(
      id: json['id'],
      tenCongViec: json['tenCongViec'],
      danhGia: json['danhGia'],
      giaTien: json['giaTien'],
      nguoiTao: json['nguoiTao'],
      hinhAnh: json['hinhAnh'],
      moTa: json['moTa'],
      maChiTietLoaiCongViec: json['maChiTietLoaiCongViec'],
      moTaNgan: json['moTaNgan'],
      saoCongViec: json['saoCongViec'],
    );
  }
}

class CongViecItem {
  final int id;
  final CongViec congViec;
  final String tenLoaiCongViec;
  final String tenNhomChiTietLoai;
  final String tenChiTietLoai;
  final String tenNguoiTao;
  final String avatar;

  CongViecItem({
    required this.id,
    required this.congViec,
    required this.tenLoaiCongViec,
    required this.tenNhomChiTietLoai,
    required this.tenChiTietLoai,
    required this.tenNguoiTao,
    required this.avatar,
  });

  factory CongViecItem.fromJson(Map<String, dynamic> json) {
    return CongViecItem(
      id: json['id'],
      congViec: CongViec.fromJson(json['congViec']),
      tenLoaiCongViec: json['tenLoaiCongViec'],
      tenNhomChiTietLoai: json['tenNhomChiTietLoai'],
      tenChiTietLoai: json['tenChiTietLoai'],
      tenNguoiTao: json['tenNguoiTao'],
      avatar: json['avatar'],
    );
  }
}
class BinhLuan {
  final int id;
  final DateTime ngayBinhLuan;
  final String noiDung;
  final int saoBinhLuan;
  final String tenNguoiBinhLuan;
  final String avatar;

  BinhLuan({
    required this.id,
    required this.ngayBinhLuan,
    required this.noiDung,
    required this.saoBinhLuan,
    required this.tenNguoiBinhLuan,
    required this.avatar,
  });

  factory BinhLuan.fromJson(Map<String, dynamic> json) {
    return BinhLuan(
      id: json['id'],
      ngayBinhLuan: _parseDate(json['ngayBinhLuan']),
      noiDung: json['noiDung'],
      saoBinhLuan: json['saoBinhLuan'],
      tenNguoiBinhLuan: json['tenNguoiBinhLuan'],
      avatar: json['avatar'],
    );
  }
  static List<BinhLuan> fromJsonList(List<dynamic>? list) {
    return list != null
        ? list
            .map((e) => BinhLuan.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
  }
  static DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      final parts = value.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
  }
}