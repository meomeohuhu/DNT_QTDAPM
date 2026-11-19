# FRESHFARM – HỆ THỐNG THƯƠNG MẠI ĐIỆN TỬ NÔNG SẢN SẠCH & TRUY XUẤT NGUỒN GỐC QR ĐỘNG

> **ĐỒ ÁN CUỐI KỲ TÍCH HỢP CHO 02 MÔN HỌC:**  
> 1. **QUẢN TRỊ DỰ ÁN PHẦN MỀM (QTDAPM)**  
> 2. **PHÁT TRIỂN ỨNG DỤNG ĐA NỀN TẢNG (DNT)**  
>
> **Đơn vị đào tạo:** Trường Đại học Công nghệ Thông tin & Truyền thông Việt - Hàn (VKU) – Đại học Đà Nẵng  
> **Khoa:** Khoa học Máy tính | **Lớp sinh hoạt:** 23SE3  
> **Giảng viên hướng dẫn:** ThS. Võ Văn Lường  
>
> **Nhóm sinh viên thực hiện:**
> - **Trần Dương Thái** – 23IT249 (Trưởng nhóm / PM, Mobile Lead)
> - **Bùi Nguyễn Toàn** – 23IT277 (Backend Lead, Database Architect)
> - **Nguyễn Thành Thịnh** – 23IT262 (Backend & Database Developer)
> - **Lê Thị Diệu Tâm** – 23IT244 (Frontend Lead, Tester & BA)

---

## I. TỔNG QUAN DỰ ÁN VÀ TÍNH ĐỒNG BỘ 2 MÔN HỌC

Hệ thống **FRESHFARM** được xây dựng với mục tiêu giải quyết bài toán nhức nhối trong ngành nông nghiệp Việt Nam: **thực phẩm bẩn, thiếu minh bạch nguồn gốc và tình trạng thương lái ép giá nông dân**. 

Dự án được thiết kế đồng bộ 100% giữa hai góc nhìn:

```
┌────────────────────────────────────────────────────────┐
│               HỆ THỐNG FRESHFARM VKU                   │
├───────────────────────────┬────────────────────────────┤
│   QUẢN TRỊ DỰ ÁN (SPM)   │   ĐA NỀN TẢNG (FLUTTER)    │
├───────────────────────────┼────────────────────────────┤
│ • 40 gói công việc WBS    │ • 10 Module hoàn chỉnh     │
│ • Dự toán Delphi/PERT     │ • 4 Vai trò (RBAC)         │
│ • Điều hành EVM (CPI, SPI)│ • Quét QR dưới 1.5s        │
│ • Project Plan 365 / XML  │ • Sinh VietQR Napas 247    │
│ • Quản lý rủi ro & chất   │ • Backend Firebase BaaS    │
│   lượng 3 lớp nghiêm ngặt │ • Chạy đa nền tảng mượt mà │
└───────────────────────────┴────────────────────────────┘
```

---

## II. 10 PHÂN HỆ NGHIỆP VỤ CỐT LÕI

Bản demo Flutter tập trung vào các luồng chính trong WBS và Báo cáo Chương 4. Dữ liệu mặc định được lưu cục bộ và bốn vai trò được mô phỏng.

1. **Xác thực & Phân quyền đa vai trò (RBAC):** Hỗ trợ 4 tác nhân hệ thống:
   - **Người tiêu dùng (Customer):** Mua hàng, lọc tiêu chuẩn VietGAP, quét QR, thanh toán VietQR.
   - **Nhà sản xuất / Nông hộ (Farmer):** Quản lý nông trại, tạo lô hàng, sinh tem QR truy xuất.
   - **Nhà cung cấp / Kho hàng (Supplier):** Quản lý tồn kho FIFO, cảnh báo hết hàng, điều phối xuất kho.
   - **Quản trị viên (Admin):** Dashboard doanh thu, biểu đồ phân tích đơn hàng, Dashboard EVM dự án.
   > **Điểm nhấn đặc biệt:** Thanh chuyển đổi vai trò nhanh (*RoleSelectorBar*) ở đầu màn hình cho phép giảng viên kiểm tra toàn bộ 4 góc nhìn chỉ bằng 1 cú chạm!
2. **Danh mục & Hồ sơ nông sản sạch:** Quản lý sản phẩm với hình ảnh chất lượng cao, chứng nhận VietGAP, GlobalGAP, Organic USDA, OCOP 4 sao, vùng trồng và số lượng tồn kho.
3. **Giỏ hàng & Quản lý phiên mua sắm:** Đồng bộ dữ liệu, tự động tính phí vận chuyển, miễn phí ship cho đơn >300.000đ, chiết khấu đơn lớn >400.000đ.
4. **Máy trạng thái đơn hàng (State Machine Pattern):** Quản lý vòng đời đơn qua 5 trạng thái: `Chờ xác nhận → Đã duyệt → Đang đóng gói → Đang giao → Đã giao / Hủy`.
5. **Thanh toán VietQR Napas 247 & COD:** Tự động sinh mã VietQR động chuẩn ngân hàng Việt Nam (số tài khoản mẫu, số tiền và mã đơn) kèm hộp thoại đối soát mô phỏng.
6. **Quản lý Hộ sản xuất & Nguồn cung:** Quản lý hồ sơ trang trại, diện tích canh tác (ha), giấy chứng nhận VietGAP, sản lượng cam kết và nhật ký mùa vụ.
7. **Quản lý Kho & Lô hàng (Batch/Lot):** Quản lý tồn kho theo lô, cảnh báo tự động khi chạm ngưỡng tồn kho tối thiểu (<45 sản phẩm).
8. **Điều phối Vận chuyển chuyên dụng:** Quản lý mã vận đơn (Tracking Code), nhiệt độ xe lạnh bảo quản nông sản 18°C - 22°C (AhaMove, Giao Hàng Nhanh, Viettel Post).
9. **Truy xuất nguồn gốc QR Code động (<1.5 giây):** Quét mã QR bằng Camera di động hoặc chọn nhanh mã mẫu để xem **Interactive Timeline 5 bước** (Gieo giống → Chăm sóc hữu cơ → Kiểm định VietGAP tại đồng → Thu hoạch đóng gói → Xuất kho bảo quản).
10. **Bảng điều khiển Admin & EVM Dashboard:** Tích hợp trực tiếp các chỉ số quản trị dự án học thuật ($BAC, PV, EV, AC, CPI, SPI, CV, SV$) và tỉ lệ đóng góp 25% của 4 thành viên lên biểu đồ trực quan `fl_chart`.

---

## III. KIẾN TRÚC KỸ THUẬT & CÔNG NGHỆ

- **Framework:** Flutter 3.x (Dart 3.x)
- **Quản lý trạng thái (State Management):** `Provider` (Kiến trúc phân tầng sạch Clean Architecture / Feature-first)
- **Cơ sở dữ liệu & Backend:** Google Firebase
  - **Cloud Firestore:** Lưu trữ tài liệu NoSQL với cấu trúc Collections (`products`, `orders`, `batches`, `farms`, `users`).
  - **Firebase Authentication:** Định danh và phân quyền RBAC.
  - **Firebase Storage & Hosting:** Lưu trữ ảnh nông sản và triển khai bản build Web.
  - **Firestore Security Rules:** Bảo mật dữ liệu chống IDOR và NoSQL Injection.
  - **Firestore Composite Indexes:** Tối ưu hóa tốc độ truy vấn QR dưới 1.5 giây.
- **Thư viện chuyên dụng:**
  - `mobile_scanner`: Quét mã QR bằng Camera phần cứng.
  - `qr_flutter`: Sinh mã QR động cho lô hàng và VietQR Napas 247.
  - `fl_chart`: Vẽ biểu đồ cột và xu hướng đơn hàng.
  - `intl`: Định dạng tiền tệ Việt Nam Đồng (VND) và ngày giờ.
  - `shared_preferences`: Bộ nhớ đệm cục bộ (Offline-first Persistence).

---

## IV. HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG

### 1. Yêu cầu môi trường
- Đã cài đặt **Flutter SDK** từ 3.44, kèm Dart 3.12 trở lên theo `pubspec.yaml`.
- Trình duyệt **Google Chrome** hoặc thiết bị di động / máy ảo Android/iOS.

### 2. Cài đặt các gói phụ thuộc
```bash
flutter pub get
```

### 3. Chạy ứng dụng trên Trình duyệt Web (Chrome)
*(Khuyến nghị khi thuyết trình trên máy tính giảng đường)*:
```bash
flutter run -d chrome
```

Ứng dụng mặc định dùng dữ liệu demo cục bộ. Có thể bật kết nối Firebase bằng `--dart-define=FRESHFARM_FIREBASE=true`. Đơn hàng vẫn được lưu trên thiết bị. VietQR dùng để mô phỏng thanh toán trong buổi demo.

### 4. Chạy ứng dụng trên Máy tính macOS (Desktop)
```bash
flutter run -d macos
```

### 5. Chạy ứng dụng trên Thiết bị / Máy ảo Android
```bash
flutter run -d android
```

### 6. Kiểm tra mã nguồn và Test
```bash
flutter analyze  # Kết quả: No issues found!
flutter test     # Kết quả: All tests passed!
```

---

## V. KỊCH BẢN DEMO ĐẠT ĐIỂM TỐI ĐA (10/10) CHO BUỔI VẤN ĐÁP

### Bước 1: Giới thiệu kiến trúc và vai trò (1 phút)
- Mở ứng dụng, chỉ cho giảng viên thấy thanh **RoleSelectorBar** ở trên cùng.
- Nhấn chọn lần lượt qua 4 vai trò để chứng minh hệ thống đã tích hợp trọn vẹn cả 4 tác nhân: **Người tiêu dùng (KH)** ↔ **Nông hộ (NSX)** ↔ **Kho hàng (NCC)** ↔ **Quản trị viên (Admin)**.

### Bước 2: Demo luồng mua hàng và thanh toán VietQR (Khách hàng) (2 phút)
1. Tại giao diện **Người tiêu dùng**, tìm kiếm sản phẩm hoặc lọc theo chuẩn `VietGAP`, `GlobalGAP`.
2. Bấm vào sản phẩm *"Cà chua bi Ruby Dalat GAP"*, xem chi tiết và bấm **"Xem chuỗi"** để mở màn hình **Truy xuất nguồn gốc**.
3. Bấm **"Thêm vào giỏ"**, mở Giỏ hàng và bấm **"Tiến hành đặt hàng"**.
4. Chọn phương thức thanh toán **"Chuyển khoản VietQR Napas 247"**.
5. Hộp thoại **VietQR** hiện lên với mã QR động thật của ngân hàng MB, đúng số tiền và nội dung đơn hàng.
6. Bấm **"Mô phỏng: Đã chuyển tiền thành công"** → Đơn hàng được tạo và lưu trên thiết bị.

### Bước 3: Demo tính năng quét mã QR truy xuất nguồn gốc (2 phút)
1. Nhấn vào biểu tượng **Mã QR** trên thanh AppBar.
2. Trình quét Camera kích hoạt mượt mà; nếu đang demo trên Web/Laptop, bấm vào một trong các **mã mẫu thử nghiệm** (`BATCH-DL-2026-001`, `BATCH-MC-2026-002`, `BATCH-BT-2026-003`).
3. Màn hình **Hồ sơ truy xuất chuỗi cung ứng** hiển thị ngay lập tức (<1.5 giây):
   - Số giấy phép VietGAP, tên trạm kiểm định KCS, kết quả phân tích dư lượng BVTV 0.0 mg/kg.
   - **Chuỗi hành trình 5 bước** từ gieo hạt, kiểm tra ruộng, thu hoạch, lưu kho lạnh đến vận chuyển.

### Bước 4: Demo Kênh Nông hộ và Kênh Kho hàng (1.5 phút)
1. Chuyển sang vai trò **NSX**: Xem danh sách các lô hàng, bấm **"Tạo lô hàng & Sinh mã QR"** để tạo một lô hàng mới với tiêu chuẩn chứng nhận và sản lượng thu hoạch.
2. Chuyển sang vai trò **NCC**: Xem bảng tồn kho, bấm các nút điều chỉnh số lượng tồn kho `+20` / `-10`, chuyển sang tab **Điều phối xuất kho** và bấm **"Chuyển sang: Đang đóng gói / Đang giao"** để chứng minh máy trạng thái hoạt động chính xác.

### Bước 5: Demo Kênh Quản trị và Bảng EVM (Môn Quản trị dự án) (2 phút)
1. Chuyển sang vai trò **Admin**:
   - Tab 1: Xem biểu đồ phân bổ trạng thái đơn hàng và KPI doanh thu.
   - Tab 2: Mở **Quản trị dự án EVM**. Giảng viên sẽ thấy toàn bộ các chỉ số trong **Chương 4 Báo cáo** ($BAC = \$4.126$, $PV = \$2.650$, $EV = \$2.307,20$, $CPI = 1.00$, $SPI = 0.87 \rightarrow 1.00$) cùng bảng phân công đóng góp **25%** của 4 thành viên (Thái, Toàn, Thịnh, Tâm).
2. Trình bày lý do kỹ thuật: *Việc chuyển đổi sang Flutter + Firebase đã giúp nhóm khắc phục lỗi native module máy ảnh, nén tiến độ và đưa chỉ số SPI hồi phục về mức kỳ vọng, hoàn thành đúng hạn 27/11/2026.*

---
*Chúc nhóm bảo vệ thành công rực rỡ và đạt điểm số cao nhất cho cả 2 môn học!*
