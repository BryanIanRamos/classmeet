import 'package:flutter/material.dart';
import 'package:practice1/core/constants/app_color.dart';
import 'package:practice1/core/constants/app_theme.dart';

class WelcomeApp extends StatelessWidget {
  const WelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.themeData,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Welcome_bg.png'),
                repeat: ImageRepeat.repeat,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.modulate,
                ),
              ),
            ),
            child: Center(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Section
                    Image.asset(
                      'assets/images/ClassMeet_Main_Logo.png',
                      scale: 1.2,
                    ),

                    SizedBox(height: 5),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ClassMeet Title
                        Text(
                          'Class',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary,
                          ),
                        ),
                        Text(
                          'Meet',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondary,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25),

                    // Signin in button
                    ElevatedButton(
                      onPressed: () {
                        print('Sign in has been Clicked!');
                      },
                      child: SizedBox(
                        width: 200,
                        height: 40,
                        child: Center(
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight(700),
                            ),
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Create an account',
                        style: TextStyle(fontSize: 16),
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
}
