import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/ui/a/AddBillPage.dart';

import '../../utils/LocalStorage.dart';
import 'package:intl/intl.dart';

import '../../utils/ZhiShou.dart';
import '../y/BudgetPage.dart';

class HomePage extends StatelessWidget {
  final Function(int) onTap;

  const HomePage({super.key, required this.onTap});


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: HomePageScress(onTap: onTap),
    );
  }
}

class HomePageScress extends StatefulWidget {
  final Function(int) onTap;

  const HomePageScress({super.key, required this.onTap});

  @override
  _HomePageScressState createState() => _HomePageScressState();
}

class _HomePageScressState extends State<HomePageScress>
    with SingleTickerProviderStateMixin {
  bool restartState = false;
  final Duration checkInterval = const Duration(milliseconds: 500);
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> recentData = [];
  String formattedDate = 'Today';
  String income = "";
  String expense = "";
  String balance = "";
  String budget = "";
  String expenditurePercentage = "";
  @override
  void initState() {
    super.initState();
    setListData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  RecordBean? septemberRecord = null;

  void setListData() async {
    formattedDate = DateFormat('yyyy-MM').format(DateTime.now());
    filterDataByMonth(formattedDate);
    Map<String, String> summary =
        await RecordBean.calculateMonthlySummary(formattedDate);
    print("收入: ${summary['income']}");
    print("支出: ${summary['expense']}");
    print("结余: ${summary['balance']}");
    print("预算: ${summary['budget']}");
    print("百分比: ${summary['expenditurePercentage']}");
    setState(() {
      income = summary['income']??"0";
      expense = summary['expense']??"0";
      balance = summary['balance']??"0";
      budget = summary['budget']??"0";
      expenditurePercentage = summary['expenditurePercentage']??"0";
    });
  }

  void filterDataByMonth2(String month) async {
    final localStorage = LocalStorage();
    String jsonStr = await localStorage.getValue(LocalStorage.accountJson);
    try {
      // 解析 JSON 字符串
      List<dynamic> jsonData = jsonDecode(jsonStr);
      // 强制转换为 List<Map<String, dynamic>>
      List<Map<String, dynamic>> parsedData =
          jsonData.map((e) => e as Map<String, dynamic>).toList();
      print("从本地读取数据---${parsedData}");
      setState(() {
        filteredData =
            parsedData.where((data) => data["dateMonth"] == month).toList();
      });
    } catch (e) {
      print("解析 JSON 失败: $e");
    }
  }

  void filterDataByMonth(String month) async {
    final localStorage = LocalStorage();
    String jsonStr = await localStorage.getValue(LocalStorage.accountJson)?? "";

    try {
      List<dynamic> jsonData = jsonDecode(jsonStr);
      List<Map<String, dynamic>> parsedData =
          jsonData.map((e) => e as Map<String, dynamic>).toList();

      print("从本地读取数据---${parsedData}");

      // 筛选出符合月份的数据
      List<Map<String, dynamic>> monthFilteredData =
          parsedData.where((data) => data["dateMonth"] == month).toList();

      if (monthFilteredData.isNotEmpty) {
        // 获取当月数据的第一项
        Map<String, dynamic> monthData = monthFilteredData.first;

        // 提取账单日期数据并排序
        List<String> days = monthData.keys
            .where((key) => key != "dateMonth" && key != "yu")
            .toList()
          ..sort((a, b) => int.parse(b).compareTo(int.parse(a))); // 按日期倒序

        // 筛选最近 3 天的日期
        List<String> recentThreeDays = days.take(3).toList();

        // 过滤出最近 3 天的数据
        Map<String, dynamic> filteredDays = {};
        for (String day in recentThreeDays) {
          filteredDays[day] = monthData[day];
        }

        // 保留筛选后的数据结构
        Map<String, dynamic> filteredMonthData = {
          "dateMonth": monthData["dateMonth"],
          "yu": monthData["yu"],
          ...filteredDays
        };

        setState(() {
          filteredData = [filteredMonthData]; // 更新 filteredData，仅保留最近 3 天
        });
      }
    } catch (e) {
      print("解析 JSON 失败: $e");
    }
  }

  void pageToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBillPage(),
      ),
    ).then((value) {
      setListData();
    });
  }
  void pageToBudget() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BudgetPage()),
    );
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
    setListData();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
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
                      fontSize: 20,
                      color: Color(0xFF2D170B),
                    ),
                  ),
                  Text(
                    'book',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'plus',
                      fontSize: 20,
                      color: Color(0xFFF79866),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
                width: double.infinity,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/img/ic_home_but_3.webp'),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'This Month',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 15,
                            color: Color(0xFFDEFF5C),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 79,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFF101828),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Balance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'sf',
                              fontSize: 15,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 98,
                      height: 77,
                      child: Image.asset('assets/img/ic_home_top.webp'),
                    ),
                    Expanded(
                      child: Text(
                        balance,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'plus',
                          fontSize: 24,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 169,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/img/ic_home_but.webp'),
                    )),
                    child:  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Income',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 14,
                            color: Color(0xB3FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          income,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 169,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/img/ic_home_but.webp'),
                    )),
                    child:  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 14,
                            color: Color(0xB3FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          expense,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  pageToBudget();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    border: Border.all(color: const Color(0xFFE7E2E2)), // 边框
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Budget:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'sf',
                          fontSize: 12,
                          color: Color(0xFF747688),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 支持左右滑动
                      Container(
                        width: 130,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text(
                                '${expense.replaceAll('-', '')}/${budget}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'sf',
                                  fontSize: 16,
                                  color: Color(0xFF101828),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            expenditurePercentage,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'sf',
                              fontSize: 14,
                              color: Color(0xFFF79766),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset('assets/img/ic_menu.webp'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  pageToAdd();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24),
                  width: double.infinity,
                  height: 80,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/img/ic_home_but_2.webp'),
                    fit: BoxFit.cover,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset('assets/img/ic_add.webp'),
                        ),
                        SizedBox(width: 9),
                        const Text(
                          'Add a Record',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'sf',
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    //边框
                    border: Border.all(color: const Color(0xFFE7E2E2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (filteredData.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            widget.onTap(1); // 切换到 BillPage
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 12),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                              image:
                                  AssetImage('assets/img/ic_home_but_4.webp'),
                              fit: BoxFit.fill,
                            )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Recent Bills',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'sf',
                                    fontSize: 15,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Image.asset('assets/img/ic_menu.webp'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (filteredData.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final monthData = filteredData[index];
                              final days = monthData.keys
                                  .where((key) =>
                                      key != "dateMonth" && key != "yu")
                                  .toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: days.map((day) {
                                  final dayData = monthData[day];
                                  final zhiShouList = dayData["zhiShouList"];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (zhiShouList.length > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: Text(
                                            "${monthData["dateMonth"]}-$day",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF747688),
                                            ),
                                          ),
                                        ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: zhiShouList.length,
                                        itemBuilder: (context, idx) {
                                          final item = zhiShouList[idx];
                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: ListTile(
                                              leading: Image.asset(item["icon"],
                                                  width: 40, height: 40),
                                              title: Text(item["name"]),
                                              subtitle: Container(
                                                constraints: const BoxConstraints(
                                                  maxWidth: 100,
                                                ),
                                                child: Text(
                                                    item["note"].isEmpty
                                                        ? "none"
                                                        : "${item["note"]}"),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                // 内容宽度自适应
                                                children: [
                                                  Container(
                                                    constraints: const BoxConstraints(
                                                      maxWidth: 80,
                                                    ),
                                                    child: Text(
                                                      "${item["isInCome"] ? "+" : "-"}${item["num"]}",
                                                      style: TextStyle(
                                                        color: item["isInCome"]
                                                            ? const Color(
                                                                0xFFA5BE69)
                                                            : const Color(
                                                                0xFFF79766),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20.0,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // 间距
                                                  GestureDetector(
                                                    onTap: () {
                                                      deleteOperationData(
                                                          item["id"]);
                                                    },
                                                    child: SizedBox(
                                                      width: 30,
                                                      height: 20,
                                                      child: Image.asset(
                                                          'assets/img/ic_item_x.png'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      if (filteredData.isEmpty)
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 155,
                                height: 155,
                                child: Image.asset('assets/img/ic_emp.webp'),
                              ),
                              GestureDetector(
                                onTap: () {
                                  pageToAdd();
                                },
                                child: SizedBox(
                                  width: 184,
                                  height: 38,
                                  child:
                                      Image.asset('assets/img/ic_add_re.png'),
                                ),
                              ),
                            ],
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
