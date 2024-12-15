import 'package:chattz_app/main.dart';
import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetDetailsPage extends StatefulWidget {
  final String name, email;

  const GetDetailsPage(this.name, this.email, {super.key});

  @override
  State<GetDetailsPage> createState() => _GetDetailsPageState();
}

class _GetDetailsPageState extends State<GetDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  List<String> _selectedRoles = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _collegeNameController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  bool get isFormValid =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _collegeNameController.text.isNotEmpty &&
      _rollNumberController.text.isNotEmpty &&
      _selectedRoles.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.cyan.shade900,
              Colors.teal.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Enter your ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Details',
                                  style: TextStyle(
                                    color: Colors.teal[200],
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Please provide your details to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Name',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Your email',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value!)) {
                              return 'Invalid email address';
                            }
                            return null;
                          },
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _collegeNameController,
                          label: 'College Name',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'College name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _rollNumberController,
                          label: 'Roll Number',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Roll number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildMultiSelectDropDownField(
                          label: 'Select Your Interests',
                          items: roles,
                          onConfirm: (values) {
                            setState(() {
                              _selectedRoles = values;
                            });
                          },
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _nameController,
                              _emailController,
                              _collegeNameController,
                              _rollNumberController,
                            ]),
                            builder: (context, _) {
                              return ElevatedButton(
                                onPressed: isFormValid
                                    ? () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          // Handle form submission logic

                                          // create a map of the user details
                                          Map<String, dynamic> userInfoMap = {
                                            'name': _nameController.text,
                                            'email': _emailController.text,
                                            "collegeName":
                                                _collegeNameController.text,
                                            "collegeId":
                                                _rollNumberController.text,
                                            "gotDetails": true,
                                            "groups": [],
                                          };

                                          // try adding the user to the database
                                          await UserService().addUserDetails(
                                              userInfoMap,
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);

                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AuthPage()));
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? Colors.teal[900]
                                      : Colors.grey[800],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Finish',
                                  style: TextStyle(
                                    color: isFormValid
                                        ? Colors.white
                                        : Colors.grey[500],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () async {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OnboardingPage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> getRoles() {
    List<String> roles = [];
    FirestoreServices().getRoles().then((value) {
      roles = value;
    });
    return roles;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextStyle? errorStyle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.teal[300],
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16, // Slightly larger font for readability
        fontWeight: FontWeight.w500, // Semi-bold for better focus
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.teal[200],
          fontSize: 14, // Consistent sizing for label text
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.grey[700]!), // Darker grey for enabled state
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal[300]!, // Slightly brighter teal for focus
            width: 2, // Slightly thicker underline for focus
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2, // Consistent thickness for error state
          ),
        ),
        errorStyle: errorStyle ??
            const TextStyle(
              color: Colors.redAccent, // Subtle error color
              fontSize: 12, // Slightly smaller for less distraction
              fontWeight: FontWeight.w400,
            ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12), // Adjust padding for better spacing
        hintText: 'Enter $label', // Provide a helpful hint
        hintStyle: TextStyle(
          color: Colors.grey[600], // Subtle hint text
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildMultiSelectDropDownField({
    required String label,
    required List<String> items,
    required void Function(List<String>) onConfirm,
  }) {
    items = items.contains('None of them') ? items : ['None of them', ...items];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Constrained Dropdown width and height
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.teal[200]!),
              ),
            ),
            isExpanded: true,
            iconSize: 30, // Adjust icon size
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors
                        .grey[850], // Subtle background for the entire tile
                    borderRadius: BorderRadius.circular(
                        8), // Rounded corners for the tile
                  ),
                  child: Row(
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Slightly larger font size
                          fontWeight: FontWeight.w500, // Semi-bold for emphasis
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              // Show "Select Interests" always as the selected item
              return items.map((_) {
                return Text(
                  _selectedRoles.isNotEmpty
                      ? _selectedRoles.join(', ')
                      : 'Select Interests',
                  // 'Select Interests',
                  style: TextStyle(
                    color: Colors.teal[200],
                    fontWeight: FontWeight.w400,
                  ),
                );
              }).toList();
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  // Only include 'None of them' if _selectedRoles is empty
                  if (_selectedRoles.isEmpty) {
                    if (!items.contains('None of them')) {
                      items = ['None of them', ...items];
                    }
                  } else {
                    items.remove('None of them');
                  }

                  if (value == 'None of them' && _selectedRoles.isEmpty) {
                    _selectedRoles.add('None of them');
                  } else if (value != 'None of them') {
                    _selectedRoles.remove('None of them');
                    if (!_selectedRoles.contains(value)) {
                      _selectedRoles.add(value);
                    }
                  }

                  // Call the onConfirm callback with the updated selected roles
                  onConfirm(_selectedRoles);
                });
              }
            },
            hint: Text(
              'Select Interests',
              style: TextStyle(
                color: Colors.teal[200],
                fontWeight: FontWeight.w400,
              ),
            ),
            dropdownColor: Colors.grey[900], // Dropdown background color
            itemHeight: 48, // Limit the height of each dropdown item
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: _selectedRoles.map((course) {
            return Chip(
              label: Text(course, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.teal[900],
              deleteIcon: const Icon(Icons.close, color: Colors.white),
              onDeleted: () {
                setState(() {
                  _selectedRoles.remove(course);
                  onConfirm(_selectedRoles);
                });
              },
            );
          }).toList(),
        ),
        if (_selectedRoles.isEmpty)
          Text(
            'Please select at least one',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
      ],
    );
  }
}
