import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/utils/ThirdUtils.dart';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../utils/LocalStorage.dart';
import '../../utils/ZhiShou.dart';
import '../g/Guide.dart';
import 'BottomSheetWithInput.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

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
  _BudgetPageScressState createState() => _BudgetPageScressState();
}

class _BudgetPageScressState extends State<AddFeelPageScreen> {
  List<String> _expensesText = [];
  DateTime selectedDate = DateTime.now();
  String nowDate = '';
  String expense = "";
  String balance = "";
  String budget = "";
  String expenditurePercentage = "";

  @override
  void initState() {
    super.initState();
    nowDate = DateFormat('yyyy-MM').format(selectedDate);
    getAccData();
    setListData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAccData() async {
    setState(() {
      _expensesText = ThirdUtils.getAccListTextData(false);
    });
  }

  Future<String> getTotalAmountBreakdown(String category) async {
    // 统计分类总金额
    double? summary = await RecordBean.getCategoryTotal(nowDate, category);
    print("统计分类总金额---${category}----${summary}");
    if (summary.isNaN || summary<=0) {
      return "0.0";
    }
    return "-${summary.toStringAsFixed(2)}";
  }

  Future<String> getTotalAmountPercentage(String category) async {
    // 统计分类占比
    try {
      double? summary = await RecordBean.getCategoryTotal(nowDate, category);
      double expenseData = num.parse(expense).toDouble();
      double bfb = ((summary / expenseData) * 100);
      if(bfb.isNaN){
        return "0%";
      }
      String cleanedString = bfb.toStringAsFixed(2).replaceAll('-', '');
      print("统计分类总金额---${category}----${bfb}");
      return "${cleanedString}%";
    } catch (e) {
      print("Error parsing expense or budget: $e");
      return "0%";
    }
  }

  String getImageData(index) {
    return ThirdUtils.getAccListImageData(false)[index];
  }

  void getAdjustedDate(bool isNext) {
    if (isNext) {
      if (DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day)
          .isAfter(DateTime.now())) {
        selectedDate =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('It is not possible to select a future date')),
        );
        return;
      }
      selectedDate =
          DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
      if (selectedDate.month < selectedDate.month) {
        selectedDate = DateTime(selectedDate.year + 1, 1, selectedDate.day);
      }
    } else {
      selectedDate =
          DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
      if (selectedDate.month > selectedDate.month) {
        selectedDate = DateTime(selectedDate.year - 1, 12, selectedDate.day);
      }
    }
    setState(() {
      nowDate = DateFormat('yyyy-MM').format(selectedDate);
    });
    getAccData();
    setListData();
  }

  void setListData() async {
    print("nowDate: ${nowDate}");
    Map<String, String> summary =
        await RecordBean.calculateMonthlySummary(nowDate);
    print("收入: ${summary['income']}");
    print("支出: ${summary['expense']}");
    print("结余: ${summary['balance']}");
    print("预算: ${summary['budget']}");
    print("百分比: ${summary['expenditurePercentage']}");
    setState(() {
      expense = summary['expense'] ?? "0";
      balance = summary['balance'] ?? "0";
      budget = summary['budget'] ?? "0";
      expenditurePercentage = summary['expenditurePercentage'] ?? "0";
    });
  }

  double parseAndDivideByHundred(String percentageString) {
    try {
      // 去掉百分号
      String cleanedString = percentageString.replaceAll('%', '');
      print("cleanedString====$cleanedString");
      // 检查字符串是否为空或 null
      if (cleanedString.isEmpty) {
        return 0.0;
      }
      // 将字符串转换为 double
      double value = double.parse(cleanedString);
      // 除以 100
      double result = value / 100;
      // 返回结果
      return result;
    } catch (e) {
      print("Error parsing percentage string: $e");
      // 返回一个默认值，例如 0.0
      return 0.0;
    }
  }

  String getRemainingBudget() {
    try {
      double expenseData = num.parse(expense).toDouble();
      double budgetData = num.parse(budget).toDouble();
      return (expenseData + budgetData).toString();
    } catch (e) {
      print("Error parsing expense or budget: $e");
      // 返回一个默认值，例如 "0"
      return "0";
    }
  }

  Future<void> setMonthlyBudgetData(String num) async {
    //String 转 double
    double budgetData = double.parse(num);
    await RecordBean.setMonthlyBudget(nowDate, budgetData);
    getAccData();
    setListData();
    ThirdUtils.showToast("The modification was successful");
  }

  @override
  Widget build(BuildContext context) {
    nowDate = DateFormat('yyyy-MM').format(selectedDate);
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
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  const Text(
                    'Budget Management',
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
              GestureDetector(
                onTap: () {
                  selectMonth(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                          getAdjustedDate(false);
                        },
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/img/ic_arrow_left.webp'),
                        ),
                      ),
                      Text(
                        nowDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'plus',
                          fontSize: 16,
                          color: Color(0xFF747688),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          getAdjustedDate(true);
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
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showBottomSheetWithInput(context, "Set Monthly Budget",
                            (value) {
                          if (value.isNotEmpty) {
                            LocalStorage().setYuData(value.toString());
                            print("保存的数据：$value");
                            setMonthlyBudgetData(value);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 21, vertical: 6),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/ic_set.webp'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: const Text(
                          'Set Budget',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Remaining Budget',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF747688),
                      ),
                    ),
                    Text(
                      getRemainingBudget(),
                      style: const TextStyle(
                        fontFamily: 'sf',
                        fontSize: 32,
                        color: Color(0xFF101828),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10,right: 10,top: 2,bottom: 8),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/ic_jdz.webp'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Text(
                        "${parseAndDivideByHundred(expenditurePercentage)*100}%",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'sf',
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ProgressBar(
                        progress:
                            parseAndDivideByHundred(expenditurePercentage),
                        // Set initial progress here
                        height: 8,
                        borderRadius: 9,
                        backgroundColor: const Color(0xFFEDEBDF),
                        progressColor: const Color(0xFFF79766),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/img/ic_pet_bg.webp'),
                      fit: BoxFit.fill,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Budget',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF747688),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            budget,
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
                  Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/img/ic_pet_bg.webp'),
                      fit: BoxFit.fill,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Consumption',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF747688),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            expense,
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
                ],
              ),
              //网格布局
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 每行两列
                      crossAxisSpacing: 10, // 水平间距
                      mainAxisSpacing: 10, // 垂直间距
                      childAspectRatio: 1.8, // 宽高比，调整条目形状
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
                                const SizedBox(height: 4), // 调整文本间距
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

  Future<void> selectMonth(BuildContext context) async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    DateTime currentDate = DateTime.now();

    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = initialDate.year;
        int selectedMonth = initialDate.month;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Month'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      currentDate.year - 1999,
                      // Generate years from 2000 to current year
                      (index) => DropdownMenuItem(
                        value: 2000 + index,
                        child: Text((2000 + index).toString()),
                      ),
                    ),
                    onChanged: (int? value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                            DateFormat.MMMM().format(DateTime(0, index + 1))),
                      ),
                    ),
                    onChanged: (int? value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(selectedYear, selectedMonth),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        print("pickedDate=====$pickedDate");
      });

      nowDate = DateFormat('yyyy-MM').format(selectedDate);
    }
  }
}
