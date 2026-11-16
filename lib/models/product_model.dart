class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String unit; // kg, hộp 500g, túi 1kg, combo
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final String farmId;
  final String farmName;
  final String region;
  final String certification; // VietGAP, GlobalGAP, Organic USDA, OCOP
  final String batchId;
  int stockQuantity;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.imageUrl,
    required this.description,
    this.rating = 4.8,
    this.reviewCount = 42,
    required this.farmId,
    required this.farmName,
    required this.region,
    required this.certification,
    required this.batchId,
    required this.stockQuantity,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'unit': unit,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'farmId': farmId,
      'farmName': farmName,
      'region': region,
      'certification': certification,
      'batchId': batchId,
      'stockQuantity': stockQuantity,
      'isFeatured': isFeatured,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Rau củ',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      unit: map['unit'] ?? 'kg',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      farmId: map['farmId'] ?? '',
      farmName: map['farmName'] ?? '',
      region: map['region'] ?? '',
      certification: map['certification'] ?? 'VietGAP',
      batchId: map['batchId'] ?? '',
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 100,
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? originalPrice,
    String? unit,
    String? imageUrl,
    String? description,
    double? rating,
    int? reviewCount,
    String? farmId,
    String? farmName,
    String? region,
    String? certification,
    String? batchId,
    int? stockQuantity,
    bool? isFeatured,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      region: region ?? this.region,
      certification: certification ?? this.certification,
      batchId: batchId ?? this.batchId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

