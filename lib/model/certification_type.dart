import 'package:flutter/foundation.dart';

class CertificationType with ChangeNotifier {
  final int id;
  final String name;
  final String description;
  // ignore: non_constant_identifier_names
  final String requires_issuance_date;
  // ignore: non_constant_identifier_names
  final String requires_expiration_date;
  // ignore: non_constant_identifier_names
  final String requires_file_upload;
  // ignore: non_constant_identifier_names
  final String requires_frontal_img;
  // ignore: non_constant_identifier_names
  final String requires_rear_img;
  // ignore: non_constant_identifier_names
  final String requires_verification_url;
  // ignore: non_constant_identifier_names
  final String requires_levels;
  // ignore: non_constant_identifier_names
  final String certification_levels;

  CertificationType(
      {required this.id,
      required this.name,
      required this.description,
      // ignore: non_constant_identifier_names
      required this.requires_issuance_date,
      // ignore: non_constant_identifier_names
      required this.requires_expiration_date,
      // ignore: non_constant_identifier_names
      required this.requires_file_upload,
      // ignore: non_constant_identifier_names
      required this.requires_frontal_img,
      // ignore: non_constant_identifier_names
      required this.requires_rear_img,
      // ignore: non_constant_identifier_names
      required this.requires_verification_url,
      // ignore: non_constant_identifier_names
      required this.requires_levels,
      // ignore: non_constant_identifier_names
      required this.certification_levels});

  factory CertificationType.fromJson(Map<String, dynamic> json) {
    return CertificationType(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        requires_issuance_date: json['requires_issuance_date'],
        requires_expiration_date: json['requires_expiration_date'],
        requires_file_upload: json['requires_file_upload'],
        requires_frontal_img: json['requires_frontal_img'],
        requires_rear_img: json['requires_rear_img'],
        requires_verification_url: json['requires_verification_url'],
        requires_levels: json['requires_levels'],
        certification_levels: json['certification_levels']);
  }
}
