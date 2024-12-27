import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:the_third_bookkeeping/utils/AccountData.dart';

class ThirdUtils {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  static List<String> getAccListTextData(bool isInCome) {
    if (isInCome) {
      // expenses
      return AccountData.incomeText;
    } else {
      // income
      return AccountData.expensesText;
    }
  }

  static List<String> getAccListImageData(bool isInCome) {
    if (isInCome) {
      // expenses
      return AccountData.incomeImage;
    } else {
      // income
      return AccountData.expensesImage;
    }
  }


  static List<String> getAccListTextDataZong() {
      // income
      return AccountData.dataTextZong;
  }

  static List<String> getAccListImageDataZong() {
      return AccountData.dataImageZong;
  }
//是否是收入
  static bool isIncome(String category) {
    if (AccountData.expensesText.any((element) => element == category)) {
      return false;
    }
    if (AccountData.incomeText.any((element) => element == category)) {
      return true;
    }
    // 如果 category 既不在 expensesText 也不在 incomeText 中，可以返回一个默认值，比如 false
    return false;
  }

}