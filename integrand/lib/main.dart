import 'package:flutter/material.dart';
import 'package:integrand/models/models.dart';

void main() {
  runApp(
    ListenableBuilder(
      listenable: Models(), 
      builder: (context, child) {
        // ignore: prefer_const_constructors
        return IntegrandApp();
      },
    )
  );
}

class IntegrandApp extends StatefulWidget {
  const IntegrandApp({super.key});

  @override
  State<IntegrandApp> createState() => _IntegrandAppState();
}

class _IntegrandAppState extends State<IntegrandApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrand',
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[900],
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        child: MediaQuery.withNoTextScaling(
          child: Text('Welcome to Integrand!'),
        ),
      ),
    );
  }
}