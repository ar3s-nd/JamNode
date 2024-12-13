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
  List<String> imageUrls = [
    "https://img.freepik.com/free-psd/3d-icon-social-media-app_23-2150049569.jpg?t=st=1734021272~exp=1734024872~hmac=e1631345b981bb44b56fa08ae2ed84a3c155df03ac3e688f117ddf8701e24976&w=826"
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQttE9sxpEu1EoZgU2lUF_HtygNLCaz2rZYHg&s",
    "https://cdn-icons-png.flaticon.com/512/1053/1053244.png",
    "https://cdn.vectorstock.com/i/1000v/92/16/default-profile-picture-avatar-user-icon-vector-46389216.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-wLGEqZy7Akjn0ZMf3qYTxNWZZMMimodTfA&s",
  ];

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
                        // _buildMultiSelectField(
                        //   label: 'Courses',
                        //   items: const [
                        //     "Accordion",
                        //     "Bagpipes",
                        //     "Banjo",
                        //     "Bass Guitar",
                        //     "Cello",
                        //     "Clarinet",
                        //     "Double Bass",
                        //     "Drums",
                        //     "Fiddle",
                        //     "Flute",
                        //     "Guitar",
                        //     "Keyboard",
                        //     "Kora",
                        //     "Piano",
                        //     "Saxophone",
                        //     "Sitar",
                        //     "Steelpan",
                        //     "Tabla",
                        //     "Trombone",
                        //     "Trumpet",
                        //     "Violin"
                        //   ],
                        //   onConfirm: (values) {
                        //     setState(() {
                        //       _selectedRoles = values;
                        //     });
                        //   },
                        // ),
                        _buildMultiSelectDropDownField(
                          label: 'Courses',
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
                                          String randomImageUrl =
                                              (imageUrls..shuffle()).first;

                                          // create a map of the user details
                                          Map<String, dynamic> userInfoMap = {
                                            'name': _nameController.text,
                                            'email': _emailController.text,
                                            "collegeName":
                                                _collegeNameController.text,
                                            "collegeId":
                                                _rollNumberController.text,
                                            "imageUrl": randomImageUrl,
                                            "gotDetails": true,
                                            "groupId": "",
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
      cursorColor: Colors.teal[800],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal[200]),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.teal[200]!),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle: errorStyle,
      ),
      validator: validator,
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> items,
    required void Function(List<String>) onConfirm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.teal[200]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: items.map((item) {
            return FilterChip(
              label: Text(item),
              labelStyle: const TextStyle(color: Colors.white),
              selected: _selectedRoles.contains(item),
              selectedColor: Colors.teal[900],
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedRoles.add(item);
                  } else {
                    _selectedRoles.remove(item);
                  }
                  onConfirm(_selectedRoles);
                });
              },
              backgroundColor: Colors.grey[900],
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (_selectedRoles.isEmpty)
          Text(
            'Please select at least one',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildMultiSelectDropDownField({
    required String label,
    required List<String> items,
    required void Function(List<String>) onConfirm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.teal[200]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.teal[200]!),
            ),
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && !_selectedRoles.contains(value)) {
              setState(() {
                _selectedRoles.add(value);
                onConfirm(_selectedRoles);
              });
            }
          },
          hint: Text(
            'Select Courses',
            style: TextStyle(color: Colors.grey[400]),
          ),
          dropdownColor: Colors.grey[900],
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
