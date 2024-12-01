import 'package:b_shop/backEndFunctions.dart';
import 'package:b_shop/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserModel{
  final String fullName;
  final String email;
  final String uid;
  final String number;
  UserModel({
    required this.email,
    required this.fullName,
    required this.uid,
    required this.number,
  });

  Map<String,dynamic> toJson()=>{
    "Name":fullName,
    "Email":email,
    "Cart":{},
    "Uid":uid,
    "AddressBook":{},
    "Number":number
  };
}


class AuthMethods {
  // firebase
  final FirebaseAuth _auth = FirebaseAuth.instance; // auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // firestore

  // create user account
  Future<String> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String number,
  }) async {
    // final root = await getApplicationDocumentsDirectory();
    String res = "Some error occured!";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          fullName.isNotEmpty
          ) {
        // create a user with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // unique id for the user
        final userId = cred.user!.uid;
        // user model
        UserModel user = UserModel(
            fullName: fullName,
            email: email,
            uid: userId,
          number: number,
            );

        //send data to cloud firestore
        await _firestore.collection("Users").doc(userId).set(user.toJson());
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //sign in
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured!";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      res = "Success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // reset password
  Future<String> resetPassword({required String email}) async {
    String res = "Please try again later";
    try {
      // send the verification link to the user
      await _auth.sendPasswordResetEmail(email: email);

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
  Future<String> signinWithPhone({required String number,required BuildContext context,required String name,required Function(String) codeSent})async{
    String res = "Error Occured Please try again";
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (PhoneAuthCredential credential) async{
        res = "Success";
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          showsnackbar(context, 'The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async{
        codeSent(verificationId);
        // showDialog(context: context, builder: (context){
        //   return Dialog(
        //     child: Padding(
        //       padding: const EdgeInsets.all(10.0),
        //       child: TextField(
        //         controller: TextEditingController(),
        //         onChanged: (value)async{
        //           if (value.length>4) {
        //             // Create a PhoneAuthCredential with the code

        //             PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: value);
        //             // Sign the user in (or link) with the credential
        //             final cred = await _auth.signInWithCredential(credential);
        //             final userId = cred.user?.uid;
        //             UserModel newUser = UserModel(email: "email", fullName: name, Uid: userId!, number: number);
        //             final userd = await firestore.collection("Users").where("Uid",isEqualTo: userId).get();
        //             if (userd.docs.isEmpty) {
        //               await firestore.collection("Users").doc(userId).set(newUser.toJson());
        //             }
        //           // Navigator.pop(context);
        //           }
        //         },
        //         decoration: InputDecoration(
        //           hintText: "Code received",
        //         ),
        //       ),
        //     ),
        //   );
        // });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
  
  Future<void>logoutA()async{
  await Hive.box("UserData").clear();
  await _auth.signOut();
}
}

Future<String> signInWithSmsCode(String verificationId, String smsCode,[String name = "name",String number = "num"]) async { 
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential( verificationId: verificationId, smsCode: smsCode, );
   final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
   await firestore.collection("Users").where("uid",isEqualTo: userCred.user!.uid).get().then((onValue)async{
    if (onValue.docs.isEmpty) {
      // print("EmptyMf,,,,,,,,,,,,,,,,,,,,,,,,,,");
      UserModel userModel = UserModel(email: "email", fullName: name, uid: userCred.user!.uid, number: number);
      await firestore.collection("Users").doc(userCred.user!.uid).set(userModel.toJson());
    }
   });
   return "Success";
  } catch (e) {
    return e.toString();
  }
    } 