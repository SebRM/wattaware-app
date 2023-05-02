import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattaware_app/enheder.dart';
import 'package:wattaware_app/indstillinger.dart';

import 'elpriser.dart';
import 'auth_model.dart';
import 'auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthModel(),
      builder: (context, child) => MaterialApp(
        title: "Min app",
        home: FutureBuilder(
            future: context.read<AuthModel>().tryAutoLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                final isLoggedIn = context.watch<AuthModel>().isLoggedIn;
                return isLoggedIn ? const MainUI() : const AuthScreen();
              }
            }),
        theme: ThemeData(
          fontFamily: "Gill Sans MT",
          colorScheme: ThemeData.light().colorScheme.copyWith(
                primary: const Color(0xff165998),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
                secondary: const Color(0xff165998),
                onSecondary: Colors.white,
              ),
        ),
      ),
    );
  }
}

class MainUI extends StatefulWidget {
  const MainUI({
    super.key,
  });

  @override
  State<MainUI> createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = [
    const EnhederPage(),
    const ElpriserPage(),
    Builder(
      builder: (BuildContext context) {
        AuthModel authModel = Provider.of<AuthModel>(context);
        return IndstillingerPage(authModel: authModel);
      },
    ),
  ];

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(
            top: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.outlet),
              label: "Enheder",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.equalizer),
              label: "Elpriser",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Indstillinger",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff165998),
          unselectedItemColor: Colors.grey[800],
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
