import 'package:auth_buttons/auth_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/auth/API.dart';
import 'package:wechat/contant.dart';
import 'package:wechat/dialog.dart';
import 'package:wechat/screens/Home_Screens/home_screens.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _isAnimated = false;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: ListTile(
          subtitle: Container(
            width: 100,
            child: GoogleAuthButton(
              style: AuthButtonStyle(
                borderRadius: 20,
                height: 45,
                textStyle: TextStyle(
                    color: whiteColor, fontSize: 17, fontWeight: FontWeight.w700),
                iconType: AuthIconType.outlined,
              ),
              onPressed: () async{

                handlebuttonClick();
              },
              materialStyle: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(primaryColor),
              ),
            ),
          ),
        ),
        body: Center(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                      'گپ shup',
                    style: GoogleFonts.aBeeZee(
                      color: primaryColor,
                      fontSize: 55,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 400,
                  ),
                ],
              ),
              AnimatedPositioned(
                top: mq.height * .25,
                right: _isAnimated ? mq.width * .10 : -mq.width * .4,
                width: mq.width * .45,
                duration: Duration(seconds: 2),
                child: Image.asset(
                  'assets/images/chat.png',
                  height: mq.height * .4,
                  width: mq.width * .6,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  handlebuttonClick()  {
    Dialogs.showProgresbar(context);
    _googleSignIn().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          });
        }
      }
    });
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<String> _googleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        if (googleAuth.idToken != null) {
          final userCredential = await auth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken),
          );
        }
      }
    } catch (e) {
      Dialogs.showSnakcbar(context, 'Check Connection');
    }
    return 'ok';
  }
}
