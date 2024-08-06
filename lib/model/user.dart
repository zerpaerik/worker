import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  final int? id;
  // ignore: non_constant_identifier_names
  final String? first_name;
  final String? email;
  // ignore: non_constant_identifier_names
  final DateTime birth_date;
  // ignore: non_constant_identifier_names
  final String? last_name;
  final String? password1;
  final String? password2;
  final String? gender;
  final int? country;
  final int? state;
  final int? city;
  final String? address_1;
  final String? address_2;
  // ignore: non_constant_identifier_names
  final bool? is_us_citizen; // IS AMERICAN
  // ignore: non_constant_identifier_names
  final String? id_type; //SSN - ITIN
  // ignore: non_constant_identifier_names
  final String? id_number;
  // ignore: non_constant_identifier_names
  final String? doc_type; // PAS -LIC - STATE ID
  // ignore: non_constant_identifier_names
  final String? doc_number; // NUM PAS-LIC-STATEID
  // ignore: non_constant_identifier_names
  final File? doc_image;
  // ignore: non_constant_identifier_names
  final DateTime doc_expire_date;
  // ignore: non_constant_identifier_names
  final String? dependents_number;
  // ignore: non_constant_identifier_names
  final String? marital_status;
  final File? signature;
  final File? tax_doc_file;

  // ignore: non_constant_identifier_names
  final String? contact_first_name;
  // ignore: non_constant_identifier_names
  final String? contact_last_name;
  // ignore: non_constant_identifier_names
  final String? contact_phone;
  // ignore: non_constant_identifier_names
  final String? contact_email;
  // ignore: non_constant_identifier_names
  final int? blood_type;
  // ignore: non_constant_identifier_names
  final int? rh_factor;
  // ignore: non_constant_identifier_names
  final String? phone_number;
  // ignore: non_constant_identifier_names
  final String? zip_code;
  // ignore: non_constant_identifier_names
  final File? profile_image;
  // ignore: non_constant_identifier_names
  final String? degree_levels;
  // ignore: non_constant_identifier_names
  final String? speciality_or_degree;
  // ignore: non_constant_identifier_names
  final String? english_mastery;
  // ignore: non_constant_identifier_names
  final String? english_learning_method;
  // ignore: non_constant_identifier_names
  final String? english_learning_level;
  // ignore: non_constant_identifier_names
  final String? spanish_mastery;
  // ignore: non_constant_identifier_names
  final String? spanish_learning_method;
  // ignore: non_constant_identifier_names
  final String? spanish_learning_level;
  // ignore: non_constant_identifier_names
  final String? expertise_area;
  // ignore: non_constant_identifier_names
  final File? cv_file;
  // ignore: non_constant_identifier_names
  final String? btn_id;
  // ignore: non_constant_identifier_names
  final String? referral_code;

  // ignore: non_constant_identifier_names
  final String? doc_type_no;
  // ignore: non_constant_identifier_names
  final DateTime? expiration_date_no;
  // ignore: non_constant_identifier_names
  final File? front_image_no;
  // ignore: non_constant_identifier_names
  final File? rear_image_no;
  // ignore: non_constant_identifier_names
  final File? i94_form_image;
  // ignore: non_constant_identifier_names
  final String? uscis_number;
  final String? birthplace;
  final String? ssn_dependents_number;
  final String? other_income;
  final String? deduction_type;
  final String? deduction_amount;
  final String? state_name;
  final String? city_name;

  User(
      {this.id,
      // ignore: non_constant_identifier_names
      required this.first_name,
      required this.email,
      // ignore: non_constant_identifier_names
      required this.birth_date,
      // ignore: non_constant_identifier_names
      required this.last_name,
      this.password1,
      this.password2,
      required this.gender,
      required this.country,
      required this.state,
      required this.city,
      required this.address_1,
      required this.address_2,
      required this.birthplace,
      // ignore: non_constant_identifier_names
      this.is_us_citizen,
      // ignore: non_constant_identifier_names
      this.id_type,
      // ignore: non_constant_identifier_names
      this.id_number,
      // ignore: non_constant_identifier_names
      this.doc_type,
      // ignore: non_constant_identifier_names
      required this.doc_expire_date,
      // ignore: non_constant_identifier_names
      this.doc_image,
      // ignore: non_constant_identifier_names
      this.doc_number,
      // ignore: non_constant_identifier_names
      required this.dependents_number,
      // ignore: non_constant_identifier_names
      required this.contact_first_name,
      // ignore: non_constant_identifier_names
      required this.contact_last_name,
      // ignore: non_constant_identifier_names
      required this.contact_phone,
      // ignore: non_constant_identifier_names
      required this.contact_email,
      this.signature,
      // ignore: non_constant_identifier_names
      this.marital_status,
      // ignore: non_constant_identifier_names
      this.blood_type,
      // ignore: non_constant_identifier_names
      this.rh_factor,
      // ignore: non_constant_identifier_names
      this.phone_number,
      // ignore: non_constant_identifier_names
      this.zip_code,
      // ignore: non_constant_identifier_names
      this.profile_image,
      // ignore: non_constant_identifier_names
      this.degree_levels,
      // ignore: non_constant_identifier_names
      required this.speciality_or_degree,
      // ignore: non_constant_identifier_names
      this.english_learning_method,
      // ignore: non_constant_identifier_names
      this.english_learning_level,
      // ignore: non_constant_identifier_names
      this.english_mastery,
      // ignore: non_constant_identifier_names
      this.spanish_mastery,
      // ignore: non_constant_identifier_names
      this.spanish_learning_method,
      // ignore: non_constant_identifier_names
      this.spanish_learning_level,
      // ignore: non_constant_identifier_names
      this.expertise_area,
      // ignore: non_constant_identifier_names
      this.cv_file,
      // ignore: non_constant_identifier_names
      required this.btn_id,
      // ignore: non_constant_identifier_names
      this.referral_code,
      // ignore: non_constant_identifier_names
      this.doc_type_no,
      // ignore: non_constant_identifier_names
      this.expiration_date_no,
      // ignore: non_constant_identifier_names
      this.front_image_no,
      // ignore: non_constant_identifier_names
      this.rear_image_no,
      // ignore: non_constant_identifier_names
      this.i94_form_image,
      // ignore: non_constant_identifier_names
      this.uscis_number,
      this.ssn_dependents_number,
      this.other_income,
      this.deduction_type,
      this.deduction_amount,
      required this.tax_doc_file,
      required this.state_name,
      required this.city_name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      profile_image: File(json['profile_image']),
      country: json['country'],
      state: json['state'],
      city: json['city'],
      birth_date: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'].toString())
          : DateTime.now(),
      gender: json['gender'],
      zip_code: json['zip_code'],
      address_1: json['address_1'],
      address_2: json['address_2'],
      birthplace: json['birthplace'],
      id_type: json['id_type'],
      id_number: json['id_number'],
      doc_type: json['doc_type'] ?? '0',
      phone_number: json['phone_number'] ?? '0',
      doc_number: json['doc_number'] ?? '-',
      doc_image: json['doc_image'],
      contact_first_name: json['contact_first_name'] ?? '0',
      contact_last_name: json['contact_last_name'] ?? '0',
      contact_phone: json['contact_phone'] ?? '0',
      contact_email: json['contact_email'] ?? '0',
      btn_id: json['btn_id'],
      dependents_number: json['dependents_number'] != null
          ? json['dependents_number'].toString()
          : '0',
      marital_status: json['marital_status'],
      degree_levels: json['degree_levels'],
      speciality_or_degree: json['speciality_or_degree'] ?? '0',
      referral_code: json['referral_code'],
      tax_doc_file: json['tax_doc_file'],
      state_name: json['state_name'],
      city_name: json['city_name'],
      doc_expire_date: json['doc_expire_date'] != null
          ? DateTime.parse(json['doc_expire_date'].toString())
          : DateTime.now(),

      /* ssn_dependents_number: json['ssn_dependents_number'],
      other_income: json['other_income'],
      deduction_type: json['deduction_type'],
      deduction_amount: json['deduction_amount'],*/
    );
  }

  /* factory User.fromJson1(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      btn_id: json['btn_id'],
      profile_image: json['profile_image'] != null
          ? new File(json['profile_image'])
          : null,
    );
  }*/

  @override
  String toString() {
    return 'Usuario(id: $id, first_name: $first_name, email: $email, birth_date: $birth_date, last_name: $last_name, password1: $password1, password2: $password2, gender: $gender, country: $country, state: $state, city: $city, address_1: $address_1, address_2: $address_2, is_us_citizen: $is_us_citizen, id_type: $id_type, id_number: $id_number, doc_type: $doc_type, doc_number: $doc_number, doc_image: $doc_image, doc_expire_date: $doc_expire_date, dependents_number: $dependents_number, marital_status: $marital_status, signature: $signature, contact_first_name: $contact_first_name, contact_last_name: $contact_last_name, contact_phone: $contact_phone, contact_email: $contact_email, blood_type: $blood_type, rh_factor: $rh_factor, phone_number: $phone_number, zip_code: $zip_code)';
  }
}
