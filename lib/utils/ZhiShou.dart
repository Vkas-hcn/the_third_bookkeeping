import 'dart:convert';

import '../utils/LocalStorage.dart';

class ZhiShouData {
  String num;
  bool isInCome;
  String note;
  String id;
  String icon;
  String name;
  String date;

  ZhiShouData({
    required this.num,
    required this.isInCome,
    required this.note,
    required this.id,
    required this.icon,
    required this.name,
    required this.date,
  });

  factory ZhiShouData.fromJson(Map<String, dynamic> json) {
    return ZhiShouData(
      num: json['num'] as String,
      isInCome: json['isInCome'] as bool,
      note: json['note'] as String,
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'num': num,
      'isInCome': isInCome,
      'note': note,
      'id': id,
      'icon': icon,
      'name': name,
      'date': date,
    };
  }
}

class MonthData {
  List<ZhiShouData> zhiShouList;

  MonthData({required this.zhiShouList});

  factory MonthData.fromJson(List<dynamic> jsonList) {
    return MonthData(
      zhiShouList: jsonList.map((e) => ZhiShouData.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zhiShouList': zhiShouList.map((e) => e.toJson()).toList(),
    };
  }
}

class RecordBean {
  Map<String, MonthData> monthlyData;
  String dateMonth;
  String yu;

  RecordBean(
      {required this.monthlyData, required this.dateMonth, required this.yu});

  factory RecordBean.fromJson(Map<String, dynamic> json) {
    Map<String, MonthData> parsedMonthlyData = {};
    json.forEach((key, value) {
      if (key != 'dateMonth' && key != 'yu') {
        parsedMonthlyData[key] =
            MonthData.fromJson(value['zhiShouList'] as List<dynamic>);
      }
    });

    return RecordBean(
      monthlyData: parsedMonthlyData,
      dateMonth: json['dateMonth'] as String,
      yu: json['yu'] as String,
    );
  }

  static Future<void> updateYuByMonth(String month, String newYu) async {
    month = month.substring(0, 7);
    List<RecordBean> records = await loadRecords();
    RecordBean? recordToUpdate = getDataByMonth(month, records);

    if (recordToUpdate == null) {
      return;
    }
    await saveRecords(records);
  }

  static Future<void> updateRecord(String recordId,
      ZhiShouData updatedData) async {
    List<RecordBean> records = await loadRecords();
    bool recordFound = false;

    for (var record in records) {
      record.monthlyData.forEach((day, monthData) {
        for (int i = 0; i < monthData.zhiShouList.length; i++) {
          if (monthData.zhiShouList[i].id == recordId) {
            monthData.zhiShouList[i] = updatedData;
            recordFound = true;
            break;
          }
        }
      });
      if (recordFound) {
        break;
      }
    }

    if (!recordFound) {
      throw Exception("Record with ID $recordId not found.");
    }

    await saveRecords(records);
  }

  static Map<String, double> calculateDailyTotals(MonthData dailyData,
      String dayKey) {
    double totalZhi = 0.0;
    double totalShou = 0.0;

    for (var zhiShouData in dailyData.zhiShouList) {
      if (!zhiShouData.isInCome) {
        totalZhi += double.tryParse(zhiShouData.num) ?? 0.0;
      } else if (zhiShouData.isInCome) {
        totalShou += double.tryParse(zhiShouData.num) ?? 0.0;
      }
    }
    totalZhi = double.parse(totalZhi.toStringAsFixed(2));
    totalShou = double.parse(totalShou.toStringAsFixed(2));

    return {
      "totalZhi": totalZhi,
      "totalShou": totalShou,
    };
  }

  static Future<List<RecordBean>> loadRecords() async {
    final String? jsonStr =
    await LocalStorage().getValue(LocalStorage.accountJson);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      List<dynamic> jsonList = json.decode(jsonStr);
      List<RecordBean> records = jsonList
          .map((json) => RecordBean.fromJson(json as Map<String, dynamic>))
          .toList();

      for (var record in records) {
        List<MapEntry<String, MonthData>> sortedEntries =
        record.monthlyData.entries.toList()
          ..sort((a, b) {
            int dayA = int.parse(a.key);
            int dayB = int.parse(b.key);
            return dayB.compareTo(dayA);
          });

        record.monthlyData = Map.fromEntries(sortedEntries);
      }

      return records;
    } else {
      return [];
    }
  }

  Map<String, double> calculateMonthlyTotals() {
    double totalZhi = 0.0;
    double totalShou = 0.0;

    monthlyData.forEach((day, monthData) {
      for (var zhiShouData in monthData.zhiShouList) {
        if (zhiShouData.isInCome == false) {
          totalZhi += double.tryParse(zhiShouData.num) ?? 0.0;
        } else if (zhiShouData.isInCome == true) {
          totalShou += double.tryParse(zhiShouData.num) ?? 0.0;
        }
      }
    });
    totalZhi = double.parse(totalZhi.toStringAsFixed(2));
    totalShou = double.parse(totalShou.toStringAsFixed(2));
    return {
      "totalZhi": totalZhi,
      "totalShou": totalShou,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'dateMonth': dateMonth,
      'yu': yu,
    };
    monthlyData.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }

  static Future<void> saveRecords(List<RecordBean> records) async {
    final String jsonStr =
    json.encode(records.map((record) => record.toJson()).toList());
    await LocalStorage().setValue(LocalStorage.accountJson, jsonStr);
  }

  void addDataByDate(String inputDate, bool isInCome, String num, String note,
      List<RecordBean>? records, String icon, String name) {
    DateTime inputDateTime = DateTime.parse(inputDate);
    //DateTime.parse(inputDate)转换成2020-12-01
    String dayString =
        '${inputDateTime.year}-${inputDateTime.month.toString().padLeft(
        2, '0')}-${inputDateTime.day.toString().padLeft(2, '0')}';
    String monthString =
        '${inputDateTime.year}-${inputDateTime.month.toString().padLeft(
        2, '0')}'; // 2024-10
    String day = inputDateTime.day.toString();

    if (records == null || records.isEmpty) {
      records = [];
    }

    RecordBean? currentMonthRecord;

    for (var record in records) {
      if (record.dateMonth == monthString) {
        currentMonthRecord = record;
        break;
      }
    }

    if (currentMonthRecord == null) {
      String prevMonthString =
          "${inputDateTime.year}-${inputDateTime.month - 1}";
      RecordBean? prevMonthRecord = records.firstWhere(
            (record) => record.dateMonth == prevMonthString,
        orElse: () =>
            RecordBean(monthlyData: {}, dateMonth: monthString, yu: '50'),
      );

      String newYuValue = prevMonthRecord != null ? prevMonthRecord.yu : '50';

      currentMonthRecord = RecordBean(
        monthlyData: {},
        dateMonth: monthString,
        yu: newYuValue,
      );
      records.add(currentMonthRecord);
    }

    if (!currentMonthRecord.monthlyData.containsKey(day)) {
      currentMonthRecord.monthlyData[day] = MonthData(zhiShouList: []);
    }

    MonthData dayData = currentMonthRecord.monthlyData[day]!;

    // 根据 type 来添加支出或收入
    dayData.zhiShouList.add(ZhiShouData(
      num: num,
      isInCome: isInCome,
      note: note,
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      icon: icon,
      name: name,
      date: dayString,
    ));

    final String jsonStr =
    json.encode(records.map((record) => record.toJson()).toList());
    print("object==jsonStr==${jsonStr}");
    saveRecords(records);
  }

  static RecordBean? getDataByMonth(String month, List<RecordBean> records) {
    for (var record in records) {
      if (record.dateMonth == month) {
        return record;
      }
    }
    return null;
  }

  static List<RecordBean> parseRecords(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    final List<dynamic> jsonData = json.decode(jsonStr);
    return jsonData.map((data) => RecordBean.fromJson(data)).toList();
  }

  static Future<Map<String, dynamic>> getMonthlyDataByDate(String month) async {
    // 1. 从本地加载记录数据
    List<RecordBean> records = await RecordBean.loadRecords();

    // 2. 查找指定月份的记录
    RecordBean? recordToUpdate = RecordBean.getDataByMonth(month, records);
    if (recordToUpdate == null) {
      print("未找到指定月份的数据: $month");
      return {}; // 如果没有找到该月份的记录，返回空数据
    }

    // 3. 按日期分类显示数据
    Map<String, List<ZhiShouData>> dailyData = {};

    // 遍历每一天的数据
    recordToUpdate.monthlyData.forEach((day, monthData) {
      // 获取每天的数据列表
      List<ZhiShouData> zhiShouList = monthData.zhiShouList;

      // 按日期分类添加
      dailyData[day] = zhiShouList;
    });

    // 返回按日期分类的结果
    return dailyData;
  }

  static Future<void> deleteRecordById(String recordId) async {
    // 加载所有记录
    List<RecordBean> records = await loadRecords();
    bool recordDeleted = false;

    // 遍历每个月的记录
    for (var record in records) {
      record.monthlyData.forEach((day, monthData) {
        // 找到指定的记录并删除
        monthData.zhiShouList.removeWhere((zhiShouData) {
          if (zhiShouData.id == recordId) {
            recordDeleted = true;
            return true;
          }
          return false;
        });
      });

      // 如果找到并删除了记录，直接退出循环
      if (recordDeleted) {
        break;
      }
    }

    // 如果记录未找到，抛出异常
    if (!recordDeleted) {
      throw Exception("Record with ID $recordId not found.");
    }

    // 保存修改后的记录
    await saveRecords(records);
  }

  static Future<Map<String, String>> calculateMonthlySummary(
      String month) async {
    // 确保月份格式为 YYYY-MM
    month = month.substring(0, 7);

    // 从本地加载记录数据
    List<RecordBean> records = await RecordBean.loadRecords();

    // 查找指定月份的数据
    RecordBean? targetRecord = RecordBean.getDataByMonth(month, records);

    if (targetRecord == null) {
      print("未找到指定月份的数据: $month");
      return {
        "income": "+0.00",
        "expense": "-0.00",
        "balance": "0.00",
        "budget": "0.00",
        "expenditurePercentage": "0.00",
      };
    }

    // 计算总收入和总支出
    Map<String, double> totals = targetRecord.calculateMonthlyTotals();
    double totalIncome = totals["totalShou"] ?? 0.0;
    double totalExpense = totals["totalZhi"] ?? 0.0;

    // 计算结余
    double balance = totalIncome - totalExpense;
    print("totalExpense====${totalExpense}");
    print("totalIncome * 100====${totalIncome}");
    print(
        "bbbbbbbbbbbb====${(totalExpense / totalIncome * 100).toStringAsFixed(
            2)}");
    double value = double.parse(targetRecord.yu);
    return {
      "income": "+${totalIncome.toStringAsFixed(2)}",
      "expense": "-${totalExpense.toStringAsFixed(2)}",
      "balance": balance >= 0
          ? "+${balance.toStringAsFixed(2)}"
          : balance.toStringAsFixed(2),
      "budget": targetRecord.yu,
      "expenditurePercentage":
      "${(totalExpense / value * 100).toStringAsFixed(2)}%",
    };
  }

  // 修改或创建当月预算值
  static Future<void> setMonthlyBudget(String month, double newBudget) async {
    // 确保月份格式为 YYYY-MM
    month = month.substring(0, 7);

    // 加载记录数据
    List<RecordBean> records = await loadRecords();

    // 查找指定月份的数据
    RecordBean? targetRecord = getDataByMonth(month, records);

    if (targetRecord != null) {
      // 修改现有数据的预算值
      targetRecord.yu = newBudget.toStringAsFixed(2);
      print("修改预算成功：${targetRecord.dateMonth} -> ${targetRecord.yu}");
    } else {
      // 创建新的记录数据
      RecordBean newRecord = RecordBean(
        dateMonth: month,
        yu: newBudget.toStringAsFixed(2),
        monthlyData: {},
      );
      records.add(newRecord);
      print("新增预算成功：${newRecord.dateMonth} -> ${newRecord.yu}");
    }

    // 保存更新后的数据
    await saveRecords(records);
  }

  static Future<double> getCategoryTotal(String month, String cateName) async {
    double totalAmount = 0.0; // 输入分类的总金额
    List<RecordBean> recordBeanList = await loadRecords();

    // 查找指定月份的记录
    RecordBean? recordToUpdate = getDataByMonth(month, recordBeanList);
    if (recordToUpdate == null) {
      return 0.0;
    }

    // 遍历当月的每日数据
    recordToUpdate.monthlyData.forEach((day, monthData) {
      for (var zhiShouData in monthData.zhiShouList) {
        // 只计算与传入的分类名称匹配的数据
        if (zhiShouData.name == cateName) {
          double amount = double.tryParse(zhiShouData.num) ?? 0.0;
          totalAmount += amount; // 累加分类的总金额
        }
      }
    });

    return totalAmount;
  }

  static Future<Map<String, double>> calculateStatistics(String year, int staticTypeInt) async {
    // 加载记录
    List<RecordBean> recordBeanList = await loadRecords();

    // 初始化总金额
    double totalAmount = 0.0;

    // 遍历数据
    for (RecordBean record in recordBeanList) {
      // 检查记录是否属于指定年份
      if (record.dateMonth.startsWith(year)) {
        for (var monthEntry in record.monthlyData.entries) {
          // 获取当月支出/收入列表
          MonthData monthData = monthEntry.value;
          for (ZhiShouData item in monthData.zhiShouList) {
            // 根据 staticTypeInt 判断需要累加的数据类型
            double amount = double.tryParse(item.num) ?? 0.0;
            if (staticTypeInt == 0) {
              // 结余 (收入为正，支出为负)
              totalAmount += item.isInCome ? amount : -amount;
            } else if (staticTypeInt == 1 && item.isInCome) {
              // 收入
              totalAmount += amount;
            } else if (staticTypeInt == 2 && !item.isInCome) {
              // 支出
              totalAmount += amount;
            }
          }
        }
      }
    }

    // 计算统计结果
    double avgMonthly = double.parse((totalAmount / 12).toStringAsFixed(2));
    double avgDaily = double.parse((totalAmount / 365).toStringAsFixed(2));
    return {
      "This Year": totalAmount,
      "Avg. Monthly": avgMonthly,
      "Avg. Daily": avgDaily,
    };
  }

  static Future<Map<String, double>> calculateMonthlyStatistics(String month, int staticTypeInt) async {
    // 加载记录
    List<RecordBean> recordBeanList = await loadRecords();

    // 初始化总金额
    double totalAmount = 0.0;

    // 获取当月的天数
    int daysInMonth = DateTime(
      int.parse(month.split('-')[0]), // 年份
      int.parse(month.split('-')[1]) + 1, // 下个月
      0, // 获取上个月的最后一天
    ).day;

    // 遍历数据
    for (RecordBean record in recordBeanList) {
      // 检查记录是否属于指定月份
      if (record.dateMonth == month) {
        for (var monthEntry in record.monthlyData.entries) {
          // 获取当月支出/收入列表
          MonthData monthData = monthEntry.value;
          for (ZhiShouData item in monthData.zhiShouList) {
            // 根据 staticTypeInt 判断需要累加的数据类型
            double amount = double.tryParse(item.num) ?? 0.0;
            if (staticTypeInt == 0) {
              // 结余 (收入为正，支出为负)
              totalAmount += item.isInCome ? amount : -amount;
            } else if (staticTypeInt == 1 && item.isInCome) {
              // 收入
              totalAmount += amount;
            } else if (staticTypeInt == 2 && !item.isInCome) {
              // 支出
              totalAmount += amount;
            }
          }
        }
      }
    }

    // 计算统计结果
    double avgWeekly = double.parse((totalAmount / 4).toStringAsFixed(2));
    double avgDaily = double.parse((totalAmount / daysInMonth).toStringAsFixed(2));
    return {
      "This Year": totalAmount,
      "Avg. Monthly": avgWeekly,
      "Avg. Daily": avgDaily,
    };
  }


}
