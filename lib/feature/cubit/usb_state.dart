part of 'usb_cubit.dart';

class UsbState {
  final List<String> data;
  final List<UsbDevice> devices;
  final UsbDevice? device;

  UsbState({this.data = const [], this.devices = const [], this.device});

  UsbState copyWith({
    List<String>? data,
    List<UsbDevice>? devices,
    UsbDevice? device,
  }) =>
      UsbState(
        data: data ?? this.data,
        device: device ?? this.device,
        devices: devices ?? this.devices,
      );
}
