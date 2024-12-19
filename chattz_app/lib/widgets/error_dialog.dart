import 'package:chattz_app/components/image_circle.dart';
import 'package:flutter/material.dart';

class ErrorDialog {
  static void show({
    required BuildContext context,
    required String title,
    String? description,
    VoidCallback? onRetry,
    String text1 = 'Retry',
    String text2 = 'Close',
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor:
              Colors.transparent, // Transparent for custom shadow effect
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Main content card
              Container(
                margin: const EdgeInsets.only(top: 50),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.black]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50), // Space for the icon
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            text2,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                        if (onRetry != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onRetry();
                            },
                            child: Text(
                              text1,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Icon at the top
              ImageCircle(
                letter: '!',
                circleRadius: 40,
                fontSize: 40,
                colors: [Colors.black, Colors.teal],
                letterColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
}
