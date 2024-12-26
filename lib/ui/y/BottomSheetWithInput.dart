import 'package:flutter/material.dart';

import '../../utils/ThirdUtils.dart';

class BottomSheetWithInput extends StatefulWidget {
  final String title;
  final void Function(String) onSave;

  const BottomSheetWithInput({Key? key, required this.title, required this.onSave}) : super(key: key);

  @override
  State<BottomSheetWithInput> createState() => _BottomSheetWithInputState();
}

class _BottomSheetWithInputState extends State<BottomSheetWithInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: keyboardHeight, // 动态调整底部间距
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(); // 关闭弹框
                        },
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset('assets/img/ic_dialog_x.webp'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 输入框
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    decoration: InputDecoration(
                      hintText: 'Enter Budget',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 保存按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final _input = _controller.text.trim(); // 获取输入内容
                        if (_input.isEmpty || _input == '0' || _input == "") {
                          ThirdUtils.showToast("The num is incorrect");
                          return;
                        }
                        RegExp regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');
                        if (!regExp.hasMatch(_input)) {
                          ThirdUtils.showToast("Please enter a valid number");
                          return;
                        }
                        widget.onSave(_input);
                        Navigator.of(context).pop(); // 关闭弹框
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 24),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void showBottomSheetWithInput(BuildContext context, String title, void Function(String) onSave) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 允许弹框动态调整高度
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Wrap(
        children: [
          BottomSheetWithInput(
            title: title,
            onSave: onSave,
          ),
        ],
      );
    },
  );
}
