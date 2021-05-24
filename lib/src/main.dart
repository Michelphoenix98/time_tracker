import 'package:time_tracker/time_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MainApp());
  });
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
            value: FirebaseAuth.instance.authStateChanges(), initialData: null),
      ],
      child: MaterialApp(
        title: 'Time Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AppScreen(),
      ),
    );
  }
}

class AppScreen extends StatefulWidget {
  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);
    bool loggedIn = user != null;
    if (!loggedIn)
      return LoginScreen();
    else {
      return FutureBuilder(
        future: isNewDay(user.uid),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            refreshDailyActivity(user.uid);
          }
          return HomeScreen();
        },
      );
    }
  }
}
