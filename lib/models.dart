
import 'package:cloud_firestore/cloud_firestore.dart';

class orderModel {
  final String orderNumber;
  final String owner ;
  final List location;
  final Map items;
  final bool ondelivery;
  final double price;
  final String paymentNum;
  final bool live;
  orderModel({
    required this.items,
    required this.location,
    required this.orderNumber,
    required this.owner,
    required this.ondelivery,
    required this.price,
    required this.paymentNum,
    required this.live,
  });
  Map<String,dynamic> toJyson()=>{
    "Owner":owner,
    "Location":location,
    "delivered":false,
    "items":items,
    "orderNumber":orderNumber,
    "PaymentState":"Waiting",
    "OndeliveryPayment":ondelivery,
    "price":price,
    "Number":paymentNum,
    "time":FieldValue.serverTimestamp(),
    "Live":live,
  };
}