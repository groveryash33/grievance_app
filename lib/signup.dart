// signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/custom_color.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String _selectedCourse = 'BCA';
  String _selectedGender = 'Male';

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('signup')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'mobile': _mobileController.text,
          'course': _selectedCourse,
          'gender': _selectedGender,
        });

        // Navigate to next screen after successful signup
      } catch (e) {
        print('Error signing up: $e');
        // Handle signup errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppColors.backgroundColor),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    errorStyle: const TextStyle(color: Colors.white),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    filled: true,
                    errorStyle: const TextStyle(color: Colors.white),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    errorStyle: const TextStyle(color: Colors.white),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    filled: true,
                    errorStyle: const TextStyle(color: Colors.white),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCourse = newValue!;
                    });
                  },
                  items: ['BCA', 'MCA']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                            color: AppColors
                                .backgroundColor), // Set text color to white
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Course',
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    filled: true,
                    errorStyle: const TextStyle(color: Colors.white),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                  items: ['Male', 'Female']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                            color: AppColors
                                .backgroundColor), // Set text color to white
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: AppColors.backgroundColor),
                    filled: true,
                    errorStyle: const TextStyle(color: Colors.white),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                GestureDetector(
                  onTap: () {
                    final snackBar = const SnackBar(
                      content: Text('New User has added'),
                      // duration: Duration(
                      //     seconds:
                      //         0), // Duration for how long the Snackbar will be displayed
                      // action: SnackBarAction(
                      //   label: 'Close',
                      //   onPressed: () {
                      //     // Some action to be performed when the user presses the action button
                      //   },
                      // ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.whiteColor),
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.backgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
