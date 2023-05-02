import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthModel>(context, listen: false);
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  'assets/logo-blue.png',
                  height: 70,
                ),
              ),
              ToggleButtons(
                borderRadius: BorderRadius.circular(8.0),
                fillColor: const Color(0xFF165998),
                selectedColor: Colors.white,
                onPressed: (int index) {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                isSelected: [isLogin, !isLogin],
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Log ind'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Opret'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  labelText: isLogin ? 'Brugernavn eller email' : 'Brugernavn',
                  labelStyle: const TextStyle(color: Color(0xFF0f4472)),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isLogin)
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF0f4472)),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0f4472)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0f4472)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0f4472)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0f4472)),
                    ),
                  ),
                ),
              if (!isLogin) const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Kodeord',
                  labelStyle: TextStyle(color: Color(0xFF0f4472)),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0f4472)),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (isLogin)
                ElevatedButton(
                  onPressed: () async {
                    await auth.logIn(userController.text, passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0f4472),
                  ),
                  child: const Text('Log ind'),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    await auth.signUp(userController.text, emailController.text, passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0f4472),
                  ),
                  child: const Text('Opret bruger'),
                ),
              const SizedBox(height: 8),
              Consumer<AuthModel>(
                builder: (context, auth, _) => Text(
                  auth.statusMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
