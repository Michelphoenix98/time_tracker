import 'package:time_tracker/time_tracker.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Tracker"),
      ),
      body: Center(
        child: RawMaterialButton(
          fillColor: Colors.red,
          hoverColor: Colors.redAccent,
          splashColor: Colors.redAccent.shade200,
          child: Icon(Icons.login),
          onPressed: () async {
            await FirebaseAuth.instance.signInAnonymously();
            var user = Provider.of<User?>(context, listen: false);
            createAccount(user!.uid);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (context) => HomeScreen()));
          },
        ),
      ),
    );
  }
}
