import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart' ;
import 'package:location_permissions/location_permissions.dart'as test ;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/Constants.dart';
import 'package:background_locator/settings/locator_settings.dart' as loc;
import 'package:flutter/material.dart';
import 'package:background_locator/settings/android_settings.dart' as bgSetting;

import 'backgroundLovation/lib/location_service_repository.dart';






class FirebaseService_Location {
  late SharedPreferences sharedPref;
  void getLocationPermission() async {
    init();
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
      print("location changed here latitude ${event.latitude} ==>longitude  ${event.longitude}");
      writeLocationToFirebase(
          latitude: event.latitude.toString(),
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



  Future<void> _startLocator() async{
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback:LocationCallbackHandler.initCallback ,
        initDataCallback: data,
        disposeCallback:LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: loc.LocationAccuracy.NAVIGATION, distanceFilter: 0),
        autoStop: true,
        androidSettings:  bgSetting.AndroidSettings(
            accuracy: loc.LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: bgSetting.LocationClient.google,
            androidNotificationSettings: bgSetting.AndroidNotificationSettings(
              notificationIcon:"images/ic_app_logo.png" ,
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:LocationCallbackHandler.notificationCallback)));
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    if (data == null) {
      return;
    }

    await BackgroundLocator.updateNotificationText(
        title: "new location received",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');



    bool per=await _checkLocationPermission();
    if(per)_startLocator().then((value) async {
      final _isRunning = await BackgroundLocator.isServiceRunning();
      // Future.delayed(Duration(seconds: 10)).then((value) =>  );
      print("mfbdjfbhf gbfs gsjgfjs gsggdsgs  $_isRunning");
      // Fluttertoast.showToast(msg: "hhhhhh....... $_isRunning");
    });
    final _isRunning = await BackgroundLocator.isServiceRunning();
    // Future.delayed(Duration(seconds: 10)).then((value) =>  );
    // Fluttertoast.showToast(msg: "hhhhhh....... $_isRunning");
  }




  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case test.PermissionStatus.unknown:
      case test.PermissionStatus.denied:
      case test.PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == test.PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case test.PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }






  ReceivePort port = ReceivePort();

  init(){
    if (IsolateNameServer.lookupPortByName(LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
          (dynamic data) async {
        await _updateNotificationText(data);
      },
    );
    initPlatformState();
  }







}












//callback handler
/*
import 'dart:async';

import 'package:background_locator/location_dto.dart';

import 'location_service_repository.dart';
*/

class LocationCallbackHandler {
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}











