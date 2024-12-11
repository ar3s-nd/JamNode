import 'package:chattz_app/pages/auth_page.dart';
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
  List<String> _selectedCourses = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
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
      _selectedCourses.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
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
                    label: 'College Email ID',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'College email is required';
                      }
                      return null;
                    },
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
                  //       _selectedCourses = values;
                  //     });
                  //   },
                  // ),
                  _buildMultiSelectDropDownField(
                    label: 'Courses',
                    items: const [
                      "Accordion",
                      "Bagpipes",
                      "Banjo",
                      "Bass Guitar",
                      "Cello",
                      "Clarinet",
                      "Double Bass",
                      "Drums",
                      "Fiddle",
                      "Flute",
                      "Guitar",
                      "Keyboard",
                      "Kora",
                      "Piano",
                      "Saxophone",
                      "Sitar",
                      "Steelpan",
                      "Tabla",
                      "Trombone",
                      "Trumpet",
                      "Violin"
                    ],
                    onConfirm: (values) {
                      setState(() {
                        _selectedCourses = values;
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
                              ? () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    // Handle form submission logic

                                    // set gotDetails to true
                                    AuthPage().gotDetails = true;
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFormValid
                                ? Colors.teal[900]
                                : Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color:
                                  isFormValid ? Colors.white : Colors.grey[500],
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
              selected: _selectedCourses.contains(item),
              selectedColor: Colors.teal[900],
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedCourses.add(item);
                  } else {
                    _selectedCourses.remove(item);
                  }
                  onConfirm(_selectedCourses);
                });
              },
              backgroundColor: Colors.grey[900],
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (_selectedCourses.isEmpty)
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
            if (value != null && !_selectedCourses.contains(value)) {
              setState(() {
                _selectedCourses.add(value);
                onConfirm(_selectedCourses);
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
          children: _selectedCourses.map((course) {
            return Chip(
              label: Text(course, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.teal[900],
              deleteIcon: Icon(Icons.close, color: Colors.white),
              onDeleted: () {
                setState(() {
                  _selectedCourses.remove(course);
                  onConfirm(_selectedCourses);
                });
              },
            );
          }).toList(),
        ),
        if (_selectedCourses.isEmpty)
          Text(
            'Please select at least one',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
      ],
    );
  }
}
