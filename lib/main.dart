import 'package:flutter/material.dart';
import 'package:flutter_sq/repositories/diary_repository.dart';
import 'package:flutter_sq/view/diary_home_screen.dart';
import 'package:flutter_sq/viewmodels/diary_viewmodel.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DiaryViewModel(DiaryRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        title: 'Diary App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const DiaryHomeScreen(),
      ),
    );
  }
}
