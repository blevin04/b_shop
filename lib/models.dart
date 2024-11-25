
class orderModel {
  final String orderNumber;
  final String owner ;
  final List location;
  final bool paymentState;
  final Map items;
  final bool delivered;
  final bool ondelivery;
  final double price;
  final String paymentNum;
  orderModel({
    required this.items,
    required this.location,
    required this.orderNumber,
    required this.owner,
    required this.paymentState,
    required this.delivered,
    required this.ondelivery,
    required this.price,
    required this.paymentNum,
  });
  Map<String,dynamic> toJyson()=>{
    "Owner":owner,
    "Location":location,
    "delivered":delivered,
    "items":items,
    "orderNumber":orderNumber,
    "PaymentState":paymentState,
    "OndeliveryPayment":ondelivery,
    "price":price,
    "Number":paymentNum
  };
}