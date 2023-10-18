import 'dart:async';
import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/screens/DriverDashboardScreen.dart';
import 'package:taxi_driver/utils/Colors.dart';
import 'package:taxi_driver/utils/Constants.dart';
import 'package:taxi_driver/utils/Extensions/AppButtonWidget.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/app_common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/CurrentRequestModel.dart';
import '../model/RideHistory.dart';
import '../model/RiderModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Images.dart';
import 'ReviewScreen.dart';
import 'RideHistoryScreen.dart';

class DetailScreen extends StatefulWidget {
  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  CurrentRequestModel? currentData;
  RiderModel? riderModel;
  Payment? payment;
  List<RideHistory> rideHistory = [];
  bool isPaymentDone = false;


   late final Stream<Payment>  counterStream;
  @override
  void initState() {
    startStream();
    super.initState();
    init();
  }

  startStream()async{
    counterStream= ((){
      late final StreamController<Payment> controller;
      controller=StreamController<Payment>(
        onListen: ()async {
            orderDetailApi(shouldLoad: false);
        },
      );
      return controller.stream;
    })();
  }

  Stream<Payment?> getDataAsStream()async*{
    while(true){
      await Future.delayed(Duration(seconds: 2));
      yield await orderDetailApi(shouldLoad: false);

    }
  }



  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    currentRideRequest();
    mqttForUser();
  }



  Future<void> currentRideRequest() async {
    appStore.setLoading(true);
    await getCurrentRideRequest().then((value) async {
      appStore.setLoading(false);
      print("this is the sdfsdfd fsdfsd  ${currentData?.id}");
      currentData = value;
      currentData!.payment=Payment(
        paymentType: CASH
      );
      await orderDetailApi(shouldLoad: true);
      print("hri sdi kjfds fbf ${value.id}");
      setState(() {});
    })/*.catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    })*/;
  }

  Future<void> savePaymentApi() async {
    appStore.setLoading(true);
    Map req = {
      "id": currentData?.payment?.id??riderModel!.paymentId,
      "rider_id": currentData?.payment?.riderId??riderModel!.riderId,
      "ride_request_id": currentData?.payment?.rideRequestId??RIDE_REQUEST_ID_BY_ALOK,
      "datetime": DateTime.now().toString(),
      "total_amount": currentData?.payment?.totalAmount??riderModel!.subtotal,
      "payment_type": currentData?.payment?.paymentType??riderModel!.paymentType,
      "txn_id": "",
      "payment_status": "paid",
      "transaction_detail": ""
    };
    log(req);
    await savePayment(req).then((value) {
      appStore.setLoading(false);
      ///
       getCurrentRideRequest().then((value) async {
        appStore.setLoading(false);
        //print("onRideRequest  ${value.onRideRequest}");
        if (value.onRideRequest != null) {
          appStore.currentRiderRequest = value.onRideRequest;
          servicesListData = value.onRideRequest;

          userDetail(value.onRideRequest!.riderId);

          setState(() {});

          if (servicesListData != null) {
            if (servicesListData!.status == COMPLETED &&
                servicesListData!.isDriverRated == 0) {
              //change here also
              RIDE_REQUEST_ID_BY_ALOK= servicesListData!.id!;
              /*launchScreen(context, DetailScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);*/
                 launchScreen(
                context,
                ReviewScreen(
                    rideId: value.onRideRequest!.id!, currentData: value),
                pageRouteAnimation: PageRouteAnimation.Slide,
                isNewTask: true);
            } else if (value.payment != null &&
                value.payment!.paymentStatus == PENDING) {
              launchScreen(context, DetailScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
            }
          }
        } else {
          if (value.payment != null && value.payment!.paymentStatus == PENDING) {
            launchScreen(context, DetailScreen(),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          }
        }
        if (servicesListData == null) {
          Map req = {
            "is_available": 1,
          };
          updateStatus(req).then((value) {
            // Future.delayed(Duration(seconds: 10), () {
            //   getCurrentRequest();
            // });
            //getCurrentRequest();
            //
          });
        } else {
          Map req = {
            "is_available": 0,
          };
          updateStatus(req).then((value) async {});
        }
        await getCurrentRideRequest();
      }).catchError((error) {
        toast(error.toString());

        appStore.setLoading(false);

        servicesListData = null;
        setState(() {});
      });


     /* launchScreen(context, DriverDashboardScreen(),
          isNewTask: true,
          pageRouteAnimation: PageRouteAnimation.SlideBottomTop);*/
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<Payment?> orderDetailApi({required bool shouldLoad}) async {
    if(shouldLoad) appStore.setLoading(true);
    await rideDetail(orderId: currentData?.payment?.rideRequestId??RIDE_REQUEST_ID_BY_ALOK)
        .then((value) {
      if(shouldLoad)appStore.setLoading(false);
print("fsfdfsd fsdfsdf sfsdfsdfsd fsfd $value");
      riderModel = value.data;
      payment = value.payment!;
      rideHistory = value.rideHistory!;
      print("gd ndmng d g df gdg  ${payment!.driverTips}");
      setState(() {});
    }).catchError((error) {
      if(shouldLoad)appStore.setLoading(false);
      log('${error.toString()}');
    });
    return payment;
    // if(payment!.driverTips==null) Future.delayed(Duration(seconds: 2)).then((value) => orderDetailApi(shouldLoad: false));
  }

  mqttForUser() async {
    client.setProtocolV311();
    client.logging(on: true);
    client.keepAlivePeriod = 120;
    client.autoReconnect = true;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      debugPrint(e.toString());
      client.connect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.onSubscribed = onSubscribed;

      log('connected');
      debugPrint('connected');
    } else {
      client.connect();
    }

    void onconnected() {
      debugPrint('connected');
    }

    client.subscribe(
        'ride_request_status_' + sharedPref.getInt(USER_ID).toString(),
        MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (jsonDecode(pt)['success_type'] == 'rating') {
        currentRideRequest();
      } else if (jsonDecode(pt)['success_type'] == 'change_payment_type') {
        currentRideRequest();
      } else if (jsonDecode(pt)['success_type'] == 'payment_status_message') {
        setState(() {
          isPaymentDone = true;
        });
        Future.delayed(
          Duration(seconds: 5),
          () {
            setState(() {
              isPaymentDone = false;
            });
            launchScreen(context, DriverDashboardScreen(), isNewTask: true);
          },
        );
      }
    });

    client.onConnected = onconnected;
  }

  void onConnected() {
    log('Connected');
  }

  void onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
  OnRideRequest? servicesListData;
  @override
  Widget build(BuildContext context) {
   if(currentData==null) currentRideRequest();
   if(riderModel==null)orderDetailApi(shouldLoad: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(language.detailScreen,
            style: boldTextStyle(color: Colors.white)),
      ),
      body: currentData != null && riderModel != null
          ? Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: appStore.isDarkMode
                              ? scaffoldSecondaryDark
                              : primaryColor.withOpacity(0.05),
                          borderRadius: radius(),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Ionicons.calendar,
                                    color: textSecondaryColorGlobal, size: 18),
                                SizedBox(width: 8),
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text(
                                      '${printDate(riderModel!.createdAt.validate())}',
                                      style: primaryTextStyle(size: 14)),
                                ),
                              ],
                            ),
                            Divider(height: 30, thickness: 1),
                            Text(
                                '${language.distance}: ${riderModel!.distance.toString()} ${riderModel!.distanceUnit.toString()}',
                                style: boldTextStyle(size: 14)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.near_me, color: Colors.green),
                                    SizedBox(height: 4),
                                    SizedBox(
                                      height: 50,
                                      child: DottedLine(
                                        direction: Axis.vertical,
                                        lineLength: double.infinity,
                                        lineThickness: 1,
                                        dashLength: 2,
                                        dashColor: primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Icon(Icons.location_on, color: Colors.red),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 2),
                                      if (riderModel!.startTime != null)
                                        Text(
                                            riderModel!.startTime != null
                                                ? printDate(
                                                    riderModel!.startTime!)
                                                : '',
                                            style:
                                                secondaryTextStyle(size: 12)),
                                      if (riderModel!.startTime != null)
                                        SizedBox(height: 4),
                                      Text(riderModel!.startAddress.validate(),
                                          style: primaryTextStyle(size: 14)),
                                      SizedBox(height: 22),
                                      if (riderModel!.endTime != null)
                                        Text(
                                            riderModel!.endTime != null
                                                ? printDate(
                                                    riderModel!.endTime!)
                                                : '',
                                            style:
                                                secondaryTextStyle(size: 12)),
                                      if (riderModel!.endTime != null)
                                        SizedBox(height: 4),
                                      Text(riderModel!.endAddress.validate(),
                                          style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 30, thickness: 1),
                            inkWellWidget(
                              onTap: () {
                                launchScreen(context,
                                    RideHistoryScreen(rideHistory: rideHistory),
                                    pageRouteAnimation:
                                        PageRouteAnimation.SlideBottomTop);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.viewHistory,
                                      style: primaryTextStyle(
                                          color: primaryColor)),
                                  Icon(Entypo.chevron_right,
                                      color: primaryColor, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: appStore.isDarkMode
                              ? scaffoldSecondaryDark
                              : primaryColor.withOpacity(0.05),
                          borderRadius: radius(),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.paymentDetails,
                                style: boldTextStyle(size: 16)),
                            Divider(height: 30, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.paymentType,
                                    style: primaryTextStyle()),
                                Text(
                                    paymentStatus(
                                        riderModel!.paymentType.validate()),
                                    style: boldTextStyle()),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.paymentStatus,
                                    style: primaryTextStyle()),
                                Text(
                                    paymentStatus(
                                        riderModel!.paymentStatus.validate()),
                                    style: boldTextStyle()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (riderModel!.otherRiderData != null)
                        SizedBox(height: 16),
                      if (riderModel!.otherRiderData != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: appStore.isDarkMode
                                      ? scaffoldSecondaryDark
                                      : primaryColor.withOpacity(0.05),
                                  borderRadius: radius()),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.riderInformation,
                                      style: boldTextStyle()),
                                  Divider(height: 30, thickness: 1),
                                  Row(
                                    children: [
                                      Icon(FontAwesome.user,
                                          size: 18,
                                          color: textPrimaryColorGlobal),
                                      SizedBox(width: 12),
                                      Text(
                                          riderModel!.otherRiderData!.name
                                              .validate(),
                                          style: primaryTextStyle()),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          launchUrl(
                                              Uri.parse(
                                                  'tel:${riderModel!.otherRiderData!.conatctNumber.validate()}'),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      defaultRadius)),
                                          child: Icon(Ionicons.ios_call,
                                              size: 18, color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                          riderModel!
                                              .otherRiderData!.conatctNumber
                                              .validate(),
                                          style: primaryTextStyle()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),

                      StreamBuilder(stream:getDataAsStream() , builder: (context, AsyncSnapshot<Payment?> snapshot) {
                        return Text(snapshot.data?.driverTips.toString()??"");

                      },),

                      payment!.driverTips!=null?Container(
                        decoration: BoxDecoration(
                            color: appStore.isDarkMode
                                ? scaffoldSecondaryDark
                                : primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.priceDetail,
                                style: boldTextStyle(size: 16)),
                            Divider(height: 30, thickness: 1),
                            if (riderModel!.perDistanceCharge != null)
                              totalCount(
                                  title: language.basePrice,
                                  description: '',
                                  subTitle: '${riderModel!.baseFare}'),
                            SizedBox(height: 8),
                            if (riderModel!.perDistanceCharge != null)
                              totalCount(
                                  title: language.distancePrice,
                                  description: '',
                                  subTitle:
                                      riderModel!.perDistanceCharge.toString()),
                            SizedBox(height: 8),
                            if (riderModel!.perMinuteDriveCharge != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(language.duration,
                                        style: primaryTextStyle()),
                                  ),
                                  Text('${riderModel!.duration}',
                                      style: primaryTextStyle()),
                                ],
                              ),
                            SizedBox(height: 8),
                            totalCount(
                                title: language.waitTime,
                                description: '',
                                subTitle:
                                    '${riderModel!.perMinuteWaitingCharge}'),
                            SizedBox(height: 8),
                            if (payment != null)
                              totalCount(
                                  title: language.tip,
                                  description: '',
                                  subTitle: payment!.driverTips.toString()),
                            if (payment != null) SizedBox(height: 16),
                            if (riderModel!.extraCharges!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.extraCharges,
                                      style: boldTextStyle()),
                                  SizedBox(height: 8),
                                  ...riderModel!.extraCharges!.map((e) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.only(top: 4, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              e.key
                                                  .validate()
                                                  .capitalizeFirstLetter(),
                                              style: primaryTextStyle()),
                                          Text(
                                              appStore.currencyPosition == LEFT
                                                  ? '${appStore.currencyCode} ${e.value}'
                                                  : '${e.value} ${appStore.currencyCode}',
                                              style: primaryTextStyle()),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                ],
                              ),
                            if (riderModel!.couponData != null &&
                                riderModel!.couponDiscount != 0)
                              SizedBox(height: 8),
                            if (riderModel!.couponData != null &&
                                riderModel!.couponDiscount != 0)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.couponDiscount,
                                      style:
                                          primaryTextStyle(color: Colors.red)),
                                  Text(
                                      appStore.currencyPosition == LEFT
                                          ? '-${appStore.currencyCode} ${riderModel!.couponDiscount.toString()}'
                                          : '-${riderModel!.couponDiscount.toString()} ${appStore.currencyCode}',
                                      style: primaryTextStyle(
                                          color: Colors.green)),
                                ],
                              ),
                            Divider(height: 30, thickness: 1),
                            totalCount(
                                title: language.total,
                                description: '',
                                subTitle: '${riderModel!.subtotal}',
                                isTotal: true),
                          ],
                        ),
                      ):Column(
                        children: [
                          loaderWidget(),
                          const SizedBox(height: 10,),
                          Text("Waiting for the user to confirm",style: TextStyle(color: primaryColor,fontSize: 18),)
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: isPaymentDone,
                    child: Center(
                        child: Lottie.asset(paymentSuccessful,
                            width: 400, height: 400, fit: BoxFit.contain))),
              ],
            )
          : Observer(builder: (context) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            }),
      bottomNavigationBar: currentData != null
          ? Padding(
              padding: EdgeInsets.all(16),
              child: currentData!.payment!.paymentType == CASH
                  ? payment?.driverTips!=null? AppButtonWidget(
                      text: language.cashCollected,
                      textStyle: boldTextStyle(color: Colors.white),
                      color: primaryColor,
                      onTap: () {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            positiveText: language.yes,
                            negativeText: language.no,
                            dialogType: DialogType.CONFIRMATION,
                            title: language.areYouSureCollectThisPayment,
                            context, onAccept: (v) async {
                         await savePaymentApi();

                          //////added by alok for the review in the end







                          ///////
                        });
                      },
                    ):const SizedBox()
                  : AppButtonWidget(
                      text: language.waitingForDriverConformation,
                      textStyle: boldTextStyle(color: Colors.white, size: 12),
                      color: primaryColor,
                      onTap: () {
                        if (currentData!.payment!.paymentStatus == COMPLETED) {
                          launchScreen(context, DriverDashboardScreen(),
                              isNewTask: true,
                              pageRouteAnimation:
                                  PageRouteAnimation.SlideBottomTop);
                        } else {
                          //currentRideRequest();
                          toast(language.waitingForDriverConformation);
                        }
                      },
                    ),
            )
          : SizedBox() ,
    );
  }

  Widget chargesWidget({String? name, String? amount}) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name!, style: primaryTextStyle()),
          Text(amount!, style: primaryTextStyle()),
        ],
      ),
    );
  }

  Future<void> getCurrentRequest() async {
    print("fn toi get getCurrentRequest getCurrentRequestgetCurrentRequest");
    appStore.setLoading(true);
    await getCurrentRideRequest().then((value) async {
      appStore.setLoading(false);
      //print("onRideRequest  ${value.onRideRequest}");
      if (value.onRideRequest != null) {
        appStore.currentRiderRequest = value.onRideRequest;
        servicesListData = value.onRideRequest;

        userDetail( value.onRideRequest!.riderId);

        setState(() {});

        if (servicesListData != null) {
          if (servicesListData!.status == COMPLETED &&
              servicesListData!.isDriverRated == 0) {
            //change here also
            RIDE_REQUEST_ID_BY_ALOK= servicesListData!.id!;
            launchScreen(context, DetailScreen(),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
            /*   launchScreen(
                context,
                ReviewScreen(
                    rideId: value.onRideRequest!.id!, currentData: value),
                pageRouteAnimation: PageRouteAnimation.Slide,
                isNewTask: true);*/
          } else if (value.payment != null &&
              value.payment!.paymentStatus == PENDING) {
            launchScreen(context, DetailScreen(),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          }
        }
      } else {
        if (value.payment != null && value.payment!.paymentStatus == PENDING) {
          launchScreen(context, DetailScreen(),
              pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        }
      }
      if (servicesListData == null) {
        Map req = {
          "is_available": 1,
        };
        updateStatus(req).then((value) {
          // Future.delayed(Duration(seconds: 5), () {
          //   getCurrentRequest();
          // });
          //getCurrentRequest();
          //
        });
      } else {
        Map req = {
          "is_available": 0,
        };
        updateStatus(req).then((value) async {});
      }
      await getCurrentRideRequest();
    }).catchError((error) {
      toast(error.toString());

      appStore.setLoading(false);

      servicesListData = null;
      setState(() {});
    });
  }
}
