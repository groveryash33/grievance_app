import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/custom_color.dart';
import '../firebase_storage/firebase_Storage.dart';
import '../authentication/authentication.dart';
import '../splash_screen.dart';

class GriveanceHomepage extends StatefulWidget {
  final User user;
  static const String grivencehomepage = "TodoBucketHomepage";
  const GriveanceHomepage({super.key, required this.user});

  @override
  State<GriveanceHomepage> createState() => _GriveanceHomepageState();
}

class _GriveanceHomepageState extends State<GriveanceHomepage> {
  late bool _isSigningOut = false;
  
  // Hardcoded collection name for StreamBuilder
  final String collectionName = 'My Grievance'; 

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SplashScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  String formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String day = DateFormat('d').format(dateTime);
    String month = DateFormat('MMMM').format(dateTime);
    String year = DateFormat('y').format(dateTime);
    String suffix = _getDaySuffix(int.parse(day));
    String time = DateFormat('h:mm a').format(dateTime);

    return '$day$suffix $month $year at $time';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String grievanceTitle = '';
  String grievanceDescription = '';

  final String adminEmail = 'yashgrover8622@gmail.com';
  
  Stream<QuerySnapshot> getGrievanceStream() {
    // 🛑 WARNING: This simple email check is insecure for a real application.
    if (widget.user.email == adminEmail) {
      // Admin gets ALL grievances
      return FirebaseFirestore.instance.collection(collectionName).snapshots();
    } else {
      // Regular user gets ONLY THEIR OWN grievances filtered by userId
      return FirebaseFirestore.instance
          .collection(collectionName)
          .where('userId', isEqualTo: widget.user.uid) // Filter by UID
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text(
            'Grievance',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            widget.user.photoURL != null
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.whiteColor),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.network(
                          widget.user.photoURL!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor),
                      child: const ClipOval(
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            GestureDetector(
                onTap: () async {
                  setState(() {
                    _isSigningOut = true;
                  });
                  await Authentication.signOut(context: context);
                  setState(() {
                    _isSigningOut = false;
                  });
                  Navigator.of(context).pushReplacement(_routeToSignInScreen());
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 20, left: 10),
                  child: const Icon(
                    Icons.logout,
                    size: 30,
                    color: Colors.white,
                  ),
                ))
          ]),
      body: StreamBuilder(
          stream: getGrievanceStream(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 43),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "No grievance entry yet!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 22.0),
                      child: const Text(
                        "Add your grievance entry and keep track of them!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            }

            final List<DocumentSnapshot> docs = snapshot.data!.docs;

            {
              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Text(
                          "My Tickets",
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                      widget.user.email == adminEmail
                          ? ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 20.0,
                              ),
                              itemCount: docs.length,
                              shrinkWrap: true,
                              reverse: true,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, elementindex) {
                                var getdata = docs[elementindex].data() as Map;
                                Timestamp timestamp = getdata['dateCreated'];
                                String formattedDateTime =
                                    formatDateTime(timestamp);

                                var status =
                                    getdata["greivanceStatus"] ?? "Open";
                                    
                                return Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Grievance ID: ${docs[elementindex].id}", // Correctly display Document ID
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.backgroundColor,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Student Name: ${getdata['userName'] ?? widget.user.displayName ?? ''}", // Use stored name or fallback
                                          style: TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: "Status: ",
                                                style: TextStyle(
                                                  color:
                                                      AppColors.backgroundColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              TextSpan(
                                                text: getdata[
                                                        'greivanceStatus'] ??
                                                    "",
                                                style: TextStyle(
                                                  color: status == "Completed" ? Colors.green : Colors.orange, // Visual cue for status
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Date : $formattedDateTime",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.backgroundColor,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Title: ${getdata['grievanceTitle'] ?? ""}",
                                          style: TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Description: ${getdata['grievanceDescription'] ?? ""}",
                                          style: TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: status == "Completed" ? null : () { // Disable if already completed
                                              markAsCompleted(
                                                  docs[elementindex].id);
                                            },
                                            child:
                                                const Text("Mark as Completed"),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              deleteGrievanceEntry(
                                                  docs[elementindex].id);
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                );
                              },
                            )
                          : ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 10.0,
                              ),
                              itemCount: docs.length,
                              shrinkWrap: true,
                              reverse: true,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, elementindex) {
                                var getdata = docs[elementindex].data() as Map;
                                Timestamp timestamp = getdata['dateCreated'];
                                String formattedDateTime =
                                    formatDateTime(timestamp);

                                var status =
                                    getdata["greivanceStatus"] ?? "Open";

                                return ExpansionTile(
                                  // Removed trailing logic for _isExpanded as it was incorrect
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      getdata['grievanceTitle'].toString().isNotEmpty ? getdata['grievanceTitle'].toString() : "",
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.0,
                                            color: AppColors.whiteColor),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RichText(
                                              text: TextSpan(
                                                children: <InlineSpan>[
                                                  TextSpan(
                                                    text: "Status: ",
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.whiteColor,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: getdata[
                                                                'greivanceStatus']
                                                            .toString()
                                                            .isNotEmpty
                                                        ? getdata[
                                                                'greivanceStatus']
                                                            .toString()
                                                        : "",
                                                    style: TextStyle(
                                                      color: status == "Completed" ? Colors.green : Colors.orange,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Description: ${getdata['grievanceDescription'].toString().isNotEmpty ? getdata['grievanceDescription'].toString() : ""}",
                                              style: TextStyle(
                                                color: AppColors.whiteColor,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Date : $formattedDateTime",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.whiteColor,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                    ],
                  ),
                ),
              );
            }
          }),
      floatingActionButton: widget.user.email == adminEmail
          ? Container() // Admin does not see the FAB
          : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('Add Grievance Entry'),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Use pop()
                              },
                              icon: Icon(
                                Icons.close,
                                color: AppColors.backgroundColor,
                                size: 30,
                              ))
                        ],
                      ),
                      content: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Grievance Title',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Grievance Title';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  grievanceTitle = value!;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Grievance Description',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Grievance Description';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  grievanceDescription = value!;
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      
                                      // Call updated addEntry with named parameters, including userId
                                      await addEntry(
                                          userId: widget.user.uid,
                                          grievanceName: widget.user.displayName ?? widget.user.email ?? "Anonymous User",
                                          grievanceTitle: grievanceTitle,
                                          grievanceDescription: grievanceDescription,
                                          grievanceType: "Food", // Still hardcoded
                                      ); 
                                      
                                      Navigator.of(context).pop(); // Close the dialog
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.add,
                size: 20,
                color: AppColors.backgroundColor,
              )),
    );
  }
}
