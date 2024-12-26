import 'package:chattz_app/main.dart';
import 'package:chattz_app/shimmer/shimmer_effect.dart';
import 'package:flutter/material.dart';

class ShimmerHomePage extends StatelessWidget {
  const ShimmerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CircleAvatar(backgroundColor: Colors.grey.shade900),
          )
        ],
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
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                itemCount: 100,
                itemBuilder: (context, index) {
                  return Container(
                    height: screenHeight * 0.13,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade900,
                            radius: 30,
                          ),
                          SizedBox(width: screenWidth * 0.05),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: screenHeight * 0.035,
                                width: screenWidth * 0.45,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: screenHeight * 0.03,
                                width: screenWidth * 0.3,
                              ),
                            ],
                          ),
                          SizedBox(width: screenWidth * 0.08),
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade900,
                            radius: 15,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const ShimmerEffect(),
            ],
          ),
        ),
      ),
    );
  }
}
