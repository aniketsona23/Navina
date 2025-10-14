class EmergencyContact {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? relationship;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a copy of this contact with updated fields
  EmergencyContact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert EmergencyContact to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'is_primary': isPrimary ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create EmergencyContact from Map (from database)
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      relationship: map['relationship'] as String?,
      isPrimary: (map['is_primary'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Create a new EmergencyContact for insertion
  factory EmergencyContact.create({
    required String name,
    required String phoneNumber,
    String? relationship,
    bool isPrimary = false,
  }) {
    final now = DateTime.now();
    return EmergencyContact(
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      isPrimary: isPrimary,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(id: $id, name: $name, phoneNumber: $phoneNumber, relationship: $relationship, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.relationship == relationship &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      phoneNumber,
      relationship,
      isPrimary,
    );
  }

  // Validate phone number format (supports Indian numbers)
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Indian phone number patterns:
    // +91XXXXXXXXXX (12 digits with country code)
    // XXXXXXXXXX (10 digits without country code)
    // 0XXXXXXXXX (11 digits with leading 0)
    
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return true; // +91XXXXXXXXXX format
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      return true; // 91XXXXXXXXXX format
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      return true; // 0XXXXXXXXXX format
    } else if (cleaned.length == 10 && RegExp(r'^[6-9]').hasMatch(cleaned)) {
      return true; // XXXXXXXXXX format (starting with 6-9)
    }
    
    return false;
  }

  // Format phone number for display (Indian format)
  String get formattedPhoneNumber {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Indian phone number formatting
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      // +91 XXXX XXX XXX
      final number = cleaned.substring(3);
      return '+91 ${number.substring(0, 5)} ${number.substring(5, 8)} ${number.substring(8)}';
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      // +91 XXXX XXX XXX
      final number = cleaned.substring(2);
      return '+91 ${number.substring(0, 5)} ${number.substring(5, 8)} ${number.substring(8)}';
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      // 0XXXX XXX XXX
      final number = cleaned.substring(1);
      return '0${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
    } else if (cleaned.length == 10 && RegExp(r'^[6-9]').hasMatch(cleaned)) {
      // XXXX XXX XXX
      return '${cleaned.substring(0, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
    }
    
    return phoneNumber; // Return original if can't format
  }

  // Get phone number for dialing (removes formatting, adds +91 if needed)
  String get dialablePhoneNumber {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return cleaned; // Already has +91
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned'; // Add + prefix
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      return '+91${cleaned.substring(1)}'; // Remove 0, add +91
    } else if (cleaned.length == 10 && RegExp(r'^[6-9]').hasMatch(cleaned)) {
      return '+91$cleaned'; // Add +91 prefix
    }
    
    return phoneNumber; // Return original if can't format
  }

  // Get display name with relationship
  String get displayName {
    if (relationship != null && relationship!.isNotEmpty) {
      return '$name ($relationship)';
    }
    return name;
  }

  // Check if this is a valid contact
  bool get isValid {
    return name.trim().isNotEmpty && 
           phoneNumber.trim().isNotEmpty && 
           isValidPhoneNumber(phoneNumber);
  }
}
