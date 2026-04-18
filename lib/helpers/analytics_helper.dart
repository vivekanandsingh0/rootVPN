import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsHelper {
  // Replace with your actual PostHog API Key
  static const String _postHogApiKey = 'phc_sjG5rPJhtEfccAcZCEvRM2fBRYGYMD5etqNEgve4U92p';
  static const String _postHogHost = 'https://app.posthog.com';

  static Future<void> init() async {
    // PostHog initialization is often handled automatically if configured in manifest/info.plist
    // but you can also trigger manual configuration if needed.
  }

  static void logEvent(String eventName, {Map<String, Object>? properties}) {
    Posthog().capture(
      eventName: eventName,
      properties: properties,
    );
  }

  static void screenView(String screenName) {
    Posthog().screen(screenName: screenName);
  }

  static void identifyUser(String userId, {Map<String, Object>? userProperties}) {
    Posthog().identify(userId: userId, userProperties: userProperties);
  }

  // Specific VPN Events
  static void logVpnConnectionAttempt(String serverName, String country) {
    logEvent('vpn_connection_attempt', properties: {
      'server_name': serverName,
      'country': country,
    });
  }

  static void logVpnConnectionSuccess(String serverName, String country) {
    logEvent('vpn_connection_success', properties: {
      'server_name': serverName,
      'country': country,
    });
  }

  static void logVpnConnectionFailure(String serverName, String error) {
    logEvent('vpn_connection_failure', properties: {
      'server_name': serverName,
      'error': error,
    });
  }

  static void logAdImpression(String adType) {
    logEvent('ad_impression', properties: {
      'ad_type': adType,
    });
  }
}
