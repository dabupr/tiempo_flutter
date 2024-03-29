import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

Future<GeoPoint?> mapClicked(
    BuildContext context, double defaultLatitude, double defaultLongitude) async {
  //ValueNotifier<GeoPoint?> notifier = ValueNotifier(null);

  var pickedPosition = await showSimplePickerLocation(
    context: context,
    //title: " ",
    isDismissible: true,
    textConfirmPicker: "Pick",
    contentPadding: const EdgeInsets.all(12),
    initZoom: 7,
    initPosition: GeoPoint(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
    ),
    radius: 8.0,
  );
  return pickedPosition;
}
