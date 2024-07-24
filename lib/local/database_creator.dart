import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database db;

class DatabaseCreator {
  // tables
  static const todoTable = 'config';
  static const todoTable1 = 'workers';
  static const todoTable2 = 'workday';
  static const todoTable3 = 'clocks';
  static const todoTable4 = 'chat';
  static const todoTable5 = 'contract';
  static const todoTable6 = 'workday_online';
  static const todoTable7 = 'tester';

  static const id = 'id';
  // config
  static const language = 'language';
  static const token = 'token';
  static const role = 'role';
  static const contract = 'contract';
  static const offline = 'offline';
  static const email = 'email';
  static const profile_image = 'profile_image';
  static const id_type = 'id_type';
  static const doc_type = 'doc_type';
  static const dependents = 'dependents';
  static const contact = 'contact';
  static const addres = 'addres';
  static const clock_in_module = 'clock_in_module';
  static const clock_out_module = 'clock_out_module';
  static const expenses_module = 'expenses_module';
  static const warnings_module = 'warnings_module';

  // workers
  static const btn_id = 'btn_id';
  static const first_name = 'first_name';
  static const last_name = 'last_name';
  static const image = 'image';
  static const wk_id = 'wk_id';
  static const accepted_id = 'accepted_id';

  //workday
  static const init = 'init';
  static const end = 'end';
  static const estatus = 'estatus';
  //contract
  static const contract_id = 'contract_id';
  static const contract_name = 'contract_name';
  static const contract_temp = 'contract_temp';

  //clocks
  static const worker = 'worker';
  static const worker_name = 'worker_name';
  static const worker_last = 'worker_last';
  static const worker_btnid = 'worker_btnid';
  static const clock_type = 'clock_type';
  static const clock_in_start = 'clock_in_start';
  static const message = 'message';
  static const registration_datetime = 'registration_datetime';
  static const verified = 'verified';
  //chat
  static const chat_id = 'chat_id';
  static const room_name = 'room_name';
  static const group_name = 'group_name';
  static const contract_name_chat = 'contract_name_chat';
  static const last_msg = 'last_msg';
  static const last_created = 'last_created';
  static const icon_chat = 'icon_chat';

  //workday_online
  static const workday_id = 'workday_id';
  static const clock_in_init = 'clock_in_init';
  static const clock_in_fin = 'clock_in_fin';
  static const clock_out_init = 'clock_out_init';
  static const clock_out_fin = 'clock_out_fin';
  static const clock_in_location = 'clock_in_location';
  static const clock_out_location = 'clock_out_location';
  static const workday_status = 'workday_status';
  static const workday_other = 'workday_other';
  static const has_clockin = 'has_clockin';
  static const has_clockout = 'has_clockout';
  static const default_init = 'default_init';
  static const default_exit = 'default_exit';
  static const ult_clock = 'ult_clock';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>>? selectQueryResult,
      int? insertAndUpdateQueryResult,
      List<dynamic>? params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createTodoTable(Database db) async {
    final sql = 'CREATE TABLE $todoTable ($id INTEGER PRIMARY KEY UNIQUE ,'
        ' $language TEXT , $token TEXT, $role TEXT, $contract TEXT ,$first_name TEXT,$last_name TEXT,$btn_id TEXT,$email TEXT,$image TEXT,$offline TEXT,$profile_image TEXT,$id_type TEXT,$doc_type TEXT,$dependents TEXT,$contact TEXT,$addres TEXT,$clock_in_module BOOLEAN,$clock_out_module BOOLEAN,$expenses_module BOOLEAN,$warnings_module BOOLEAN)';

    await db.execute(sql);
  }

  Future<void> createTodoTable1(Database db) async {
    final sql = 'CREATE TABLE $todoTable1 ($id INTEGER PRIMARY KEY UNIQUE ,'
        ' $first_name TEXT ,$last_name TEXT, $btn_id TEXT, $image TEXT, $wk_id INTEGER , $accepted_id INTEGER  )';

    await db.execute(sql);
  }

  Future<void> createTodoTable2(Database db) async {
    final sql = 'CREATE TABLE $todoTable2 ($id INTEGER PRIMARY KEY UNIQUE ,'
        ' $estatus TEXT ,$init TIMESTAMP, $end TIMESTAMP )';

    await db.execute(sql);
  }

  Future<void> createTodoTable3(Database db) async {
    final sql = 'CREATE TABLE $todoTable3 ($id INTEGER PRIMARY KEY UNIQUE ,'
        ' $worker INT ,$worker_name TEXT,$worker_last TEXT,$worker_btnid TEXT,$clock_type TEXT,$clock_in_start TIMESTAMP,$message TEXT,$verified BOOL )';

    await db.execute(sql);
  }

  Future<void> createTodoTable4(Database db) async {
    final sql = 'CREATE TABLE $todoTable4 ($id INTEGER PRIMARY KEY UNIQUE ,'
        '$chat_id INT, $room_name TEXT ,$group_name TEXT,$contract_name TEXT,$last_msg TEXT, $last_created TIMESTAMP, $icon_chat TEXT)';

    await db.execute(sql);
  }

  Future<void> createTodoTable5(Database db) async {
    final sql = 'CREATE TABLE $todoTable5 ($id INTEGER PRIMARY KEY UNIQUE ,'
        ' $contract_id INT ,$contract_name TEXT, $contract_temp TEXT)';

    await db.execute(sql);
  }

  Future<void> createTodoTable6(Database db) async {
    final sql = 'CREATE TABLE $todoTable6 ($id INTEGER PRIMARY KEY UNIQUE ,'
        '$workday_id INT ,$clock_in_init TIMESTAMP, $clock_in_fin TIMESTAMP, $clock_out_init TIMESTAMP, $clock_out_fin TIMESTAMP, $clock_in_location TEXT, $clock_out_location TEXT, $workday_status TEXT, $workday_other TEXT,$has_clockin BOOLEAN, $has_clockout BOOLEAN, $default_init TIMESTAMP, $default_exit TIMESTAMP, $ult_clock TIMESTAMP)';

    await db.execute(sql);
  }

  Future<void> createTodoTable7(Database db) async {
    final sql = 'CREATE TABLE $todoTable7 ($id INTEGER PRIMARY KEY UNIQUE ,'
        '$workday_id INT ,$clock_in_init TIMESTAMP, $clock_in_fin TIMESTAMP, $clock_out_init TIMESTAMP, $clock_out_fin TIMESTAMP, $clock_in_location TEXT, $clock_out_location TEXT, $workday_status TEXT, $workday_other TEXT)';

    await db.execute(sql);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
      //await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('config');
    db = await openDatabase(path, version: 3, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTodoTable(db);
    await createTodoTable1(db);
    await createTodoTable2(db);
    await createTodoTable3(db);
    await createTodoTable4(db);
    await createTodoTable5(db);
    await createTodoTable6(db);
  }
}
