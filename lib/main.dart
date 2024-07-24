import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/utils/language.dart';
import 'package:worker/blocs/locale_bloc/locale_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'local/database_creator.dart';
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

  runApp(MultiProvider(providers: [
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
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            home: SelectLang(),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multilang App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, state) {
                return _buildLanguageSwitch(
                  context,
                  Theme.of(context),
                  state,
                );
              },
            ),
            Text(
              l10n.hours,
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitch(
    BuildContext context,
    ThemeData theme,
    LocaleState state,
  ) {
    return TextButton(
      onPressed: () {
        context.read<LocaleBloc>().add(
              ChangeLanguage(
                state.selectedLanguage == Language.english
                    ? Language.spanish
                    : Language.english,
              ),
            );
      },
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: "EN",
            style: TextStyle(
              fontSize: 18,
              color: state.selectedLanguage == Language.english
                  ? Colors.blue
                  : Colors.black,
            ),
          ),
          const TextSpan(
            text: " | ",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "ES",
            style: TextStyle(
              fontSize: 18,
              color: state.selectedLanguage == Language.spanish
                  ? Colors.blue
                  : Colors.black,
            ),
          ),
        ]),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
