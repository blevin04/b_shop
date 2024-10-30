import 'package:flutter/material.dart';

showsnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //backgroundColor: const Color.fromARGB(255, 106, 105, 105),
    content: Text(content)));
}