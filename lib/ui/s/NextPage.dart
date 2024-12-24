import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/ui/m/HomePage.dart';
import 'package:the_third_bookkeeping/ui/m/MainApp.dart';
import 'package:the_third_bookkeeping/utils/LocalStorage.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NextPageScreen(),
    );
  }
}

class NextPageScreen extends StatefulWidget {
  const NextPageScreen({super.key});

  @override
  _NextPageScreenState createState() => _NextPageScreenState();
}

class _NextPageScreenState extends State<NextPageScreen>
    with SingleTickerProviderStateMixin {
  bool restartState = false;
  final Duration checkInterval = const Duration(milliseconds: 500);
  bool startInt = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void pageToHome() {
    LocalStorage().setGuideData("1");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ( MainApp())),
        (route) => route == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: startInt ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/guide_2.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: startInt ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/guide_1.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (!startInt) {
                      setState(() {
                        startInt = true;
                      });
                    }else{
                      pageToHome();
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Image.asset('assets/img/ic_s_but.webp'),
                  ),
                ),
                const SizedBox(height: 44),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBar({
    required this.progress,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
