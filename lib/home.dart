import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:literacy_app/constant.dart' show books;
import 'package:literacy_app/profile.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:literacy_app/backend_code/user.dart' show getUserData;
import 'package:literacy_app/main.dart' show auth;
import 'package:literacy_app/lesson_screen.dart' show LessonScreen;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true; // Track loading state

  Future<void> initUserData() async {
    try {
      if (user != null) {
        Map<String, dynamic> data = await getUserData(user!.uid);
        setState(() {
          userData = data;
          isLoading = false; // Data fetched
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
      setState(() {
        isLoading = false; // Avoid infinite loading
      });
    }
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;

    if (user != null) {
      initUserData();
    } else {
      log('No user is currently signed in.');
    }

    auth.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
        initUserData(); // Reinitialize userData when user changes
      }
    });

    log(user.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(), // Loading spinner
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vocal Search Bar at the Top
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const Text(
                  'An be Kalan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Gafe dɔ ɲini',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white),
                      onPressed: () {
                        // Implement vocal search logic here
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Book List
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'An ka gafew',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final isInProgress = userData!['inProgressBooks']
                      .any((b) => b['title'] == book['title']);
                  final isCompleted =
                  userData!['completedBooks'].contains(book['title']);

                  return GestureDetector(
                    onTap: () => openLesson(context, book['title']!),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(book['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                  isCompleted
                                      ? 0.7 // Opacity for completed books
                                      : isInProgress
                                      ? 0.35 // Opacity for in-progress books
                                      : 0.0, // No overlay for other books
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book['title']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Navigation Tab Bar at the Bottom
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          if (index == 0) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Go back to the existing HomePage instance
            }
          } else if (index == 3) {
            showModalBottomSheet(
              context: context,
              builder: (context) => ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      navigateToProfilePage();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      navigateToSettingsPage();
                    },
                  ),
                ],
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Gafew'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_4x4), label: 'Crosswords'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Daɲɛ'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  void navigateToProfilePage() {
    if (userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            xp: userData!["xp"],
            user: user!,
          ),
        ),
      );
    }
  }

  void navigateToSettingsPage() {
    // Logic for navigating to the Settings Page
  }

  Future<void> openLesson(BuildContext context, String bookTitle) async {
    // Navigate to LessonScreen and await the result
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          uid: user!.uid,
          userdata: userData!,
          bookTitle: bookTitle,
        ),
      ),
    );

    // Update `userdata` if a result is returned
    if (updatedUserData != null) {
      setState(() {
        userData = updatedUserData;
      });
    }
  }
}
