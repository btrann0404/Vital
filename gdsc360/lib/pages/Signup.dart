import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdsc360/components/my_button.dart';
import 'package:gdsc360/components/my_text_field.dart';
import 'package:gdsc360/pages/Login.dart';
import 'package:gdsc360/pages/RoleSignup.dart';
import 'package:gdsc360/utils/authservice.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final Auth auth = Auth();
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await auth.createUserAuth(
          emailController.text,
          passwordController.text,
          password2Controller.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSignup()),
        );
      } on FirebaseAuthException catch (e) {
        errorMessage = e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Signup Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 142, 217, 252),
      appBar: AppBar(
        title: const Text("Sign Up"),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 142, 217, 252),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // This will center the icons in the row
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 100,
                          color: Colors.pink,
                        ),
                        const Icon(
                          Icons.local_hospital_rounded,
                          size: 100,
                          color: Color.fromARGB(255, 224, 29, 15),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome to ",
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Vital",
                        style: TextStyle(
                            color: Colors.pink[400],
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "!",
                        style: TextStyle(
                            color: Colors.pink[400],
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    controller: password2Controller,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    onTap: () => registerUser(),
                    buttonString: 'Sign Up',
                    buttonColor: Colors.black,
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Already a member? Log In',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
