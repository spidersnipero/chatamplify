import 'package:flutter/material.dart';

class Spalsh extends StatelessWidget {
  const Spalsh({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat app'),
      ),
      body: const Center(
        child: Text("Loading"),
      ),
    );
  }
}
