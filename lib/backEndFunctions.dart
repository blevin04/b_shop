
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();

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