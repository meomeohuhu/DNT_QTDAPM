import json
import urllib.request

PROJECT_ID = "dnt-q-90cae"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def to_firestore_value(val):
    if isinstance(val, bool):
        return {"booleanValue": val}
    elif isinstance(val, int):
        return {"integerValue": str(val)}
    elif isinstance(val, float):
        return {"doubleValue": val}
    elif isinstance(val, str):
        return {"stringValue": val}
    elif isinstance(val, list):
        return {"arrayValue": {"values": [to_firestore_value(v) for v in val]}}
    elif isinstance(val, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in val.items()}}}
    elif val is None:
        return {"nullValue": None}
    return {"stringValue": str(val)}

def upload_doc(collection, doc_id, data):
    url = f"{BASE_URL}/{collection}/{doc_id}"
    body = {
        "fields": {k: to_firestore_value(v) for k, v in data.items()}
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode('utf-8'),
        headers={"Content-Type": "application/json"},
        method="PATCH"
    )
    with urllib.request.urlopen(req) as resp:
        return resp.status

# Data definitions
farms = [
    {
        "id": "FARM-DL-01",
        "name": "Nông trại Sinh học Hướng Dương Đà Lạt",
        "ownerName": "Nguyễn Văn Nông",
        "phone": "0912345678",
        "location": "Xã Đạ Sar, Huyện Lạc Dương",
        "province": "Lâm Đồng",
        "areaHectares": 3.5,
        "vietGapCertNo": "VietGAP-TT-2026-0891",
        "issueDate": "15/01/2026",
        "productsGrown": ["Cà chua bi Dalat GAP", "Cải xoăn Kale", "Dâu tây New Zealand"]
    },
    {
        "id": "FARM-BT-02",
        "name": "Hợp tác xã Trái cây Đặc sản Bến Tre",
        "ownerName": "Lê Hoàng Ba",
        "phone": "0908765432",
        "location": "Xã Sơn Định, Huyện Chợ Lách",
        "province": "Bến Tre",
        "areaHectares": 5.2,
        "vietGapCertNo": "VietGAP-BNT-2026-1102",
        "issueDate": "20/02/2026",
        "productsGrown": ["Sầu riêng Ri6 Chợ Lách", "Chôm chôm nhãn"]
    },
    {
        "id": "FARM-TG-03",
        "name": "Nông trang Bưởi Da Xanh Tiền Giang",
        "ownerName": "Phạm Văn Hòa",
        "phone": "0939112233",
        "location": "Huyện Cái Bè",
        "province": "Tiền Giang",
        "areaHectares": 4.0,
        "vietGapCertNo": "VietGAP-TGG-2026-0455",
        "issueDate": "10/03/2026",
        "productsGrown": ["Bưởi da xanh ruột hồng", "Xoài cát Hòa Lộc"]
    },
    {
        "id": "FARM-MC-04",
        "name": "Nông trại Công nghệ cao Mộc Châu",
        "ownerName": "Trịnh Thị Mai",
        "phone": "0944556677",
        "location": "Thị trấn Mộc Châu",
        "province": "Sơn La",
        "areaHectares": 6.0,
        "vietGapCertNo": "GlobalGAP-SLA-2026-009",
        "issueDate": "05/01/2026",
        "productsGrown": ["Dưa lưới Huỳnh Long Mộc Châu", "Bí ngô Nhật"]
    }
]

products = [
    {
        "id": "PROD-001",
        "name": "Cà chua bi Ruby Dalat GAP",
        "category": "Rau củ hữu cơ",
        "price": 45000.0,
        "originalPrice": 55000.0,
        "unit": "Hộp 500g",
        "imageUrl": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500",
        "description": "Cà chua bi giống Ruby Hà Lan canh tác nhà màng theo tiêu chuẩn VietGAP nghiêm ngặt. Trái giòn ngọt đậm đà, lượng lycopene cao gấp 3 lần cà chua thường.",
        "rating": 4.9,
        "reviewCount": 128,
        "farmId": "FARM-DL-01",
        "farmName": "Nông trại Hướng Dương Đà Lạt",
        "region": "Lạc Dương, Lâm Đồng",
        "certification": "VietGAP",
        "batchId": "BATCH-DL-2026-001",
        "stockQuantity": 85,
        "isFeatured": True
    },
    {
        "id": "PROD-002",
        "name": "Dưa lưới Huỳnh Long Mộc Châu",
        "category": "Trái cây sạch",
        "price": 85000.0,
        "originalPrice": 105000.0,
        "unit": "Quả (1.5 - 1.8 kg)",
        "imageUrl": "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500",
        "description": "Dưa lưới vỏ vàng ruột cam Huỳnh Long trồng tại cao nguyên Mộc Châu khí hậu mát mẻ, độ ngọt brix > 14. Đạt chuẩn an toàn sinh học quốc tế GlobalGAP.",
        "rating": 4.8,
        "reviewCount": 96,
        "farmId": "FARM-MC-04",
        "farmName": "Nông trại Công nghệ cao Mộc Châu",
        "region": "Mộc Châu, Sơn La",
        "certification": "GlobalGAP",
        "batchId": "BATCH-MC-2026-002",
        "stockQuantity": 40,
        "isFeatured": True
    },
    {
        "id": "PROD-003",
        "name": "Sầu riêng Ri6 Chợ Lách cơm vàng hạt lép",
        "category": "Trái cây sạch",
        "price": 135000.0,
        "originalPrice": 160000.0,
        "unit": "kg (Nguyên quả)",
        "imageUrl": "https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=500",
        "description": "Sầu riêng Ri6 chính gốc Chợ Lách Bến Tre chín cây tự nhiên, tuyệt đối không ngâm tẩm hóa chất. Cơm vàng ráo tay, ngọt béo đậm đà, đạt OCOP 4 sao tỉnh Bến Tre.",
        "rating": 5.0,
        "reviewCount": 215,
        "farmId": "FARM-BT-02",
        "farmName": "HTX Nông sản Bến Tre",
        "region": "Chợ Lách, Bến Tre",
        "certification": "OCOP 4 Sao",
        "batchId": "BATCH-BT-2026-003",
        "stockQuantity": 30,
        "isFeatured": True
    },
    {
        "id": "PROD-004",
        "name": "Bơ sáp 034 Đắk Lắk dẻo ngọt",
        "category": "Trái cây sạch",
        "price": 60000.0,
        "originalPrice": 75000.0,
        "unit": "kg (3-4 quả)",
        "imageUrl": "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500",
        "description": "Bơ sáp 034 quả thon dài, hạt bé như ngón tay, thịt dày dẻo quánh béo ngậy. Thu hái đúng độ già từ các vườn bơ chứng nhận VietGAP Đắk Lắk.",
        "rating": 4.7,
        "reviewCount": 78,
        "farmId": "FARM-DL-01",
        "farmName": "Nông trại Hướng Dương Đà Lạt",
        "region": "Cư M'gar, Đắk Lắk",
        "certification": "VietGAP",
        "batchId": "BATCH-DL-2026-004",
        "stockQuantity": 65,
        "isFeatured": False
    },
    {
        "id": "PROD-005",
        "name": "Rau muống thủy canh hữu cơ Ba Tri",
        "category": "Rau củ hữu cơ",
        "price": 25000.0,
        "originalPrice": 30000.0,
        "unit": "Túi 500g",
        "imageUrl": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500",
        "description": "Rau muống trồng theo phương pháp thủy canh hồi lưu khép kín, không dư lượng nitrat và kim loại nặng. Thân giòn rụm xào tỏi hoặc nấu canh tươi mát.",
        "rating": 4.8,
        "reviewCount": 110,
        "farmId": "FARM-BT-02",
        "farmName": "HTX Nông sản Bến Tre",
        "region": "Ba Tri, Bến Tre",
        "certification": "Organic USDA",
        "batchId": "BATCH-BT-2026-005",
        "stockQuantity": 120,
        "isFeatured": False
    },
    {
        "id": "PROD-006",
        "name": "Bưởi da xanh ruột hồng Tiền Giang",
        "category": "Trái cây sạch",
        "price": 65000.0,
        "originalPrice": 80000.0,
        "unit": "Quả (1.2 - 1.4 kg)",
        "imageUrl": "https://images.unsplash.com/photo-1557800636-894a64c1696f?w=500",
        "description": "Bưởi da xanh tép hồng mọng nước, vị ngọt thanh không chua, dễ tách múi. Đạt tiêu chuẩn VietGAP xuất khẩu.",
        "rating": 4.9,
        "reviewCount": 140,
        "farmId": "FARM-TG-03",
        "farmName": "Nông trang Bưởi Da Xanh Tiền Giang",
        "region": "Cái Bè, Tiền Giang",
        "certification": "VietGAP",
        "batchId": "BATCH-TG-2026-006",
        "stockQuantity": 55,
        "isFeatured": True
    },
    {
        "id": "PROD-007",
        "name": "Cải xoăn Kale Đà Lạt giàu vi chất",
        "category": "Rau củ hữu cơ",
        "price": 40000.0,
        "originalPrice": 50000.0,
        "unit": "Túi 400g",
        "imageUrl": "https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=500",
        "description": "Siêu thực phẩm Cải xoăn Kale xoăn tít xanh mướt, giàu Vitamin K, C và canxi hữu cơ. Thích hợp ép nước detox hoặc làm salad bổ dưỡng.",
        "rating": 4.6,
        "reviewCount": 65,
        "farmId": "FARM-DL-01",
        "farmName": "Nông trại Hướng Dương Đà Lạt",
        "region": "Đà Lạt, Lâm Đồng",
        "certification": "VietGAP",
        "batchId": "BATCH-DL-2026-007",
        "stockQuantity": 70,
        "isFeatured": False
    },
    {
        "id": "PROD-008",
        "name": "Xoài cát Hòa Lộc Tiền Giang",
        "category": "Trái cây sạch",
        "price": 95000.0,
        "originalPrice": 110000.0,
        "unit": "kg (2-3 quả)",
        "imageUrl": "https://images.unsplash.com/photo-1553279768-865429fa0078?w=500",
        "description": "Xoài cát Hòa Lộc danh tiếng nức lòng, thịt vàng ươm mịn màng không xơ, hương thơm ngào ngạt lan tỏa. Chứng nhận GlobalGAP thu hoạch đúng kỳ.",
        "rating": 5.0,
        "reviewCount": 198,
        "farmId": "FARM-TG-03",
        "farmName": "Nông trang Bưởi Da Xanh Tiền Giang",
        "region": "Hòa Hưng, Tiền Giang",
        "certification": "GlobalGAP",
        "batchId": "BATCH-TG-2026-008",
        "stockQuantity": 45,
        "isFeatured": True
    }
]

batches = [
    {
        "id": "BATCH-DL-2026-001",
        "productId": "PROD-001",
        "productName": "Cà chua bi Ruby Dalat GAP",
        "farmId": "FARM-DL-01",
        "farmName": "Nông trại Sinh học Hướng Dương Đà Lạt",
        "farmLocation": "Thôn Đạ Nghịt, Xã Lát, Huyện Lạc Dương, Tỉnh Lâm Đồng",
        "harvestDate": "14/11/2026",
        "expiryDate": "28/11/2026",
        "certType": "VietGAP",
        "certNumber": "VietGAP-TT-2026-0891",
        "certAuthority": "Trung tâm Giám định Kiểm nghiệm Nông Lâm Thủy Sản Vùng 2",
        "inspectorName": "Kỹ sư Nông học Lê Văn Khoa",
        "testResults": "Dư lượng BVTV: 0.00 mg/kg | Kim loại nặng: Đạt chuẩn an toàn tuyệt đối",
        "totalYieldKg": 850,
        "timeline": [
            {
                "title": "Gieo hạt & Cấy mô sinh học",
                "description": "Sử dụng hạt giống F1 Ruby nhập khẩu Hà Lan, ươm trong khay giá thể xơ dừa hữu cơ xử lý nhiệt.",
                "timestamp": "15/08/2026 08:30",
                "location": "Nhà ươm Kỹ thuật cao Hướng Dương, Đà Lạt",
                "responsiblePerson": "KS. Trịnh Văn Thành",
                "isCompleted": True
            },
            {
                "title": "Chăm sóc dinh dưỡng hữu cơ",
                "description": "Tưới nhỏ giọt công nghệ Israel với dịch đạm cá lên men vi sinh và tro trấu kali hữu cơ. Không dùng thuốc BVTV hóa học.",
                "timestamp": "25/09/2026 09:00",
                "location": "Nhà kính Farm 2, Lạc Dương, Lâm Đồng",
                "responsiblePerson": "Tổ trưởng Canh tác Trần Văn Bình",
                "isCompleted": True
            },
            {
                "title": "Kiểm nghiệm VietGAP tại đồng",
                "description": "Đoàn kiểm định lấy mẫu ngẫu nhiên lá và quả tươi phân tích 45 hoạt chất bảo vệ thực vật. Kết quả: ÂM TÍNH 100%.",
                "timestamp": "10/11/2026 14:15",
                "location": "Phòng Lab Chi cục Trồng trọt & BVTV Lâm Đồng",
                "responsiblePerson": "KS. Lê Văn Khoa (Thanh tra kiểm định)",
                "isCompleted": True
            },
            {
                "title": "Thu hái & Phân loại đóng gói",
                "description": "Thu hái thủ công sáng sớm khi trái đạt độ chín hồng 85%. Đóng hộp nhựa PET nguyên sinh dán tem QR truy xuất nguồn gốc.",
                "timestamp": "14/11/2026 06:45",
                "location": "Trạm sơ chế đóng gói Hướng Dương Farm",
                "responsiblePerson": "Đội trưởng KCS Nguyễn Thị Sen",
                "isCompleted": True
            },
            {
                "title": "Nhập kho lạnh & Sẵn sàng phân phối",
                "description": "Vận chuyển xe lạnh chuyên dụng về Kho Trung tâm Logistics FreshFarm. Bảo quản nhiệt độ tiêu chuẩn 12°C - 15°C.",
                "timestamp": "15/11/2026 04:30",
                "location": "Kho phân phối FreshFarm miền Trung, Hòa Quý, Đà Nẵng",
                "responsiblePerson": "Thủ kho Bùi Nguyễn Toàn",
                "isCompleted": True
            }
        ]
    },
    {
        "id": "BATCH-MC-2026-002",
        "productId": "PROD-002",
        "productName": "Dưa lưới Huỳnh Long Mộc Châu",
        "farmId": "FARM-MC-04",
        "farmName": "Nông trại Công nghệ cao Mộc Châu",
        "farmLocation": "Bản Búa, Xã Đông Sang, Huyện Mộc Châu, Tỉnh Sơn La",
        "harvestDate": "12/11/2026",
        "expiryDate": "30/11/2026",
        "certType": "GlobalGAP",
        "certNumber": "GlobalGAP-SLA-2026-009",
        "certAuthority": "Tổ chức Chứng nhận Quốc tế Control Union",
        "inspectorName": "Chuyên gia Đánh giá Vũ Mạnh Hùng",
        "testResults": "Độ ngọt Brix: 14.5 | Dư lượng Nitrat: 45 mg/kg (ngưỡng cho phép <150 mg/kg)",
        "totalYieldKg": 1200,
        "timeline": [
            {
                "title": "Xuống giống dưa lưới Huỳnh Long",
                "description": "Gieo hạt dưa giống thuần chủng Nhật Bản trên bầu giá thể đá khoáng perlite vô trùng.",
                "timestamp": "20/08/2026 07:00",
                "location": "Khu màng sinh học Mộc Châu SmartFarm",
                "responsiblePerson": "Chuyên viên giống Trịnh Thị Mai",
                "isCompleted": True
            },
            {
                "title": "Thụ phấn sinh học bằng ong mật",
                "description": "Thả ong mật tự nhiên thụ phấn vào ban mai. Mỗi dây chỉ giữ lại 01 quả duy nhất để tập trung dưỡng chất.",
                "timestamp": "18/09/2026 08:30",
                "location": "Nhà màng Khu A, Mộc Châu, Sơn La",
                "responsiblePerson": "Kỹ sư nông nghiệp Đặng Hải Nam",
                "isCompleted": True
            },
            {
                "title": "Kiểm định chất lượng GlobalGAP",
                "description": "Đánh giá an toàn thực phẩm, nguồn nước ngầm vùng cao và ghi chép nhật ký điện tử minh bạch.",
                "timestamp": "08/11/2026 10:00",
                "location": "Đoàn đánh giá Control Union Việt Nam",
                "responsiblePerson": "Thanh tra viên Vũ Mạnh Hùng",
                "isCompleted": True
            },
            {
                "title": "Cắt cành thu hoạch & Bọc lưới xốp",
                "description": "Cắt cuống hình chữ T đặc trưng, bọc lưới xốp bảo vệ vỏ quả và dán tem chống hàng giả.",
                "timestamp": "12/11/2026 09:30",
                "location": "Xưởng đóng gói Mộc Châu",
                "responsiblePerson": "Quản đốc xưởng Hoàng Đình Luật",
                "isCompleted": True
            },
            {
                "title": "Điều phối vận chuyển Logistics",
                "description": "Xe lạnh khởi hành qua quốc lộ 6 về trung tâm giao nhận FreshFarm phục vụ đơn hàng.",
                "timestamp": "13/11/2026 18:00",
                "location": "Trung tâm Vận tải Hàng tươi FreshFarm",
                "responsiblePerson": "Điều phối viên Trần Dương Thái",
                "isCompleted": True
            }
        ]
    },
    {
        "id": "BATCH-BT-2026-003",
        "productId": "PROD-003",
        "productName": "Sầu riêng Ri6 Chợ Lách cơm vàng hạt lép",
        "farmId": "FARM-BT-02",
        "farmName": "Hợp tác xã Trái cây Đặc sản Bến Tre",
        "farmLocation": "Ấp Vĩnh Nam, Xã Vĩnh Thành, Huyện Chợ Lách, Tỉnh Bến Tre",
        "harvestDate": "15/11/2026",
        "expiryDate": "22/11/2026",
        "certType": "OCOP 4 Sao",
        "certNumber": "OCOP-BT-2026-092",
        "certAuthority": "UBND Tỉnh Bến Tre & Sở Nông nghiệp & PTNT",
        "inspectorName": "KS. Nguyễn Văn Tấn",
        "testResults": "Cơm vàng dẻo béo ngậy | 100% không chất kích thích ép chín | Rụng tự nhiên",
        "totalYieldKg": 2500,
        "timeline": [
            {
                "title": "Bao trái sầu riêng bằng túi chuyên dụng",
                "description": "Bao từng quả sầu riêng trên cành bằng túi sợi chống côn trùng đục trái, giữ màu vỏ xanh tự nhiên.",
                "timestamp": "10/09/2026 08:00",
                "location": "Vườn sầu riêng 20 năm tuổi, Chợ Lách",
                "responsiblePerson": "Nông dân Lê Hoàng Ba",
                "isCompleted": True
            },
            {
                "title": "Kiểm tra độ già và gõ kiểm âm",
                "description": "Nghệ nhân gõ kiểm tra âm thanh cơm sầu riêng, đo trọng lượng quả từ 2.5kg - 4.5kg.",
                "timestamp": "14/11/2026 15:30",
                "location": "Vườn thực nghiệm OCOP Bến Tre",
                "responsiblePerson": "Nghệ nhân sầu riêng Huỳnh Văn Lành",
                "isCompleted": True
            },
            {
                "title": "Thu hoạch cắt cành & Vận chuyển",
                "description": "Hái thủ công và đóng thùng carton đục lỗ thông thoáng, niêm phong mã truy xuất OCOP tỉnh.",
                "timestamp": "15/11/2026 07:15",
                "location": "HTX Nông sản Bến Tre",
                "responsiblePerson": "Giám đốc HTX Lê Hoàng Ba",
                "isCompleted": True
            }
        ]
    }
]

orders = [
    {
        "id": "FF-20261116-01",
        "userId": "USR-001",
        "userName": "Trần Dương Thái",
        "userPhone": "0905123456",
        "shippingAddress": "470 Đường Trần Đại Nghĩa, Q. Ngũ Hành Sơn, Đà Nẵng",
        "items": [
            {
                "productId": "PROD-001",
                "productName": "Cà chua bi Ruby Dalat GAP",
                "imageUrl": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500",
                "price": 45000.0,
                "quantity": 2,
                "unit": "Hộp 500g"
            },
            {
                "productId": "PROD-002",
                "productName": "Dưa lưới Huỳnh Long Mộc Châu",
                "imageUrl": "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500",
                "price": 85000.0,
                "quantity": 1,
                "unit": "Quả (1.5 - 1.8 kg)"
            }
        ],
        "totalAmount": 175000.0,
        "shippingFee": 20000.0,
        "discountAmount": 15000.0,
        "finalAmount": 180000.0,
        "paymentMethod": "vietqr",
        "isPaid": True,
        "status": "shipping",
        "createdAt": "2026-11-16T10:30:00Z",
        "deliveryTrackingCode": "FASTCOLD-FF-8841",
        "deliveryPartner": "AhaMove Xe Lạnh Chuẩn 18°C"
    },
    {
        "id": "FF-20261115-02",
        "userId": "USR-001",
        "userName": "Trần Dương Thái",
        "userPhone": "0905123456",
        "shippingAddress": "470 Đường Trần Đại Nghĩa, Q. Ngũ Hành Sơn, Đà Nẵng",
        "items": [
            {
                "productId": "PROD-003",
                "productName": "Sầu riêng Ri6 Chợ Lách cơm vàng hạt lép",
                "imageUrl": "https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=500",
                "price": 135000.0,
                "quantity": 3,
                "unit": "kg (Nguyên quả)"
            }
        ],
        "totalAmount": 405000.0,
        "shippingFee": 0.0,
        "discountAmount": 25000.0,
        "finalAmount": 380000.0,
        "paymentMethod": "vietqr",
        "isPaid": True,
        "status": "delivered",
        "createdAt": "2026-11-15T08:15:00Z",
        "deliveryTrackingCode": "VNPOST-FF-7712",
        "deliveryPartner": "Giao Hàng Nhanh Express"
    },
    {
        "id": "FF-20261116-03",
        "userId": "USR-001",
        "userName": "Trần Dương Thái",
        "userPhone": "0905123456",
        "shippingAddress": "Khu Đô thị FPT City, Phường Hòa Hải, Q. Ngũ Hành Sơn, Đà Nẵng",
        "items": [
            {
                "productId": "PROD-005",
                "productName": "Rau muống thủy canh hữu cơ Ba Tri",
                "imageUrl": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500",
                "price": 25000.0,
                "quantity": 4,
                "unit": "Túi 500g"
            },
            {
                "productId": "PROD-006",
                "productName": "Bưởi da xanh ruột hồng Tiền Giang",
                "imageUrl": "https://images.unsplash.com/photo-1557800636-894a64c1696f?w=500",
                "price": 65000.0,
                "quantity": 2,
                "unit": "Quả (1.2 - 1.4 kg)"
            }
        ],
        "totalAmount": 230000.0,
        "shippingFee": 20000.0,
        "discountAmount": 0.0,
        "finalAmount": 250000.0,
        "paymentMethod": "cod",
        "isPaid": False,
        "status": "pending",
        "createdAt": "2026-11-16T14:15:00Z",
        "deliveryTrackingCode": "PENDING-PICKUP",
        "deliveryPartner": "Viettel Post Nông Sản"
    }
]

print("Starting Firestore Data Seeding for project:", PROJECT_ID)

print("\n1. Uploading Farms...")
for f in farms:
    st = upload_doc("farms", f["id"], f)
    print(f"  + Farm {f['id']}: HTTP {st}")

print("\n2. Uploading Products...")
for p in products:
    st = upload_doc("products", p["id"], p)
    print(f"  + Product {p['id']}: HTTP {st} ({p['name']})")

print("\n3. Uploading Traceability Batches...")
for b in batches:
    st = upload_doc("batches", b["id"], b)
    print(f"  + Batch {b['id']}: HTTP {st} ({b['productName']})")

print("\n4. Uploading Orders...")
for o in orders:
    st = upload_doc("orders", o["id"], o)
    print(f"  + Order {o['id']}: HTTP {st} ({o['finalAmount']} VND)")

print("\nALL SEEDING COMPLETED SUCCESSFULLY!")

