import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:literacy_app/main.dart' show auth;
import 'package:literacy_app/backend_code/user.dart' show deleteUserData;

const placeholderImage =
    'https://drive.google.com/uc?export=download&id=1_egpUE2P2KJ3WVQ44iCT0ux6f_KdJVdO';

class ProfilePage extends StatefulWidget {
  final int xp;
  final User user;
  const ProfilePage({super.key, required this.user, required this.xp});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController controller;
  String? photoURL;
  bool showSaveButton = false;
  bool isLoading = false;

  @override
  void initState() {
    controller = TextEditingController(text: widget.user.displayName);
    controller.addListener(_onNameChanged);

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);
    super.dispose();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _onNameChanged() {
    setState(() {
      showSaveButton = controller.text != widget.user.displayName && controller.text.isNotEmpty;
    });
  }

  List get userProviders => widget.user.providerData.map((e) => e.providerId).toList();

  Future updateDisplayName() async {
    await widget.user.updateDisplayName(controller.text);
    setState(() {
      showSaveButton = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name updated')),
    );
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setIsLoading();

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${widget.user.uid}.jpg');
        await ref.putFile(File(pickedImage.path));
        final downloadURL = await ref.getDownloadURL();

        await widget.user.updatePhotoURL(downloadURL);
        setState(() {
          photoURL = downloadURL;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload picture')),
        );
      }

      setIsLoading();
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await deleteUserData(widget.user.uid);
        await widget.user.delete();
        Navigator.of(context).pop(); // Navigate to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    if (widget.user.isAnonymous) {
      await deleteUserData(widget.user.uid);
      await widget.user.delete(); // Delete anonymous account
    }
    await auth.signOut();
    await GoogleSignIn().signOut();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final randomColor = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      0.4, // Light overlay
    );

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Profile',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            maxRadius: 60,
                            backgroundImage: NetworkImage(
                              widget.user.photoURL ?? placeholderImage,
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  randomColor,
                                ],
                                stops: const [0.7, 1.0],
                              ),
                            ),
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 0,
                            bottom: 0,
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(40),
                              child: InkWell(
                                onTap: _uploadProfilePicture,
                                radius: 50,
                                child: const SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Icon(Icons.camera_alt),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                          textAlign: TextAlign.center,
                          controller: controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            alignLabelWithHint: true,
                            label: Center(
                              child: Text('Click to add a display name'),
                            ),
                          ),
                        ),
                      Text('${widget.xp} XP', ),
                      const SizedBox(height: 5),
                      Text(widget.user.email ?? 'user@anonymous.none'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (userProviders.contains('password'))
                            const Icon(Icons.mail),
                          if (userProviders.contains('google.com'))
                            SizedBox(
                              width: 24,
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          widget.user.sendEmailVerification();
                        },
                        child: const Text('Verify Email'),
                      ),
                      const Divider(thickness: 1.0,),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          _signOut();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade100,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _deleteAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text('Delete Account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 40,
              top: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !showSaveButton
                    ? SizedBox(key: UniqueKey())
                    : TextButton(
                  onPressed: isLoading ? null : updateDisplayName,
                  child: const Text('Save changes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
