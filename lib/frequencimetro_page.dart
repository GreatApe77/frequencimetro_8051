import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:frequencimetro_8051/frequencimeter.dart';
import 'package:frequencimetro_8051/frequencimeter_impl.dart';

class FrequencimetroPage extends StatefulWidget {
  const FrequencimetroPage({super.key});

  @override
  State<FrequencimetroPage> createState() => _FrequencimetroPageState();
}

class _FrequencimetroPageState extends State<FrequencimetroPage> {
  final _frequencimeterBluetooth = FrequencimeterImpl(FlutterBlueClassic());
  bool _isThereBluetooth = false;
  bool _isConnected = false;
  bool _isScanning = false;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    _frequencimeterBluetooth.bluetoothDisponibility.listen((event) {
      if (!mounted) return;
      if (event == BluetoothDisponibility.avaiable) {
        setState(() {
          _isThereBluetooth = true;
        });
        return;
      }
      setState(() {
        _isThereBluetooth = false;
      });
    });
    _frequencimeterBluetooth.avaiableDevices.listen((event) {
      debugPrint('RECEBEU EVENTO');
      if (!mounted) return;
      setState(() {
        _devices.add(event);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _frequencimeterBluetooth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThereBluetooth) {
      return Scaffold(
        body: Center(
          child: FilledButton.icon(
            icon: Icon(Icons.bluetooth),
            iconAlignment: IconAlignment.end,
            onPressed: () => _frequencimeterBluetooth.turnOnBluetooth(),
            label: Text('Habilitar bluetooth'),
          ),
        ),
      );
    }
    if (!_isConnected) {
      return Scaffold(
        appBar: AppBar(
          
          title: Text('Dispositivos'),
          actions: [
            _isScanning
                ? TextButton(
                  onPressed: () {
                    _frequencimeterBluetooth.stopScan();
                    setState(() {
                      _isScanning = false;
                      _devices.clear();
                    });
                  },
                  child: Text('Parar de escanear'),
                )
                : TextButton(
                  onPressed: () {
                    _frequencimeterBluetooth.scan();
                    setState(() {
                      _isScanning = true;
                    });
                  },
                  child: Text('Escanear dispositivos'),
                ),
          ],
        ),
        body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                '${_devices[index].name ?? 'Dispositivo sem nome'} (${_devices[index].address})',
              ),
              onTap: () {},
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Frequencímetro')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('700000 Hz', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 20),
            FilledButton(onPressed: () {}, child: Text('Realizar medição')),
            //
          ],
        ),
      ),
    );
  }
}
