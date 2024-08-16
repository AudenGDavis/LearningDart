import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String text = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Flutter is cool')
        ),

        body: Container(
          child: Text(text),
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed:  () async {
            text += "attempting/n";
            List<UsbDevice> devices = await UsbSerial.listDevices();
            if (devices.isEmpty) {
              setState(() {
                text += "No devices found\n";
              });
              return;
            }

            UsbPort? port = await devices[0].create();

            if (port != null) {
              bool openResult = await port.open();
              if (!openResult) {
                setState(() {
                  text += "Failed to open port\n";
                });
                return;
              }

              await port.setDTR(true);
              await port.setRTS(true);
              port.setPortParameters(115200, UsbPort.DATABITS_8,
                UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

              port.inputStream?.listen((Uint8List event) {
                setState(() {
                  text += event.toString();
                });
                port.close();
              });

              await port.write(Uint8List.fromList([0x10, 0x00]));
            } else {
              setState(() {
                text = "Failed to create port\n";
              });
            }
          },
        ),
      ),
    );
  }
}
