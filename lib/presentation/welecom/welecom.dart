import 'package:chat_bot/core/assets/app_images.dart';
import 'package:chat_bot/core/config/app_color.dart';
import 'package:chat_bot/presentation/splash/splash.dart';
import 'package:flutter/material.dart';



class WelecomPage extends StatefulWidget {
  const WelecomPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelecomPageState createState() => _WelecomPageState();
}

class _WelecomPageState extends State<WelecomPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const SplashPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: AppColor.primaryColor)),
          Center(child: Image.asset(AppImages.logo)),
        ],
      ),
    );
  }
}
