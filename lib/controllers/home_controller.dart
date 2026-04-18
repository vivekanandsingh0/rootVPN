import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/ad_helper.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';
import '../helpers/analytics_helper.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;

  final vpnState = VpnEngine.vpnDisconnected.obs;

  @override
  void onInit() {
    super.onInit();
    VpnEngine.vpnStageSnapshot().listen((event) {
      vpnState.value = event;
      
      // Log connection results
      if (event == VpnEngine.vpnConnected) {
        AnalyticsHelper.logVpnConnectionSuccess(vpn.value.countryLong, vpn.value.countryShort);
      } else if (event == VpnEngine.vpnDisconnected && vpnState.value != VpnEngine.vpnDisconnected) {
          // This might be a failure if it was connecting and now disconnected
      }
    });
  }

  void connectToVpn() async {
    if (vpn.value.openVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      final rawConfig = Utf8Decoder().convert(data);

      // Fix and Clean Config for better reliability
      final config = _fixConfig(rawConfig, vpn.value.ip);

      final vpnConfig = VpnConfig(
          country: vpn.value.countryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);

      AdHelper.showInterstitialAd(onComplete: () async {
        AnalyticsHelper.logVpnConnectionAttempt(vpn.value.countryLong, vpn.value.countryShort);
        await VpnEngine.startVpn(vpnConfig);
      });
    } else {
      await VpnEngine.stopVpn();
    }
  }

  String _fixConfig(String config, String ip) {
    // 1. Normalize line endings and remove comments/empty lines
    var lines = config.replaceAll('\r', '').split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    // 2. Remove flags we want to override or that cause issues with older/forked binaries
    lines.removeWhere((l) => 
        l.startsWith('#') || l.startsWith(';') ||
        l.startsWith('cipher') || l.startsWith('auth') || l.startsWith('tls-cipher') ||
        l.startsWith('verb') || l.startsWith('resolv-retry') || l.startsWith('nobind') ||
        l.startsWith('persist-key') || l.startsWith('persist-tun') || 
        l.startsWith('handshake-window') || l.startsWith('connect-retry') || 
        l.startsWith('float') || l.startsWith('data-ciphers')
    );

    // 3. Add broadly compatible security and MTU settings
    lines.addAll([
        'resolv-retry infinite',
        'nobind',
        'persist-key',
        'persist-tun',
        'cipher AES-128-CBC',
        'auth SHA1',
        'verb 3',
        'auth-nocache',
        'tun-mtu 1500',
        'mssfix 1450',
        'tls-cipher DEFAULT'
    ]);

    return lines.join('\n');
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.blue;

      case VpnEngine.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  // vpn button text
  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Tap to Connect';

      case VpnEngine.vpnConnected:
        return 'Disconnect';

      case VpnEngine.vpnWaitConnection:
        return 'Waiting...';

      case VpnEngine.vpnAuthenticating:
        return 'Authenticating...';

      case VpnEngine.vpnConnecting:
        return 'Connecting...';

      case VpnEngine.vpnNoConnection:
        return 'No Network';

      case VpnEngine.vpnDenied:
        return 'Denied';

      default:
        return 'Connecting...';
    }
  }
}
