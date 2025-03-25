import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_demo_uart/manager/usb_manger/usb_manager.dart';
import 'package:usb_serial/usb_serial.dart';

part 'usb_state.dart';

class UsbCubit extends Cubit<UsbState> {
  final UsbManager _manager;
  StreamSubscription<List<UsbDevice>>? _subscription;
  StreamSubscription<Uint8List>? _dataSubscription;

  UsbCubit(this._manager) : super(UsbState()) {
    _subscription = _manager.device.listen(
      (event) => emit(state.copyWith(devices: event)),
    );
  }

  Future<void> connectToLatestDevice() async {
    final port = await _manager.selectDevice();
    if (port != null) {
      _dataSubscription = port.inputStream?.listen(
        (event) => emit(state.copyWith(data: [
          String.fromCharCodes(event),
          ...state.data,
        ])),
      );
    }
  }

  Future<void> refreshDeviceList() => _manager.refreshDeviceList();

  Future<void> disconnect() => _manager.dispose();

  Future<void> sendData(String value) => _manager.sendData(value);

  void clearData() => emit(state.copyWith(data: []));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await _dataSubscription?.cancel();
    _dataSubscription = null;
    return super.close();
  }
}
