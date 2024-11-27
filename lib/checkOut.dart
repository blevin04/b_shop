import 'package:b_shop/backEndFunctions.dart';
import 'package:b_shop/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      int price = value[1] as int;
      total += price;
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
           const Text("Phone Number"),
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
                  if (number.text.isNotEmpty) {
                    List OrderState = [];
                    //List sold = items.keys.toList();
                    while(OrderState.isEmpty){
                      showcircleprogress(context);
                      OrderState =  await placeOrder(
                      items,
                      location, 
                      false, 
                      total.toDouble(), 
                      number.text);
                     
                    }
                    Navigator.pop(context);
                    if (OrderState.first == "placed") {
                      showDialog(
                        context: context, 
                        barrierDismissible: false,
                        builder: (context){
                          return Dialog(
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
                                    return Container(
                                      height: 400,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                        const Text("Waiting For Payment",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        paymentState == "waiting"?
                                        const Center(child: CircularProgressIndicator(),):
                                        paymentState == "Success"?
                                        const Text("Success",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),):
                                        const Text("Error",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)
                                        // Text("Enter ")
                                      ],),
                                    );
                                  },
                                ),
                                IconButton(onPressed: (){
                                  Navigator.pop(context);
                                }, icon:const Icon(Icons.cancel)
                                )
                              ],
                            ),
                          );
                        });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  alignment: Alignment.center,
                  width: 100,
                  padding:const EdgeInsets.all(8.0),
                  child:const Text("Pay"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}