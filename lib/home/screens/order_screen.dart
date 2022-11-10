// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  final String? payload;
  const OrderScreen({
    Key? key,
    this.payload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order screen"),
      ),
      body: Center(
        child: Text(payload ?? "No payload found"),
      ),
    );
  }
}
