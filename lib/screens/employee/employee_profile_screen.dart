import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final uid = context.read<AuthProvider>().currentUser?.uid;
        if (uid != null) {
          final success = await context.read<UserProvider>().uploadProfileImage(
            uid,
            pickedFile,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success ? 'Profile image updated!' : 'Failed to upload image',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _saveProfile() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      final success = await context.read<UserProvider>().updateUserProfile(
        uid: uid,
        name: _nameController.text,
        department: _departmentController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<UserProvider>().error ??
                    'Failed to update profile',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, _) {
        final user = userProvider.user;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            user?.profileImageUrl != null
                                ? NetworkImage(user!.profileImageUrl!)
                                : null,
                        child:
                            user?.profileImageUrl == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Fields
                if (!_isEditing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile('Name', user?.name ?? 'N/A'),
                      _buildInfoTile('Email', user?.email ?? 'N/A'),
                      _buildInfoTile('Department', user?.department ?? 'N/A'),
                      _buildInfoTile('Phone', user?.phone ?? 'N/A'),
                    ],
                  )
                else
                  Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Name',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _departmentController,
                        hintText: 'Department',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // Edit/Save Button
                if (!_isEditing)
                  CustomButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  )
                else
                  CustomButton(
                    text: 'Save Changes',
                    isLoading: userProvider.isLoading,
                    onPressed: _saveProfile,
                  ),
                const SizedBox(height: 16),

                // Logout Button
                CustomButton(
                  text: 'Logout',
                  onPressed: () {
                    authProvider.signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
