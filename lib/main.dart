import 'package:b_shop/firebase_options.dart';
import 'package:b_shop/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main()async {
    WidgetsFlutterBinding.ensureInitialized();
 await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  await Hive.openBox("Theme");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  void changeTheme(ThemeMode themeMode){
   
    setState(() {
      _themeMode = themeMode;
    });
  }
  // This widget is the root of your application.
  ThemeMode _themeMode =Hive.box("Theme").isEmpty?ThemeMode.light: Hive.box("Theme").get("DarkMode")==0?
  ThemeMode.light:ThemeMode.dark;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Hive.openBox("Categories");
    Hive.openBox("UserData");
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      darkTheme: ThemeData.dark(),
      home: const Homepage(),
    );
  }
}
