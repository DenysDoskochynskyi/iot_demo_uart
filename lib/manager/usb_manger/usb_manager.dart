import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:usb_serial/usb_serial.dart';

abstract class BaseUsbService {
  Future<List<UsbDevice>> getDeviceList();

  Future<UsbPort?> connectToDevice(UsbDevice device, {int rate = 115200});

  sendData(UsbPort? port, {required String data});
}

class UsbService extends BaseUsbService {
  @override
  Future<UsbPort?> connectToDevice(UsbDevice device,
      {int rate = 115200}) async {
    final port = await device.create();
    bool openResult = (await port?.open() ?? false);
    if (!openResult) {
      print("Не вдалося відкрити порт");
      return null;
    }
    await port?.setDTR(true);
    await port?.setRTS(true);
    await port?.setPortParameters(
      rate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    return port;
  }

  @override
  Future<List<UsbDevice>> getDeviceList() async {
    final list = await UsbSerial.listDevices();
    return list;
  }

  @override
  void sendData(UsbPort? port, {required String data}) {
    if (port != null) {
      port.write(Uint8List.fromList(data.codeUnits));
    }
  }
}

class UsbManager {
  UsbManager(this.service) {
    refreshDeviceList();
  }

  final BaseUsbService service;
  final _cachedDevice = BehaviorSubject<List<UsbDevice>>.seeded([]);
  final _cachedPort = BehaviorSubject<UsbPort?>();
  final _cachedRate = BehaviorSubject<int>.seeded(115200);

  Stream<List<UsbDevice>> get device => _cachedDevice.stream;

  UsbPort? get port => _cachedPort.valueOrNull;

  Future<void> refreshDeviceList() async {
    final data = await service.getDeviceList();
    _cachedDevice.add(data);
  }

  Future<UsbPort?> selectDevice() async {
    final data = _cachedDevice.value;
    if (data.isEmpty) await refreshDeviceList();

    final port = await service.connectToDevice(
      _cachedDevice.value.first,
      rate: _cachedRate.value,
    );
    _cachedPort.add(port);
    return port;
  }

  Future<void> sendData(String data) async {
    await service.sendData(_cachedPort.valueOrNull, data: data);
  }

  Future<void> dispose() async {
    await _cachedPort.valueOrNull?.close();
    _cachedPort.add(null);
  }
}
