// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdsc360/components/my_button.dart';
import 'package:gdsc360/components/my_text_field.dart';
import 'package:gdsc360/components/square_tile.dart';
import 'package:gdsc360/pages/MainPage.dart';
import 'package:gdsc360/pages/Signup.dart';
import 'package:gdsc360/utils/authservice.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Auth auth = Auth();
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await auth.loginUserAuth(
          emailController.text,
          passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } on FirebaseAuthException catch (e) {
        errorMessage = e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Login Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 142, 217, 252),
      appBar: AppBar(
        title: const Text("Log In"),
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
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    onTap: () => loginUser(),
                    buttonString: 'Sign In',
                    buttonColor: Colors.black,
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Not a member? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //or continue with
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        Text("Or continue with"),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  //google + apple authentication
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //google
                      SquareTile(imagePath: 'lib/assets/google-logo.png'),
                      SizedBox(
                        width: 20,
                      ),
                      SquareTile(imagePath: 'lib/assets/apple-log.png'),
                    ],
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


// return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Form(
//             key: _formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Text("Login"),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       hintText: "Enter Email",
//                       labelText: "Email",
//                     ),
//                     controller: emailController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Missing Email";
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       hintText: "Enter Password",
//                       labelText: "Password",
//                     ),
//                     obscureText: true,
//                     controller: passwordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Missing Password";
//                       }
//                       return null;
//                     },
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       loginUser();
//                       print(
//                           "Email is ${emailController.text} and Password is ${passwordController.text} ");
//                     },
//                     child: const Text('Submit'),
//                   ),
//                   MaterialButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/signup');
//                       },
//                       child: const Text("Register Here")),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
