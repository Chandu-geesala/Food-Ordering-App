import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart'; // Import for Flutter 3.0+ with launchUrl

class MapUtils {
  MapUtils._();

  static Future<void> lauchMapFromSourceToDestination(double sourceLat, double sourceLng, double destinationLat, double destinationLng) async {
    final mapOptions = [
      'saddr=$sourceLat,$sourceLng',
      'daddr=$destinationLat,$destinationLng',
      'dir_action=navigate'
    ].join('&');

    final mapUrl = 'https://www.google.com/maps?$mapOptions';

    if (await canLaunchUrlString(mapUrl)) { // Use canLaunchUrlString for better compatibility
      await launchUrlString(mapUrl); // Use launchUrlString for Flutter 3.0+
    } else {
      throw 'Could not launch $mapUrl';
    }
  }
}
