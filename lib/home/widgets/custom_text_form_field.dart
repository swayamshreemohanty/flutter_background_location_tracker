// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final String label;
  final int? maxLines;
  final bool? enabled;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final bool readOnly;
  CustomTextFormField({
    Key? key,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    required this.label,
    this.enabled,
    this.onTap,
    this.suffixIcon,
    this.readOnly = false,
  }) : super(key: key);

  final OutlineInputBorder activeBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.grey.shade600),
    borderRadius: BorderRadius.circular(15),
  );
  final OutlineInputBorder deActiveBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
    borderRadius: BorderRadius.circular(15),
  );
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextFormField(
          readOnly: readOnly,
          enabled: enabled,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          onTap: onTap,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            focusedBorder: activeBorderStyle,
            enabledBorder: deActiveBorderStyle,
            focusedErrorBorder: activeBorderStyle,
            errorBorder: deActiveBorderStyle,
            disabledBorder: deActiveBorderStyle,
          ),
        ),
      );
}
