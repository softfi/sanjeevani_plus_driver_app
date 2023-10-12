import 'package:flutter/material.dart';
import 'package:taxi_driver/screens/DriverDashboardScreen.dart';
import 'package:taxi_driver/screens/LoginScreen.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import 'VerifyDeliveryPersonScreen.dart';
import 'WalkThroughtScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await driverDetail();
    await Future.delayed(Duration(seconds: 8));
    if (false/*sharedPref.getBool(IS_FIRST_TIME) ?? true*/) {
      launchScreen(context, WalkThroughtScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
    } else {
      if (sharedPref.getInt(IS_Verified_Driver) == 0 && appStore.isLoggedIn) {

        //doc verified or not he will redirected to the dashboard
        launchScreen(context, DriverDashboardScreen(), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
       // launchScreen(context, VerifyDeliveryPersonScreen(isShow: true), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else if (sharedPref.getInt(IS_Verified_Driver) == 1 && appStore.isLoggedIn) {
        launchScreen(context, DriverDashboardScreen(), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
      } else {
        launchScreen(context, LoginScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      }
    }
  }

  Future<void> driverDetail() async {
    if (appStore.isLoggedIn) {
      await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
        if (value.data!.status == REJECT || value.data!.status == BANNED) {
          toast('${language.yourAccountIs} ${value.data!.status}. ${language.pleaseContactSystemAdministrator}');
          logout();
        }
      }).catchError((error) {
        //
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/splash.gif', fit: BoxFit.contain, height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width),
            SizedBox(height: 16),
            // Text(language.appName, style: boldTextStyle(color: Colors.white, size: 22)),
          ],
        ),
      ),
    );
  }
}
