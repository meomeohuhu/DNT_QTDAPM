class FarmModel {
  final String id;
  final String name;
  final String ownerName;
  final String phone;
  final String location;
  final String province;
  final double areaHectares;
  final String vietGapCertNo;
  final String issueDate;
  final List<String> productsGrown;

  FarmModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.location,
    required this.province,
    required this.areaHectares,
    required this.vietGapCertNo,
    required this.issueDate,
    required this.productsGrown,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerName': ownerName,
      'phone': phone,
      'location': location,
      'province': province,
      'areaHectares': areaHectares,
      'vietGapCertNo': vietGapCertNo,
      'issueDate': issueDate,
      'productsGrown': productsGrown,
    };
  }

  factory FarmModel.fromMap(Map<String, dynamic> map) {
    return FarmModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      province: map['province'] ?? '',
      areaHectares: (map['areaHectares'] as num?)?.toDouble() ?? 1.0,
      vietGapCertNo: map['vietGapCertNo'] ?? '',
      issueDate: map['issueDate'] ?? '',
      productsGrown: List<String>.from(map['productsGrown'] ?? []),
    );
  }
}

