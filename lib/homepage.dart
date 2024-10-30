import 'package:b_shop/checkOut.dart';
import 'package:b_shop/main.dart';
import 'package:b_shop/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
List images = [
  "https://rubiskenya.com/wp-content/uploads/2023/09/rubis-gas-scaled-1.png",
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmv8AS3xqFXwGfpeggg6GjINaJpjQxJ9rZ4g&s",
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCGzSaUywHqv352rLqj8Zg9hV3qoJHQPhO2g&s"
];
Map comDate = {
  "Rubis 13kg gas":["Rubis 13kg refill with 1800",1800,5],
  "Sea Gas 6kg ":["Seagas 6kg gas with free burner",2200,10],
  "Exe Atta Mark 1 2kg":["2KG of exe unga for chapatis",160,20],
};
bool darkmode = false;
class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: CircleAvatar(radius: MediaQuery.of(context).size.width/5,),),
            const Text("Can add more "),
           const ListTile(
              title: Text("Feedback"),
            ),

          ],
        ),
      ),
      floatingActionButton: 
      IconButton(onPressed: ()async{
        final Uri _phoneUri = Uri(
      scheme: "tel",
      path: "0792006050"
  );
  await launchUrl(_phoneUri);
      }, 
      icon:const CircleAvatar(
        radius: 20,
        child: Padding(
        padding: EdgeInsets.all(5),
        child: Icon(Icons.call)))),
      appBar:AppBar(
        actions: [
          StatefulBuilder(
            builder: (context,themestate) {
              return IconButton(onPressed: (){
              if (darkmode) {
                MyApp.of(context)!.changeTheme(ThemeMode.light);
              }else{
                MyApp.of(context)!.changeTheme(ThemeMode.dark);
              }
              themestate((){
                darkmode = !darkmode;
              });
             }, icon: Icon(darkmode?Icons.dark_mode: Icons.sunny));
            }
          )],
        //toolbarHeight: 30,
        title:const Text("B_Shop ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        ),
      body:current_screen==0? home():
      current_screen == 1?search():cart(context),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              splashColor: Colors.transparent,
              enableFeedback: false,
              onPressed: (){
              setState(() {
                current_screen = 0;
              });
            }, icon:   Icon(Icons.home,size: 30,color: current_screen==0?Colors.blue:null,)),
            IconButton(onPressed: (){
              setState(() {
                current_screen = 1;
              });
            }, icon: Icon(Icons.search,size: 30,color: current_screen==1?Colors.blue:null,)),
            IconButton(onPressed: (){
              setState(() {
                current_screen = 2;
              });
            }, icon:Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Icon(Icons.shopping_cart,size: 30,color: current_screen==2?Colors.blue:null,),
            ))
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
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0,right: 10),
                        child: Text(categories[index]),
                      ),
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
             itemCount: images.length,
             itemBuilder: (BuildContext context, int index) {
              List contentkeys = comDate.keys.toList();
              var price = comDate[contentkeys[index]][1];
              //String name = comDate[contentkeys[index]][0];
              Map <String,dynamic> items = {contentkeys[index]:price};
               return Card(
                elevation: 1,
                //color: Colors.transparent,
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Center(child: Image(image: NetworkImage(images[index])))),
                    Padding(padding:const EdgeInsets.only(top: 5,left: 5,right: 5),child: Text(contentkeys[index],softWrap: true, maxLines: 2,overflow: TextOverflow.ellipsis,),),
                     Padding(
                      padding:const EdgeInsets.only(left: 5,right: 5),
                       child: Text("KSH ${price.toString()}",style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                     ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          padding:const EdgeInsets.all(0),
                          onPressed: (){}, icon:const Icon(Icons.add_shopping_cart,size: 20,)),
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Checkout(items: items)));
                          }, child:const Text("Buy Now"))
                      ],
                    )
                  ],
                ),
               );
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

Widget cart(BuildContext context){
  bool selectedaddress = false;
  Map<String,dynamic> items = {};
  comDate.forEach((key,value){
    items.addAll({key:value[1]});
  });
  return SingleChildScrollView(
    child: Column(
      children: [
        ListTile(
          leading:const CircleAvatar(
            radius: 30,
          ),
          title:const Text("User Name",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle:const Text("My Cart"),
          trailing: IconButton(onPressed: (){}, icon:const Icon(Icons.edit)),
        ),
       const Divider(),
       Container(
        //height: 30,
        child: Column(
          children: [
            SizedBox(
              height: 30,
              child: Stack(
                children: [
                 const Center(child: Text("Delivery Location"),),
                  Positioned(
                    right: 10,
                    top: -2,
                    //bottom: 0,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      onPressed: (){}, icon:const Icon(Icons.add)))
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Home Address"),
              trailing: StatefulBuilder(
                builder: (BuildContext context, setStateloc) {
                  return IconButton(onPressed: (){
                    setStateloc((){
                      selectedaddress = !selectedaddress;
                    });
                  }, icon: Icon(selectedaddress?Icons.check_box: Icons.check_box_outline_blank_outlined));
                },
              ),
            )
          ],
        ),
       ),
        ListView.builder(
          itemCount: images.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
           List names = comDate.keys.toList();
            return Card(
              elevation: 6,
              child: SizedBox(
                //height: 150,
                child:
                 ListTile(
                  //minTileHeight: 100,
                  contentPadding:const EdgeInsets.all(5),
                  leading: Image(image: NetworkImage(images[index])),
                  title: Text(names[index]),
                  subtitle: Text(comDate[names[index]][0],softWrap: true,maxLines: 3,overflow: TextOverflow.ellipsis,),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("KSH ${comDate[names[index]][1].toString()}",style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                      Expanded(child: TextButton(onPressed: (){}, child:const Text("Remove",style: TextStyle(color: Colors.red,fontWeight:FontWeight.w500,decoration: TextDecoration.underline),))),

                    ],
                  ),
                 )
                ),
            );
          },
        ),
       // const SizedBox(height: 20,),
        Card(
          margin:const EdgeInsets.all(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: (){
              if (selectedaddress) {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Checkout(items: items,)));
              }else{
                showsnackbar(context, "Select Address");
              }
            },
            splashColor: const Color.fromARGB(56, 33, 149, 243),
            enableFeedback: false,
            child:const Padding(
              padding:  EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Check out"),
                  Icon(Icons.exit_to_app)
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}