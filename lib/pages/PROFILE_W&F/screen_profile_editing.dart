import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/TextField.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/theme.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Mock data - in a real app, this would come from your user data

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    _firstNameController.text = ref.read(UserProvider)!.firstName;
    _lastNameController.text = ref.read(UserProvider)!.lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // void _saveChanges() async {
  //   ShowLoadingDialog(context);
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(ref.read(UserProvider)!.uid)
  //       .update({
  //     'firstName': _firstNameController.text,
  //     'lastName': _lastNameController.text,
  //   });
  //   ref.read(UserProvider.notifier).addnames(
  //         _firstNameController.text,
  //         _lastNameController.text,
  //       );
  //   // This would save the changes to your backend
  //   // For now, just navigate back
  //   Navigator.pop(context);
  //   Navigator.pop(context);
  // }

  Future<void> _saveChanges() async {
    ShowLoadingDialog(context);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ref.read(UserProvider)!.uid)
          .update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
      });

      ref.read(UserProvider.notifier).addnames(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
          );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Go back to previous screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      showCustomSnackBar(
        context,
        "Failed to update profile. Please try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Themes.white0(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Themes.black0(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: Themes.headline2(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'outfit',
                color: Themes.fire_red,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0), // Ensure everything aligns properly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Profile picture section
              Center(
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Themes.white2(context),
                      width: 1.w,
                    ),
                    color: Colors
                        .grey[300], // Background color for better visibility
                  ),
                  child: Icon(
                    Icons.person,
                    size: 80, // Adjust icon size as needed
                    color: Themes.gray3(context), // Adjust icon color as needed
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              SizedBox(height: 30.h),

              // First name label
              Text('First Name', style: Themes.MidContainerText(context)),
              SizedBox(height: 6.h),

              // First name field
              textField(
                _firstNameController,
                context,
                'Enter your first name',
              ),

              SizedBox(height: 20.h),

              // Last name label
              Text('Last Name', style: Themes.MidContainerText(context)),
              SizedBox(height: 6.h),

              // Last name field
              textField(
                _lastNameController,
                context,
                'Enter your last name',
              ),

              SizedBox(height: 40.h),
              // Save button (if any)
            ],
          ),
        ),
      ),
    );
  }
}
