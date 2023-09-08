import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Constants.dart';

class FirebaseService_Location {
  late SharedPreferences sharedPref;
  void getLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      getLocationPermission();
    } else {
      getLocation();
    }
  }

  Location location = Location();
  StreamSubscription<LocationData>? stream;

  getLocation() async {
    if (!await location.isBackgroundModeEnabled()) {
      location.enableBackgroundMode().then((value) {
        if (!value) {
          getLocation();
        }
      });
    }
    if (!await location.serviceEnabled()) {
      askForService:
      location.requestService().then((value) {
        if (!value) {
          getLocation();
        }
      });
    }
    await Firebase.initializeApp();
    stream = location.onLocationChanged.listen((event) {
      print("location changed here ${event.latitude}");
      print("location changed here ${event.longitude}");
      writeLocationToFirebase(
          latitude: event.longitude.toString(),
          longitude: event.longitude.toString());
    });
  }

  void pauseStream() {
    stream!.pause();
  }

  Future<void> writeLocationToFirebase(
      {required String latitude, required String longitude}) async {
    sharedPref = await SharedPreferences.getInstance();
    var email = sharedPref.getString(USER_EMAIL);
    DatabaseReference ref =
        FirebaseDatabase.instance.ref(email?.replaceAll(".", ""));
    try {
      await ref.set({"latitude": latitude, "longitude": longitude});
    } catch (_) {
      // await ref.set({"latitude": latitude, "longitude": longitude});
      await ref.update({"latitude": latitude, "longitude": longitude});
    }
    /*FirebaseFirestore.instance
        .collection('userLocation')
        .doc(email)
        .set({'text': 'data added through app$latitude'});*/
  }
}
