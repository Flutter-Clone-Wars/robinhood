import 'package:flutter/material.dart';
import 'package:robinhood/demos/crypto_summary_demo.dart';
import 'package:robinhood/demos/neon_horizon_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robinhood Clone',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            children: const [
              CryptoSummaryDemo(),
              SizedBox(height: 64),
              NeonHorizonDemo(),
            ],
          ),
        ),
      ),
    );
  }
}
