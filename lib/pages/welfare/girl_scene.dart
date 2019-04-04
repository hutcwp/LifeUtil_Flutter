import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _controller;
  List<String> images;
  int cur_page = 1;

  @override
  void initState() {
    super.initState();
    images = List();
    _controller = ScrollController();
    fetchWrapper();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        fetchWrapper();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('福利专区'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await new Future.delayed(const Duration(seconds: 1));
          cur_page = 0;
          images.clear();
          fetchWrapper();
        },
        child: GridView.builder(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0),
          controller: _controller,
          itemCount: getLength(),
          itemBuilder: (BuildContext context, int index) {
            if (index < images.length) {
              return _buildItem(images[index]);
            }
            else
              return showMoreLoading();
          },
        ),
      ),
    );
  }

  int getLength() {
    if (images.length % 2 == 0) {
      return images.length + 1;
    } else {
      return images.length + 2;
    }
  }

  Widget _buildItem(String url) {
    return Container(
      constraints: BoxConstraints.tightFor(height: 150.0),
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget showMoreLoading() {
    return Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '加載中...',
              style: TextStyle(fontSize: 16.0),
            )
          ],
        ));
  }

  fetch() async {
    final String url = "http://gank.io/api/data/福利/10/" + cur_page.toString();
    print("api = " + url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      cur_page++;
      String jsonProduct = response.body;
      final jsonResponse = json.decode(jsonProduct);
      GirlResponse product = new GirlResponse.fromJson(jsonResponse);

      setState(() {
        for (int i = 0; i < product.results.length; i++) {
          images.add(product.results[i].url);
//          print("图片url = " + product.results[i].url);
        }
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  fetchWrapper() {
//    for (int i = 0; i < 10; i++) {
    fetch();
//    }
  }
}

/// javaBean
/// 接口地址   http://gank.io/api/data/%E7%A6%8F%E5%88%A9/10/1
/// {
///  "error": false,
///  "results": [{
///    "_id": "5c6a4ae99d212226776d3256",
///    "url": "https://ws1.sinaimg.cn/large/0065oQSqly1g0ajj4h6ndj30sg11xdmj.jpg"
///  }, {
///    "_id": "5bcd71979d21220315c663fc",
///    "url": "https://ws1.sinaimg.cn/large/0065oQSqgy1fwgzx8n1syj30sg15h7ew.jpg"
///  }]
///}
class GirlResponse {
  final bool error;
  final List<Girl> results;

  GirlResponse({this.error, this.results});

  factory GirlResponse.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    print(list.runtimeType);
    List<Girl> imagesList = list.map((i) => Girl.fromJson(i)).toList();

    return GirlResponse(error: parsedJson['error'], results: imagesList);
  }
}

class Girl {
  final String id;
  final String url;

  Girl({this.id, this.url});

  factory Girl.fromJson(Map<String, dynamic> parsedJson) {
    return Girl(id: parsedJson['_id'], url: parsedJson['url']);
  }
}
