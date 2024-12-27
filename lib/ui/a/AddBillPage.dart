import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_third_bookkeeping/utils/ThirdUtils.dart';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../utils/LocalStorage.dart';
import '../../utils/ZhiShou.dart';

class AddBillPage extends StatelessWidget {
  const AddBillPage({super.key});

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
  _AddBillPageScressState createState() => _AddBillPageScressState();
}

class _AddBillPageScressState extends State<AddFeelPageScreen> {
  List<String> _expensesText = [];
  int currentPageIndex = 0;
  bool isInCome = false;
  final Duration checkInterval = const Duration(milliseconds: 500);
  final TextEditingController _textEditingController = TextEditingController();
  String formattedDate = 'Today';
  DateTime selectedDate = DateTime.now();
  String _input = '';

  @override
  void initState() {
    super.initState();
    getAccData();
    preloadImages(); // 提前加载图片
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAccData() async {
    setState(() {
      _expensesText = ThirdUtils.getAccListTextData(isInCome);
    });
  }

  Future<String> getImageData(index) async {
    return ThirdUtils.getAccListImageData(isInCome)[index];
  }
  List<String> _cachedImages = [];


  /// 预加载图片并缓存
  void preloadImages() async {
    final List<String> images =
    await Future.wait(List.generate(_expensesText.length, getImageData));
    setState(() {
      _cachedImages = images;
    });
  }

  void cheackIncome(bool state) {
    setState(() {
      isInCome = state;
      currentPageIndex = 0;
    });
    getAccData();
    preloadImages();
  }

  void setNumToolTip(String value) {
    setState(() {
      if (_input.length > 9) return;
      if (value == '.' && (_input.contains('.') || _input.isEmpty)) {
        return;
      }
      _input += value;
    });
  }

  void _deleteLastCharacter() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  void saveToNextPaper(bool isBack) async {
    if (_input.isEmpty || _input == '0' || _input == "") {
      ThirdUtils.showToast("The amount is incorrect");
      return;
    }
    RegExp regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    if (!regExp.hasMatch(_input)) {
      ThirdUtils.showToast("Please enter a valid number");
      return;
    }
    double amount = double.parse(_input);
    if(amount==0){
      ThirdUtils.showToast("The amount is incorrect");
      return;
    }
    await addAccountFun(_input);
    if (isBack) {
      Navigator.pop(context);
    }
    setState(() {
      _input = '';
      _textEditingController.clear();
    });
  }

  Future<void> addAccountFun(String num) async {
    double? amount = double.tryParse(num);
    // 从本地读取数据
    String? jsonStr = await LocalStorage().getValue(LocalStorage.accountJson);
    print("从本地读取数据---${jsonStr}");
    // 解析本地数据
    List<RecordBean> records = RecordBean.parseRecords(jsonStr);

    String imageData = await getImageData(currentPageIndex);
    // 添加一条新数据
    if (records.isNotEmpty) {
      records[0].addDataByDate(
          formattedDate,
          isInCome,
          amount.toString(),
          _textEditingController.text,
          records,
          imageData,
          _expensesText[currentPageIndex]);
    } else {
      String yuDef = await LocalStorage().getYuData();
      // 如果本地没有记录，创建一个新的记录
      RecordBean newRecord = RecordBean(
        monthlyData: {},
        dateMonth: formattedDate.substring(0, 7),
        yu: yuDef,
      );
      newRecord.addDataByDate(
          formattedDate,
          isInCome,
          amount.toString(),
          _textEditingController.text,
          records,
          imageData,
          _expensesText[currentPageIndex]);
      records.add(newRecord);
    }
    String? datra = await LocalStorage().getValue(LocalStorage.accountJson);
    print("打印当前数据 ---${datra}");
    ThirdUtils.showToast("Added successfully!");
  }

  @override
  Widget build(BuildContext context) {
    formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
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
                      'Accounting',
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
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCEF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFFCEF),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (_expensesText.length / 8).ceil(),
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: currentPageIndex == index
                                    ? const Color(0xFFF79766)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),


                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 220,
                          child: PageView.builder(
                            onPageChanged: (index) {},
                            itemCount: (_expensesText.length / 8).ceil(),
                            itemBuilder: (context, pageIndex) {
                              final startIndex = pageIndex * 8;
                              final endIndex = (startIndex + 8) > _expensesText.length
                                  ? _expensesText.length
                                  : startIndex + 8;
                              final items = _expensesText.sublist(startIndex, endIndex);

                              return SizedBox(
                                height: 220,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 2,
                                    crossAxisSpacing: 5,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final actualIndex = startIndex + index;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentPageIndex = actualIndex;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(160),
                                              color: currentPageIndex == actualIndex
                                                  ? const Color(0xFFFFA25E)
                                                  : Colors.transparent,
                                            ),
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: _cachedImages.isNotEmpty
                                                  ? Image.asset(_cachedImages[actualIndex])
                                                  : const CircularProgressIndicator(),
                                            ),
                                          ),
                                          Text(
                                            items[index],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: currentPageIndex == actualIndex
                                                  ? const Color(0xFFF79766)
                                                  : const Color(0xFFAFABA8),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                cheackIncome(false);
                              },
                              child: SizedBox(
                                width: 120,
                                height: 43,
                                child: Image.asset(isInCome
                                    ? 'assets/img/bg_expen_2.png'
                                    : 'assets/img/bg_expen_1.png'),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                cheackIncome(true);
                              },
                              child: SizedBox(
                                width: 120,
                                height: 43,
                                child: Image.asset(isInCome
                                    ? 'assets/img/bg_income_1.png'
                                    : 'assets/img/bg_income_2.png'),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Divider(
                    height: 1,
                    color: Color(0xFFE6EEF6),
                  ),
                ),
                Container(
                  color: const Color(0xFFFFFCEF),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    border: Border.all(
                                        color: const Color(0xFFE7E2E2)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12),
                                    child: Text(
                                      _input.isEmpty ? '0' : _input,
                                      style: const TextStyle(
                                        fontFamily: "sf",
                                        fontSize: 16,
                                        color: Color(0xFF101828),
                                      ),
                                    ),
                                  )),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                selectDate(context);
                              },
                              child: Container(
                                width: 131,
                                height: 43,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/img/bg_date_c.webp'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF802408),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: Image.asset(
                                          'assets/img/ic_arrow_right.webp'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(color: const Color(0xFFE7E2E2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12),
                        child: TextField(
                          maxLength: 30,
                          maxLines: 1,
                          controller: _textEditingController,
                          buildCounter: (
                            BuildContext context, {
                            required int currentLength,
                            required bool isFocused,
                            required int? maxLength,
                          }) {
                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF000000),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter Notes',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF747688),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      )),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // 确保所有子元素顶部对齐
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // 子元素在水平上均匀分布
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start, // 确保垂直对齐一致
                        children: [
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("1");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_1.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("4");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_4.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("7");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_7.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              _deleteLastCharacter();
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_x.webp'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("2");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_2.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("5");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_5.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("8");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_8.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("0");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_0.webp'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("3");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_3.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("6");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_6.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip("9");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_9.webp'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setNumToolTip(".");
                            },
                            child: SizedBox(
                              width: 69,
                              height: 52,
                              child: Image.asset('assets/img/ic_dian.webp'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              saveToNextPaper(false);
                            },
                            child: SizedBox(
                              width: 119,
                              height: 112,
                              child: Image.asset('assets/img/ic_record.png'),
                            ),
                          ),
                          const SizedBox(height: 8), // 添加间距以与其他列一致
                          GestureDetector(
                            onTap: () {
                              saveToNextPaper(true);
                            },
                            child: SizedBox(
                              width: 119,
                              height: 112,
                              child: Image.asset('assets/img/ic_add_num.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // 初始日期为今天
      firstDate: DateTime(2000),
      // 设置一个合理的过去日期
      lastDate: DateTime.now(),
      // 最后日期为今天
      // 设置一个合理的未来日期
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF031F3E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF031F3E),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        print("pickedDate=====$pickedDate");
      });
    }
  }
}
