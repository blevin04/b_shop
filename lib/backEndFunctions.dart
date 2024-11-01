
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();

Future<Map<String,dynamic>> getFeed()async{
    Map<String,dynamic> feed ={};

    return feed;
}
Future<List<Uint8List>> getImages()async{
    List<Uint8List> productImages =[];

    return productImages;
}
void getCategories()async{
   var categories= Hive.box("Categories");
   firestore.collection("Products").where("Category",whereNotIn: categories.values).get().then((onValue){
   for(var value in onValue.docs){
    categories.add(value.id);
   }
   });
   print(categories.values);
}