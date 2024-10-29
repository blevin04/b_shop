import 'package:flutter/material.dart';

class Checkout extends StatelessWidget {
  final Map<String,dynamic> items;
  const Checkout({super.key,required this.items});

  @override
  Widget build(BuildContext context) {
    var total = 0;
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
                  
                  items.forEach((key,value){
                    total += value as int;
                  });
                  return ListTile(
                    title:Text (items.keys.toList()[index].toString()),
                    subtitle: Text("X1"),
                    trailing: Text("KSH ${items[items.keys.toList()[index]].toString()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  );
                },
              ),
            ),
            Row(
              children: [
               const Text("Total:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
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
                  message: "Mpesa Number to be charged",
                  child: Icon(Icons.help_outline),
                )
              ],
            ),
            Card(
              margin:const EdgeInsets.all(20),
              child: InkWell(
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