import 'package:time_tracker/time_tracker.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${user!.uid}"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                    builder: (context) => LoginScreen()));
              })
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: getActivityList(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());

              if (snapshot.data!.exists) {
                List<dynamic> elements =
                    snapshot.data!["activities"].keys.toList();
                elements.sort((m1, m2) {
                  var r1 = snapshot.data!["activities"][m1]["hours"] * 60 +
                      snapshot.data!["activities"][m1]["minutes"];
                  var r2 = snapshot.data!["activities"][m2]["hours"] * 60 +
                      snapshot.data!["activities"][m2]["minutes"];
                  var c = r1 - r2;

                  return -c;
                });
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: elements.map<Widget>((value) {
                      return Card(
                        child: ListTile(
                          title: Text(value),
                          subtitle: Text(
                              "${snapshot.data!["activities"][value]["hours"].toString().padLeft(2, '0')}:"
                              "${snapshot.data!["activities"][value]["minutes"].toString().padLeft(2, '0')}"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => LogScreen(
                                  title: value,
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Are you sure?"),
                                    content:
                                        Text("You cannot undo this process"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          removeActivity(value, user.uid);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Yes"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("No"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
      floatingActionButton: AddActivityButton(),
    );
  }
}
