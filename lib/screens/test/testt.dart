import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Model.dart';



class SignUpState extends State {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String? uname, uemail, umobile, upassword;

  final _formKey = GlobalKey<FormState>();

  final emailcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final mobilecontroller = TextEditingController();
  final passcontroller = TextEditingController();

  Future<String?> signInWithGoogle() async {
    await Firebase.initializeApp();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
    await _auth.signInWithCredential(credential);
    final User user = authResult.user!;

    if (user != null) {
      // Checking if email and name is null
      assert(user.email != null);
      assert(user.mobile != null);
      assert(user.pass != null);
      assert(user.name != null);

      uname = user.displayName;
      uemail = user.email;
      umobile = user.mobile;
      upassword = user.pass;

      // Only taking the first part of the name, i.e., First Name
      if (uname!.contains(" ")) {
        uname = uname!.substring(0, uname!.indexOf(" "));
      }

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');
      return '$user';
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }

  void writeData() async {
    _formKey.currentState!.save();
    var databaseUrl =
        "https://pizza-king-c1275-default-rtdb.firebaseio.com/" +
            "register.json";

    try {
      final response = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode({"email":uemail,"name":uname,"mobile":umobile,"password":upassword}),
      );
    } catch (error) {}
  }

  Widget build(BuildContext context) {
    final emailField = TextFormField(
      onSaved: (value) {
        uemail = value!;
      },
      obscureText: false,
      controller: emailcontroller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email Here",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );

    final name = TextFormField(
      onSaved: (value) {
        uname = value!;
      },
      obscureText: false,
      controller: namecontroller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Name Here",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );

    final mobile = TextFormField(
      onSaved: (value) {
        umobile = value!;
      },
      obscureText: false,
      controller: mobilecontroller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Mobile Here",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );

    final passwordField = TextFormField(
      onSaved: (value) {
        upassword = value!;
      },
      obscureText: true,
      controller: passcontroller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password Here",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(20.0),
      color: Color.fromARGB(255, 93, 17, 20),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
        onPressed: () {
          //writeData();
          User user = User();
          user.email = emailcontroller.text;
          user.name = namecontroller.text;
          user.mobile = mobilecontroller.text;
          user.pass = passcontroller.text;
          writeData();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  SignUp ()));
          //  showAlertDialog(context, user);
        },
        child: Text(
          "Submit",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return Scaffold(

      appBar: AppBar(title: Text("Signup Form"),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign up Form", style: TextStyle(color: Color.fromARGB(255, 93, 17, 20))),
                  SizedBox(height: 45.0),
                  emailField,
                  SizedBox(height: 25.0),
                  name,
                  SizedBox(height: 25.0),
                  mobile,
                  SizedBox(height: 25.0),
                  passwordField,
                  SizedBox(
                    height: 35.0,
                  ),
                  loginButon,
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


