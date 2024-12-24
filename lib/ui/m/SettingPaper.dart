import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/ThirdUtils.dart';

class SettingPaper extends StatelessWidget {
  const SettingPaper({super.key});

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg_pp.webp'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                const Text(
                  'set',
                  style: TextStyle(
                    fontFamily: 'plus',
                    fontSize: 16,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 50),

                SizedBox(
                  width: 120,
                  height: 151,
                  child: Image.asset('assets/img/ic_setting_top.webp'),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    //边框
                    border: Border.all(
                        color: Color(0xFFE7E2E2)
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                        },
                        child:  Center(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/img/ic_tt.webp',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Share with Friends",
                                style: TextStyle(
                                  color: Color(0xFF747688),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        height: 1,
                        color: Color(0xFFE6EEF6),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          launchPP();
                        },
                        child:  Center(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/img/ic_setting_pp.webp',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: Color(0xFF747688),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        height: 1,
                        color: Color(0xFFE6EEF6),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          launchUserAgreement();
                        },
                        child:  Center(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/img/icon_heart.webp',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Terms of Service",
                                style: TextStyle(
                                  color: Color(0xFF747688),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        height: 1,
                        color: Color(0xFFE6EEF6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }


  void launchPP() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.blooming.unlimited.fast';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ThirdUtils.showToast('Cant open web page $url');
    }
  }

  void launchUserAgreement() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.blooming.unlimited.fast';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ThirdUtils.showToast('Cant open web page $url');
    }
  }

  void restartApp(BuildContext context) {
    Navigator.of(context).removeRoute(ModalRoute.of(context) as Route);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SettingPaper()),
        (route) => route == null);
  }
}

