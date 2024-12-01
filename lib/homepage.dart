import 'dart:io';
import 'package:b_shop/authMethods.dart';
import 'package:b_shop/authPage.dart';
import 'package:b_shop/backEndFunctions.dart';
import 'package:b_shop/checkOut.dart';
import 'package:b_shop/main.dart';
import 'package:b_shop/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
int current_screen = 0;

// List images = [
//   "https://rubiskenya.com/wp-content/uploads/2023/09/rubis-gas-scaled-1.png",
//   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmv8AS3xqFXwGfpeggg6GjINaJpjQxJ9rZ4g&s",
//   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCGzSaUywHqv352rLqj8Zg9hV3qoJHQPhO2g&s"
// ];
// Map comDate = {
//   "Rubis 13kg gas":["Rubis 13kg refill with 1800",1800,5],
//   "Sea Gas 6kg ":["Seagas 6kg gas with free burner",2200,10],
//   "Exe Atta Mark 1 2kg":["2KG of exe unga for chapatis",160,20],
// };
bool darkmode = false;
Future<String> getImage(BuildContext context)async{
  String image = "";
  Permission.accessMediaLocation
    .onDeniedCallback(() async {
  Permission.accessMediaLocation.request();
  if (await Permission.accessMediaLocation.isDenied) {
    showsnackbar(context, "Permission denied");
  }
  if (await Permission.accessMediaLocation.isGranted) {
    showsnackbar(context, 'Granted');
  }
});
FilePickerResult? result = (await FilePicker.platform
    .pickFiles(type: FileType.image,allowMultiple: false));
if (result != null) {
  image = result.files.single.path!;
  
 // setState(() {});
}
if (result == null) {
  showsnackbar(context, 'no image chossen');
}
return image;
}
void saveTheme()async{
   darkmode?
     await Hive.box("Theme").put("DarkMode",0):
     await Hive.box("Theme").put("DarkMode", 1);
}
Future<List> openboxs()async{
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
  await Hive.openBox("Categories");
  List categoriesL =[];

   if(Hive.box("Categories").isEmpty){
    await getCategories();
    categoriesL = Hive.box("Categories").values.toList();
   }else{
    categoriesL = Hive.box("Categories").values.toList();
   }
  
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
              child: FutureBuilder(
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
                          //print(snapshotdp.data);
                          return  CircleAvatar(
                        radius: 80,
                        backgroundImage: MemoryImage(snapshotdp.data),
                        );
                        },
                      ),
                ),
            ListTile(
              title: const Text("Feedback"),
              onTap: (){
                showsnackbar(context, "Coming soon");
              },
            ),
            ListTile(
              onTap: ()async{
                FirebaseAuth.instance.currentUser == null?
                Navigator.push(context,MaterialPageRoute(builder: (context)=>const Authpage())):
                await AuthMethods().logoutA();
              },
              title:FirebaseAuth.instance.currentUser == null?const Text("LogIn"):const Text("LogOut"),
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
  String filter ="All";
  ValueNotifier<int> refreshFeed = ValueNotifier(0);
  return SingleChildScrollView(
        child: Column(
          children: [
          const SizedBox(height: 15,),
           SizedBox(
            height: 50,
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
                        decoration:const BoxDecoration(
                          color:Color.fromARGB(255, 112, 110, 110),
                        ),
                        child:const Text(""),
                      );
                    },
                  );
                }
                List catego = ["All"];
                catego.addAll(snapshott.data!);
                 return StatefulBuilder(
                   builder: (context,categoState) {
                     return ListView.builder(
                       itemCount: catego.length,
                       shrinkWrap: true,
                      // padding: EdgeInsets.all(5),
                       scrollDirection: Axis.horizontal,
                       itemBuilder: (BuildContext context, int index) {
                         return Padding(
                           padding: const EdgeInsets.only(left: 5.0),
                           child: TextButton(onPressed: (){
                            if(filter != catego[index]){
                              refreshFeed.value++;
                              categoState((){
                              filter = catego[index];
                            });
                            }
                           }, child:Column(
                             children: [
                               Text(catego[index]),
                               Container(
                                height: 5,
                                width: catego[index].length.toDouble()*10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:filter==catego[index]? Colors.blue:Colors.transparent
                                ),
                               )
                             ],
                           )),
                         );
                       },
                     );
                   }
                 );
               }
             ),
           ),
           const SizedBox(height: 15,),
           ListenableBuilder(
            listenable: refreshFeed,
             builder: (context,child) {
               return FutureBuilder(
                future: getFeed(filter),
                 builder: (context,feedSnapshot) {
                  if (feedSnapshot.connectionState == ConnectionState.waiting) {
                    // print("............................");
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
                  }
                  // print(feedSnapshot.data);
                  if (feedSnapshot.data!.isEmpty) {
                    return const Center(child: Text("All items in this category are sold-out"),);
                  }
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
                      // print("/////////////////////////");
                      String name = feedSnapshot.data![conKeys[index]]["Name"];
                      int priceN = feedSnapshot.data![conKeys[index]]["Price"].toInt();
                      Map <String,dynamic> items = {conKeys[index]:[name,priceN,1]};
                      
                      int ammountInCart = 0;
                      bool incart = false;
                      if ( Hive.box("UserData").containsKey("Cart")) {
                         Map cart = Hive.box("UserData").get("Cart");
                         if (cart.containsKey(conKeys[index])) {
                           incart = true;
                           ammountInCart = cart[conKeys[index]].last;
                           //print("bbbbbbbbbbbbbbbbbbb");
                         }
                      }
                       return Card(
                        elevation: 0,
                        color: Colors.transparent,
                        
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
                                    fit: BoxFit.fill,
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
                            StatefulBuilder(
                              builder: (context,cartState) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    !incart?
                                    IconButton(
                                      padding:const EdgeInsets.all(0),
                                      onPressed: ()async{
                                        if(FirebaseAuth.instance.currentUser ==null)
                                        {showDialog(context: context, builder: (context){
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
                                        });}else{
                                          ammountInCart++;
                                          await addtoCart(conKeys[index], ammountInCart, name,priceN.toDouble());
                                         cartState((){
                                          incart = true;
                                         });
                                        }
                                      }, icon:const Icon(Icons.add_shopping_cart,size: 20,)):
                                      InputQty.int(
                                        onQtyChanged: (val)async {
                                        ammountInCart = val;
                                       await addtoCart(conKeys[index], val, name,priceN.toDouble());
                                      },
                                      ),
                                      TextButton(onPressed: (){
                                        List locationdata = [];
                                        showDialog(context: context, builder: (context){
                                          return Dialog(
                                            child: Container(
                                              height: MediaQuery.of(context).size.height/2,
                                              child: FutureBuilder(
                                                future: Hive.openBox("AddressBook"),
                                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const Center(child: CircularProgressIndicator(),);
                                                  }
                                                  Box addressbox = Hive.box("AddressBook");
                                                  
                                                  return ListView.builder(
                                                    itemCount: addressbox.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      String nameAdress = addressbox.get(addressbox.keys.toList()[index]).first;
                                                      String other = addressbox.get(addressbox.keys.toList()[index]).last;
                                                      double latitude = addressbox.get(addressbox.keys.toList()[index])[1];
                                                      double longitude = addressbox.get(addressbox.keys.toList()[index])[2];
                                                      return ListTile(
                                                        onTap: ()async{
                                                          locationdata = addressbox.get(addressbox.keys.toList()[index]);
                                                          await Navigator.pushReplacement(context, (MaterialPageRoute(builder: (context)=>Checkout(items: items, location: locationdata))));
                                                        },
                                                        title: Text(nameAdress),
                                                        subtitle: Text(other),
                                                        trailing: IconButton(onPressed: ()async{
                                                          await openMap(latitude, longitude, context);
                                                        }, 
                                                        icon:const Icon(FontAwesomeIcons.mapLocation)
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        });
                                      }, child:const Text("Buy Now"))
                                  ],
                                );
                              }
                            )
                          ],
                        ),
                       );
                     },
                   );
                 }
               );
             }
           ),
          ],
        ),
      );
}

class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}
Map filteredFeed ={};
TextEditingController searchController = TextEditingController();
class _searchState extends State<search> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
           Padding(
          padding:const EdgeInsets.all(10),
          child: SearchBar(
            controller: searchController,
            leading:const Icon(Icons.search),
            hintText: "Search for an item eg.milk",
            onChanged: (value){
              List toRemove =[];
              filteredFeed.forEach((key,value0){
                //String test ="";
                if (!value0["Name"].toLowerCase().contains(value.toLowerCase())) {
                  toRemove.add(key);
                }
              });
              toRemove.forEach((value){
                filteredFeed.remove(value);
              });
              setState(() {
                
              });
            },
          )),
          FutureBuilder(
            future: getFeed(""),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              if (filteredFeed.isEmpty && searchController.text.isEmpty) {
                filteredFeed = snapshot.data!;
              }
              return GridView.builder(
                shrinkWrap: true,
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                 ),
                 itemCount: filteredFeed.length,
                 itemBuilder: (BuildContext context, int index) {
                  // List contentkeys = comDate.keys.toList();
                  // var price = comDate[contentkeys[index]][1];
                  // //String name = comDate[contentkeys[index]][0];
                  List conKeys = filteredFeed.keys.toList();
                  String name = filteredFeed[conKeys[index]]["Name"];
                  int priceN = filteredFeed[conKeys[index]]["Price"].toInt();
                  Map <String,dynamic> items = {conKeys[index]:[name,priceN,1]};
                  int ammountInCart = 0;
                  bool incart = false;
                  if ( Hive.box("UserData").containsKey("Cart")) {
                     Map cart = Hive.box("UserData").get("Cart");
                     if (cart.containsKey(conKeys[index])) {
                       incart = true;
                       ammountInCart = cart[conKeys[index]].last;
                     }
                  }
                   return Card(
                    elevation: 0,
                    color: Colors.transparent,
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
                        StatefulBuilder(
                          builder: (context,cartState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                !incart?
                                IconButton(
                                  padding:const EdgeInsets.all(0),
                                  onPressed: ()async{
                                    if(FirebaseAuth.instance.currentUser ==null)
                                    {showDialog(context: context, builder: (context){
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
                                    });}else{
                                      ammountInCart++;
                                    await addtoCart(conKeys[index], ammountInCart, name,priceN.toDouble());
                                     cartState((){
                                      incart = true;
                                     });
                                    }
                                    
                                    
                                  }, icon:const Icon(Icons.add_shopping_cart,size: 20,)):
                                  InputQty.int(
                                    onQtyChanged: (val)async {
                                    ammountInCart = val;
                                   await addtoCart(conKeys[index], val, name,priceN.toDouble());
                                  },
                                  ),
                                  TextButton(onPressed: ()async{
                                    List locationdata = [];
                                    showDialog(context: context, builder: (context){
                                      return Dialog(
                                        child: Container(
                                          height: MediaQuery.of(context).size.height/2,
                                          child: FutureBuilder(
                                            future: Hive.openBox("AddressBook"),
                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator(),);
                                              }
                                              Box addressbox = Hive.box("AddressBook");
                                              
                                              return ListView.builder(
                                                itemCount: addressbox.length,
                                                shrinkWrap: true,
                                                itemBuilder: (BuildContext context, int index) {
                                                  String nameAdress = addressbox.get(addressbox.keys.toList()[index]).first;
                                                  String other = addressbox.get(addressbox.keys.toList()[index]).last;
                                                  double latitude = addressbox.get(addressbox.keys.toList()[index])[1];
                                                  double longitude = addressbox.get(addressbox.keys.toList()[index])[2];
                                                  return ListTile(
                                                    onTap: ()async{
                                                      locationdata = addressbox.get(addressbox.keys.toList()[index]);
                                                      await Navigator.pushReplacement(context, (MaterialPageRoute(builder: (context)=>Checkout(items: items, location: locationdata))));
                                                    },
                                                    title: Text(nameAdress),
                                                    subtitle: Text(other),
                                                    trailing: IconButton(onPressed: ()async{
                                                      await openMap(latitude, longitude, context);
                                                    }, 
                                                    icon:const Icon(FontAwesomeIcons.mapLocation)
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    });

                                    
                                  }, child:const Text("Buy Now"))
                              ],
                            );
                          }
                        )
                      ],
                    ),
                   );
                 },
               );
            },
          ),
        ],
      ),
    );
  }
}
// Widget search(){
//   return SingleChildScrollView(
//     child: Column(
//       children: [
//         SizedBox(height: 15,),
//         Padding(
//           padding: EdgeInsets.all(10),
//           child: SearchBar(
//             leading: Icon(Icons.search),
//             hintText: "Search for an item eg.milk",
//           ))
//       ],
//     ),
//   );
// }

class cart extends StatefulWidget {
  const cart({super.key});

  @override
  State<cart> createState() => _cartState();
}
 bool selectedaddress = false;
 List selectedAddress = [];
 Map<String,dynamic> items = {};
 ValueNotifier<int> cartView = ValueNotifier(0);
 void openCartbox()async{
 await Hive.openBox("Cart");
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
              child: ListenableBuilder(
                listenable: Hive.box("UserData").listenable(),
                builder: (context,child) {
                  return ListTile(
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
                          //print(snapshotdp.data);
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
                                  StatefulBuilder(
                                    builder: (context,dpState) {
                                      return Stack(
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
                                              if((snapshotdp.data == null|| snapshotdp.data.isEmpty) && imagePath.isEmpty){
                                                //print("domnnnnn");
                                                return const CircleAvatar(
                                                radius: 50,
                                              child: Icon(Icons.shopping_cart,size: 30,),
                                              );
                                              }
                                              //print(snapshotdp.data);
                                              if (imagePath.isNotEmpty) {
                                                //print("object");
                                                return  CircleAvatar(
                                                radius: 50,
                                                backgroundImage: FileImage(File(imagePath)),
                                            );
                                              }
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
                                              onPressed: ()async{
                                                imagePath = await getImage(context);
                                                dpState((){});
                                              }, 
                                              icon:const Icon(Icons.change_circle)),
                                          )
                                        ],
                                      );
                                    }
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
                    );
                }
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
                    Center(child: TextButton(
                      onPressed: ()async{
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
                    StatefulBuilder(
                      builder: (context,selectAdressState) {
                        return ListView.builder(
                          itemCount: addressBox.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onLongPress: (){
                                //Edit the Address

                              },
                              onTap:(){
                                // double latitude = addressBox.get(addressBox.keys.toList()[index])[1];
                                // double longitude = addressBox.get(addressBox.keys.toList()[index])[2];
                                selectedaddress = true;
                                selectedAddress=addressBox.get(addressBox.keys.toList()[index]);
                                selectAdressState((){});
                              },
                              title: Text("${addressBox.get(addressBox.keys.toList()[index]).first}"),
                              subtitle: Text(addressBox.get(addressBox.keys.toList()[index]).last),
                              leading:selectedAddress==addressBox.get(addressBox.keys.toList()[index])?
                              const Icon(Icons.check_box):
                              const Icon(Icons.check_box_outline_blank),
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
                    );
                  }
                )
                ;
              },
            ),
          ],
        ),
       ),
       ListenableBuilder(
        listenable: cartView,
         builder: (context,child) {
           return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: (){
                cartView.value = 0;
              }, child:Container(
                padding:const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: cartView.value ==0?
                  const Color.fromARGB(255, 4, 61, 108):
                  Colors.transparent
                ),child:  Text("My Cart",style: TextStyle(
                  color:cartView.value==0? Colors.white:null,
                  fontWeight: FontWeight.bold,fontSize: 15),),
              )),
              TextButton(onPressed: (){
                cartView.value = 1;
              }, child: Container(
                padding:const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: cartView.value ==1?
                  const Color.fromARGB(255, 4, 61, 108):
                  Colors.transparent
                ),
                child:  Text(
                  "Open Orders",
                  style: TextStyle(
                    color: cartView.value==1?
                    Colors.white:
                    null,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  ),
                  ),
              )),
              TextButton(onPressed: (){
                cartView.value = 2;
              }, child:  Container(
                padding:const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: cartView.value == 2?
                     const Color.fromARGB(255, 4, 61, 108):
                    Colors.transparent
                ),
                child: Text(
                  "Closed Orders",style: 
                  TextStyle(
                    color: cartView.value==2?
                    Colors.white:
                    null,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  ),
                  ),
              )),
            ],
           );
         }
       ),
       ListenableBuilder(
        listenable: cartView,
        builder: (context,child){
          return Visibility(
            visible: cartView.value == 1,
            child: FutureBuilder(
              future: getOpenOrders(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (snapshot.data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("No Orders placed"),
                    ),
                  );
                }
                List cartKeys = snapshot.data.keys.toList();
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    Map itemsOpen = snapshot.data[cartKeys[index]];
                    return Card(
                      child: ListView.builder(
                        itemCount: itemsOpen["items"].length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          List itemId = itemsOpen["items"].keys.toList(); 
                          
                          List order = itemsOpen["items"][itemId[index]];
                          // print(order);
                          return ListTile(
                            title: Text(order.first),
                            subtitle: Text("X${order.last}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("${order[1]*order.last}"),
                                const Text("In transit")
                              ],
                            )
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        }),
        ListenableBuilder(
          listenable: cartView, 
          builder: (context,child){
            return Visibility(
              visible: cartView.value == 2,
              child: FutureBuilder(
                future: getClossedOrders(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  List cartKeys = snapshot.data.keys.toList();
                  if (snapshot.data.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No Complete deliveries"),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      Map itemsClosed = snapshot.data[cartKeys[index]];
                      return Card(
                        child: ListView.builder(
                        itemCount: itemsClosed["items"].length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          List itemId = itemsClosed["items"].keys.toList(); 
                          
                          List order = itemsClosed["items"][itemId[index]];
                          // print(order);
                          return ListTile(
                            title: Text(order.first),
                            subtitle: Text("X${order.last}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("${order[1]*order.last}"),
                                const Text("Delivered on ....")
                              ],
                            )
                          );
                        },
                      ),
                      );
                    },
                  );
                },
              ),
            );
          }),
        ListenableBuilder(
          listenable: cartView,
          builder: (context,child) {
            return Visibility(
              visible: cartView.value == 0,
              child: ListenableBuilder(
                listenable: Hive.box("UserData").listenable(),
                builder: (context,child) {
                  return FutureBuilder(
                    future: getCart(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      //print(snapshot.data);
                      Map cart = snapshot.data!;
                      List names = [];
                      List quantities = [];
                      List prices = [];
                      List cartId = [];
                      print(cart);
                     cart.forEach((key,value){
                      names.add(value.first);
                      quantities.add(value.last);
                      prices.add(value[1]);
                      cartId.add(key);
                      items.addAll({key:[value.first,value[1],value.last]});
                     });
                     
                    return snapshot.data.isNotEmpty? 
                    ListView.builder(
                    itemCount: snapshot.data.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                           //minTileHeight: 100,
                           contentPadding:const EdgeInsets.all(5),
                          // leading: Image(image:),
                            title: Text(names[index]),
                            subtitle: Text("X ${quantities[index]}",softWrap: true,maxLines: 3,overflow: TextOverflow.ellipsis,),
                           trailing: Column(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               Text("KSH ${(prices[index]*quantities[index])}",style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                               Expanded(child: TextButton(onPressed: ()async{
                                 await removeFromCart(cartId[index]);
                               }, child:const Text("Remove",style: TextStyle(color: Colors.red,fontWeight:FontWeight.w500,decoration: TextDecoration.underline),))),
                                      
                             ],
                           ),
                          ),
                        ),
                      );
                    },
                  ):
                 const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Icon(Icons.shopping_cart_sharp),
                        Text("your Cart is empty"),
                        SizedBox(height: 20,),
                      ],
                    ),
                  )
                  ;
                    },
                  );
                }
              ),
            );
          }
        ),
       // const SizedBox(height: 20,),
       
        ListenableBuilder(
          listenable: cartView,
          builder: (context,child) {
            return Visibility(
              visible: cartView.value == 0,
              child: Card(
                margin:const EdgeInsets.all(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: ()async{
                    if (items.isEmpty) {
                      showsnackbar(context, "Empty Cart");
                    }
                    if (selectedaddress && items.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Checkout(items: items,location: selectedAddress,)));
                    }if(!selectedaddress){
                      showsnackbar(context, "Select Address");
                      // await placeOrder(
                      //   items, 
                      //   ["location"], 
                      //   false, 
                      //   5, 
                      //   "0745222065"
                      //   );
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
              ),
            );
          }
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