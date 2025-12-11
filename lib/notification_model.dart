class NotificationModel {
  String selectedHour;
  String selectedDay;
  String selectedField;

  NotificationModel(this.selectedHour, this.selectedDay, this.selectedField);

  String notification() {
    return '$selectedHour, $selectedDay, $selectedField';
  }
}

class NotificationFromKeeperToUser {
  String notification() {
    return 'Bir randevu talebi geldi!';
  }
}