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

}