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
  int currentPage = 0; // Track the current page index
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void pageToHome() {
    LocalStorage().setGuideData("1");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainApp()),
            (route) => route == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/guide_1.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/guide_2.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (currentPage == 0) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      pageToHome();
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 150,
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

