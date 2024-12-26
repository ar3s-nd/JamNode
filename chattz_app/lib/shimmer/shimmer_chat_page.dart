import 'dart:math';

import 'package:chattz_app/main.dart';
import 'package:chattz_app/shimmer/shimmer_effect.dart';
import 'package:flutter/material.dart';

class ShimmerChatPage extends StatelessWidget {
  const ShimmerChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade900,
            radius: screenHeight * 0.001,
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          height: screenHeight * 0.04,
        ),
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Messages
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      itemCount: 100,
                      itemBuilder: (context, index) {
                        bool isSender = Random().nextInt(2) == 0;
                        double messageWidth = Random().nextDouble() *
                                (screenWidth * 0.6) +
                            screenWidth * 0.2; // Random width 20-80% of screen
                        int lineCount =
                            Random().nextInt(4) + 2; // Random 2-5 lines

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: isSender
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isSender) ...[
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey.shade800,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  width: messageWidth,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft:
                                          Radius.circular(isSender ? 20 : 4),
                                      bottomRight:
                                          Radius.circular(isSender ? 4 : 20),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        List.generate(lineCount, (lineIndex) {
                                      double lineWidth =
                                          Random().nextDouble() * 0.7 +
                                              0.3; // 30-100% of box width
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Container(
                                          height: 8,
                                          width: messageWidth * lineWidth,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Textbox
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.8,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade800,
                          radius: screenWidth * 0.05,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const ShimmerEffect(),
            ],
          ),
        ),
      ),
    );
  }
}
