import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final controller = ScrollController();

  List<String> items = [];
  var hasMore = true;
  var page = 1;
  bool isLoading = false;

  @override
  void initState(){

    super.initState();
    fetch();

    controller.addListener(() {
      if(controller.position.maxScrollExtent == controller.offset){
        fetch();
      }
    });
  }

  @override
  void dispose(){
    controller.dispose();

    super.dispose();
  }

  Future fetch() async{
    if (isLoading) return;
    isLoading = true;

    final limit = 25;
    var dio = Dio();
    Response response = await dio.get('https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');

    if(response.statusCode == 200) {
      final List newItems = response.data;
      setState(() {
        page++;
        isLoading = false;

        if(newItems.length < limit){
          hasMore = false;
        }

        items.addAll(newItems.map<String>((item) {
          final number = item["id"];

          return "Item $number";
        }).toList());
      });
    }
  }

  Future refresh() async{
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 1;
      items.clear();
    });
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Infinite Scroll View"),
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            controller: controller,
            padding: const EdgeInsets.all(8),
            itemCount: items.length + 1,
            itemBuilder: (context, index){
              if(index < items.length){
                final item = items[index];
                return ListTile(title: Text(item));
              }else{
                return Center(
                  child: hasMore
                      ? CircularProgressIndicator()
                      : Text("No more data to load"),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}