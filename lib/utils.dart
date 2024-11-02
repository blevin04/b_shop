import 'package:flutter/material.dart';
import 'package:location/location.dart';

showsnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //backgroundColor: const Color.fromARGB(255, 106, 105, 105),
    content: Text(content)));
}

showcircleprogress(BuildContext context) {

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return   StatefulBuilder(
    builder: (BuildContext context, setState) {
      return  Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 120,
            width: 120,
            color:const Color.fromARGB(84, 50, 50, 50),
            child: const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color.fromARGB(131, 128, 124, 124),
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
        );
          }
        );
       
      });
}
Future<LocationData> getLocation()async{
  Location location = new Location();

bool _serviceEnabled;
PermissionStatus _permissionGranted;
LocationData _locationData;

_serviceEnabled = await location.serviceEnabled();
if (!_serviceEnabled) {
  _serviceEnabled = await location.requestService();
  if (!_serviceEnabled) {
    return LocationData.fromMap({});
  }
}

_permissionGranted = await location.hasPermission();
if (_permissionGranted == PermissionStatus.denied) {
  _permissionGranted = await location.requestPermission();
  if (_permissionGranted != PermissionStatus.granted) {
    return LocationData.fromMap({});
  }
}
_locationData = await location.getLocation();
return _locationData;
}