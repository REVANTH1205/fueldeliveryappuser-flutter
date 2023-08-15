import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmaptest/assisttant/geofire_assistant.dart';
import 'package:gmaptest/driver_choosing/select_nearest_driver_screen.dart';
import 'package:gmaptest/map.dart';
import 'package:gmaptest/modal/user_modal.dart';
import 'package:gmaptest/payment_invoice.dart';
import 'package:provider/provider.dart';

import 'app_info.dart';
import 'assisttant/assistant_methods.dart';
import 'global/global.dart';
import 'modal/active_nearby_avaliable_drivers.dart';


class FuelRequestPage extends StatefulWidget {
  const FuelRequestPage({Key? key}) : super(key: key);

  @override
  State<FuelRequestPage> createState() => _FuelRequestPageState();
}

class _FuelRequestPageState extends State<FuelRequestPage> {

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];
  DatabaseReference? referenceRideRequest;
  double WaitingRespomseFromDriverContainerHeight=0;


  List<String> fueltype = ["Petrol", "Diesel", "Power Petrol"];
  String? seletedfueltype;

  List<String> fuelquan = ["1", "2", "3", "4", "5"];
  String? seletedfuelquan;

  saveOrder(){

    var localaddress = Provider.of<AppInfo>(context,listen: false).userPickUpLocation;


    Map Ordermap = {

      "name": userModalcurrentinfo!.name,
      "originLat": localaddress!.locationLatitude,
      "orginLad": localaddress!.locationLongitude,
      "phone":  userModalcurrentinfo!.phone,
      "location": localaddress!.locationName,
      "fuel_quantity": seletedfuelquan,
      "time" : DateTime.now().toString(),
      "fuel_type": seletedfueltype,
      "cust_id": currentFirebaseUser!.uid,
      "drver_id":"waiting",
    };
    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("FuelOrders");
    driversRef.child(currentFirebaseUser!.uid).set(Ordermap);



    Fluttertoast.showToast(msg: "Order has been successfully placed");
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MyMapScreen()));

  }

  saveRideRequestInformation()
  {
    //1. save the RideRequest Information
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Request").push();
    var localaddress = Provider.of<AppInfo>(context,listen: false).userPickUpLocation;


    Map Ordermap = {

      "name": userModalcurrentinfo!.name,
      "originLat": localaddress!.locationLatitude,
      "orginLad": localaddress!.locationLongitude,
      "phone":  userModalcurrentinfo!.phone,
      "location": localaddress!.locationName,
      "fuel_quantity": seletedfuelquan,
      "time" : DateTime.now().toString(),
      "fuel_type": seletedfueltype,
      "cust_id": currentFirebaseUser!.uid,
      "drver_id":"waiting",
    };
    referenceRideRequest!.set(Ordermap);

    onlineNearByAvailableDriversList= GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  searchNearestOnlineDrivers() async
  {
    //no active driver available
    if(onlineNearByAvailableDriversList.length == 0)
    {
      //cancel/delete the RideRequest Information
      referenceRideRequest!.remove();
      Fluttertoast.showToast(msg: "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      Future.delayed(const Duration(milliseconds: 4000), ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MyMapScreen()));
      });

      return;
    }

    //active driver available
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveDriver(referenceRideRequest:referenceRideRequest)));


    if(response == "driverChoosed")
    {
      FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(chosenDriverId!)
          .once()
          .then((snap)
      {
        if(snap.snapshot.value != null)
        {
          //send notification to that specific driver
          sendNotificationToDriverNow(chosenDriverId!);

          showWaitingResponceUI();

          FirebaseDatabase.instance.ref()
              .child("drivers")
              .child(chosenDriverId!).child("newRideStatus")
              .onValue.listen((eventSnapshot) {



            if(eventSnapshot.snapshot.value =="Idle"){
              
              Fluttertoast.showToast(msg: "The driver has cancelled the request, Please choose Another Driver");
              Future.delayed(const Duration(milliseconds: 4000),()
              {
                Fluttertoast.showToast(msg: "Please restart the app");
                SystemNavigator.pop();
              });

            }

            if(eventSnapshot.snapshot.value =="accepted"){
              //design and display the UI
              Fluttertoast.showToast(msg: "Driver has acceptted your Request");
            }
          });

        }

      else{
        Fluttertoast.showToast(msg: "This Driver doesn't exist , Please choose another one");
      }

      });
    }

  }

  showWaitingResponceUI(){
    setState(() {
     WaitingRespomseFromDriverContainerHeight = 400;
    });
  }


sendNotificationToDriverNow(String chosenDriverId)
{
  //assign/SET rideRequestId to newRideStatus in
  // Drivers Parent node for that specific choosen driver
  FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(chosenDriverId!)
      .child("newRideStatus")
      .set(referenceRideRequest!.key);

  //automate the push notification
  //automate the push notification service
  FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(chosenDriverId)
      .child("token").once().then((snap)
  {
    if(snap.snapshot.value != null)
    {
      //String deviceRegistrationToken = snap.snapshot.value.toString();
        String deviceRegistrationToken = "dS-rpQjYQ6OF5NxWb789RG:APA91bHS9wnHn1cjrnQmaOFMVFV1jZm928Kh-uKA_YVACSjXFV1JoeLueo25eIg6b6ithh78e62_oTsEFU5cQC2st8zYS7hU_ycfoslkq0scgYTygiewy-7RwwbdZzPbzW_lcsuVp2xW";
      //send Notification Now
      print("#########################Device Registration token ::::::::::::::::########################");
      print(deviceRegistrationToken);

      AssistantMethods.sendNotificationToDriverNow(
        deviceRegistrationToken,
        referenceRideRequest!.key.toString(),
        context,
      );
      Fluttertoast.showToast(msg: "Notification sent Successfully.");
    }
    else
    {
      Fluttertoast.showToast(msg: "Please choose another driver.");
      return;
    }
  });

}




  retrieveOnlineDriversInformation(List onlineNearestDriversList) async
  {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for(int i=0; i<onlineNearestDriversList.length; i++)
    {
      await ref.child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot)
      {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
        print("Drivers Information = "+ dList.toString());
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Request fuel"
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/fuelrequest.png"),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Fuel Order",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40.0),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.add_location_alt_outlined,
                        color: Colors.black87,
                      ),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Location",
                            style:
                            TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            Provider.of<AppInfo>(context)
                                .userPickUpLocation !=
                                null
                                ? (Provider.of<AppInfo>(context)
                                .userPickUpLocation!
                                .locationName!)
                                .substring(0, 40) +
                                "..."
                                : "Not getting address",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  const Divider(
                    height: 1,
                    thickness: 2,
                    color: Colors.grey,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        DropdownButton(
                          hint: const Text(
                            "Fuel Type:",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                          value: seletedfueltype,
                          onChanged: (newValue){
                            setState(() {
                              seletedfueltype = newValue.toString();
                            });
                          },
                          items: fueltype.map((fuel){
                            return DropdownMenuItem(
                              child: Text(
                                fuel,
                                style: const TextStyle(color: Colors.black),
                              ),
                              value: fuel,
                            );
                          }).toList(),

                        ),
                        const SizedBox(width: 50),

                        DropdownButton(
                          hint: const Text(
                            "Quantity in Liters",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                          value: seletedfuelquan,
                          onChanged: (newValue){
                            setState(() {
                              seletedfuelquan = newValue.toString();
                            });
                          },
                          items: fuelquan.map((pay){
                            return DropdownMenuItem(
                              child: Text(
                                pay,
                                style: const TextStyle(color: Colors.black),
                              ),
                              value: pay,
                            );
                          }).toList(),

                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50,vertical:20),
                    child: Row(
                      children: [
                        Text("Price : ${(int.tryParse(seletedfuelquan ?? '0') ?? 0) * 100 }",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight:FontWeight.bold,
                          fontSize: 20,
                        ),
                        )

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50,vertical:20),
                    child: Row(
                      children: [
                        Text("Price + Delivery charge: ${(int.tryParse(seletedfuelquan ?? '0') ?? 0) * 100+40 }",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight:FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 10.0),


                  const SizedBox(height: 16.0),

                  ElevatedButton(
                    child: const Text(
                      "Request Driver",
                    ),
                    onPressed: () {
                      // save the details into firebase
                      saveRideRequestInformation();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  
                  //Ui for Waiting Response

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
