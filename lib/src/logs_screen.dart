import 'package:time_tracker/time_tracker.dart';

class LogScreen extends StatefulWidget {
  final title;
  @override
  _LogScreenState createState() => _LogScreenState();
  LogScreen({this.title});
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Logs for ${widget.title}"),
      ),
      body: FutureBuilder<List<Task>>(
        future: getActivityLog(widget.title, user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error!!!"));
          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.map<Widget>((e) {
              return Card(
                child: ListTile(
                  subtitle: Text(e.date),
                  title: Text(
                      "${e.duration["hours"].toString().padLeft(2, '0')}:${e.duration["minutes"].toString().padLeft(2, '0')}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
