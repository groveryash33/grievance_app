import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grievance_app/authentication/authentication.dart';
import 'package:intl/intl.dart';

import '../constants/custom_color.dart';
import '../firebase_storage/firebase_Storage.dart';
import '../splash_screen.dart';

class GriveanceHomepage extends StatefulWidget {
  User user;
  static const String grivencehomepage = "TodoBucketHomepage";
  GriveanceHomepage({super.key, required this.user});

  @override
  State<GriveanceHomepage> createState() => _GriveanceHomepageState();
}

class _GriveanceHomepageState extends State<GriveanceHomepage> {
  late bool _isSigningOut = false;

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

  //// datetime format
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

  String? userId = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String grievanceTitle = '';
  String grievanceDescription = '';

  // List of dropdown items
  List<String> dropdownItems = [
    'Hostel',
    'Food',
    'Counselling',
    'Certificate',
  ];

  final String adminEmail = 'yashgrover8622@gmail.com';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    String selectedItem = dropdownItems.first;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text(
            'Grievance',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          centerTitle: true,
          // pinned: true,
          // floating: true,

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
          stream: FirebaseFirestore.instance
              .collection('/My Grievance/')
              // .where(widget.user.email.toString(),
              //     isEqualTo: "yashgrover8622@gmail.com")
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
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
                    // const Padding(
                    //   padding: EdgeInsets.all(48.0),
                    //   child: Text(
                    //     "My Tickets",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(fontSize: 22, color: Colors.white),
                    //   ),
                    // ),
                    const Text(
                      "No grievance entry yet !",
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

            // Here you can safely access snapshot.data!
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

                                userId = snapshot.data!.docs[elementindex].id;
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
                                          "GrievanceId:${widget.user.uid}:   ",
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
                                          "Student Name: ${widget.user.displayName}" ??
                                              "",
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
                                                text: "Status",
                                                style: TextStyle(
                                                  color:
                                                      AppColors.backgroundColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const WidgetSpan(
                                                child: SizedBox(width: 10),
                                              ),
                                              TextSpan(
                                                text: getdata[
                                                        'greivanceStatus'] ??
                                                    "",
                                                style: const TextStyle(
                                                  color: Colors.green,
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
                                          "Date : $formattedDateTime" ?? "",
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
                                            onPressed: () {
                                              // Mark grievance as completed
                                              markAsCompleted(
                                                  docs[elementindex].id);
                                            },
                                            child:
                                                const Text("Mark as Completed"),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Delete grievance entry
                                              deleteGrievanceEntry(
                                                  docs[elementindex].id);
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          // ListView.separated(
                          //     separatorBuilder: (context, index) =>
                          //         const SizedBox(
                          //           height: 10.0,
                          //         ),
                          //     itemCount: docs.length,
                          //     shrinkWrap: true,
                          //     reverse: true,
                          //     physics: const ClampingScrollPhysics(),
                          //     itemBuilder: (context, elementindex) {
                          //       var getdata = docs[elementindex].data() as Map;
                          //       Timestamp timestamp = getdata['dateCreated'];
                          //       String formattedDateTime =
                          //           formatDateTime(timestamp);

                          //       userId = snapshot.data!.docs[elementindex].id;
                          //       var status =
                          //           getdata["greivanceStatus"] ?? "Open";

                          //       return Card(
                          //         child: Column(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.start,
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   "GrievanceId:${widget.user.uid}:   ",
                          //                   style: TextStyle(
                          //                       fontWeight: FontWeight.w400,
                          //                       color:
                          //                           AppColors.backgroundColor,
                          //                       fontSize: 16.0),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   "Student Name: ${getdata['grievanceEntryBy'].toString().isNotEmpty ? getdata['grievanceEntryBy'].toString() : ""}",
                          //                   style: TextStyle(
                          //                       color:
                          //                           AppColors.backgroundColor,
                          //                       fontSize: 18),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: RichText(
                          //                     text: TextSpan(
                          //                         children: <InlineSpan>[
                          //                       TextSpan(
                          //                         text: "Status",
                          //                         style: TextStyle(
                          //                             color: AppColors
                          //                                 .backgroundColor,
                          //                             fontSize: 18),
                          //                       ),
                          //                       const WidgetSpan(
                          //                           child: SizedBox(width: 10)),
                          //                       TextSpan(
                          //                         text: getdata[
                          //                                     'greivanceStatus']
                          //                                 .toString()
                          //                                 .isNotEmpty
                          //                             ? getdata[
                          //                                     'greivanceStatus']
                          //                                 .toString()
                          //                             : "",
                          //                         style: const TextStyle(
                          //                             color: Colors.green,
                          //                             fontSize: 18),
                          //                       )
                          //                     ])),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   "Date : $formattedDateTime" ?? "",
                          //                   // style: TextStyle(
                          //                   //     fontWeight: FontWeight.w400,
                          //                   //     color: AppColors.backgroundColor,
                          //                   //     fontSize: 16.0),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   "Title: ${getdata['grievanceTitle'].toString().isNotEmpty ? getdata['grievanceTitle'].toString() : ""}",
                          //                   style: TextStyle(
                          //                       color:
                          //                           AppColors.backgroundColor,
                          //                       fontSize: 18),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   "Description: ${getdata['grievanceDescription'].toString().isNotEmpty ? getdata['grievanceDescription'].toString() : ""}",
                          //                   style: TextStyle(
                          //                       color:
                          //                           AppColors.backgroundColor,
                          //                       fontSize: 18),
                          //                 ),
                          //               )
                          //             ]),
                          //       );
                          //     })

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

                                userId = snapshot.data!.docs[elementindex].id;
                                var status =
                                    getdata["greivanceStatus"] ?? "Open";

                                return ExpansionTile(
                                  trailing: _isExpanded
                                      ? Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 20,
                                          color: Colors.white,
                                        ) // Collapse icon
                                      : Icon(Icons.keyboard_arrow_down,
                                          size: 20, color: Colors.white),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          getdata['grievanceTitle'].toString().isNotEmpty ? getdata['grievanceTitle'].toString() : "",
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.0,
                                            color: AppColors.whiteColor),
                                      ),
                                      //    margin: const EdgeInsets.all(12.0),
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
                                                    text: "Status",
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.whiteColor,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const WidgetSpan(
                                                    child: SizedBox(width: 10),
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
                                                    style: const TextStyle(
                                                      color: Colors.green,
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
                                              "Date : $formattedDateTime" ?? "",
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

                      // : ListView.separated(
                      //     separatorBuilder: (context, index) =>
                      //         const SizedBox(
                      //           height: 10.0,
                      //         ),
                      //     itemCount: docs.length,
                      //     shrinkWrap: true,
                      //     reverse: true,
                      //     physics: const ClampingScrollPhysics(),
                      //     itemBuilder: (context, elementindex) {
                      //       var getdata = docs[elementindex].data() as Map;
                      //       Timestamp timestamp = getdata['dateCreated'];
                      //       String formattedDateTime =
                      //           formatDateTime(timestamp);

                      //       userId = snapshot.data!.docs[elementindex].id;
                      //       var status =
                      //           getdata["greivanceStatus"] ?? "Open";

                      //       return Container(
                      //         decoration: BoxDecoration(
                      //             border: Border.all(
                      //                 width: 1.0,
                      //                 color: AppColors.whiteColor)),
                      //         child: Container(
                      //           margin: const EdgeInsets.all(12.0),
                      //           child: Column(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.start,
                      //             crossAxisAlignment:
                      //                 CrossAxisAlignment.start,
                      //             children: [
                      //               Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceBetween,
                      //                 children: [
                      //                   Padding(
                      //                     padding:
                      //                         const EdgeInsets.all(8.0),
                      //                     child: Text(
                      //                       "Title: ${getdata['grievanceTitle'].toString().isNotEmpty ? getdata['grievanceTitle'].toString() : ""}",
                      //                       style: TextStyle(
                      //                           color: AppColors.whiteColor,
                      //                           fontSize: 18),
                      //                     ),
                      //                   ),
                      //                   GestureDetector(
                      //                     onTap: () {
                      //                       setState(() {
                      //                         deleteTasks(snapshot.data!
                      //                             .docs[elementindex].id);
                      //                       });

                      //                       // Then show a snackbar.
                      //                       ScaffoldMessenger.of(context)
                      //                           .showSnackBar(SnackBar(
                      //                               backgroundColor:
                      //                                   AppColors
                      //                                       .backgroundColor,
                      //                               content: Text(
                      //                                 '${getdata['grievanceTitle'].toString()} has been successfully deleted',
                      //                                 style: TextStyle(
                      //                                     color: AppColors
                      //                                         .whiteColor,
                      //                                     fontSize: 18.0),
                      //                               )));
                      //                     },
                      //                     child: const Icon(
                      //                       Icons.delete,
                      //                       size: 30.0,
                      //                       color: Colors.white,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: RichText(
                      //                     text: TextSpan(
                      //                         children: <InlineSpan>[
                      //                       TextSpan(
                      //                         text: "Status",
                      //                         style: TextStyle(
                      //                             color:
                      //                                 AppColors.whiteColor,
                      //                             fontSize: 18),
                      //                       ),
                      //                       const WidgetSpan(
                      //                           child: SizedBox(width: 10)),
                      //                       TextSpan(
                      //                         text: getdata[
                      //                                     'greivanceStatus']
                      //                                 .toString()
                      //                                 .isNotEmpty
                      //                             ? getdata[
                      //                                     'greivanceStatus']
                      //                                 .toString()
                      //                             : "",
                      //                         style: const TextStyle(
                      //                             color: Colors.green,
                      //                             fontSize: 18),
                      //                       )
                      //                     ])),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Text(
                      //                   "Description: ${getdata['grievanceDescription'].toString().isNotEmpty ? getdata['grievanceDescription'].toString() : ""}",
                      //                   style: TextStyle(
                      //                       color: AppColors.whiteColor,
                      //                       fontSize: 18),
                      //                 ),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Text(
                      //                   "Date : $formattedDateTime" ?? "",
                      //                   style: TextStyle(
                      //                       fontWeight: FontWeight.w400,
                      //                       color: AppColors.whiteColor,
                      //                       fontSize: 16.0),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     }),
                    ],
                  ),
                ),
              );
            }
          }),
      floatingActionButton: widget.user.email == adminEmail
          ? Container()
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
                                Navigator.of(context).pop;
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
                              // DropdownButton<String>(
                              //   value: selectedItem,
                              //   icon: const Icon(Icons.arrow_downward),
                              //   elevation: 16,
                              //   style:
                              //       const TextStyle(color: Colors.deepPurple),
                              //   underline: Container(
                              //     height: 2,
                              //     color: Colors.deepPurpleAccent,
                              //   ),
                              //   onChanged: (String? value) {
                              //     // This is called when the user selects an item.
                              //     setState(() {
                              //       selectedItem = value!;
                              //     });
                              //   },
                              //   items: dropdownItems
                              //       .map<DropdownMenuItem<String>>(
                              //           (String value) {
                              //     return DropdownMenuItem<String>(
                              //       value: value,
                              //       child: Text(value),
                              //     );
                              //   }).toList(),
                              // ),
                              // const SizedBox(height: 20),
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
                                      // Perform any action with the validated input
                                      print('_grievanceTitle: $grievanceTitle');
                                      print(
                                          '_grievanceDescription: $grievanceDescription');
                                      await addEntry(
                                          widget.user.displayName ?? "",
                                          //   grievanceTitle,
                                          Timestamp.now(),
                                          grievanceTitle,
                                          grievanceDescription,
                                          "Food",
                                          "Open");
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
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
                color: widget.user.email != adminEmail
                    ? AppColors.backgroundColor
                    : Colors.white,
              )),
    );
  }
}
