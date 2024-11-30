import 'package:b_shop/authMethods.dart';
import 'package:b_shop/homepage.dart';
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
TextEditingController numberController = TextEditingController();

TextEditingController numberLogin = TextEditingController();
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

bool useEmail = false;
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
      body: StatefulBuilder(
        builder: (context,setstate) {
          return Column(
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
                    Text("Create an account",style: TextStyle(color: Colors.white),)
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
              Visibility(
                visible: useEmail,
                child: Padding(
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
              ),
              Visibility(
                visible: !useEmail,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: numberController,
                    decoration: InputDecoration(
                      labelText: "Phone number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:const BorderSide(color:  Color.fromARGB(255, 86, 85, 85))
                      )
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: useEmail,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:const BorderSide(color:  Color.fromARGB(255, 86, 85, 85))
                      )
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: useEmail,
                child: StatefulBuilder(
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
              ),
              Row(
                children: [
                  TextButton(onPressed: (){
                    setstate((){
                      useEmail = !useEmail;
                    });
                  }, child: Text(useEmail?"Use phone number instead": "Use email and password instead?"))
                ],
              ),
              const SizedBox(height: 50,),
              InkWell(
                onTap: ()async{
                  if (nameController.text.isEmpty) {
                    showsnackbar(context, "Enter Valid Name");
                  }
                  if (numberController.text.isEmpty) {
                    showsnackbar(context, "Enter valid number");
                  }
                  if (
                      nameController.text.isNotEmpty &&
                      numberController.text.isNotEmpty &&
                      !useEmail
                      ) {
                    String state = "";
                  while (state.isEmpty) {
                    showcircleprogress(context);
                    // state = await AuthMethods().createAccount(
                    // email: emailController.text, 
                    // password: passwordController.text, 
                    // fullName: nameController.text,
                    // number: numberController.text,
                    // );
                    
                    state = await AuthMethods().signinWithPhone(
                      name: nameController.text,
                      number: numberController.text, context: context);
                  }
                  if (state=="Success") {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    showsnackbar(context, "Welcome ${nameController.text}");
                  }
                  }
                  /////
                  if (
                      nameController.text.isNotEmpty &&
                      useEmail &&
                      emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty &&
                      confirmController.text.isNotEmpty
                      ) {
                    String state = "";
                  while (state.isEmpty) {
                    showcircleprogress(context);
                    state = await AuthMethods().createAccount(
                    email: emailController.text, 
                    password: passwordController.text, 
                    fullName: nameController.text,
                    number: numberController.text,
                    );
                    
                    // state = await AuthMethods().signinWithPhone(
                    //   name: nameController.text,
                    //   number: numberController.text, context: context);
                  }
                  if (state=="Success") {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    showsnackbar(context, "Welcome ${nameController.text}");
                  }
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
                  child:const Text("Register",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18,color: Colors.white),),
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
          );
        }
      ),
    );
}
bool loginWithEmail = false;
class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context,setstate) {
            return Column(
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
                      Text("Log in to your account",style: TextStyle(color:Colors.white),)
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                Visibility(
                  visible: !loginWithEmail,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: numberLogin,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:const BorderSide(color:Color.fromARGB(255, 86, 85, 85))
                        )
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !loginWithEmail,
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 20,),
                           Text("You will receive a code on this number to log in"),
                        ],
                      ),
                      const Text("or"),
                      TextButton(onPressed: (){
                        setstate((){
                          loginWithEmail = true;
                        });
                      }, child:const Text("Log in with email and password"))
                    ],
                  ),
                ),
                
                Visibility(
                  visible: loginWithEmail,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: emailLogin,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:const BorderSide(color:Color.fromARGB(255, 86, 85, 85))
                        )
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Visibility(
                  visible: loginWithEmail,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: passwordLogin,
                      decoration: InputDecoration(
                        labelText: "password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:const BorderSide(color:Color.fromARGB(255, 86, 85, 85))
                        )
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: loginWithEmail,
                  child: TextButton(
                    onPressed: (){}, 
                  child:const Text("Forgot password?")),
                ),
                Visibility(
                  visible: loginWithEmail,
                  child: TextButton(onPressed: (){
                    setstate((){
                      loginWithEmail = false;
                    });
                  }, child:const Text("Log in with phone number")),
                ),
                const SizedBox(height: 30,),
                Center(
                  child: InkWell(
                    onTap: ()async{
                      if (emailLogin.text.isEmpty&& loginWithEmail) {
                        showsnackbar(context, "Enter Valid email");
                      }
                      if (passwordLogin.text.isEmpty && loginWithEmail) {
                        showsnackbar(context, "Enter password");
                      }
                      if (passwordLogin.text.isNotEmpty&&emailLogin.text.isNotEmpty && loginWithEmail) {
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
                      if (!loginWithEmail && numberLogin.text.isNotEmpty) {
                        print("shit");
                        String state = "";
                        while (state.isEmpty) {
                          // showcircleprogress(context);

                          state = await AuthMethods().signinWithPhone(number: numberLogin.text, context: context, name: "name");

                        }
                        Navigator.pop(context);
                        print("............................");
                        print(state);
                        if (state == "Success") {
                          Navigator.pushAndRemoveUntil(context, (MaterialPageRoute(builder: (context)=>const Homepage())), (route)=>false);
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
                      child:const Text("Login",style: TextStyle(fontSize: 22,color: Colors.white),),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          image:NetworkImage("https://banner2.cleanpng.com/20240111/qtv/transparent-google-logo-colorful-google-logo-with-bold-green-1710929465092.webp")),
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
            );
          }
        ),
      ),
    );
  }
}