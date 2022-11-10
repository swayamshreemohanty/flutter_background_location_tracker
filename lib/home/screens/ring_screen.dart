// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class RingScreen extends StatefulWidget {
  final String? payload;
  const RingScreen({
    Key? key,
    this.payload,
  }) : super(key: key);

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ring screen"),
      ),
      body: Center(
        child: Text(widget.payload ?? "No payload found"),
      ),
    );
  }
}
