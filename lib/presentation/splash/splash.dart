import 'package:chat_bot/core/assets/app_images.dart';
import 'package:chat_bot/core/config/app_color.dart';
import 'package:chat_bot/presentation/home/chat_home.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 30),
                _assistancText(),
                _subText(),
                const SizedBox(height: 30),
                _splashImage(),
                const SizedBox(height: 100),
                _continueButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _assistancText() {
    return const Text(
      'You AI Assistant',
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: AppColor.primaryColor,
      ),
    );
  }

  Widget _subText() {
    return const Text(
      'Using this software,you can ask you \n questions and receive articles using \n artificial intelligence assistant',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF757575),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _splashImage() {
    return Image.asset(AppImages.splash);
  }

  Widget _continueButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChatHome()),
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 19,
                    color: AppColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: const Icon(
                  Icons.arrow_forward,
                  color: AppColor.secondaryColor,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
