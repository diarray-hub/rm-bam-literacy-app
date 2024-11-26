/// Defining the main utility functions for a reading lesson
import 'package:collection/collection.dart';
import 'package:literacy_app/backend_code/user.dart' show saveUserData;

Future<Map<String, dynamic>> bookmark(
    String uid,
    String title,
    String pageRef,
    int readingTime,
    List<double> accuracies,
    Map<String, dynamic> userData
    ) async {

  // Check if the book is already bookmarked
  final bookmarkedIndex = userData['inProgressBooks'].indexWhere((book) => book['title'] == title);

  if (bookmarkedIndex != -1) {
    // Update the existing bookmark
    userData['inProgressBooks'][bookmarkedIndex]['bookmark'] = pageRef;
    userData['inProgressBooks'][bookmarkedIndex]['readingTime'] = readingTime; // Increment reading time
    userData['inProgressBooks'][bookmarkedIndex]['accuracies'] = accuracies;
  } else {
    // Create new bookmark
    Map<String, dynamic> bookMarking = {
      'title': title,
      'bookmark': pageRef,
      'readingTime': readingTime,
      'accuracies': accuracies,
    };
    // Add a new bookmark
    userData['inProgressBooks'].add(bookMarking);
  }
  // Save new userData to firebase
  await saveUserData(uid, userData);
  // Return the latest version of userData
  return userData;
}

Future<Map<String, dynamic>> markBookAsCompleted(
    String uid,
    String title,
    String pageRef,
    double readingTime,
    List<double> accuracies,
    Map<String, dynamic> userData,
    ) async {
  // Check if the book is already bookmarked
  final bookmarkedIndex = userData['inProgressBooks']
      .indexWhere((book) => book['title'] == title);

  if (bookmarkedIndex != -1) {
    // Remove the bookmark
    userData['inProgressBooks'].removeAt(bookmarkedIndex);
  }

  // Add the book to completed books if not already present
  if (!userData['completedBooks'].contains(title)) {
    userData['completedBooks'].add(title);
  }

  // Calculate average accuracy
  double averageAccuracy = accuracies.sum / accuracies.length;

  // Update User XP based on reading time and average accuracy
  int earnedXp = ((20 * averageAccuracy) + (50 / (readingTime + 1))).toInt();
  userData['xp'] += earnedXp;

  // Save the updated userData (assuming you have a function to save it)
  await saveUserData(uid, userData);

  // Return updated userData, total reading time, and average accuracy
  return {
    'userData': userData,
    'averageAccuracy': averageAccuracy,
    'earnedXp': earnedXp,
  };
}
