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
      shadowColor: Colors.tealAccent.withOpacity(0.4),
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
                  ? TextFormField(
                      controller: controller,
                      cursorColor: Colors.tealAccent,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16, // Slightly larger font for readability
                        fontWeight:
                            FontWeight.w500, // Semi-bold for better focus
                      ),
                      decoration: InputDecoration(
                        labelText: label,
                        labelStyle: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 14, // Consistent sizing for label text
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .grey[700]!), // Darker grey for enabled state
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .tealAccent, // Slightly brighter teal for focus
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12), // Adjust padding for better spacing
                        hintText: 'Enter $label', // Provide a helpful hint
                        hintStyle: TextStyle(
                          color: Colors.grey[600], // Subtle hint text
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
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
                    if (controller.text.isNotEmpty) {
                      value = controller.text;
                    } else {
                      controller.text = value;
                    }
                    isUpdating = !isUpdating;
                    if (!isUpdating) {
                      update(value);
                    }
                  });
                },
                icon: isUpdating
                    ? const Icon(Icons.check_rounded, color: Colors.tealAccent)
                    : const Icon(Icons.edit_rounded, color: Colors.tealAccent),
              )
          ],
        ),
      ),
    );
  }
}
