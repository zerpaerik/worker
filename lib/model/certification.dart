import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:worker/model/certification_type.dart';

class Certification with ChangeNotifier {
  final int id;
  // ignore: non_constant_identifier_names
  final DateTime issuance_date;
  // ignore: non_constant_identifier_names
  final DateTime expiration_date;
  // ignore: non_constant_identifier_names
  final File file_upload;
  // ignore: non_constant_identifier_names
  final File frontal_img;
  // ignore: non_constant_identifier_names
  final File rear_img;
  // ignore: non_constant_identifier_names
  final String verification_url;
  // ignore: non_constant_identifier_names
  final String certification_level;
  // ignore: non_constant_identifier_names
  final CertificationType certification_type;

  Certification(
      {required this.id,
      // ignore: non_constant_identifier_names
      required this.issuance_date,
      // ignore: non_constant_identifier_names
      required this.expiration_date,
      // ignore: non_constant_identifier_names
      required this.file_upload,
      // ignore: non_constant_identifier_names
      required this.frontal_img,
      // ignore: non_constant_identifier_names
      required this.rear_img,
      // ignore: non_constant_identifier_names
      required this.verification_url,
      // ignore: non_constant_identifier_names
      required this.certification_level,
      // ignore: non_constant_identifier_names
      required this.certification_type});

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      issuance_date: json['issuance_date'],
      expiration_date: json['expiration_date'],
      verification_url: json['verification_url'],
      frontal_img: json['frontal_img'],
      rear_img: json['rear_img'],
      file_upload: json['file_upload'],
      certification_level: json['certification_level'],
      certification_type:
          CertificationType.fromJson(json['certification_type']),
    );
  }
}
