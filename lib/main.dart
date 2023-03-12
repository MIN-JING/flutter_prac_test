import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // 運行 MyApp
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // ChangeNotifier: 將元件自己的變動通知給其他元件
  var current = WordPair.random();

  // getNext()方法: 重新產生一個隨機單字，並增加通知任何觀察者的notifyListeners()方法
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // toggleFavorite()方法: 如果點擊時單字 pair 已在 List 內，則移除；否則新增至陣列。
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            // SafeArea: 確保 child 視圖不會被系統狀態列遮擋
            SafeArea(
              child: NavigationRail(
                // extended: true 顯示圖例標籤
                // 當最大 width >= 600 時，左側抽屜頁可擴張寬度來顯示更多內容
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  print('selected: $value');
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.favorite),
                title: Text('第一個單字；第二個單字'),
                subtitle: Text(
                    '${favorites[index].first.toString()} ; ${favorites[index].second.toString()}'),
              );
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )
        ])
      ]),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // 取得 App 當前主題
    var theme = Theme.of(context);
    // displayMedium 屬性可以是 null
    var style = theme.textTheme.displayMedium!.copyWith(
        color: theme.colorScheme.onPrimary, fontSize: 40.0, letterSpacing: 0.5);

    return Card(
      // 定義卡片顏色與主題顏色相同
      color: theme.colorScheme.primary,
      elevation: 3.0,
      borderOnForeground: true,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(pair.asLowerCase,
            // semanticsLabel: 為了讓語音輔助(e.g. TalkBack)程式可以知道文字內容是單字 pair，
            // 用 pair.first、pair.second 標示出來
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}
