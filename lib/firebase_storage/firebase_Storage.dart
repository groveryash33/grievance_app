import 'package:cloud_firestore/cloud_firestore.dart';

////class FirebaseStorage {
String collectionName = "/My Grievance/";
FirebaseFirestore firestore = FirebaseFirestore.instance;

// Create a CollectionReference called users that references the firestore collection
CollectionReference users =
    FirebaseFirestore.instance.collection(collectionName);

Future<void> addEntry(
    String grievanceName,
    Timestamp dateCreated,
    String grievanceTitle,
    String grievanceDescription,
    String greivanceType,
    String greivanceStatus) {
  CollectionReference<Map<String, dynamic>> users =
      FirebaseFirestore.instance.collection(collectionName);

  Map<String, dynamic> addTasksData = {
    'grievanceName': grievanceName, // Stokes and Sons
    'dateCreated': dateCreated,
    'grievanceTitle': grievanceTitle,
    "greivanceType": greivanceType,
    'greivanceStatus': greivanceStatus,
    'grievanceDescription': grievanceDescription
  };
  // Call the user's CollectionReference to add a new user
  return users
      .add(addTasksData)
      .then((value) => print("User Added at "))
      .catchError((error) => print("Failed to add user: $error"));
}

Future deleteTasks(String taskId) async {
  var collection = FirebaseFirestore.instance
      .collection(collectionName); // fetch the collection name i.e. tasks
  collection
          .doc(
              taskId) // ensure the right task is deleted by passing the task id to the method
          .delete() // delete method removes the task entry in the collection
      ;
}

Future updateTask(String taskId, bool completed) async {
  var collection = FirebaseFirestore.instance
      .collection(collectionName); // fetch the collection name i.e. tasks
  collection
      .doc(
          taskId) // ensure the right task is deleted by passing the task id to the method
      .update({
    'isCompleted': completed,
  });
}

// Function to mark grievance entry as completed
void markAsCompleted(String docId) {
  var docRef = FirebaseFirestore.instance.collection(collectionName).doc(docId);

  // Update 'grievanceStatus' field to 'Completed'
  docRef.update({'greivanceStatus': 'Completed'}).then((_) {
    print('Grievance marked as completed successfully.');
  }).catchError((error) {
    print('Failed to mark grievance as completed: $error');
  });
}

// Function to delete grievance entry
void deleteGrievanceEntry(String docId) {
  var docRef = FirebaseFirestore.instance.collection(collectionName).doc(docId);

  // Delete the document
  docRef.delete().then((_) {
    print('Grievance entry deleted successfully.');
  }).catchError((error) {
    print('Failed to delete grievance entry: $error');
  });
}

///}
