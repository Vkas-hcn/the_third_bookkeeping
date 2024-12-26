import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/ui/m/HomePage.dart';
import 'BillPage.dart';
import 'SettingPaper.dart';
import 'StatisticsPage.dart';
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onTap: _onItemTapped),
      const BillPage(),
      const StatisticsPage(),
      const SettingPaper(),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFF8F8F8),
        body: Column(
          children: [
            Expanded(
              child: _pages[_selectedIndex],
            ),
            BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Image.asset(
                    width: 32,
                    height: 32,
                    _selectedIndex == 0
                        ? 'assets/img/icon_home.webp'
                        : 'assets/img/icon_home_2.webp',
                    fit: BoxFit.contain,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    width: 32,
                    height: 32,
                    _selectedIndex == 1
                        ? 'assets/img/icon_bill.webp'
                        : 'assets/img/icon_bill_2.webp',
                    fit: BoxFit.contain,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    width: 32,
                    height: 32,
                    _selectedIndex == 2
                        ? 'assets/img/icon_statis.webp'
                        : 'assets/img/icon_statis_2.webp',
                    fit: BoxFit.contain,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    width: 32,
                    height: 32,
                    _selectedIndex == 3
                        ? 'assets/img/icon_set.webp'
                        : 'assets/img/icon_set_2.webp',
                    fit: BoxFit.contain,
                  ),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue, // 可以设置为其他颜色
              unselectedItemColor: Colors.grey, // 未选中时的颜色
              onTap: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}

