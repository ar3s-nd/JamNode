import 'package:chattz_app/main.dart';
import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/pages/get_skill_level_page.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetDetailsPage extends StatefulWidget {
  final String name, email, collegeName, rollNumber;
  final List<String> skills;

  const GetDetailsPage({
    super.key,
    required this.name,
    required this.email,
    required this.collegeName,
    required this.rollNumber,
    required this.skills,
  });

  @override
  State<GetDetailsPage> createState() => _GetDetailsPageState();
}

class _GetDetailsPageState extends State<GetDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    _collegeNameController.text = widget.collegeName;
    _rollNumberController.text = widget.rollNumber;
    _selectedSkills = widget.skills;
  }

  @override
  void dispose() {
    _collegeNameController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  void push() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GetSkillLevelPage(skills: _selectedSkills),
      ),
    );
  }

  void pusReplacementAuthPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  bool get isFormValid =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _collegeNameController.text.isNotEmpty &&
      _rollNumberController.text.isNotEmpty &&
      _selectedSkills.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              pusReplacementAuthPage();
            },
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        color: Colors.tealAccent,
        backgroundColor: Colors.black,
        onRefresh: () async {
          setState(() {});
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2D1F3D),
                Colors.teal.shade900,
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                      label: 'Select Your Skills',
                      items: skillsGlobal,
                      onConfirm: (values) {
                        setState(() {
                          _selectedSkills = values;
                        });
                      },
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
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
                                      // create a map of the user details
                                      Map<String, dynamic> skills = {};
                                      for (var skill in _selectedSkills) {
                                        if (skill != 'None of them') {
                                          skills[skill] = 1;
                                        }
                                      }
                                      Map<String, dynamic> userInfoMap = {
                                        'name': _nameController.text,
                                        'email': _emailController.text,
                                        "collegeName":
                                            _collegeNameController.text,
                                        "collegeId": _rollNumberController.text,
                                        "gotDetails": false,
                                        "groups": [],
                                        'skills': skills,
                                      };

                                      if (_selectedSkills
                                          .contains('None of them')) {
                                        userInfoMap['gotDetails'] = true;
                                      }

                                      // try adding the user to the database
                                      await UserService().updateProfile(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userInfoMap,
                                      );
                                      if (userInfoMap['gotDetails']) {
                                        pusReplacementAuthPage();
                                      } else {
                                        push();
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFormValid
                                  ? const Color.fromARGB(255, 20, 117, 101)
                                  : Colors.grey[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _selectedSkills.contains('None of them')
                                  ? 'Finish'
                                  : 'Next',
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
        ),
      ),
    );
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
              // Show "Select Skills" always as the selected item
              return items.map((_) {
                return Text(
                  _selectedSkills.isNotEmpty ? 'Add Skills' : 'Select Skills',
                  // 'Select Skills',
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
                  // Only include 'None of them' if _selectedSkills is empty
                  if (_selectedSkills.isEmpty) {
                    if (!items.contains('None of them')) {
                      items = ['None of them', ...items];
                    }
                  } else {
                    items.remove('None of them');
                  }

                  if (value == 'None of them' && _selectedSkills.isEmpty) {
                    _selectedSkills.add('None of them');
                  } else if (value != 'None of them') {
                    _selectedSkills.remove('None of them');
                    if (!_selectedSkills.contains(value)) {
                      _selectedSkills.add(value);
                    }
                  }

                  // Call the onConfirm callback with the updated selected skills
                  onConfirm(_selectedSkills);
                });
              }
            },
            hint: Text(
              'Select Skills',
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
          children: _selectedSkills.map((course) {
            return Chip(
              label: Text(course, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.teal[900],
              deleteIcon: const Icon(Icons.close, color: Colors.white),
              onDeleted: () {
                setState(() {
                  _selectedSkills.remove(course);
                  onConfirm(_selectedSkills);
                });
              },
            );
          }).toList(),
        ),
        if (_selectedSkills.isEmpty)
          Text(
            'Please select at least one',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
      ],
    );
  }
}
