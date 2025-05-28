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
  final List<BluetoothDevice> _devices = [];
  List<BluetoothDevice> get avaiableDevices => _devices;
  late FlutterBlueClassic _flutterBlueClassic;
  FrequencimeterImpl(FlutterBlueClassic flutterBlueClassicPlugin) {
    _flutterBlueClassic = flutterBlueClassicPlugin;
    _flutterBlueClassic.adapterState.listen((event) {
      if (event == BluetoothAdapterState.on) {
        _disponibilityController.add(BluetoothDisponibility.avaiable);
        return;
      }
      _disponibilityController.add(BluetoothDisponibility.notAvaiable);
    });
    _flutterBlueClassic.scanResults.listen((event) {
      _devices.add(event);
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
    await _frequencyStreamController.close();
  }

  @override
  Future<void> initialize() async {}

  @override
  void startMeasure() {
    // TODO: implement startMeasure
  }
}
