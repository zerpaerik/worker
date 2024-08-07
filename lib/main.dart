import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/utils/language.dart';
import 'package:worker/blocs/locale_bloc/locale_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:worker/widgets/login/login_new.dart';
import 'package:worker/widgets/login/preview.dart';

import 'local/database_creator.dart';
import 'model/config.dart';
import 'model/user.dart';
import 'providers/auth.dart';
import 'providers/certifications.dart';
import 'providers/chat.dart';
import 'providers/crew.dart';
import 'providers/expenses.dart';
import 'providers/offer_job.dart';
import 'providers/offline.dart';
import 'providers/travel.dart';
import 'providers/users.dart';
import 'providers/warnings.dart';
import 'providers/workday.dart';
import 'widgets/select_language/select.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  SharedPreferences type = await SharedPreferences.getInstance();

  var status = prefs.getBool('isLoggedIn') ?? false;
  var image = prefs.getBool('isImage') ?? false;
  var address = prefs.getBool('isAddres') ?? false;
  var health = prefs.getBool('isHealth') ?? false;
  var contact = prefs.getBool('isContact') ?? false;
  var id_type = prefs.getBool('isIdType') ?? false;
  var is_business = prefs.getBool('isBusiness') ?? false;
  var doc = prefs.getBool('isDoc') ?? false;
  var id_number_type = prefs.getBool('id_number_type') ?? false;
  var id_image_type = prefs.getBool('id_image_type') ?? false;
  var typee = type.getString('type') ?? 'no';

  runApp(MultiProvider(
      providers: [
        BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Users(),
        ),
        ChangeNotifierProvider.value(
          value: Certifications(),
        ),
        ChangeNotifierProvider.value(
          value: OfferJob(),
        ),
        ChangeNotifierProvider.value(
          value: WorkDay(),
        ),
        ChangeNotifierProvider.value(
          value: ExpensesP(),
        ),
        ChangeNotifierProvider.value(
          value: TravelProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ChatProvider(),
        ),
        ChangeNotifierProvider.value(
          value: OfflineProvider(),
        ),
        ChangeNotifierProvider.value(
          value: WarningsProvider(),
        ),
        ChangeNotifierProvider.value(
          value: CrewProvider(),
        ),
      ],
      child: MyApp(
        token: '1111',
      )));
}

class MyApp extends StatefulWidget {
  String token;

  MyApp({required this.token});
  @override
  State<MyApp> createState() => _MyAppState(token);
}

class _MyAppState extends State<MyApp> {
  Config? config;
  String? token;
  _MyAppState(this.token);
  String? tok = '';

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      config = todo;
    });
    return todo;
  }

  @override
  void initState() {
    getToken();
    getTodo(1);
    super.initState();
  }

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');

    setState(() {
      tok = stringValue;
    });
    return stringValue;
  }

  @override
  Widget build(BuildContext context) {
    print('token');
    print(tok);
    return MultiProvider(
      providers: [
        BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Users(),
        ),
        ChangeNotifierProvider.value(
          value: Certifications(),
        ),
        ChangeNotifierProvider.value(
          value: OfferJob(),
        ),
        ChangeNotifierProvider.value(
          value: WorkDay(),
        ),
        ChangeNotifierProvider.value(
          value: ExpensesP(),
        ),
        ChangeNotifierProvider.value(
          value: TravelProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ChatProvider(),
        ),
        ChangeNotifierProvider.value(
          value: OfflineProvider(),
        ),
        ChangeNotifierProvider.value(
          value: WarningsProvider(),
        ),
        ChangeNotifierProvider.value(
          value: CrewProvider(),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: state.selectedLanguage.localeValue,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: ThemeData(
              fontFamily: 'Montserrat',
            ),
            home: config == null
                ? SelectLang()
                : tok == '' || tok == null || tok == 'label'
                    ? const PreviewAccount()
                    : DashboardHome(noti: false, data: {}),
          );
        },
      ),
    );
  }
}
