import 'dart:developer' as developer;
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mqttServiceProvider = Provider<MqttService>((ref) => MqttService());

class MqttService {
  MqttServerClient? client;

  Future<void> connect() async {
    client = MqttServerClient('broker.hivemq.com', 'flutter_merchant_client_id');
    client!.port = 1883;
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;
    
    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_merchant_client')
        .withWillTopic('merchant/status')
        .withWillMessage('offline')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } on NoConnectionException catch (e) {
      developer.log('MQTT Exception: $e', name: 'MqttService');
      client!.disconnect();
    } on SocketException catch (e) {
      developer.log('MQTT SocketException: $e', name: 'MqttService');
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.subscribe('device/status', MqttQos.atLeastOnce);
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        developer.log('MQTT Received: topic=${c[0].topic}, payload=$pt', name: 'MqttService');
      });
    }
  }

  void publishPayment(String payload) {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      client!.publishMessage('merchant/payment', MqttQos.exactlyOnce, builder.payload!);
      developer.log('MQTT Published to merchant/payment: $payload', name: 'MqttService');
    } else {
      developer.log('MQTT Not connected - payment not published', name: 'MqttService');
    }
  }

  void onConnected() {
    developer.log('MQTT Connected', name: 'MqttService');
  }

  void onDisconnected() {
    developer.log('MQTT Disconnected', name: 'MqttService');
    // Add retry logic here if needed
  }

  void onSubscribed(String topic) {
    developer.log('MQTT Subscribed topic: $topic', name: 'MqttService');
  }
}
