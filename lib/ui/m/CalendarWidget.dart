import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedMonth = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    final int totalDays = daysInMonth(focusedMonth);
    final List<DateTime> days = List.generate(
      totalDays,
          (index) => DateTime(focusedMonth.year, focusedMonth.month, index + 1),
    );

    return Column(
      children: [
        // 输入切换月份
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "输入月份 (例如: 2024-12)",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: updateMonth,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
        ),
        // 日历网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 一周7天
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = day.day == selectedDate.day &&
                  day.month == selectedDate.month &&
                  day.year == selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = day;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.attach_money, size: 14, color: Colors.green),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
