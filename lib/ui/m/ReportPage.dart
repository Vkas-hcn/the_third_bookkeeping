import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/utils/ThirdUtils.dart';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../utils/LocalStorage.dart';
import '../../utils/ZhiShou.dart';
import '../g/Guide.dart';
import 'CalendarWidget.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

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
  _ReportPageScressState createState() => _ReportPageScressState();
}

class _ReportPageScressState extends State<AddFeelPageScreen> {
  DateTime selectedDate = DateTime.now();
  String nowDate = '';
  String nowDateDay = '';
  DateTime focusedMonth = DateTime.now();
  String income = "";
  String expense = "";
  String balance = "";
  List<Map<String, dynamic>> filteredData = [];
  Map<String, double> dailyBalances = {}; // 存储每天的余额
  @override
  void initState() {
    super.initState();
    nowDate = DateFormat('yyyy-MM').format(selectedDate);
    nowDateDay = DateFormat('yyyy-MM-dd').format(selectedDate);
    getBillsByDate(nowDateDay,false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getBillsByDate(String date, bool isRefresh) async {
    final localStorage = LocalStorage();
    String jsonStr = await localStorage.getValue(LocalStorage.accountJson);
    try {
      // 解析 JSON 数据
      List<dynamic> jsonData = jsonDecode(jsonStr);
      List<Map<String, dynamic>> parsedData =
          jsonData.map((e) => e as Map<String, dynamic>).toList();

      print("从本地读取数据---$parsedData");

      // 提取日期和月份
      String dateMonth = date.substring(0, 7); // 提取到月份部分，例如 "2024-12"
      String day = date.substring(8, 10); // 提取到日期部分，例如 "26"

      // 筛选出指定月份的数据
      List<Map<String, dynamic>> monthFilteredData =
          parsedData.where((data) => data["dateMonth"] == dateMonth).toList();

      if (monthFilteredData.isNotEmpty) {
        // 获取当月数据的第一项
        Map<String, dynamic> monthData = monthFilteredData.first;
        // 遍历每一天的数据
        if(!isRefresh){
          monthData.forEach((day, dayData) {
            if (day != "dateMonth" && day != "yu") {
              if (dayData.containsKey("zhiShouList")) {
                List<dynamic> zhiShouList = dayData["zhiShouList"];

                // 解析账单信息
                List<Map<String, dynamic>> dayFilteredData =
                zhiShouList.map((item) => item as Map<String, dynamic>).toList();

                // 计算收入、支出和结余
                Map<String, double> result =
                calculateIncomeExpenseBalance(dayFilteredData);
                if(result['balance']!=null){
                  setState(() {
                    //大于零加+号
                    dailyBalances[day] = result['balance'] ?? 0.0;
                    print("遍历每一天的数据==${day}----${dailyBalances[day]}");
                  });
                }
              }
            }
          });
        }

        // 检查是否有当天的数据
        if (monthData.containsKey(day)) {
          // 返回当天所有账单信息
          Map<String, dynamic> dayData = monthData[day];

          if (dayData.containsKey("zhiShouList")) {
            List<dynamic> zhiShouList = dayData["zhiShouList"];

            // 解析账单信息
            setState(() {
              filteredData = zhiShouList
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
            });

            print("解析后的账单数据: $filteredData");
            // 计算收入、支出和结余
            Map<String, double> result =
                calculateIncomeExpenseBalance(filteredData);
            print(
                "收入: ${result['income']}, 支出: ${result['expense']}, 结余: ${result['balance']}");
            setState(() {
              income = result['income'].toString();
              expense = result['expense'].toString();
              balance = result['balance'].toString();
            });
          }
        }else{
          setState(() {
            filteredData = [];
            income = "0.0";
            expense = "0.0";
            balance = "0.0";
          });
        }
      }
    } catch (e) {
      print("解析 JSON 失败: $e");
    }
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

  void deleteOperationData(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteOperationData2(id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void deleteOperationData2(String id) async {
    await RecordBean.deleteRecordById(id);
    getBillsByDate(nowDateDay,false);
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
        focusedMonth = newMonth;
        selectedDate = DateTime(newMonth.year, newMonth.month, 1);
      });
    } catch (e) {
      // 输入解析错误处理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('输入格式错误，请使用 yyyy-MM 格式')),
      );
    }
  }

  void getAdjustedDate(bool isNext) {
    if (isNext) {
      if (DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day)
          .isAfter(DateTime.now())) {
        selectedDate =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('It is not possible to select a future date')),
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
      nowDateDay = DateFormat('yyyy-MM-dd').format(selectedDate);
      dailyBalances.clear();
    });
    updateMonth(nowDate);
    getBillsByDate(nowDateDay,false);
  }

  @override
  Widget build(BuildContext context) {
    nowDate = DateFormat('yyyy-MM').format(selectedDate);
    nowDateDay = DateFormat('yyyy-MM-dd').format(selectedDate);
    final int totalDays = daysInMonth(focusedMonth);
    final List<DateTime> days = List.generate(
      totalDays,
      (index) => DateTime(focusedMonth.year, focusedMonth.month, index + 1),
    );
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
                    'Bill',
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
              Container(
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
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 一周7天
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isSelected = day.day == selectedDate.day &&
                        day.month == selectedDate.month &&
                        day.year == selectedDate.year;
                    double numVlaue = dailyBalances[(day.day).toString()]?? 0;
                    bool isIncome = numVlaue>0;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = day;
                          nowDateDay = DateFormat('yyyy-MM-dd').format(selectedDate);
                          getBillsByDate(nowDateDay,true);
                        });
                      },
                      child: Container(
                        width: 57,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ?  isIncome? Color(0xFFF79866):Color(0xFFA5BE69):Color(0xFFFFFCEF) ,
                          border: Border.all(
                            color: isSelected ?  isIncome? Color(0xFFF79866):Color(0xFFA5BE69):Color(0xFFFFFCEF) ,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontFamily: 'sf',
                                color: isSelected?Colors.white:Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isIncome?'+${numVlaue}':numVlaue.toString(),
                              style: const TextStyle(
                                color: Color(0xFF747688),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                    Text(
                      nowDateDay,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'plus',
                        fontSize: 16,
                        color: Color(0xFF747688),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                          vertical: 15.0, horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF747688),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            balance,
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
                          vertical: 15.0, horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expenses',
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
                  Container(
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
                            'Income',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF747688),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            income,
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
              const SizedBox(height: 12),
              if(filteredData.isNotEmpty)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    //边框
                    border: Border.all(color: const Color(0xFFE7E2E2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                  ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final bill = filteredData[index];
                      return ListTile(
                        leading: Image.asset(bill['icon']),
                        title: Text(bill['name']),
                        subtitle: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 200,
                          ),
                          child: Text(bill["note"].isEmpty
                              ? "none"
                              : "${bill["note"]}"),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                maxWidth: 150,
                              ),
                              child: Text(
                                "${bill["isInCome"] ? "+" : "-"}${bill["num"]}",
                                style: TextStyle(
                                  color: bill["isInCome"]
                                      ? const Color(0xFFA5BE69)
                                      : const Color(0xFFF79766),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 间距
                            GestureDetector(
                              onTap: () {
                                deleteOperationData(bill["id"]);
                              },
                              child: SizedBox(
                                width: 30,
                                height: 20,
                                child: Image.asset('assets/img/ic_item_x.png'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if(filteredData.isEmpty)
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 155,
                        height: 155,
                        child: Image.asset('assets/img/ic_emp.webp'),
                      ),
                    ],
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
