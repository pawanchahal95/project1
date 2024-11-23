import 'package:flutter/material.dart';
import 'package:proj2/chatApp/cloudChat/chat.dart';
import 'package:proj2/chatApp/cloudChat/view/chatHomePage.dart';
import 'package:proj2/services/auth/auth_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  final _usernameController = TextEditingController();
  final _userDialogController = TextEditingController();
  final _userImageController = TextEditingController();
  final _userIdController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _userDialogController.dispose();
    _userImageController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  // Fetch and populate user data
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userEmail = AuthService.firebase().currentUser!.email;
      final user = await _firebaseCloudStorage.getUser(email: userEmail);

      _usernameController.text = user.userName;
      _userDialogController.text = user.userDialog;
      _userImageController.text = user.userImage;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save user data
  Future<void> _CreateUserData() async {
    try {
      await _firebaseCloudStorage.createNewUser(


        userDialog: _userDialogController.text,
        userImage: _userImageController.text, emailId:AuthService.firebase().currentUser!.email , username:_usernameController.text, userId: AuthService.firebase().currentUser!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ChatHomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () {
                  // Add functionality to change profile picture
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change picture tapped')),
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _userImageController.text.isNotEmpty
                      ? NetworkImage(_userImageController.text)
                      : const AssetImage('assets/default_profile.png')
                  as ImageProvider,
                  child: Stack(
                    children: const [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // User Dialog
              TextField(
                controller: _userDialogController,
                decoration: InputDecoration(
                  labelText: 'About',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // User Image URL
              TextField(
                controller: _userImageController,
                decoration: InputDecoration(
                  labelText: 'Profile Image URL',
                  prefixIcon: const Icon(Icons.image),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _CreateUserData,
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
