import 'package:worker/model/workday.dart';

import '../model/config.dart';
import '../model/contract.dart';
import '../model/workers.dart';
import '../model/workday_local.dart';
import '../local/database_creator.dart';

class RepositoryServiceTodo {
  static Future<List<Config>> getAllTodos() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable};''';
    final data = await db.rawQuery(sql);
    List<Config> todos = [];

    for (final node in data) {
      final todo = Config.fromJson(node);
      todos.add(todo);
    }
    return todos;
  }

  //workday_online
  static const id = 'id';
  static const workday_id = 'workday_id';
  static const clock_in_init = 'clock_in_init';
  static const clock_in_fin = 'clock_in_fin';
  static const clock_out_init = 'clock_out_init';
  static const clock_out_fin = 'clock_out_fin';
  static const clock_in_location = 'clock_in_location';
  static const clock_out_location = 'clock_out_location';
  static const default_init = 'default_init';
  static const default_exit = 'default_exit';
  static const workday_status = 'workday_status';
  static const workday_other = 'workday_other';

  static Future<Config> getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    return todo;
  }

  static Future<dynamic> getContract(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable5}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Contract.fromJson(data.first);

    return todo;
  }

  static Future<WorkdayLocal> getWorkday(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable2}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final wk = WorkdayLocal.fromJson(data.first);
    return wk;
  }

  static Future<dynamic> getWorker(String btn_id) async {
    print(btn_id);
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable1}
    WHERE ${DatabaseCreator.btn_id} = ?''';

    List<dynamic> params = [btn_id];
    final data = await db.rawQuery(sql, params);

    final todo = Workers.fromJson(data.first);

    print(todo);
    return todo;
  }

  static Future<int> addTodo(Config todo) async {
    print(todo.language);
    var res = await db
        .rawInsert("INSERT INTO ${DatabaseCreator.todoTable} (id,language)"
            " VALUES (1,'${todo.language}')");
    print(res);
    return res;
  }

  static Future<int> addContract() async {
    var res = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable5} (id,contract_id,contract_name)"
        " VALUES (1,'','')");
    print(res);
    return res;
  }

  static Future<int> addWorkdayOnline() async {
    var res = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable6} (id,workday_id,clock_in_init, clock_in_fin,clock_out_init, clock_out_fin,clock_in_location, clock_out_location, workday_status,workday_other, has_clockin, has_clockout, default_init, default_exit, ult_clock)"
        " VALUES (1,'','','','','','','','','','','','','','')");
    print(res);
    return res;
  }

  static Future<List<Map<String, Object?>>> verifyData() async {
    // List<Map> result = await db.query(DatabaseCreator.todoTable7);
    var res = await db.query(DatabaseCreator.todoTable7);

    print(res);
    return res;
  }

  static query() async {
    // get a reference to the database

    // get all rows
    List<Map> result = await db.query(DatabaseCreator.todoTable4);

    // print the results
    result.forEach((row) => print(row));
    // {_id: 1, name: Bob, age: 23}
    // {_id: 2, name: Mary, age: 32}
    // {_id: 3, name: Susan, age: 12}
  }

  static queryw() async {
    // get a reference to the database

    // get all rows
    List<Map> result = await db.query(DatabaseCreator.todoTable2);

    // print the results
    result.forEach((row) => print(row));
    // {_id: 1, name: Bob, age: 23}
    // {_id: 2, name: Mary, age: 32}
    // {_id: 3, name: Susan, age: 12}
  }

  static Future<dynamic> querywr() async {
    List<Map> result = await db.rawQuery(
        'SELECT * FROM ${DatabaseCreator.todoTable3} WHERE clock_type=?',
        ['IN']);
    return result;
  }

  static Future<dynamic> queryww() async {
    List<Map> result =
        await db.rawQuery('SELECT * FROM ${DatabaseCreator.todoTable1}');
    return result;
  }

  static Future<dynamic> querywro() async {
    List<Map> result = await db.rawQuery(
        'SELECT * FROM ${DatabaseCreator.todoTable3} WHERE clock_type=?',
        ['OUT']);
    return result;
  }

  static Future<dynamic> getWorkerScan(String btn_id) async {
    List<Map> worker = await db.rawQuery(
        'SELECT * FROM ${DatabaseCreator.todoTable1} WHERE btn_id=?', [btn_id]);

    if (worker.length == 0) {
      Map<String, dynamic> success = {"data": worker, "status": 400};
      return success;
    } else {
      List<Map> clock = await db.rawQuery(
          'SELECT * FROM ${DatabaseCreator.todoTable3} WHERE worker_btnid=? AND clock_type=?',
          [worker[0]['btn_id'], 'IN']);

      if (clock.length > 0) {
        Map<String, dynamic> success = {"data": worker, "status": 203};
        return success;
      } else {
        Map<String, dynamic> success = {"data": worker, "status": 201};
        return success;
      }
    }
  }

  static Future<dynamic> getWorkerScanO(String btn_id) async {
    List<Map> worker = await db.rawQuery(
        'SELECT * FROM ${DatabaseCreator.todoTable1} WHERE btn_id=?', [btn_id]);

    if (worker.length == 0) {
      //NO EXSTE EL WORKER
      Map<String, dynamic> success = {"data": worker, "status": 400};
      return success;
    } else {
      List<Map> clockin = await db.rawQuery(
          'SELECT * FROM ${DatabaseCreator.todoTable3} WHERE worker_btnid=? AND clock_type=?',
          [worker[0]['btn_id'], 'IN']);

      List<Map> clock = await db.rawQuery(
          'SELECT * FROM ${DatabaseCreator.todoTable3} WHERE worker_btnid=? AND clock_type=?',
          [worker[0]['btn_id'], 'OUT']);

      if (clockin.length == 0) {
        //NO HA HECHO CLOCKIN EN LA JORNADA
        Map<String, dynamic> success = {"data": worker, "status": 401};
        return success;
      } else if (clock.length > 0) {
        //YA HIZO CLOCK OUT EN LA JORNADA
        Map<String, dynamic> success = {"data": worker, "status": 203};
        return success;
      } else {
        Map<String, dynamic> success = {"data": worker, "status": 201};
        return success;
      }

      /* if (clock.length > 0) {
        Map<String, dynamic> success = {"data": worker, "status": 203};
        return success;
      } else {
        Map<String, dynamic> success = {"data": worker, "status": 201};
        return success;
      }*/
    }
  }

  static Future<void> addTodoW(wk) async {
    for (int i = 0; i < wk.length; i++) {
      List<Map> worker = await db.rawQuery(
          'SELECT * FROM ${DatabaseCreator.todoTable1} WHERE btn_id=?',
          [wk[i]['btn_id']]);
      print(worker.length);
      if (worker.isNotEmpty) {
      } else {
        var res = await db.rawInsert(
            "INSERT INTO ${DatabaseCreator.todoTable1} (first_name,last_name,btn_id,image, wk_id, accepted_id)"
            " VALUES ('${wk[i]['first_name']}','${wk[i]['last_name']}','${wk[i]['btn_id']}','${wk[i]['profile_image']}','${wk[i]['id']}','${wk[i]['accepted_id']}')");
      }
    }
    await query();
  }

  static Future<void> addChat(wk) async {
    for (int i = 0; i < wk.length; i++) {
      List<Map> chat = await db.rawQuery(
          'SELECT * FROM ${DatabaseCreator.todoTable4} WHERE room_name=?',
          [wk[i]['sala']['room_name']]);
      print(chat.length);
      if (chat.isNotEmpty) {
      } else {
        var res = await db.rawInsert(
            "INSERT INTO ${DatabaseCreator.todoTable4} (chat_id,room_name,group_name,contract_name,last_msg,last_created,icon_chat)"
            " VALUES ('${wk[i]['sala']['id']}','${wk[i]['sala']['room_name']}','${wk[i]['sala']['group_name']}','${wk[i]['sala']['contract_name']}','${wk[i]['last']['msg']}','${wk[i]['last']['created']}','${wk[i]['sala']['group_icon']}')");
      }
    }
    await query();
    print(query());
  }

  static Future<void> syncTodoW(wk) async {
    var count = await db.rawDelete('DELETE FROM ${DatabaseCreator.todoTable1}');
    for (int i = 0; i < wk.length; i++) {
      var res = await db.rawInsert(
          "INSERT INTO ${DatabaseCreator.todoTable1} (first_name,last_name,btn_id,image, wk_id, accepted_id)"
          " VALUES ('${wk[i]['first_name']}','${wk[i]['last_name']}','${wk[i]['btn_id']}','${wk[i]['profile_image']}','${wk[i]['id']}','${wk[i]['accepted_id']}')");
      List<Map> worker = await db.rawQuery(
          'SELECT * FROM ${DatabaseCreator.todoTable3} WHERE worker_btnid=?',
          [wk[i]['btn_id']]);

      print(worker.length);
      if (worker.isNotEmpty) {
        var res = await db.rawUpdate(
            'UPDATE ${DatabaseCreator.todoTable3}  SET worker_name = ? AND worker_last = ?  WHERE worker_btnid = ?',
            [wk[i]['first_name'], wk[i]['last_name'], wk[i]['btn_id']]);
      } else {}
    }
    await query();
  }

  static Future<dynamic> addworker(btnid) async {
    DateTime now = DateTime.now();

    var res =
        await db.rawInsert("INSERT INTO ${DatabaseCreator.todoTable1} (btn_id)"
            " VALUES ('${btnid}')");

    var res1 = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable3} (worker_btnid,clock_type,verified)"
        " VALUES ('${btnid}','IN','FALSE')");
    print(res);
    await query();
    return res;
  }

  static Future<dynamic> updateWorkday() async {
    DateTime now = DateTime.now();

    var res = await db.rawUpdate(
        'UPDATE ${DatabaseCreator.todoTable2}  SET end = ?  WHERE id = ?',
        [now.toIso8601String(), '1']);
    await queryw();
  }

  static Future<dynamic> addWorkday() async {
    DateTime now = DateTime.now();

    var res = await db
        .rawInsert("INSERT INTO ${DatabaseCreator.todoTable2} (init,estatus)"
            " VALUES ('${now.toIso8601String()}','1')");
    await queryw();
  }

  static Future<dynamic> addClockIn(worker, name, last, btnid, initc) async {
    DateTime now = DateTime.now();

    var res = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable3} (worker,worker_name,worker_last,worker_btnid,clock_type,clock_in_start,message,verified)"
        " VALUES ('${worker}','${name}','${last}','${btnid}','IN','${initc}','CLOCKIN OFFLINE','FALSE')");
    print(res);
    await querywr();

    return res;
  }

  static Future<dynamic> addClockOut(worker, name, last, btnid, initc) async {
    DateTime now = DateTime.now();

    var res = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable3} (worker,worker_name,worker_last,worker_btnid,clock_type,clock_in_start,message,verified)"
        " VALUES ('${worker}','${name}','${last}','${btnid}','OUT','${initc}','CLOCKOT OFFLINE','FALSE')");
    print(res);
    await querywr();

    return res;
  }

  static Future<dynamic> addClocks(
      worker, name, last, btnid, initc, endc) async {
    DateTime now = DateTime.now();

    var resi = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable3} (worker,worker_name,worker_last,worker_btnid,clock_type,clock_in_start,message,verified)"
        " VALUES ('${worker}','${name}','${last}','${btnid}','IN','${initc}','CLOCKIN OFFLINE','FALSE')");

    var res = await db.rawInsert(
        "INSERT INTO ${DatabaseCreator.todoTable3} (worker,worker_name,worker_last,worker_btnid,clock_type,clock_in_start,message,verified)"
        " VALUES ('${worker}','${name}','${last}','${btnid}','OUT','${endc}','CLOCKOT OFFLINE','FALSE')");

    return res;
  }

  static Future<void> deleteWorkday(Config todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable2}
    WHERE ${DatabaseCreator.id} = ?
    ''';

    List<dynamic> params = [todo.id];
    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Delete todo', sql, null, result, params);
  }

  static Future<void> deleteTodo(Config todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?
    ''';

    List<dynamic> params = [todo.id];
    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Delete todo', sql, null, result, params);
  }

  static Future<void> updateTodo(Config todo, token, first_name, last_name,
      btn_id, email, image, role, id_type, doc_type, contact, address) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.token} = "${token}",
    ${DatabaseCreator.first_name} = "${first_name}",
        ${DatabaseCreator.last_name} = "${last_name}",
    ${DatabaseCreator.btn_id} = "${btn_id}",
    ${DatabaseCreator.email} = "${email}",
    ${DatabaseCreator.image} = "${image}",
    ${DatabaseCreator.role} = "${role}",
    ${DatabaseCreator.id_type} = "${id_type}",
    ${DatabaseCreator.doc_type} = "${doc_type}",
    ${DatabaseCreator.contact} = "${contact}",
    ${DatabaseCreator.addres} = "${address}"

    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateFirstLast(
      Config todo, first_name, last_name) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.first_name} = "${first_name}",
    ${DatabaseCreator.last_name} = "${last_name}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateModules(
      Config todo, clockin, clockut, expense, warning, role) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.clock_in_module} = "${clockin}",
    ${DatabaseCreator.clock_out_module} = "${clockut}",
    ${DatabaseCreator.expenses_module} = "${expense}",
    ${DatabaseCreator.warnings_module} = "${warning}",
    ${DatabaseCreator.role} = "${role}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateModulesN(Config todo, role) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.role} = "${role}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateContractDetail(
      Contract contract, id, name, temp) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable5}
    SET ${DatabaseCreator.contract_id} = "${id}",
    ${DatabaseCreator.contract_name} = "${name}",
    ${DatabaseCreator.contract_temp} = "${temp}"
    WHERE ${DatabaseCreator.id} = "1"
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  /*static Future<void> updateWorkdayIn(Workday workday, id, in_init, in_fin,
      out_init, out_fin, in_lo, out_lo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.workday_id} = "${id}",
    ${DatabaseCreator.clock_in_init} = "${in_init}",
    ${DatabaseCreator.clock_in_fin} = "${in_fin}",
    ${DatabaseCreator.clock_out_init} = "${out_init}",
    ${DatabaseCreator.clock_out_fin} = "${out_fin}",
    ${DatabaseCreator.clock_in_location} = "${in_lo}",
    ${DatabaseCreator.clock_out_location} = "${out_lo}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }*/

  static Future<void> updateWorkdayIn(
      Workday workday, id, in_init, in_lo, def_init) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.workday_id} = "${id}",
    ${DatabaseCreator.clock_in_init} = "${in_init}",
    ${DatabaseCreator.clock_in_location} = "${in_lo}",
    ${DatabaseCreator.default_init} = "${def_init}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayInL(id, def_init) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.default_init} = "${def_init}"
    WHERE ${DatabaseCreator.workday_id} = ${1}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateUltClock(id, clock) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.ult_clock} = "${clock}"
    WHERE ${DatabaseCreator.id} = ${1}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateHour(Workday workday, id, hour) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.id} = "${id}",
    ${DatabaseCreator.ult_clock} = "${hour}",
    WHERE ${DatabaseCreator.workday_id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayOutL(id, def_init) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.default_exit} = "${def_init}"
    WHERE ${DatabaseCreator.workday_id} = ${1}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayOut(
      Workday workday, out_init, out_lo, def_exit) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.clock_out_init} = "${out_init}",
    ${DatabaseCreator.clock_out_location} = "${out_lo}",
    ${DatabaseCreator.default_exit} = "${def_exit}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayInFin(Workday workday, in_fin) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.clock_in_fin} = "${in_fin}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayGuardado(Workday workday) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.workday_status} = "${1}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayFinalizado(Workday workday) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.workday_status} = "${0}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayOutFin(Workday workday, out_fin) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.clock_out_fin} = "${out_fin}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateWorkdayFin(Workday workday) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.workday_id} = "",
    ${DatabaseCreator.clock_in_init} = "",
    ${DatabaseCreator.clock_in_fin} = "",
    ${DatabaseCreator.clock_out_init} = "",
    ${DatabaseCreator.clock_out_fin} = "",
    ${DatabaseCreator.clock_in_location} = "",
    ${DatabaseCreator.clock_out_location} = "",
    ${DatabaseCreator.workday_status} = "",
    ${DatabaseCreator.workday_other} = "",
    ${DatabaseCreator.default_init} = "",
    ${DatabaseCreator.default_exit} = ""
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
    print('actualizo todo');
  }

  static Future<void> updateWorkdaySync(
      Workday workday,
      id,
      in_init,
      in_fin,
      out_init,
      out_fin,
      is_locate,
      out_locate,
      has_report,
      has_in,
      def_in,
      def_ex,
      has_out) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable6}
    SET ${DatabaseCreator.workday_id} = "${id}",
    ${DatabaseCreator.clock_in_init} = "${in_init}",
    ${DatabaseCreator.clock_in_fin} = "${in_fin}",
    ${DatabaseCreator.clock_out_init} = "${out_init}",
    ${DatabaseCreator.clock_out_fin} = "${out_fin}",
    ${DatabaseCreator.clock_in_location} = "${is_locate}",
    ${DatabaseCreator.workday_other} = "${has_report}",
    ${DatabaseCreator.has_clockin} = "${has_in}",
    ${DatabaseCreator.has_clockout} = "${has_out}",
    ${DatabaseCreator.clock_out_location} = "${out_locate}",
    ${DatabaseCreator.default_init} = "${def_in}",
    ${DatabaseCreator.default_exit} = "${def_ex}"
    WHERE ${DatabaseCreator.id} = ${workday.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateLang(lang) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.language} = "${lang}"
    WHERE ${DatabaseCreator.id} = ${1}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateImage(Config todo, image) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.image} = "${image}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateType(Config todo, type) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.id_type} = "${type}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateDoc(Config todo, doc) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.doc_type} = "${doc}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateAddrees(Config todo, address) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.addres} = "${address}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateContact(Config todo, contact) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.contact} = "${contact}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateRole(Config todo, role) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.role} = "${role}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateOffline(Config todo, offline) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.offline} = "${offline}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateContract(Config todo, contract) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.contract} = "${contract}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';

    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateONOffline(String offline) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.offline} = "${offline}"
    WHERE ${DatabaseCreator.id} = 1
    ''';

    final result = await db.rawUpdate(sql);
    print('offline on');
  }

  static Future<void> updateTodoSesion(Config todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.token} = "no"
    WHERE ${DatabaseCreator.id} = 1
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateTodoRole(Config todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.role} = ""
    WHERE ${DatabaseCreator.id} = 1
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateTodoContract(Config todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.contract} = ""
    WHERE ${DatabaseCreator.id} = 1
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  static Future<void> updateContractFull(Config todo) async {
    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.contract} = ""
    WHERE ${DatabaseCreator.id} = 1
    ''';
    final result = await db.rawUpdate(sql);
    print(result);
  }

  /**
   * 
   * 
   * $id INTEGER PRIMARY KEY UNIQUE ,'
        ' $contract_id INT ,$contract_name TEXT, $contract_temp TEXT
   * 
   * 
   */

  static Future<Object?> todosCount() async {
    final data = await db
        .rawQuery('''SELECT COUNT(*) FROM ${DatabaseCreator.todoTable}''');

    Object? count = data[0].values.elementAt(0);
    Object? idForNewItem = count;
    return idForNewItem;
  }
}
