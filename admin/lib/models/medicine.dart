class Medicine {
  final int id;
  final String name;
  final String? brand;
  final String? barcode;
  final String? dosage;
  final String? instructions;
  final String? warnings;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? createdByName;
  final String? createdByEmail;
  final String? deletedByName;

  Medicine({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    this.dosage,
    this.instructions,
    this.warnings,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.createdByName,
    this.createdByEmail,
    this.deletedByName,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      barcode: json['barcode'],
      dosage: json['dosage'],
      instructions: json['instructions'],
      warnings: json['warnings'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == true,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      createdByName: json['created_by_name'],
      createdByEmail: json['created_by_email'],
      deletedByName: json['deleted_by_name'],
    );
  }
}

