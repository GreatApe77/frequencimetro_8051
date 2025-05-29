import 'package:frequencimetro_8051/disposable.dart';

enum BluetoothDisponibility { avaiable, notAvaiable }

enum BluetoothDeviceConnection { connected, disconnected }

abstract class Frequencimeter implements Disposable {
  Stream<int> get currentFrequency;
  void startMeasure();
  Stream<BluetoothDeviceConnection> get connectionStatus;
  Stream<BluetoothDisponibility> get bluetoothDisponibility;
  void turnOnBluetooth();
}
