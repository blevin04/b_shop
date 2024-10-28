import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
int current_screen = 0;
List categories = [
  "Gas",
  "Cerials",
  "Floar",
  "other",
];
class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      floatingActionButton: IconButton(onPressed: (){}, 
      icon:Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircleAvatar(
            child: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.call))),
            Text("Call!!")
        ],
      )),
      appBar:AppBar(
        actions: [IconButton(onPressed: (){}, icon:const Icon(Icons.sunny))],
        //toolbarHeight: 30,
        title:const Text("B_Shop ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        ),
      body:current_screen==0? home():
      current_screen == 1?search():cart(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){
              setState(() {
                current_screen = 0;
              });
            }, icon: CircleAvatar(
              backgroundColor: current_screen == 0 ?Colors.lightBlue:Colors.transparent,
              child:const  Icon(Icons.home,size: 30,))),
            IconButton(onPressed: (){
              setState(() {
                current_screen = 1;
              });
            }, icon:CircleAvatar(
               backgroundColor: current_screen == 1 ?Colors.lightBlue:Colors.transparent,
              child: const Icon(Icons.search,size: 30))),
            IconButton(onPressed: (){
              setState(() {
                current_screen = 2;
              });
            }, icon:CircleAvatar(
               backgroundColor: current_screen == 2 ?Colors.lightBlue:Colors.transparent,
              child: const Icon(Icons.shopping_cart,size: 30)))
          ],
        ),
      ),
    );
  }
}
Widget home(){
  return SingleChildScrollView(
        child: Column(
          children: [
          const SizedBox(height: 15,),
           SizedBox(
            height: 30,
             child: ListView.builder(
               itemCount: categories.length,
               shrinkWrap: true,
              // padding: EdgeInsets.all(5),
               scrollDirection: Axis.horizontal,
               itemBuilder: (BuildContext context, int index) {
                 return Padding(
                   padding: const EdgeInsets.only(right: 5.0),
                   child: Container(
                    padding:const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromARGB(255, 120, 119, 119)),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(categories[index]),
                    ),
                 );
               },
             ),
           ),
           const SizedBox(height: 15,),
           GridView.builder(
            shrinkWrap: true,
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: 2,
             ),
             itemCount: 2,
             itemBuilder: (BuildContext context, int index) {
               return Card();
             },
           ),
          ],
        ),
      );
}
Widget search(){
  return SingleChildScrollView(
    child: Column(
      children: [
        SizedBox(height: 15,),
        Padding(
          padding: EdgeInsets.all(10),
          child: SearchBar(
            leading: Icon(Icons.search),
            hintText: "Search for an item eg.milk",
          ))
      ],
    ),
  );
}

Widget cart(){
  return SingleChildScrollView(
    child: Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
          ),
          title: Text("User Name",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text("My Cart"),
        )
      ],
    ),
  );
}