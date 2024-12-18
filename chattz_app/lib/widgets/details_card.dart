import 'package:chattz_app/components/auto_complete_text_field.dart';
import 'package:chattz_app/components/details_textfield.dart';
import 'package:chattz_app/main.dart';
import 'package:flutter/material.dart';

class DetailsCard extends StatefulWidget {
  const DetailsCard({
    super.key,
    required this.update,
    required this.icon,
    required this.label,
    required this.value,
    this.isUpdatable = false,
    required this.isMe,
  });
  final Function update;
  final IconData icon;
  final String label;
  final String value;
  final bool isUpdatable;
  final bool isMe;

  @override
  State<DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends State<DetailsCard> {
  late TextEditingController controller;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String label = widget.label;
    String value = widget.value;
    bool isUpdatable = widget.isUpdatable;
    bool isMe = widget.isMe;
    Function update = widget.update;
    IconData icon = widget.icon;

    return Card(
      elevation: 6,
      shadowColor: Colors.tealAccent.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.tealAccent),
            const SizedBox(width: 16),
            Expanded(
              child: isUpdating
                  ? label == 'College Name'
                      ? AutoCompleteTextField(
                          controller: controller,
                          label: label,
                          suggestions: collegeNamesGlobal,
                        )
                      : DetailsTextField(
                          controller: controller,
                          label: label,
                        )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
            if (isUpdatable && isMe)
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isUpdating) {
                      // If updating, check if the entered value is in the suggestions (only for 'College Name')
                      if (label == 'College Name' &&
                          !collegeNamesGlobal.contains(controller.text)) {
                        controller.text = value; // Revert to the previous value
                      } else {
                        value = controller.text; // Accept the new valid value
                      }
                    }
                    isUpdating = !isUpdating;
                    if (!isUpdating) {
                      update(value);
                    }
                  });
                },
                icon: Icon(
                  isUpdating ? Icons.check_rounded : Icons.edit_rounded,
                  color: Colors.tealAccent,
                ),
              )
          ],
        ),
      ),
    );
  }
}
