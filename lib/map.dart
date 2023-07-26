import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class LocationAppExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LocationAppExampleState();
}

class _LocationAppExampleState extends State<LocationAppExample> {
  ValueNotifier<GeoPoint?> notifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<GeoPoint?>(
              valueListenable: notifier,
              builder: (ctx, p, child) {
                return Center(
                  child: Text(
                    "${p?.toString() ?? ""}",
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () async {
                var p = await showSimplePickerLocation(
                  context: context,
                  isDismissible: true,
                  //title: "",
                  textConfirmPicker: "pick",
                  initZoom: 7,
                  initPosition: GeoPoint(
                    latitude: 41.3887900,
                    longitude: 2.1589900,
                  ),
                  radius: 8.0,
                );
                if (p != null) {
                  notifier.value = p;
                }
              },
              child: Text("show picker address"),
            ),
          ],
        ),
      ),
    );
  }
  
}
