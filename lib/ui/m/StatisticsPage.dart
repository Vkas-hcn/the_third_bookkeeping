import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/AccountData.dart';
import '../../utils/LocalStorage.dart';
import '../../utils/ThirdUtils.dart';
import '../../utils/ZhiShou.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AddFeelPageScreen(),
    );
  }
}

class AddFeelPageScreen extends StatefulWidget {
  const AddFeelPageScreen({super.key});

  @override
  _StatisticsPageScressState createState() => _StatisticsPageScressState();
}

class _StatisticsPageScressState extends State<AddFeelPageScreen> {
  DateTime selectedDate = DateTime.now();
  String nowDateMonth = '';
  String nowDateYear = '';
  bool isMonthly = false;
  String yearData = '0.0';
  String avgDaily = '0.0';
  String avgMonthly = '0.0';
  int staticTypeInt = 0; //0:All 1:Income 2:Expense
  List<String> _expensesText = [];

  @override
  void initState() {
    super.initState();
    nowDateYear = DateFormat('yyyy').format(selectedDate);
    nowDateMonth = DateFormat('yyyy-MM').format(selectedDate);
    getStatisticData();
    getAccData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAccData() async {
    if (staticTypeInt == 0) {
      _expensesText = AccountData.dataTextZong;
    } else if (staticTypeInt == 1) {
      _expensesText = AccountData.incomeText;
    } else {
      _expensesText = AccountData.expensesText;
    }
    setState(() {});
  }

  String getImageData(index) {
    List<String> listImage;
    if (staticTypeInt == 0) {
      listImage = AccountData.dataImageZong;
    } else if (staticTypeInt == 1) {
      listImage = AccountData.incomeImage;
    } else {
      listImage = AccountData.expensesImage;
    }
    return listImage[index];
  }

  Future<String> getTotalAmountBreakdown(String category) async {
    // 统计分类总金额
    double? summary = 0.0;
    if (isMonthly) {
      summary = await RecordBean.getCategoryTotal(nowDateMonth, category);
    } else {
      summary = await RecordBean.getCategoryTotalByYear(nowDateYear, category);
    }
    print("统计分类总金额---${category}----${summary}");
    if (summary.isNaN || summary <= 0) {
      return "0.0";
    }
    return "-${summary.toStringAsFixed(2)}";
  }

  Future<String> getTotalAmountPercentage(String category) async {
    // 统计分类占比
    try {
      double? summary = 0.0;
      double? to = 0.0;
      bool isIncomeState = ThirdUtils.isIncome(category);
      if (isMonthly) {
        summary = await RecordBean.getCategoryTotal(nowDateMonth, category);
        to = await RecordBean.getCategoryProportion(nowDateMonth, false,isIncomeState);
      } else {
        summary =
            await RecordBean.getCategoryTotalByYear(nowDateYear, category);
        to = await RecordBean.getCategoryProportion(nowDateYear, true,isIncomeState);
      }
      double bfb = ((summary / to) * 100);
      if (bfb.isNaN) {
        return "0%";
      }
      String cleanedString = bfb.toStringAsFixed(2).replaceAll('-', '');
      print("统计分类总金额---${category}----${summary}----${to}----${bfb}");
      return "${cleanedString}%";
    } catch (e) {
      print("Error parsing expense or budget: $e");
      return "0%";
    }
  }

  //切换时间维度
  void changeTimeDimension(bool state) {
    setState(() {
      isMonthly = state;
    });
    getStatisticData();
  }

  void changeType(int state) {
    setState(() {
      staticTypeInt = state;
    });
    getStatisticData();
    getAccData();
  }

  void getStatisticData() async {
    Map<String, double> statistics = {};
    if (isMonthly) {
      statistics = await RecordBean.calculateMonthlyStatistics(
          nowDateMonth, staticTypeInt);
    } else {
      statistics =
          await RecordBean.calculateStatistics(nowDateYear, staticTypeInt);
    }
    print("This Year: ${statistics["This Year"]}");
    print("Avg. Monthly: ${statistics["Avg. Monthly"]}");
    print("Avg. Daily: ${statistics["Avg. Daily"]}");

    setState(() {
      yearData = statistics["This Year"].toString();
      avgDaily = statistics["Avg. Daily"].toString();
      avgMonthly = statistics["Avg. Monthly"].toString();
    });
  }

  Map<String, double> calculateIncomeExpenseBalance(
      List<Map<String, dynamic>> data) {
    double income = 0.0;
    double expense = 0.0;

    for (var bill in data) {
      double num = double.parse(bill['num']);

      if (bill['isInCome']) {
        income += num;
      } else {
        expense += num;
      }
    }

    double balance = income - expense;

    return {
      'income': income,
      'expense': expense,
      'balance': balance,
    };
  }

  // 获取指定月份的天数
  int daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return DateTime(nextMonth.year, nextMonth.month, 0).day;
  }

  // 切换月份
  void updateMonth(String inputMonth) {
    try {
      final newMonth = DateFormat('yyyy-MM').parse(inputMonth);
      setState(() {
        selectedDate = DateTime(newMonth.year, newMonth.month, 1);
      });
    } catch (e) {
      // 输入解析错误处理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('输入格式错误，请使用 yyyy-MM 格式')),
      );
    }
  }

  void getAdjustedDate(bool isNext, bool isYear) {
    if (!isYear) {
      // 切换年份
      if (isNext) {
        if (DateTime(
                selectedDate.year + 1, selectedDate.month, selectedDate.day)
            .isAfter(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('It is not possible to select a future date')),
          );
          return;
        }
        selectedDate = DateTime(
            selectedDate.year + 1, selectedDate.month, selectedDate.day);
      } else {
        selectedDate = DateTime(
            selectedDate.year - 1, selectedDate.month, selectedDate.day);
      }
    } else {
      // 切换月份
      if (isNext) {
        if (DateTime(
                selectedDate.year, selectedDate.month + 1, selectedDate.day)
            .isAfter(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('It is not possible to select a future date')),
          );
          return;
        }
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month + 1, selectedDate.day);
        if (selectedDate.month < selectedDate.month) {
          selectedDate = DateTime(selectedDate.year + 1, 1, selectedDate.day);
        }
      } else {
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month - 1, selectedDate.day);
        if (selectedDate.month > selectedDate.month) {
          selectedDate = DateTime(selectedDate.year - 1, 12, selectedDate.day);
        }
      }
    }

    // 更新状态和界面
    setState(() {
      nowDateYear = DateFormat('yyyy').format(selectedDate);
      nowDateMonth = DateFormat('yyyy-MM').format(selectedDate);
    });
    updateMonth(nowDateMonth);
    getStatisticData();
  }

  @override
  Widget build(BuildContext context) {
    nowDateYear = DateFormat('yyyy').format(selectedDate);
    nowDateMonth = DateFormat('yyyy-MM').format(selectedDate);
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 95),
                  const Spacer(),
                  const Text(
                    'Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'sf',
                      fontSize: 16,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 65,
                    child: Image.asset('assets/img/ic_setting_top.webp'),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        changeTimeDimension(false);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 12, right: 12),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(isMonthly
                              ? 'assets/img/ic_home_but_diss.webp'
                              : 'assets/img/ic_home_but.webp'),
                          fit: BoxFit.fill,
                        )),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            'Annual Report',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'sf',
                              fontSize: 16,
                              color:
                                  isMonthly ? Color(0xFF747688) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        changeTimeDimension(true);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 12, right: 12),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(isMonthly
                              ? 'assets/img/ic_home_but.webp'
                              : 'assets/img/ic_home_but_diss.webp'),
                          fit: BoxFit.fill,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            'Monthly Report',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'sf',
                              fontSize: 16,
                              color:
                                  isMonthly ? Colors.white : Color(0xFF747688),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(color: const Color(0xFFE7E2E2)), // 边框
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        getAdjustedDate(false, isMonthly);
                      },
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Image.asset('assets/img/ic_arrow_left.webp'),
                      ),
                    ),
                    Text(
                      isMonthly ? nowDateMonth : nowDateYear,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'plus',
                        fontSize: 16,
                        color: Color(0xFF747688),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        getAdjustedDate(true, isMonthly);
                      },
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Image.asset('assets/img/ic_arrow_right2.webp'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        changeType(0);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(staticTypeInt == 0
                              ? 'assets/img/ic_set.webp'
                              : 'assets/img/ic_state_but_diss.webp'),
                          fit: BoxFit.fill,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 40),
                          child: Text(
                            "All",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: staticTypeInt == 0
                                  ? Colors.white
                                  : const Color(0xFF747688),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        changeType(1);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(staticTypeInt == 1
                              ? 'assets/img/ic_set.webp'
                              : 'assets/img/ic_state_but_diss.webp'),
                          fit: BoxFit.fill,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 4),
                          child: Text(
                            "Income",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: staticTypeInt == 1
                                  ? Colors.white
                                  : const Color(0xFF747688),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        changeType(2);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 12, right: 8),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(staticTypeInt == 2
                              ? 'assets/img/ic_set.webp'
                              : 'assets/img/ic_state_but_diss.webp'),
                          fit: BoxFit.fill,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 4),
                          child: Text(
                            "Expenses",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: staticTypeInt == 2
                                  ? Colors.white
                                  : const Color(0xFF747688),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/img/ic_pet_bg.webp'),
                        fit: BoxFit.fill,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMonthly ? 'This Month' : 'This Year',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF747688),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              yearData,
                              style: const TextStyle(
                                fontFamily: 'sf',
                                fontSize: 16,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 7),
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/img/ic_pet_bg.webp'),
                        fit: BoxFit.fill,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMonthly ? 'Avg. Weekly' : 'Avg. Monthly',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF747688),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              avgMonthly,
                              style: const TextStyle(
                                fontFamily: 'sf',
                                fontSize: 16,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 7, right: 12),
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/img/ic_pet_bg.webp'),
                        fit: BoxFit.fill,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Avg. Daily',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF747688),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              avgDaily,
                              style: const TextStyle(
                                fontFamily: 'sf',
                                fontSize: 16,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //网格布局
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: _expensesText.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 176,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE7E2E2),
                            width: 1,
                          ),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFFFFFCEF),
                              ),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.asset(getImageData(index)),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 50,
                                  ),
                                  child: Text(
                                    _expensesText[index],
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFF79766),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4), // 调整文本间距
                                FutureBuilder<String>(
                                  future: getTotalAmountBreakdown(
                                      _expensesText[index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF101828),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                        'Something went wrong',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF101828),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 70,
                                        ),
                                        child: Text(
                                          snapshot.data ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF101828),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 4),
                                FutureBuilder<String>(
                                  future: getTotalAmountPercentage(
                                      _expensesText[index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF747688),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                        'Something went wrong',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF747688),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF747688),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
