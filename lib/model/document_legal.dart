import 'package:flutter/foundation.dart';

class DocumentLegal with ChangeNotifier {
  final int id;
  final String work_elegibility;
  final String id_type;
  final String status;
  final String doc_type;
  final String number;
  final String uscis;
  final String comments;

  // ignore: non_constant_identifier_names
  final DateTime created;
  final DateTime expiration_date;

  final String front_photo;
  final String rear_photo;
  final String doc_selfie;
  final String proof_photo;

  DocumentLegal({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.work_elegibility,
    required this.id_type,
    required this.status,
    required this.doc_type,
    required this.number,
    required this.uscis,
    required this.comments,
    required this.created,
    required this.expiration_date,
    required this.front_photo,
    required this.rear_photo,
    required this.doc_selfie,
    required this.proof_photo,
  });

  factory DocumentLegal.fromJson(Map<String, dynamic> json) {
    return DocumentLegal(
      id: json['id'],
      work_elegibility: json['work_elegibility'],
      status: json['status'],
      doc_type: json['doc_type'],
      id_type: json['id_type'],
      number: json['number'] != null ? json['number'] : null,
      uscis: json['uscis'] != null ? json['uscis'] : null,
      comments: json['comments'] != null ? json['comments'] : '',
      created: json['created'] != null ? json['created'] : '',
      expiration_date:
          json['expiration_date'] != null ? json['expiration_date'] : null,
      front_photo: json['front_photo'] != null ? json['front_photo'] : '',
      rear_photo: json['rear_photo'] != null ? json['rear_photo'] : '',
      doc_selfie: json['doc_selfie'] != null ? json['doc_selfie'] : '',
      proof_photo: json['proof_photo'] != null ? json['proof_photo'] : '',
    );
  }
}
