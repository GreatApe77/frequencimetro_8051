import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:frequencimetro_8051/frequencimeter.dart';

class FrequencimeterImpl implements Frequencimeter {
  final _frequencyStreamController = StreamController<int>.broadcast();

  final _isMeasuringStatusStreamController = StreamController<bool>.broadcast();
  final _disponibilityController =
      StreamController<BluetoothDisponibility>.broadcast();
  final _connectionController =
      StreamController<BluetoothDeviceConnection>.broadcast();

  BluetoothDevice? _hc05device;

  BluetoothConnection? _bluetoothConnection;

  late FlutterBlueClassic _flutterBlueClassic;

  StreamSubscription? _hc05StreamSub;

  final List<int> _frequencyBytes = [];

  FrequencimeterImpl(FlutterBlueClassic flutterBlueClassicPlugin) {
    _flutterBlueClassic = flutterBlueClassicPlugin;
    _flutterBlueClassic.adapterStateNow.then(
      (state) => _handleDisponibilityState(state),
    );
    _flutterBlueClassic.adapterState.listen(_handleDisponibilityState);
  }

  Stream<BluetoothDevice> get avaiableDevices =>
      _flutterBlueClassic.scanResults.asBroadcastStream();

  @override
  Stream<BluetoothDisponibility> get bluetoothDisponibility =>
      _disponibilityController.stream;

  @override
  Stream<BluetoothDeviceConnection> get connectionStatus =>
      _connectionController.stream;

  @override
  Stream<int> get currentFrequency => _frequencyStreamController.stream;

  Stream<bool> get isMeasuringStatusStream =>
      _isMeasuringStatusStreamController.stream;

  Future<void> connect() async {
    if (_hc05device == null) throw Exception('Dispositivo não foi escolhido');
    try {
      _bluetoothConnection = await _flutterBlueClassic.connect(
        _hc05device!.address,
      );
      if (_bluetoothConnection == null) {
        _connectionController.add(BluetoothDeviceConnection.disconnected);
        return;
      }
      _connectionController.add(BluetoothDeviceConnection.connected);
      _subscribeToDeviceEvents();
    } catch (e) {
      _connectionController.add(BluetoothDeviceConnection.disconnected);
    }
  }

  @override
  Future<void> dispose() async {
    _hc05StreamSub?.cancel();
    _disponibilityController.close();
    _frequencyStreamController.close();
    _connectionController.close();
    _isMeasuringStatusStreamController.close();
    _bluetoothConnection?.finish();
  }

  void scan() {
    _flutterBlueClassic.startScan();
  }

  void setDevice(BluetoothDevice bluetoothDevice) {
    _hc05device = bluetoothDevice;
  }

  @override
  void startMeasure() {
    final dataToSend = ascii.encode('#');
    print(dataToSend);
    _bluetoothConnection?.output.add(dataToSend);
    _isMeasuringStatusStreamController.add(true);
  }

  void stopScan() {
    _flutterBlueClassic.stopScan();
  }

  @override
  void turnOnBluetooth() {
    _flutterBlueClassic.turnOn();
  }

  void _handleDisponibilityState(BluetoothAdapterState state) {
    if (state == BluetoothAdapterState.on) {
      _disponibilityController.add(BluetoothDisponibility.avaiable);
      return;
    }
    _disponibilityController.add(BluetoothDisponibility.notAvaiable);
  }

  void _subscribeToDeviceEvents() {
    _hc05StreamSub =
        _bluetoothConnection!.input!.listen((event) {
            print('Chegou Byte:');
            print(event);
            if (_frequencyBytes.length == 1) {
              _frequencyBytes.add(event.first);
              int mostSignificantByte = _frequencyBytes.first;
              int lessSificantByte = _frequencyBytes.last;
              int frequencyValue = _joinBytes(
                mostSignificantByte,
                lessSificantByte,
              );

              print('Valor da frequencia: $frequencyValue');
              _isMeasuringStatusStreamController.add(false);
              _frequencyStreamController.add(frequencyValue);
              _frequencyBytes.clear();
            } else {
              _frequencyBytes.add(event.first);
            }
          })
          ..onError((_) {
            _connectionController.add(BluetoothDeviceConnection.disconnected);
          })
          ..onDone(() {
            _connectionController.add(BluetoothDeviceConnection.disconnected);
          });
  }

  int _joinBytes(int a, int b) {
    return (a << 8) | b;
  }
}
