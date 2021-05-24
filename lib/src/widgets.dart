import 'package:time_tracker/time_tracker.dart';

class AddActivityButton extends StatefulWidget {
  @override
  _AddActivityButtonState createState() => _AddActivityButtonState();
}

class _AddActivityButtonState extends State<AddActivityButton> {
  bool showFab = true;
  @override
  Widget build(BuildContext context) {
    return showFab
        ? FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              var bottomSheetController = showBottomSheet(
                  context: context, builder: (context) => BottomSheetWidget());
              showFloatingActionButton(false);
              bottomSheetController.closed.then((value) {
                showFloatingActionButton(true);
              });
            },
          )
        : Container();
  }

  void showFloatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
}

class BottomSheetWidget extends StatefulWidget {
  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  TextEditingController activityController = new TextEditingController();
  GlobalKey<FormState> key = GlobalKey<FormState>();
  Duration _duration = Duration(hours: 0, minutes: 0);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 10, color: Colors.grey[300]!, spreadRadius: 5)
              ],
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: key,
                  child: TextFormField(
                    validator: (field) {
                      if (field!.isEmpty) return "Field cannot be empty";
                      return null;
                    },
                    controller: activityController,
                    decoration: InputDecoration(
                      hintText: 'Activity',
                      border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
              DurationPicker(
                duration: _duration,
                onChange: (val) {
                  setState(() => _duration = val);
                },
                snapToMins: 5.0,
              ),
              RawMaterialButton(
                  fillColor: Colors.blue,
                  hoverColor: Colors.blueAccent,
                  splashColor: Colors.blueAccent.shade200,
                  child: Icon(Icons.save),
                  onPressed: () {
                    _onPressed();
                  }),
            ]),
          )
        ],
      ),
    );
  }

  void _onPressed() async {
    String dateToday = getDate();
    var user = Provider.of<User?>(context, listen: false);
    if (key.currentState!.validate()) {
      await registerActivity({
        activityController.text: {
          'hours': _duration.inHours,
          'minutes': _duration.inMinutes % 60
        },
      }, user!.uid);
      addActivityLog(
          Task(
            date: "$dateToday",
            duration: {
              'hours': _duration.inHours,
              'minutes': _duration.inMinutes % 60
            },
          ),
          activityController.text,
          user.uid);
      Navigator.of(context).pop();
    }
  }
}
