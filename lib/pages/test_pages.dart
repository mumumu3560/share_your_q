import 'package:flutter/material.dart';

class TestPages extends StatefulWidget{

  final String title;

  const TestPages({
    Key? key,
    required this.title,
    }) : super(key: key);

  @override
  State<TestPages> createState() => _TestPagesState();
}

class _TestPagesState extends State<TestPages>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text("test"),
      ),
    );
  }
}