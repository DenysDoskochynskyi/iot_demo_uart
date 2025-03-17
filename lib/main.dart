import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iot_demo_uart/manager/usb_manger/usb_manager.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<BaseUsbService>(create: (context) => UsbService()),
      Provider<UsbManager>(
          lazy: false,
          create: (context) =>
              UsbManager(Provider.of<BaseUsbService>(context, listen: false))),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  List<Widget> _receivedData = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _disconnect() async {
    await _subscription?.cancel();
    await _port?.close();
    setState(() {
      _port = null;
    });
  }

  Future<void> _clearList() async {
    setState(() {
      _receivedData = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<UsbManager>(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter USB Serial UART")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.2,
                child: StreamBuilder<List<UsbDevice>>(
                    stream: manager.device,
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? [];

                      return ListView(
                        children: data
                            .map(
                              (e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                    'Device name: ${e.deviceName} \nID: ${e.deviceName}'),
                              ),
                            )
                            .toList(),
                      );
                    }),
              ),
              ElevatedButton(
                onPressed: manager.selectDevice,
                child: const Text("Підключитися до першого пристрою"),
              ),
              ElevatedButton(
                onPressed: manager.refreshDeviceList,
                child: const Text("Оновити список девайсів"),
              ),
              ElevatedButton(
                onPressed: manager.dispose,
                child: const Text("Відключитися"),
              ),
              ElevatedButton(
                onPressed: _clearList,
                child: const Text("Очистити термінал"),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Відправити дані"),
                onSubmitted: manager.sendData,
              ),
              const SizedBox(height: 20),
              const Text("Отримані дані:"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => manager.sendData('ON'),
                    child: const Text("On"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => manager.sendData('OFF'),
                    child: const Text("Off"),
                  ),
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: _receivedData))),
            ],
          ),
        ),
      ),
    );
  }
}
