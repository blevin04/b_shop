import 'package:b_shop/authMethods.dart';
import 'package:b_shop/utils.dart';
import 'package:flutter/material.dart';
class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}
TextEditingController nameController =TextEditingController();
TextEditingController emailController =TextEditingController();
TextEditingController passwordController =TextEditingController();
TextEditingController confirmController =TextEditingController();

TextEditingController emailLogin =TextEditingController();
TextEditingController passwordLogin =TextEditingController();
PageController pageController = PageController();
class _AuthpageState extends State<Authpage> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: [
        regesterPage(context),
        const login()
      ],
    ) ;
  }
}


Widget regesterPage(BuildContext context){
  TextStyle onError =const TextStyle(color: Colors.red);
  TextStyle normal = const TextStyle();
  OutlineInputBorder errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:const BorderSide(color: Colors.red)
  );
  OutlineInputBorder normalBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:const BorderSide(color: Colors.red)
  );
  bool errror=false;
  return Scaffold(
      body: Column(
        children: [
          Container(
            padding:const EdgeInsets.all(10),
            color: const Color.fromARGB(255, 15, 26, 35),
            height: 250,
            width: MediaQuery.of(context).size.width,
            child:const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Register",style: TextStyle(color: Colors.white,fontSize: 35,fontWeight: FontWeight.bold),),
                Text("Create an account")
              ],
            ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:const BorderSide(color: const Color.fromARGB(255, 86, 85, 85))
                )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:const BorderSide(color:  Color.fromARGB(255, 86, 85, 85))
                )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:const BorderSide(color: const Color.fromARGB(255, 86, 85, 85))
                )
              ),
            ),
          ),
          StatefulBuilder(
            builder: (context,passState) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  onChanged: (value) {
                    if (passwordController.text != value) {
                      errror = true;
                      passState((){});
                    }
                    else{
                      errror = false;
                      passState((){});
                    }
                  },
                  style:errror?onError: normal,
                  controller: confirmController,
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                      borderSide:const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: "Confirm Password",
                    border:errror?
                    errorBorder:normalBorder
                  ),
                ),
              );
            }
          ),
          const SizedBox(height: 50,),
          InkWell(
            onTap: ()async{
              if (nameController.text.isEmpty) {
                showsnackbar(context, "Enter Valid Name");
              }
              if (emailController.text.isNotEmpty) {
                showsnackbar(context, "Enter valid email");
              }
              
              String state = "";
              while (state.isEmpty) {
                showcircleprogress(context);
                state = await AuthMethods().createAccount(
                email: emailController.text, 
                password: passwordController.text, 
                fullName: nameController.text);
              }
              if (state=="Success") {
                Navigator.pop(context);
                Navigator.pop(context);
                showsnackbar(context, "Welcome ${nameController.text}");
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width/2,
              height: 50,
              padding:const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 21, 55, 22),
                borderRadius: BorderRadius.circular(20)
              ),
              child:const Text("Register",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),),
            ),
          ),
          const SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             const Text("I have an account?"),
              TextButton(onPressed: (){
                pageController.animateToPage(1, duration:const Duration(milliseconds: 250), curve: Curves.easeInOutCirc);
              }, child:const Text("login"))

            ],
          )
        ],
      ),
    );
}

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding:const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 15, 26, 35),
              height: 250,
              width: MediaQuery.of(context).size.width,
              child:const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sign in to your \n account",style: TextStyle(color: Colors.white,fontSize: 35,fontWeight: FontWeight.bold),),
                  Text("Log in to your account")
                ],
              ),
            ),
            const SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: emailLogin,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:const BorderSide(color: const Color.fromARGB(255, 86, 85, 85))
                  )
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: passwordLogin,
                decoration: InputDecoration(
                  labelText: "password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:const BorderSide(color: const Color.fromARGB(255, 86, 85, 85))
                  )
                ),
              ),
            ),
            TextButton(
              onPressed: (){}, 
            child:const Text("Forgot password?")),
            const SizedBox(height: 30,),
            Center(
              child: InkWell(
                onTap: ()async{
                  if (emailLogin.text.isEmpty) {
                    showsnackbar(context, "Enter Valid email");
                  }
                  if (passwordLogin.text.isEmpty) {
                    showsnackbar(context, "Enter password");
                  }
                  if (passwordLogin.text.isNotEmpty&&emailLogin.text.isNotEmpty) {
                    String state ="";
                  while (state.isEmpty) {
                    showcircleprogress(context);
                    state = await AuthMethods().signIn(email: emailLogin.text, password: passwordLogin.text);
                  }
                  if (state == "Success") {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    showsnackbar(context, "Welcome Back ");
                  }
                  }
                  
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width/2,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 22, 45, 23),
                  ),
                  child:const Text("Login",style: TextStyle(fontSize: 22),),
                ),
              ),
            ),
            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Container(
                  decoration:const BoxDecoration(color:  Color.fromARGB(255, 82, 81, 81)),
                  height: 2,
                  width: MediaQuery.of(context).size.width/3,
                 ),
               const Text("or log in with"),
                Container(
                  decoration:const BoxDecoration(color:  Color.fromARGB(255, 82, 81, 81)),
                  height: 2,
                  width: MediaQuery.of(context).size.width/3,
                 ),
        
              ],
            ),
            const SizedBox(height: 30,),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)
                ),
                child:const Row(
                  children: [
                    Image(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        "/lib/assets/google.png",
                        )),
                      Text("Google")
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(onPressed: (){
                  pageController.animateToPage(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubic);
                }, child:const Text("Register"))
              ],
            )
          ],
        ),
      ),
    );
  }
}