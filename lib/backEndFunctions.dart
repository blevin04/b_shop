
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:b_shop/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();
User _user = FirebaseAuth.instance.currentUser!;

Future<Map<String,dynamic>> getFeed(String filter)async{
    Map<String,dynamic> feed ={};
    if (filter.isEmpty || filter == "All") {
      await firestore.collection("Products").where("Stock",isGreaterThan: 0).get().then((onValue){
        for(var value in onValue.docs){
          // print(value.id);
            final product = {value.id:value.data()};
            feed.addAll(product);
        }
    });
    }else{
      await firestore.collection("Products").where("Category",isEqualTo: filter).get().then((onValue){
        for(var value in onValue.docs){
          final product = {value.id:value.data()};
          feed.addAll(product);
        }
      });
    }
    // print(feed);
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
    print(categories.values);
   await firestore.collection("Products").where("Category",whereNotIn: categories.values.toList()).orderBy("Clout").get().then((onValue){
   for(var value in onValue.docs){
    categories.add(value.data()["Category"]);
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
  int inStock = 0;
    Box userBox = Hive.box("UserData");
  await firestore.collection("Users").doc(_user.uid).get().then((onValue){
    prevdata = onValue.data()!["Cart"];
    // print("mmmmmmmmmm");
  });
  await firestore.collection("Products").doc(itemId).get().then((onValue){
    inStock = onValue.data()!["Stock"];
    // print("nnnnnnnn");
  });
  if (prevdata.containsKey(itemId)) {
    List info = prevdata[itemId];
    if (quantity <= inStock) {
      info.last = quantity;
    }
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

Future<List>placeOrder(
  Map items,
  List location,
  bool ondelivery,
  double price,
  String paymentnum,
  BuildContext context,
)async{
  List state = [];
  bool orderValid = true;
  try {
    String orderNumber =const Uuid().v1();
    Map onfail = {};
    Future<void> check()async{
      final completer = Completer<void>();
      items.forEach((key,value)async{
      await firestore.collection("Products").doc(key).get().then((onValue){
        int inStock = onValue.data()!["Stock"];
        if (inStock< value.last) {
          orderValid = false;
          print("mmmmmmmmmm");
          // showsnackbar(context, "Available ${value.first} stock is ${value.last}");
          onfail.addAll({key:[value,inStock]});
        }
      });
      if (key == items.keys.last) {
        completer.complete();
      }
    });
    return completer.future;
    }
      await check().then((onValue)async{
        if (orderValid) {
        print(",,,,,,,,,,,,,,,,,,,,");
        orderModel order = orderModel(
      items: items, 
      location: location, 
      orderNumber: orderNumber, 
      owner: _user.uid,
      ondelivery: ondelivery,
      price: price,
      paymentNum: paymentnum,
      live: ondelivery,
      );
        await firestore.collection("orders").doc(orderNumber).set(order.toJyson());
        if (ondelivery) {
          items.forEach((key,value)async{
            await firestore.collection("Products").doc(key).get().then((onValue)async{
              int Stock = onValue.data()!["Stock"];
              int bought = value.last;
              Stock-=bought;
              if (Stock <0) {
                Stock = 0;
              }
              await firestore.collection("Products").doc(key).update({"Stock":Stock});
            });
          });
        }
        state.add("placed");
        state.add(orderNumber);
      }else{
        print(";;;;;;");
        state.add("Order Invalid");
        state.add(onfail);
      }
      });
      
      
  } catch (e) {
    state.add(e.toString());
  }
  // print(state);
  return state;
}
Future<void> clearCart(List items)async{
  await Hive.openBox("UserData");
  if (Hive.box("UserData").containsKey("Cart")) {
    Box cartbox = Hive.box("UserData");
    for(var item in items){
      
      if (cartbox.containsKey(item)) {
        cartbox.delete(item);

      }
    }
  }
  await firestore.collection("Users").doc(_user.uid).get().then((onValue)async{
        Map cart = onValue.data()!["Cart"];
        for(var item in items){
          if (cart.containsKey(item)) {
            cart.remove(item);
          }
        }
        await firestore.collection("Users").doc(_user.uid).update({"Cart":cart});
  });
}
Future<Map<String,dynamic>> getOpenOrders()async{
  Map<String,dynamic> open = {};
  await Hive.openBox("orders");
  if (Hive.box("orders").containsKey("open")) {
    return Hive.box("orders").get("open");
  }
  else{
    await firestore.collection("orders").where("Owner",isEqualTo:  _user.uid).get().then((onValue){
      //print(onValue.docs.length);
      for(var value in onValue.docs){
        if (value.data()["delivered"]==false) {
          open.addAll({value.id:value.data()});
        }
      }
    });
    //Hive.box("orders").put("open", open);
  }
  // print(open);
  return open;
}

Future<Map<String,dynamic>> getClossedOrders()async{
 Map<String,dynamic> closed ={};
  await Hive.openBox("orders");
  if (Hive.box("orders").containsKey("closed")) {
    return Hive.box("orders").get("closed");
  }else{
    await firestore.collection("orders").where("Owner",isEqualTo: _user.uid).get().then((onValue){
      for(var value in onValue.docs){
        if (value.data()["delivered"]== true) {
          closed.addAll({value.id:value.data()});
        }
      }
    });
    // Hive.box("orders").put("closed", closed);
  }
 return closed;
}
void setUpListeners()async{
  List openOrders = [];
  await firestore.collection("orders").where("Owner",isEqualTo:  _user.uid).get().then((onValue){
    for(var value in onValue.docs){
      if(value.data()["delivered"]==false){
        openOrders.add(value.id);
      }
    }
  });
  for(var order in openOrders){
    firestore.collection("orders").doc(order).snapshots().listen((onData)async{
      bool delivered = onData.data()!["delivered"];
      if (delivered) {
        
      }
    });
  }
  
}