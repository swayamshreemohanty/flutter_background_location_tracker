import 'package:intl/intl.dart';

class FormatDate {
  static String selectedDateYYYYMMDD(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String date(String date) =>
      DateFormat.yMMMd('en_US').format(DateTime.parse(date));

  static DateTime convertTimeToAMPMDate({required String rawTime}) =>
      DateFormat("HH:mm").parse(rawTime);

  static String convertDateTimeToAMPMDateWithSeconds(
          {required DateTime dateTime}) =>
      DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);

  static String convertTimeToAMPM({required String rawTime}) =>
      DateFormat.jm().format(DateFormat("HH:mm:ss")
          .parse(rawTime)); //ex: convert from 10:45:00 to 10:45 AM

  static String convertTimeFromAMPM({required String rawTime}) =>
      DateFormat("HH:mm:ss").format(DateFormat.jm()
          .parse(rawTime)); //ex: convert from 10:45 AM to 10:45:00

  static String convertToTimeFromEpoch({required String rawTimeInSeconds}) =>
      DateFormat().add_jm().format(
            DateTime.fromMillisecondsSinceEpoch(
              (int.tryParse(rawTimeInSeconds) ?? 0) *
                  1000, //*1000 is to convert seconds to milli-seconds
            ),
          ); //ex: convert from seconds to june 21, 2022 fromat

  static String convertToDateJmFromEpoch({required String rawTimeInSeconds}) =>
      DateFormat().add_yMMMd().format(
            DateTime.fromMillisecondsSinceEpoch(
              (int.tryParse(rawTimeInSeconds) ?? 0) *
                  1000, //*1000 is to convert seconds to milli-seconds
            ),
          ); //ex: convert from seconds to 8:00 am fromat

  static DateTime convertEpochToDateTime({required String rawTimeInSeconds}) =>
      DateTime.fromMillisecondsSinceEpoch(
        (int.tryParse(rawTimeInSeconds) ?? 0) * 1000,
      );
}
