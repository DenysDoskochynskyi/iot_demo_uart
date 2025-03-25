import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo_uart/feature/cubit/usb_cubit.dart';
import 'package:iot_demo_uart/manager/usb_manger/usb_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<BaseUsbService>(create: (context) => UsbService()),
      Provider<UsbManager>(
          lazy: false,
          create: (context) =>
              UsbManager(Provider.of<BaseUsbService>(context, listen: false))),
    ],
    child: BlocProvider(
      create: (context) => UsbCubit(context.read<UsbManager>()),
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = Provider.of<UsbCubit>(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter USB Serial UART")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.2,
                child:
                    BlocBuilder<UsbCubit, UsbState>(builder: (context, state) {
                  final data = state.devices;

                  return ListView(
                    children: data
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                                'Device name: ${e.deviceName} \nID: ${e.deviceName}'),
                          ),
                        )
                        .toList(),
                  );
                }),
              ),
              ElevatedButton(
                onPressed: cubit.connectToLatestDevice,
                child: const Text("Підключитися до першого пристрою"),
              ),
              ElevatedButton(
                onPressed: cubit.refreshDeviceList,
                child: const Text("Оновити список девайсів"),
              ),
              ElevatedButton(
                onPressed: cubit.disconnect,
                child: const Text("Відключитися"),
              ),
              ElevatedButton(
                onPressed: cubit.clearData,
                child: const Text("Очистити термінал"),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Відправити дані"),
                onSubmitted: cubit.sendData,
              ),
              const SizedBox(height: 20),
              const Text("Отримані дані:"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => cubit.sendData('ON'),
                    child: const Text("On"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => cubit.sendData('OFF'),
                    child: const Text("Off"),
                  ),
                ],
              ),
              Expanded(child:
                  SingleChildScrollView(child: BlocBuilder<UsbCubit, UsbState>(
                builder: (context, state) {
                  return Column(children: [
                    for (final val in state.data)
                      Text(
                        'Data from USB: $val',
                        style: const TextStyle(color: Colors.red),
                      )
                  ]);
                },
              ))),
            ],
          ),
        ),
      ),
    );
  }
}
