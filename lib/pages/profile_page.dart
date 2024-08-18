import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/authentication/login_screen.dart';
import 'package:remisse_arequipa_driver/global.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
{
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController carTextEditingController = TextEditingController();

  setDriverInfo()
  {
    setState(() {
      nameTextEditingController.text = driverName;
      phoneTextEditingController.text = driverPhone;
      emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email.toString();
      carTextEditingController.text = "$carNumber - $carColor - $carModel";
    });
  }

  @override
  void initState() {
    super.initState();

    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //image
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: NetworkImage(
                          driverPhoto,
                        ),
                    )
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              //driver name
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 8),
                child: TextField(
                  controller: nameTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(60, 0, 0, 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),

              //driver phone
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: phoneTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(60, 0, 0, 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android_outlined,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),

              //driver email
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: emailTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(60, 0, 0, 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),

              //driver car info
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: carTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(60, 0, 0, 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.drive_eta_rounded,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              //logout btn
              ElevatedButton(
                onPressed: ()
                {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18)
                ),
                child: const Text(
                    "Logout"
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
