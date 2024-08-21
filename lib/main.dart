import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Printer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();

    // Bağlantı durumunu dinle
    bluetooth.onStateChanged().listen((state) {
      if (state == BlueThermalPrinter.CONNECTED) {
        setState(() {
          _isConnected = true;
        });
      } else if (state == BlueThermalPrinter.DISCONNECTED) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  Future<void> _getBluetoothDevices() async {
    try {
      // Cihazları tarar
      final List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _connectToDevice() async {
    if (_selectedDevice != null) {
      bool isConnected = await bluetooth.isConnected ?? false;

      if (isConnected) {
        await bluetooth.disconnect();
      }

      try {
        await bluetooth.connect(_selectedDevice!);
        setState(() {
          _isConnected = true;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _disconnectDevice() async {
    await bluetooth.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  void _printSample() async {
    if (_isConnected) {
      bluetooth.printNewLine();
      bluetooth.printCustom("Sample Print", 3, 1); // Custom text printing
      bluetooth.printNewLine();
      bluetooth.printQRcode("Bluetooth Printer Test", 150, 150, 1); // QR code printing
      bluetooth.printNewLine();
      bluetooth.printNewLine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Printer Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<BluetoothDevice>(
              hint: Text('Select Bluetooth Device'),
              value: _selectedDevice,
              items: _devices.map((device) {
                return DropdownMenuItem<BluetoothDevice>(
                  value: device,
                  child: Text(device.name ?? ""),
                );
              }).toList(),
              onChanged: (BluetoothDevice? device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConnected ? _disconnectDevice : _connectToDevice,
              child: Text(_isConnected ? 'Disconnect' : 'Connect'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConnected ? _printSample : null,
              child: Text('Print Sample'),
            ),
          ],
        ),
      ),
    );
  }
}
