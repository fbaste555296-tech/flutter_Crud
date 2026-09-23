import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Register"),
                onPressed: () async {
                  if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;
                  setState(() => loading = true);

                  try {
                    final user = await auth.registerWithEmail(
                        emailCtrl.text.trim(), passwordCtrl.text);

                    if (!mounted) return;
                    setState(() => loading = false);

                    // Send verification email
                    if (!user!.emailVerified) {
                      await user.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Verification email sent. Please check your inbox."),
                        ),
                      );
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => loading = false);

                    String message = "Registration failed";
                    if (e is FirebaseAuthException) {
                      switch (e.code) {
                        case 'email-already-in-use':
                          message = "This email is already registered.";
                          break;
                        case 'invalid-email':
                          message = "The email address is not valid.";
                          break;
                        case 'weak-password':
                          message = "Password must be at least 6 characters.";
                          break;
                        case 'operation-not-allowed':
                          message =
                              "Email/password sign-up is not enabled. Please contact support.";
                          break;
                        default:
                          message = e.message ?? "Registration failed";
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
              ),
              SizedBox(height: 12),
              TextButton(
                child: Text("Already have an account? Login"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}