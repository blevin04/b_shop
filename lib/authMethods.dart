
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel{
  final String fullName;
  final String email;
  final String Uid;
  final String number;
  UserModel({
    required this.email,
    required this.fullName,
    required this.Uid,
    required this.number,
  });

  Map<String,dynamic> toJson()=>{
    "Name":fullName,
    "Email":email,
    "Cart":{},
    "Uid":Uid,
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
            Uid: userId,
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
  // Future<String> signinWithPhone({required String number,required String password})async{
  //   String res = "Error Occured Please try again";
  //   try {
  //     await _auth.signInWith
  //   } catch (e) {
      
  //   }
  // }
}
