import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'auth_model.dart';

class Device {
  String uuid;
  String name;
  int icon;
  String status;
  bool isOn;
  String schedule;

  Device({
    required this.uuid,
    required this.name,
    required this.icon,
    required this.status,
    required this.isOn,
    required this.schedule,
  });
}

class EnhederModel with ChangeNotifier {
  final AuthModel auth;
  MqttServerClient? client;

  ValueNotifier<bool> isInitialized = ValueNotifier(false);

  EnhederModel._(this.auth) {
    initializeClient();
  }

  factory EnhederModel({required AuthModel auth}) {
    final model = EnhederModel._(auth);
    return model;
  }

  updateInfo(String uuid, {String? name, int? codePoint}) async {
    String jsonPayload = "";
    if (name == null && codePoint == null) {
      throw "Error in Device.updateInfo: Neither name or icon defined";
    } else if (name != null) {
      jsonPayload = jsonEncode({
        "info": "name",
        "name": name,
      });
    } else if (codePoint != null) {
      jsonPayload = jsonEncode({
        "info": "icon",
        "icon": codePoint,
      });
    }
    final response = await http.patch(
      Uri.parse('http://${auth.ip}:8080/device/$uuid/info'),
      headers: {
        "Authorization": "Bearer ${auth.jwt}",
        "Content-Type": "application/json",
      },
      body: jsonPayload,
    );

    if (response.statusCode != 200) throw "Error in updateInfo http request, status ${response.statusCode}";
    notifyListeners();
  }

  updateSchedule(String uuid, String newSchedule) async {
    final response = await http.post(
      Uri.parse('http://${auth.ip}:8080/device/$uuid/schedule'),
      headers: {
        "Authorization": "Bearer ${auth.jwt}",
        "Content-Type": "application/json",
      },
      body: newSchedule,
    );

    if (response.statusCode != 200) throw "Error in updateSchedule http request, status ${response.statusCode}";
    notifyListeners();
  }

  Future<void> initializeClient() async {
    await auth.tryAutoLogin();
    client = await connectToMqttBroker();
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      await fetchAndSubscribeDevices();
      isInitialized.value = true;
    }
  }

  List<Device> _devices = [];

  List<Device> get devices => _devices;

  Future<void> fetchAndSubscribeDevices() async {
    await fetchDevices();
    for (Device device in _devices) {
      final statusTopic = 'device/${device.uuid}/status';
      final stateTopic = 'device/${device.uuid}/state';

      client?.subscribe(statusTopic, MqttQos.atLeastOnce);
      client?.subscribe(stateTopic, MqttQos.atLeastOnce);
    }
  }

  Future<void> fetchDevices() async {
    final response = await http.get(Uri.parse('http://${auth.ip}:8080/user/devices/'), headers: {
      "Authorization": "Bearer ${auth.jwt}",
    });
    if (response.statusCode == 200) {
      final List<dynamic> devicesJson = json.decode(response.body);
      _devices = devicesJson.map((device) {
        return Device(
            uuid: device['uuid'],
            name: device['name'],
            icon: device['icon'],
            status: device['status'],
            isOn: (device['is_on'] == 0) ? false : true,
            schedule: device['schedule']);
      }).toList();
      notifyListeners();
    }
  }

  Future<MqttServerClient> connectToMqttBroker() async {
    // Set up the MQTT client.
    final client = MqttServerClient(auth.ip, 'flutter_client_${auth.username}_${DateTime.now().millisecondsSinceEpoch}');

    // Configure the client's options.
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onAutoReconnect = onAutoReconnect;
    client.onSubscribed = onSubscribed;
    client.onUnsubscribed = onUnsubscribed;
    // client.pongCallback = pong;

    // Set up the connection message with the username and password.
    final connMessage = MqttConnectMessage().authenticateAs('admin', 'bAWrLf7pHupr3fraCh0sob9Swa0E1rlk').startClean();
    client.connectionMessage = connMessage;

    // Connect to the MQTT broker.
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    // Check if the connection is successful.
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected to MQTT broker');
    } else {
      print('Connection failed - status ${client.connectionStatus}');
      client.disconnect();
    }

    // Listen for messages on the subscribed topics.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      final topicParts = c[0].topic.split('/');
      final String uuid = topicParts[1];

      final int deviceIndex = _devices.indexWhere((d) => d.uuid == uuid);

      if (topicParts[2] == "status") {
        _devices[deviceIndex].status = payload;
      } else if (topicParts[2] == "state") {
        final bool val = (payload == "on");
        _devices[deviceIndex].isOn = val;
      }
      notifyListeners();
    });

    return client;
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onAutoReconnect() {
    print('Auto reconnected to MQTT broker');
  }

  void onSubscribed(String? topic) {
    print('Subscribed to topic $topic');
  }

  void onUnsubscribed(String? topic) {
    print('Subscribed to topic $topic');
  }

  void pong() {
    print('Pong received from MQTT broker');
  }
}
