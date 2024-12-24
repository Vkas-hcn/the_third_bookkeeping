import 'dart:async';
import 'package:flutter/material.dart';

class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BillPageScress(),
    );
  }
}

class BillPageScress extends StatefulWidget {
  const BillPageScress({super.key});

  @override
  _BillPageScressState createState() => _BillPageScressState();
}

class _BillPageScressState extends State<BillPageScress>
    with SingleTickerProviderStateMixin {
  bool restartState = false;
  final Duration checkInterval = const Duration(milliseconds: 500);

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
                  padding: const EdgeInsets.only(left: 32, right: 32, top: 250),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 108,
                        height: 108,
                        child: Image.asset('assets/img/icon_start_ll.webp'),
                      ),
                      const SizedBox(height: 23),
                      const Text(
                        'BillPage',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'plus',
                          fontSize: 36,
                          color: Color(0xFF000000),
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
