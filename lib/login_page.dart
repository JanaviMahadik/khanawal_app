import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  String selectedRole = "Customer";
  GlobalKey<FormState> globalformkey = GlobalKey<FormState>();
  String? username;
  String? password;

  Future<void> _loginUser() async {
    if (globalformkey.currentState!.validate()) {
      globalformkey.currentState!.save();

      setState(() {
        isAPIcallProcess = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username!,
          password: password!,
        );

        if (userCredential.user != null) {
          if (selectedRole == "Customer") {
            Navigator.pushReplacementNamed(context, "/customer_home");
          } else {
            Navigator.pushReplacementNamed(context, "/cook_home");
          }
        } else {
          // Show error if login fails (though unlikely with Firebase)
          FormHelper.showSimpleAlertDialog(
            context,
            "Khanawal",
            "Invalid username or password",
            "OK",
                () {
              Navigator.of(context).pop();
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuth exceptions
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        } else {
          print(e.toString());
        }
      } finally {
        setState(() {
          isAPIcallProcess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor("#283B71"),
        body: ProgressHUD(
          child: Form(
            key: globalformkey,
            child: _loginUI(context),
          ),
          inAsyncCall: isAPIcallProcess,
          opacity: 0.3,
          key: UniqueKey(),
        ),
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/khanawal_logo.png",
                    width: 250,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              bottom: 30,
              top: 50,
            ),
            child: Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          FormHelper.inputFieldWidget(
            context,
            '\ue7fd',
            "mail",
                (onValidateVal) {
              if (onValidateVal.isEmpty) {
                return "Enter Mail";
              }
              return null;
            },
                (onSavedVal) {
              username = onSavedVal;
            },
            borderFocusColor: Colors.white,
            prefixIconColor: Colors.white,
            borderColor: Colors.white,
            textColor: Colors.white,
            hintColor: Colors.white.withOpacity(0.7),
            borderRadius: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(
              context,
              '\ue7fd',
              "password",
                  (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return "Enter Password";
                }
                return null;
              },
                  (onSavedVal) {
                password = onSavedVal;
              },
              borderFocusColor: Colors.white,
              prefixIconColor: Colors.white,
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white.withOpacity(0.7),
              borderRadius: 10,
              obscureText: hidePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                color: Colors.white.withOpacity(0.7),
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 10),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Forget Password?",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print("Forget Password");
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Set width for the button
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedRole = "Customer";
                  });
                  _loginUser();
                },
                child: Text(
                  "Login as Customer",
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#283B71"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.white, // Set border color to white
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "OR",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Set width for the button
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedRole = "Cook";
                  });
                  _loginUser();
                },
                child: Text(
                  "Login as Cook",
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#283B71"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.white, // Set border color to white
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 10),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: "Don't have an account?"),
                    TextSpan(
                      text: " Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, "/register");
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
