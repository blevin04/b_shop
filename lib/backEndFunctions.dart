
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();
User _user = FirebaseAuth.instance.currentUser!;

Future<Map<String,dynamic>> getFeed()async{
    Map<String,dynamic> feed ={};
    await firestore.collection("Products").where("Stock",isGreaterThan: 0).get().then((onValue){
        for(var value in onValue.docs){
            final product = {value.id:value.data()};
            feed.addAll(product);
        }
    });
    return feed;
}
Future<List<Uint8List>> getImages(
    String productId
)async{
    List<Uint8List> productImages =[];
    await storage.child("Products/$productId").list().then((onValue)async{
        for(var value in onValue.items){
            final data =await value.getData();
            productImages.add(data!);
        }
    });
    return productImages;
}
void getCategories()async{
    await Hive.openBox("Categories");
   var categories= Hive.box("Categories");
   if (categories.isEmpty) {
    await firestore.collection("Products").where("Category",isNotEqualTo: null).get().then((onValue){
        for(var val in onValue.docs){
            categories.add(val.data()["Category"]);
        }
     });
   }else{
    
   await firestore.collection("Products").where("Category",whereNotIn: categories.values.toList()).orderBy("Clout").get().then((onValue){
   for(var value in onValue.docs){
    categories.add(value.id);
   }
   });
   }
}
Future<Map<dynamic,dynamic>> getUser()async{
 Box userbox = Hive.box("UserData");
 Map<dynamic,dynamic> userdata ={};
 if(userbox.isEmpty){
  await firestore.collection("Users").doc(_user.uid).get().then((onValue){
    userdata = onValue.data()!;
    print(userdata);
  });
  userbox.putAll(userdata);
 }else{
 // print(userbox.values);
  userdata = userbox.toMap();
 }
  return userdata;
}

Future<Uint8List>getDp()async{
  Uint8List? dp = Uint8List(0);
  Box userBox = Hive.box("UserData");
  if (userBox.containsKey("Dp")) {
    return userBox.get("Dp");
  }
  try {
    await storage.child("Users/${_user.uid}/").list().then((onValue)async{
     dp = await onValue.items.single.getData();
    });
    userBox.put("Dp", dp!);
  } catch (e) {
    
  }
  return dp!;
}

Future<String>updateProfile(
  String newName,
  String imagePath,
)async{
  String state ="";
  try {
    Box userBox = Hive.box("UserData");
    if (newName.isNotEmpty) {
       await firestore.collection("Users").doc(_user.uid).update({"Name":newName});
       await userBox.delete("Name");
       await userBox.put("Name", newName);
    }
   if (imagePath.isNotEmpty) {
     await storage.child("Users/${_user.uid}/").putFile(File(imagePath));
    await userBox.delete("Dp");
    await userBox.put("Dp", File(imagePath).readAsBytesSync());
   }
  state = "Success";
  } catch (e) {
    state = e.toString();
  }
  return state;
}

Future<String>addAddress(
  String name,
  var latitude,
  var longitude,
  var altitude,
  String other
)async{
  Box userBox = Hive.box("AddressBook");
  String state = "";
  try {
    await firestore.collection("Users").doc(_user.uid).get().then((onValue)async{
    Map address = onValue.data()!["AddressBook"];
   // print("${address.keys.length}....................");
    List addre = [name,latitude,longitude,altitude,other];
    int keyyy = address.keys.length+1;
    //address.addAll({keyyy:addre});
    final entery = <String,dynamic>{keyyy.toString():addre};
    address.addAll(entery);
    //print("$address ////////");
    await firestore.collection("Users").doc(_user.uid).update({"AddressBook":address});
    userBox.add([name,latitude,longitude,altitude,other]);
    //print(userBox.values);
  });
  state = "Success";
  } catch (e) {
    state = e.toString();
    print(state);
  }
return state;
}
Future<Map<dynamic,dynamic>>getCart()async{
  Box userBox = Hive.box("UserData");
  Map cart ={};

  if (userBox.containsKey("Cart")) {
    cart = userBox.get("Cart");
  }else{
      await firestore.collection("Users").doc(_user.uid).get().then((onvalue){
    cart = onvalue.data()!["Cart"];
  });
  userBox.put("Cart", cart);
  }
  return cart;
}

Future<String>addtoCart(String itemId,int quantity,String name,double price)async{
  String state ="";
  Map prevdata ={};
    Box userBox = Hive.box("UserData");
  await firestore.collection("Users").doc(_user.uid).get().then((onValue){
    prevdata = onValue.data()!["Cart"];
  });
  if (prevdata.containsKey(itemId)) {
    List info = prevdata[itemId];
    info.last = quantity;
    prevdata.update(itemId,(value)=>info);
  }else{
    final ddd = <String,dynamic>{itemId:[name,price,quantity]};
    prevdata.addAll(ddd);
  }
  print(prevdata);
  if (userBox.containsKey("Cart")) {
    Map pdata = userBox.get("Cart");
    pdata.update(itemId, (value)=>[name,price,quantity],ifAbsent: ()=>[name,price,quantity]);
    userBox.put(itemId, pdata);
  }else{
    userBox.put("Cart", {itemId:[name,price,quantity]});
  }
  await firestore.collection("Users").doc(_user.uid).update({"Cart":prevdata});
  return state;
}

Future<String> removeFromCart(String itemId)async{
  String state = "";
   Box userBox = Hive.box("UserData");
  await firestore.collection("Users").doc(_user.uid).get().then((onValue)async{
    Map cart = onValue.data()!["Cart"];
    cart.remove(itemId);
    await firestore.collection("Users").doc(_user.uid).update({"Cart":cart});
  });
  Map cart =userBox.get("Cart");
  cart.remove(itemId);
  userBox.put("Cart", cart);
  return state;
}