import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart';
import 'package:letstry/cache.dart';
import 'package:letstry/providers/project_provider.dart';
import 'package:letstry/screens/editor/editor.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Cache.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectProvider(),
      child: FluentApp(
        title: "Sprite animator",
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        color: Colors.blue,
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,

          visualDensity: VisualDensity.adaptivePlatformDensity,
          focusTheme: FocusThemeData(glowFactor: 2.0),
          fontFamily: 'Inter',
        ),
        home: const EditorScreen(),
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: SizedBox(
//           width: 200,
//           height: 200,
//           child: SpriteAnimation.grid(
//             image: AssetImage('assets/sprite_sheet_512_5px.png'),
//             columns: 11,
//             rows: 11,
//             loop: false,
//             autoPlay: false,
//             fps: 24,
//             width: 512,
//             height: 512,
//           ),
//         ),
//       ),
     
//     );
//   }
// }
