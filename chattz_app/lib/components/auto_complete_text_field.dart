import 'package:flutter/material.dart';

class AutoCompleteTextField extends StatefulWidget {
  const AutoCompleteTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.suggestions,
    this.obscureText = false,
    this.validator,
    this.errorStyle,
  });

  final TextEditingController controller;
  final String label;
  final List<String> suggestions;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextStyle? errorStyle;

  @override
  State<AutoCompleteTextField> createState() => _AutoCompleteTextFieldState();
}

class _AutoCompleteTextFieldState extends State<AutoCompleteTextField> {
  List<String> filteredSuggestions = [];
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          cursorColor: Colors.tealAccent,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 14,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.tealAccent,
                width: 2,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            errorStyle: widget.errorStyle ??
                const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            hintText: 'Enter ${widget.label}',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          validator: widget.validator,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                if (value.isEmpty) {
                  filteredSuggestions = [];
                  errorMessage = null;
                } else {
                  filteredSuggestions = widget.suggestions
                      .where((college) => college.toLowerCase().startsWith(
                          value.toLowerCase())) // Case-insensitive matching
                      .toList();
                  errorMessage = filteredSuggestions.isEmpty
                      ? 'No matching suggestions found'
                      : null;
                }
              });
            }
          },
        ),
        if (filteredSuggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.controller.text = filteredSuggestions[index];
                    if (mounted) {
                      setState(() {
                        filteredSuggestions = [];
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Text(
                      filteredSuggestions[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
