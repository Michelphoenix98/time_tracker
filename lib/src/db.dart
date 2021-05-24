import 'package:time_tracker/time_tracker.dart';

///This function should be called as soon as the user is signed in
///it creates a document named as [uid] under a collection 'users'
///the document is initialized with [uid] which is a [String],
///[activities], which is a [Map] and [date], which is another [String].
Future<void> createAccount(String uid) {
  String dateToday = getDate();
  return FirebaseFirestore.instance.collection('users').doc('$uid').set({
    'uid': '$uid',
    'activities': {}, //was []
    'date': dateToday,
  });
}

///This function, as its name suggests, compares the current date with the date recorded in the
///document named [uid]
Future<bool> isNewDay(String uid) {
  String dateToday = getDate();
  return FirebaseFirestore.instance
      .collection('users')
      .doc('$uid')
      .get()
      .then((value) {
    if (dateToday == value.data()!["date"])
      return false;
    else
      return true;
  });
}

///If the value of isNewDay is true then this function is called to
///reset/refresh the values of the [activities] map of the document named [uid] to 0.
///as the document named [uid] contains denormalized data from corresponding documents
///in the activityLog collection, it is important that this method be invoked before
///displaying the values stored in the [activities] map.
Future<void> refreshDailyActivity(String uid) {
  String dateToday = getDate();
  FirebaseFirestore.instance
      .collection('users')
      .doc('$uid')
      .get()
      .then((value) {
    value.data()!["activities"].keys.forEach((activity) {
      FirebaseFirestore.instance.collection('users').doc('$uid').update({
        'activities.$activity': {'hours': 0, 'minutes': 0},
      });
    });
  });
  return FirebaseFirestore.instance.collection('users').doc('$uid').update({
    'date': dateToday,
  });
}

///This function is used to register a new activity.
///It modifies the document named [uid] of the 'users' collection, specifically the [activities] field of
///the document. It adds the newly created activity as a key that has its corresponding value of a map that
///contains two other fields, namely [hours] and [minutes].
Future<void> registerActivity(Map<String, dynamic> activity, String uid) async {
  await FirebaseFirestore.instance.collection('users').doc('$uid').update({
    'activities.${activity.keys.toList()[0]}':
        activity[activity.keys.toList()[0]]
  });
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('$uid')
        .collection('activityLog')
        .doc('${activity.keys.toList()[0]}')
        .update({
      //the reason update is called is to prevent an overwrite in case the document already exists.
      'activityName': activity.keys.toList()[0],
    });
  } catch (e) {
    //and if the document does not exist we calmly resort to handling the exception thrown in the try block
    //and go ahead with the creation of a new document.
    return FirebaseFirestore.instance
        .collection('users')
        .doc('$uid')
        .collection('activityLog')
        .doc('${activity.keys.toList()[0]}')
        .set({'activityName': activity.keys.toList()[0], 'log': {}});
  }
}

///As the name suggests, this function is used to fetch a stream of the document named [uid]
///which corresponds to the signed in user.
Stream<DocumentSnapshot> getActivityList(String uid) {
  return FirebaseFirestore.instance.collection('users').doc('$uid').snapshots();
}

///This method is usually called right after the registerActivity method.
///It is used to set up a log of the user's duration values recorded daily
///and later be fetched and displayed.
Future<void> addActivityLog(Task task, String activity, String uid) {
  String dateToday = getDate();
  // DateTime date = new DateTime(now.year, now.month, now.day).;
  return FirebaseFirestore.instance
      .collection('users')
      .doc('$uid')
      .collection('activityLog')
      .doc('$activity')
      .update({
    'log.$dateToday': task.toMap(),
  });
}

///As the name suggests it used to remove the entry of an activity from the [activities] field
///of the document named [uid]
///of the collection 'users' as well as the document named [activity] from the activityLog collection.
Future<void> removeActivity(String activity, String uid) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc('$uid')
      .collection('activityLog')
      .doc('$activity')
      .delete();
  return FirebaseFirestore.instance.collection('users').doc('$uid').update({
    'activities.$activity': FieldValue.delete(),
  });
}

///This function is used to fetch data from the document named [activity]
///of the activityLog collection. The [log] field from the document is accessed and
///transformed into a List of the [Task] class.
Future<List<Task>> getActivityLog(String activity, String uid) async {
  var snap = await FirebaseFirestore.instance
      .collection('users')
      .doc('$uid')
      .collection('activityLog')
      .doc('$activity')
      .get();

  List<Task> task = snap.data()!["log"].keys.map<Task>((e) {
    return Task.fromMap(snap.data()!["log"][e]);
  }).toList();
  task.sort((m1, m2) {
    var r = m1.date.compareTo(m2.date);
    return -r;
  });

  return task;
}
