import 'package:b_shop/authPage.dart';
import 'package:b_shop/backEndFunctions.dart';
import 'package:b_shop/checkOut.dart';
import 'package:b_shop/main.dart';
import 'package:b_shop/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
int current_screen = 0;

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
void saveTheme()async{
   darkmode?
     await Hive.box("Theme").put("DarkMode",0):
     await Hive.box("Theme").put("DarkMode", 1);
}
Future<List> openboxs()async{
  await Hive.openBox("Categories");
  List categoriesL = Hive.box("Categories").isEmpty?[]:
  Hive.box("Categories").values.toList();
  return categoriesL;
}
class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
   
    getCategories();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width/5,
                 child:const Icon(Icons.shopping_cart,size: 80,),
                ),),
           const ListTile(
              title: Text("Feedback"),
            ),
            ListTile(
              onTap: ()async{
                await FirebaseAuth.instance.signOut();
              },
              title:const Text("Logout"),
            )

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
                saveTheme();
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
      current_screen == 1?search():cart(),
      bottomNavigationBar: BottomAppBar(
        height: 60,
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
            }, icon: Icon(Icons.home,size: 30,color: current_screen==0?Colors.blue:null,)),
            IconButton(onPressed: (){
              setState(() {
                current_screen = 1;
              });
            }, icon: Icon(Icons.search,size: 30,color: current_screen==1?Colors.blue:null,)),
            IconButton(onPressed: (){
              setState(() {
                current_screen = 2;
              });
            }, icon:Icon(Icons.shopping_cart,size: 30,color: current_screen==2?Colors.blue:null,))
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
             child: FutureBuilder(
              future: openboxs(),
               builder: (context,snapshott) {
                if (snapshott.connectionState == ConnectionState.waiting) {
                  return  ListView.builder(
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 30,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 112, 110, 110),

                        ),
                        child:const Text(""),
                      );
                    },
                  );
                }
                 return ListView.builder(
                   itemCount: snapshott.data!.length,
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
                            child: Text(snapshott.data![index]),
                          ),
                        ),
                     );
                   },
                 );
               }
             ),
           ),
           const SizedBox(height: 15,),
           FutureBuilder(
            future: getFeed(),
             builder: (context,feedSnapshot) {
              if (feedSnapshot.connectionState == ConnectionState.waiting) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    return const Card();
                  },
                );
              }print(feedSnapshot.data);
               return GridView.builder(
                shrinkWrap: true,
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                 ),
                 itemCount: feedSnapshot.data!.length,
                 itemBuilder: (BuildContext context, int index) {
                  // List contentkeys = comDate.keys.toList();
                  // var price = comDate[contentkeys[index]][1];
                  // //String name = comDate[contentkeys[index]][0];
                  List conKeys = feedSnapshot.data!.keys.toList();
                  String name = feedSnapshot.data![conKeys[index]]["Name"];
                  int priceN = feedSnapshot.data![conKeys[index]]["Price"].toInt();
                  Map <String,dynamic> items = {name:priceN};
                   return Card(
                    elevation: 1,
                    //color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: 
                        FutureBuilder(
                          future: getImages(conKeys[index]),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center();
                            }
                            //print(snapshot.data.length);
                            return Center(
                              child: Image(
                                image: MemoryImage(snapshot.data.first)
                                ));
                          },
                        ),
                        ),
                        Padding(padding:const EdgeInsets.only(top: 5,left: 5,right: 5),
                        child: Text(name,softWrap: true, 
                        style:const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,overflow: TextOverflow.ellipsis,),),
                         Padding(
                          padding:const EdgeInsets.only(left: 5,right: 5),
                           child: Text("KSH $priceN",style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                         ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              padding:const EdgeInsets.all(0),
                              onPressed: ()async{
                                showDialog(context: context, builder: (context){
                                  return Dialog(
                                    child: Container(
                                      height: 100,
                                      width: 200,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                         
                                        const Padding(
                                           padding:  EdgeInsets.all(8.0),
                                           child:  Text(
                                            "Login or register to add items to cart",
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            ),
                                         ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextButton(onPressed: ()async{
                                                Navigator.pop(context);
                                               await Navigator.push(context, (MaterialPageRoute(builder: (context)=>const Authpage())));
                                              }, child:const Text("Ok")),
                                              TextButton(onPressed: (){
                                                Navigator.pop(context);
                                              }, child:const Text("Cancel"))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              }, icon:const Icon(Icons.add_shopping_cart,size: 20,)),
                              TextButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Checkout(items: items)));
                              }, child:const Text("Buy Now"))
                          ],
                        )
                      ],
                    ),
                   );
                 },
               );
             }
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

class cart extends StatefulWidget {
  const cart({super.key});

  @override
  State<cart> createState() => _cartState();
}
 bool selectedaddress = false;
 Map<String,dynamic> items = {};
 void openCartbox()async{
  Hive.openBox("Cart");
 }
class _cartState extends State<cart> {
  @override
  void initState() {
    super.initState();
    openCartbox();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    child: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: InkWell(
              onTap: ()async{
                await Navigator.push(context, (MaterialPageRoute(builder: (context)=>const Authpage())));
              },
              child:const Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login,size: 100,),
                Text("Log In to View Cart")
              ],
              ),
            ),);
        }
        return Column(
          children: [
            FutureBuilder(
              future: getUser(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Container(
              child: ListTile(
                  leading:const CircleAvatar(
                  radius: 30,
                  ),
                  title: Container(
                    height: 20,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 115, 115, 115)),
                  ),
                  subtitle:const Text("My Cart"),
                  trailing: IconButton(onPressed: (){
                
                  }, icon:const Icon(Icons.edit)),
                ),
            );
                }
                //print(snapshot.data);
                String userName = snapshot.data["Name"];
                return Container(
              child: ListTile(
                  leading:FutureBuilder(
                    future: getDp(),
                    
                    builder: (BuildContext context, AsyncSnapshot snapshotdp) {
                      if (snapshotdp.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                        radius: 30,
                        );
                      }
                      if(snapshotdp.data == null|| snapshotdp.data.isEmpty){
                        return const CircleAvatar(
                        radius: 30,
                      child: Icon(Icons.shopping_cart,size: 30,),
                      );
                      }
                      print(snapshotdp.data);
                      return  CircleAvatar(
                    radius: 30,
                    backgroundImage: MemoryImage(snapshotdp.data),
                    );
                    },
                  ),
                  title: Text(userName,style:const TextStyle(fontWeight: FontWeight.bold),),
                  subtitle:const Text("My Cart"),
                  trailing: IconButton(onPressed: (){
                    TextEditingController changeName =TextEditingController();
                    String imagePath ="";
                    showDialog(context: context,
                     builder: (context){
                      return Dialog(
                        child: Container(
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  FutureBuilder(
                                    future: getDp(),
                                    builder: (BuildContext context, AsyncSnapshot snapshotdp) {
                                      if (snapshotdp.connectionState == ConnectionState.waiting) {
                                        return const CircleAvatar(
                                        radius: 50,
                                        );
                                      }
                                      if(snapshotdp.data == null|| snapshotdp.data.isEmpty){
                                        return const CircleAvatar(
                                        radius: 50,
                                      child: Icon(Icons.shopping_cart,size: 30,),
                                      );
                                      }
                                      print(snapshotdp.data);
                                      return  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: MemoryImage(snapshotdp.data),
                                    );
                                    },
                                  ),
                                  Positioned(
                                    right: -13,
                                    bottom: -14,
                                    child: IconButton(
                                      splashColor: Colors.transparent,
                                      onPressed: (){
                                        
                                      }, 
                                      icon:const Icon(Icons.change_circle)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20,),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextField(
                                  controller: changeName,
                                  decoration: InputDecoration(
                                    labelText: "Change name",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:const BorderSide(color:  Color.fromARGB(255, 103, 101, 101))
                                    )
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: ()async{
                                  String state ="";
                                  while (state.isEmpty) {
                                    showcircleprogress(context);
                                    state = await updateProfile(
                                      changeName.text
                                      , imagePath
                                      );
                                  }
                                  Navigator.pop(context);
                                  if (state == "Success") {
                                    Navigator.pop(context);
                                    setState(() {
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromARGB(255, 20, 36, 49)
                                  ),
                                  height: 40,
                                  width: 200,
                                  child:const Text("Save Changes",style: TextStyle(color: Colors.white),),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                     });
                  }, icon:const Icon(Icons.edit)),
                ),
            );
              },
            ),
            
            const Divider(),
       Container(
        //height: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              child: Stack(
                children: [
                 const Center(child: Text("Delivery Location",style: TextStyle(fontWeight: FontWeight.bold),),),
                  Positioned(
                    right: 10,
                    top: -2,
                    //bottom: 0,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      onPressed: ()async{
                        await Hive.openBox("AddressBook");
                        Box addressBox = Hive.box("AddressBook");
                        showDialog(context: context, 
                        builder: (context){
                          return Dialog(
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                const Text("Add Delivery Location",style: TextStyle(fontWeight: FontWeight.bold),),
                                TextButton(onPressed: ()async{
                                  //////Add adress////// add location plugin
                                  
                                  //String state0 = "";
                                  LocationData locationData = await getLocation(context);
                                  Navigator.pop(context);
                                  TextEditingController namecontrollerA = TextEditingController();
                                  TextEditingController detailcontroller = TextEditingController();
                                  int num = addressBox.length+1;
                                  String adressname = "Address $num";
                                  showDialog(context: context, 
                                  builder: (context){
                                    return Dialog(
                                      child: Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("New Address",style: TextStyle(fontWeight: FontWeight.bold),),
                                            Padding(
                                              padding:const EdgeInsets.all(10),
                                              child: TextField(
                                                controller: namecontrollerA,
                                                decoration: InputDecoration(
                                                  hintText: adressname,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(13),
                                                    borderSide:const BorderSide(color:  Color.fromARGB(255, 88, 88, 88))
                                                  )
                                                ),
                                              ),
                                              ),
                                              //const SizedBox(height: 10,),
                                              Padding(
                                              padding:const EdgeInsets.all(10),
                                              child: TextField(
                                                controller: detailcontroller,
                                                decoration: InputDecoration(
                                                  hintText: "More info. eg, 2nd floor ,room 12",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(13),
                                                    borderSide:const BorderSide(color:  Color.fromARGB(255, 88, 88, 88))
                                                  )
                                                ),
                                              ),
                                              ),
                                              //const SizedBox(height: 20,),
                                              TextButton(onPressed: ()async{
                                                String state1 = "";
                                                while(state1.isEmpty){
                                                  showcircleprogress(context);
                                                  state1 =await addAddress(
                                                    namecontrollerA.text.isEmpty?adressname:namecontrollerA.text, 
                                                    locationData.latitude!, 
                                                    locationData.longitude!, 
                                                    locationData.altitude!, 
                                                    detailcontroller.text);
                                                }
                                                Navigator.pop(context);
                                                if (state1 == "Success") {
                                                  Navigator.pop(context);
                                                  
                                                }else{
                                                  showsnackbar(context, state1);
                                                }
                                              }, child:const Text("Save Address"))
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  );
                                }, 
                                child:const Row(
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                      Text("Current Location"),
                                  ],
                                )),
                                TextButton(onPressed: ()async{
                                  LocationData address;
                                  address = await getLocation(context);
                                  await openMap(address.latitude!, address.longitude!,context);
                                  
                                },
                                  child:const Row(
                                  children: [
                                    Icon(Icons.map_outlined),
                                    Text("Preview Current Location"),
                                  ],
                                )),
                                ],
                              ),
                            ),
                          );
                        });


                      }, icon:const Icon(Icons.add)))
                ],
              ),
            ),
            FutureBuilder(
              future: Hive.openBox("AddressBook"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.bottomLeft,
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(255, 120, 120, 120)),
                  );
                }
                Box addressBox = Hive.box("AddressBook");
                return 
                ListenableBuilder(
                  listenable: addressBox.listenable(),
                  builder: (context,child) {
                    return addressBox.isEmpty?
                    Center(child: TextButton(onPressed: ()async{
                      showDialog(context: context, 
                      builder: (context){
                        return Dialog(
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                               const Text("Add Delivery Location",style: TextStyle(fontWeight: FontWeight.bold),),
                               TextButton(onPressed: ()async{
                                 //////Add adress////// add location plugin
                                 
                                 //String state0 = "";
                                 LocationData locationData = await getLocation(context);
                                 Navigator.pop(context);
                                 TextEditingController namecontrollerA = TextEditingController();
                                 TextEditingController detailcontroller = TextEditingController();
                                int num = addressBox.length+1;
                                String adressname = "Address $num";
                                 showDialog(context: context, 
                                 builder: (context){
                                  return Dialog(
                                    child: Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          const Text("New Address",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Padding(
                                            padding:const EdgeInsets.all(10),
                                            child: TextField(
                                              controller: namecontrollerA,
                                              decoration: InputDecoration(
                                                hintText: adressname,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(13),
                                                  borderSide:const BorderSide(color:  Color.fromARGB(255, 88, 88, 88))
                                                )
                                              ),
                                            ),
                                            ),
                                            //const SizedBox(height: 10,),
                                            Padding(
                                            padding:const EdgeInsets.all(10),
                                            child: TextField(
                                              controller: detailcontroller,
                                              decoration: InputDecoration(
                                                hintText: "More info. eg, 2nd floor ,room 12",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(13),
                                                  borderSide:const BorderSide(color:  Color.fromARGB(255, 88, 88, 88))
                                                )
                                              ),
                                            ),
                                            ),
                                            //const SizedBox(height: 20,),
                                            TextButton(onPressed: ()async{
                                              String state1 = "";
                                              while(state1.isEmpty){
                                                showcircleprogress(context);
                                                state1 =await addAddress(
                                                  namecontrollerA.text.isEmpty?adressname:namecontrollerA.text, 
                                                  locationData.latitude!, 
                                                  locationData.longitude!, 
                                                  locationData.altitude!, 
                                                  detailcontroller.text);
                                              }
                                              Navigator.pop(context);
                                              if (state1 == "Success") {
                                                Navigator.pop(context);
                                                
                                              }else{
                                                showsnackbar(context, state1);
                                              }
                                            }, child:const Text("Save Address"))
                                        ],
                                      ),
                                    ),
                                  );
                                 }
                                 );
                               }, 
                               child:const Row(
                                 children: [
                                  Icon(Icons.location_on_outlined),
                                    Text("Current Location"),
                                 ],
                               )),
                               TextButton(onPressed: ()async{
                                LocationData address;
                                address = await getLocation(context);
                                await openMap(address.latitude!, address.longitude!,context);
                                
                               },
                                child:const Row(
                                 children: [
                                  Icon(Icons.map_outlined),
                                   Text("Preview Current Location"),
                                 ],
                               )),
                              ],
                            ),
                          ),
                        );
                      });
                    }, 
                    child:const Row(children: [Icon(Icons.add_location_alt_rounded),Text("Add New Adress")],)
                    ),):
                    ListView.builder(
                      itemCount: addressBox.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text("Address ${addressBox.get(addressBox.keys.toList()[index]).first}"),
                          subtitle: Text(addressBox.get(addressBox.keys.toList()[index]).last),
                          leading:IconButton(onPressed: (){
                            //////edit the address name and delete features
                          }, icon:const Icon(Icons.edit)),
                          trailing: IconButton(onPressed: ()async{
                            ////open the maps app for location preview
                            double latitude = addressBox.get(addressBox.keys.toList()[index])[1];
                            double longitude = addressBox.get(addressBox.keys.toList()[index])[2];
                            await openMap(latitude, longitude, context);
                          }, icon:const Icon(FontAwesomeIcons.mapLocation)),
                        );
                      },
                    );
                  }
                )
                ;
              },
            ),
          ],
        ),
       ),
        FutureBuilder(
          future: getCart(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            return ListView.builder(
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
        );
      },
    ),
  );
  }
}

// Widget cart0(BuildContext context){
//  
//   
//   comDate.forEach((key,value){
//     items.addAll({key:value[1]});
//   });
//   return 
// }