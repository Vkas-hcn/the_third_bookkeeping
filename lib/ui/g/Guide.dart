import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/ui/m/HomePage.dart';
import 'package:the_third_bookkeeping/ui/m/MainApp.dart';

import '../../utils/LocalStorage.dart';
import '../s/NextPage.dart';

class Guide extends StatelessWidget {
  const Guide({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timerProgress;
  bool restartState = false;
  final Duration checkInterval = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startProgress() {
    const int totalDuration = 2000;
    const int updateInterval = 50;
    const int totalUpdates = totalDuration ~/ updateInterval;
    int currentUpdate = 0;
    _progress = 0.0;
    _timerProgress =
        Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress = (currentUpdate + 1) / totalUpdates;
      });
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
        pageToHome();
      }
    });
  }

  void pageToHome() async {
    String state = await LocalStorage().getGuideData();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                (state == "1" ? MainApp() : const NextPage())),
        (route) => route == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 250),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 267,
                        height: 153,
                        child: Image.asset('assets/img/icon_start_ll.webp'),
                      ),
                      const SizedBox(height: 23),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Tally ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'plus',
                              fontSize: 36,
                              color: Color(0xFF2D170B),
                            ),
                          ),
                          Text(
                            'book',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'plus',
                              fontSize: 36,
                              color: Color(0xFFF79866),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 67, right: 40, left: 40),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ProgressBar(
                                progress: _progress,
                                // Set initial progress here
                                height: 6,
                                borderRadius: 3,
                                backgroundColor: Color(0x54C3C3C3),
                                progressColor: Color(0xFF101828),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
