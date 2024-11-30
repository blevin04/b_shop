import 'package:b_shop/backEndFunctions.dart';
import 'package:b_shop/utils.dart';
import 'package:flutter/material.dart';
class Checkout extends StatelessWidget {
  final Map<String,dynamic> items;
  final List location;
  const Checkout({super.key,required this.items,required this.location});
  @override
  Widget build(BuildContext context) {
    TextEditingController number = TextEditingController();
    var total = 0;
    items.forEach((key,value){
      double price = value[1];
      total += price.round();
    });
    return Scaffold(
      appBar: AppBar(
        title:const Text("Check Out"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  // print("total: $total");
                  return ListTile(
                    title:Text (items[items.keys.toList()[index]].first),
                    subtitle: Text("X${items[items.keys.toList()[index]].last}"),
                    trailing: Text("KSH ${items[items.keys.toList()[index]][1].toString()}",style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  );
                },
              ),
            ),
            Row(
              children: [
               const Text("Total:  ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                Text("KSH ${total.toString()}")
              ],
            ),
            const SizedBox(height: 20,),
           const Text("Phone Number",textAlign: TextAlign.start,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width-100,
                  child: TextField(
                    controller: number,
                    decoration: InputDecoration(
                      hintText: "eg, 0701120102",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:const BorderSide(color:  Color.fromARGB(255, 120, 118, 118))
                      )
                    ),
                  ),
                ),
                const Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: "Mpesa Number to be charged",
                  child: Icon(Icons.help_outline),
                )
              ],
            ),
            Card(
              margin:const EdgeInsets.all(20),
              child: InkWell(
                onTap: ()async{
                  if (number.text.isEmpty) {
                    showsnackbar(context, "Enter valid number");
                    // showDialog(
                    //   barrierDismissible: false,
                    //   context: context, builder: (context){
                    //   return Dialog(
                    //     child: Container(
                    //       height: 300,
                    //       child: Stack(
                    //         alignment: Alignment.topRight,
                    //         children: [
                    //           Center(
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //               children: [
                    //                 Text("Payment Failed",softWrap: true,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                    //                 Icon(Icons.close,size: 50,color: Colors.red,weight: 30,),
                    //                 Text("Please try again or contact us"),

                    //               ],
                    //             ),
                    //           ),
                    //           IconButton(onPressed: (){
                    //             Navigator.pop(context);
                    //           }, icon:const Icon(Icons.cancel))
                    //         ],
                    //       ),
                    //     ),
                    //   );
                    // });
                  }
                  if (number.text.isNotEmpty) {
                    List OrderState = [];
                    //List sold = items.keys.toList();
                    while(OrderState.isEmpty){
                      showcircleprogress(context);
                      OrderState =  await placeOrder(
                      items,
                      location, 
                      false, 
                      1, 
                      number.text,
                      context,
                      );
                      // print(OrderState);
                    }
                    Navigator.pop(context);
                    print(OrderState.length);
                    if (OrderState.first == "Order Invalid") {
                      Map invalid = OrderState.last;
                      List invalidKeys = invalid.keys.toList();
                      showDialog(context: context, builder: (context){
                        return Dialog(
                          child: ListView.builder(
                            itemCount: invalid.length,
                            itemBuilder: (BuildContext context, int index) {
                              List invalidOrder = invalid[invalidKeys[index]];
                              return Text("only ${invalidOrder.last} of ${invalidOrder[1].first} are left instock");
                            },
                          ),
                        );
                      });
                    }print(OrderState);
                    if (OrderState.first == "placed") {
                      showDialog(
                        context: context, 
                        barrierDismissible: false,
                        builder: (context){
                          return Dialog(
                            child: Container(
                              height: 400,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  StreamBuilder(
                                    stream: firestore.collection("orders").doc(OrderState.last).snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator(),);
                                      }
                                      String paymentState = snapshot.data.data()["PaymentState"];
                                      if (paymentState == "Waiting") {
                                        return const Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text("Waiting for Payment Confirmation",softWrap: true,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                            Center(child: CircularProgressIndicator(),)
                                          ],
                                        );
                                      }
                                      if (paymentState == "Success") {
                                        clearCart(items.keys.toList());
                                        return const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text("Payment Received",softWrap: true,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                              Icon(Icons.check,size: 50,color: Colors.green,weight: 30,),
                                              Text("Your Order will be delivered soon"),

                                            ],
                                          ),
                                        );
                                      }
                                     return Container();
                                    },
                                  ),
                                  IconButton(onPressed: (){
                                    Navigator.popUntil(context,ModalRoute.withName("/cart"));
                                  }, icon:const Icon(Icons.cancel)
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: ListenableBuilder(
                  listenable: number,
                  builder: (context,child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: number.text.length==10 ?Colors.blue:null,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      alignment: Alignment.center,
                      width: 100,
                      padding:const EdgeInsets.all(8.0),
                      child:const Text("Pay"),
                    );
                  }
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(onPressed: ()async{
                  List state = [];
                  // String num = "";
                  // if (Hive.box("Userdata").containsKey("Number")) {
                  //   num = Hive.box("Userdata").get("Number");
                  // }
                  
                   while (state.isEmpty) {
                    showcircleprogress(context);
                    state = await placeOrder(
                      items,
                       location,
                        true, 
                        total.toDouble(), 
                        "",
                        context,
                        );
                  }
                  Navigator.pop(context);
                  if (state[0] == "Success") {
                    clearCart(items.keys.toList());
                    showsnackbar(context, "Your order will be delivered soon");
                    Navigator.pop(context);
                  }
                }, child:const Text("Pay on delivery ?")),
              ],
            )
          ],
        ),
      ),
    );
  }
}