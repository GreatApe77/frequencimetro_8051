import 'dart:async';

import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:frequencimetro_8051/frequencimeter.dart';
import 'package:frequencimetro_8051/initializable.dart';

class FrequencimeterImpl implements Frequencimeter, Initializable {
  final _frequencyStreamController = StreamController<int>.broadcast();

  final _disponibilityController =
      StreamController<BluetoothDisponibility>.broadcast();

  final _connectionController =
      StreamController<BluetoothDeviceConnection>.broadcast();

  bool _isMeasuring = false;

  BluetoothDevice? _hc05device;

  BluetoothConnection? _bluetoothConnection;

  Stream<BluetoothDevice> get avaiableDevices =>
      _flutterBlueClassic.scanResults.asBroadcastStream();

  late FlutterBlueClassic _flutterBlueClassic;

  StreamSubscription? _hc05StreamSub;

  FrequencimeterImpl(FlutterBlueClassic flutterBlueClassicPlugin) {
    _flutterBlueClassic = flutterBlueClassicPlugin;
    _flutterBlueClassic.adapterState.listen((event) {
      if (event == BluetoothAdapterState.on) {
        _disponibilityController.add(BluetoothDisponibility.avaiable);
        return;
      }
      _disponibilityController.add(BluetoothDisponibility.notAvaiable);
    });
  }

  @override
  Stream<BluetoothDisponibility> get bluetoothDisponibility =>
      _disponibilityController.stream;

  @override
  Stream<BluetoothDeviceConnection> get connectionStatus =>
      _connectionController.stream;

  @override
  Stream<int> get currentFrequency => _frequencyStreamController.stream;

  @override
  bool get isMeasuring => _isMeasuring;

  @override
  Future<void> dispose() async {
    _hc05StreamSub?.cancel();
    _bluetoothConnection?.finish();
    await _frequencyStreamController.close();
    await _connectionController.close();
  }

  @override
  Future<void> initialize() async {}

  @override
  void startMeasure() {
    // TODO: implement startMeasure
  }

  @override
  void turnOnBluetooth() {
    _flutterBlueClassic.turnOn();
  }

  void setDevice(BluetoothDevice bluetoothDevice) {
    _hc05device = bluetoothDevice;
  }

  void scan() {
    _flutterBlueClassic.startScan();
  }

  void stopScan() {
    _flutterBlueClassic.stopScan();
  }

  @override
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

  void _subscribeToDeviceEvents() {
    _hc05StreamSub = _bluetoothConnection!.input!.listen((event) {
      print('RECEBEU DADOS');
    });
  }
}
