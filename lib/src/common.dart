String getDate() {
  DateTime now = new DateTime.now();
  String dateToday = "${now.year}-${now.month}-${now.day}";
  return dateToday;
}
