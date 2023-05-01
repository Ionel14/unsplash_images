import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Models/picture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final List<Picture> _images = <Picture>[];
  final ScrollController _controller = ScrollController();
  int _page = 1;
  bool isLoading = false;
  String _searchText = 'cars';

  @override
  void initState() {
    super.initState();
    _getPictures(_page);

    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final double offset = _controller.position.pixels;
    final double maxScrollExtend = _controller.position.maxScrollExtent;
    final double scrollableHeight = MediaQuery.of(context).size.height;

    if (!isLoading && maxScrollExtend - offset < 3 * scrollableHeight) {
      _page++;
      _getPictures(_page);
    }
  }

  Future<void> _getPictures(int page) async {
    setState(() => isLoading = true);
    final Uri uri = Uri(scheme: 'https', host: 'api.unsplash.com', pathSegments: <String>[
      'search',
      'photos'
    ], queryParameters: <String, String>{
      'query': _searchText,
      'page': '$page',
      'client_id': 'TWH9m2FHZ67eO3jM8JiBEpDwjMRARj5UkpYr6EzVziM',
      'per_page': '30',
    });

    final Response response = await get(uri);
    final Map<String, dynamic> map = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> results = map['results'] as List<dynamic>;

    _images.addAll(results.cast<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> json) => Picture.fromJson(json)));
    setState(() {
      isLoading = false;
    });
  }

  void _searchPressed() {
    _images.clear();
    _page = 1;
    _getPictures(_page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Pictures',
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Search...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                color: Colors.lightBlue,
                onPressed: _searchPressed,
              ),
            ),
            onChanged: (String value) {
              setState(() {
                _searchText = value;
              });
            },
            style: const TextStyle(fontSize: 24, color: Colors.lightBlue),
          ),
          Expanded(
            child: GridView.builder(
              controller: _controller,
              itemCount: _images.length,
              itemBuilder: (BuildContext context, int index) {
                final Picture picture = _images[index];

                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    GridTile(
                      child: Image.network(
                        picture.urls.regular,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: AlignmentDirectional.bottomStart,
                                end: Alignment.topRight,
                                colors: <Color>[
                              Colors.white54,
                              Colors.transparent,
                            ])),
                        child: ListTile(
                          title: Text(picture.user.username),
                          trailing: CircleAvatar(
                            backgroundImage: NetworkImage(picture.user.profileImage.small),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
