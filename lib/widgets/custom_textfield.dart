import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  String? label;
  TextEditingController ? cntrl;
  CustomTextfield({super.key,this.label,required this.cntrl});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: cntrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xffF2F4F7),
        label: Text(label!),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );

  }
}
