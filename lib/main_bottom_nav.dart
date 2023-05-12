import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

String getNavTitle(_selectedIndex) {
  String title = "BottomNavigationBar Sample";
  switch(_selectedIndex) {
    case 0: title = "Home"; break;
    case 1: title = "Business"; break;
    case 2: title = "School"; break;
  }

  return title;
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

// 탭을 이동할 때 쓸 변수!
  int _selectedIndex = 0;
  String navtitle = "BottomNavigationBar Sample";

  static const TextStyle optionStyle =
  TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {

    switch(index) {
      case 0: navtitle = "Home"; break;
      case 1: navtitle = "Business"; break;
      case 2: navtitle = "School"; break;
      default: navtitle = "BottomNavigationBar Sample"; break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        //title: const Text(navtitle),
        title: Text(navtitle),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // 아랫줄을 쓰지 않아도 탭이 4개 미만인 경우 기본으로 설정된다.
        // type: BottomNavigationBarType.fixed,

        // selectedItemColor: Colors.amber[800],
        // unselectedItemColor: Colors.blue,
        // backgroundColor: Colors.black,
      ),
    );
  }
}
