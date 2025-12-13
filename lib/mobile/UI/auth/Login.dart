import 'package:flutter/material.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/dashbord/ui.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/test_page.dart';

enum _ViewScheme { standard, highContrastLight, highContrastDark, emergency }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  _ViewScheme _scheme = _ViewScheme.emergency;

  Color get _bgColor {
    switch (_scheme) {
      case _ViewScheme.highContrastLight:
        return Colors.white;
      case _ViewScheme.highContrastDark:
        return Colors.black;
      case _ViewScheme.emergency:
        return const Color(0xFFFFF3CD);
      case _ViewScheme.standard:
      default:
        return Theme.of(context).scaffoldBackgroundColor;
    }
  }

  Color get _cardColor {
    switch (_scheme) {
      case _ViewScheme.highContrastLight:
        return Colors.white;
      case _ViewScheme.highContrastDark:
        return const Color(0xFF121212);
      case _ViewScheme.emergency:
        return const Color(0xFFFFF9E6);
      case _ViewScheme.standard:
      default:
        return Theme.of(context).cardColor;
    }
  }

  Color get _textColor {
    switch (_scheme) {
      case _ViewScheme.highContrastLight:
        return Colors.black;
      case _ViewScheme.highContrastDark:
        return Colors.white;
      case _ViewScheme.emergency:
        return Colors.black87;
      case _ViewScheme.standard:
      default:
        return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
  }

  Color get _accentColor {
    switch (_scheme) {
      case _ViewScheme.highContrastLight:
        return Colors.blue.shade900;
      case _ViewScheme.highContrastDark:
        return Colors.tealAccent.shade200;
      case _ViewScheme.emergency:
        return Colors.red.shade700;
      case _ViewScheme.standard:
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  void dispose() {
    email_controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = email_controller.text.trim();
      await ApiService.login_withpass(email, _passwordController.text).then((
        value,
      ) {
        if (value) {
          GotoPage(context, const DashboardPage());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Card(
            color: _cardColor,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _textColor.withOpacity(0.12), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      header: true,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Text(
                          'LOGIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: _textColor,
                            shadows: [
                              Shadow(
                                color: _textColor.withOpacity(0.15),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: email_controller,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 18, color: _textColor),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: _textColor.withOpacity(0.85),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: _textColor.withOpacity(0.9),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _textColor.withOpacity(0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _accentColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      style: TextStyle(fontSize: 18, color: _textColor),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: _textColor.withOpacity(0.85),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: _textColor.withOpacity(0.9),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                            color: _textColor.withOpacity(0.9),
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _textColor.withOpacity(0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _accentColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        if (v.length < 6) return 'Password too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: _textColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: _textColor),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Register',
                            style: TextStyle(color: _accentColor),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return DashboardPage();
                            },
                          ),
                        );
                      },
                      child: Text("dashboard"),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return TestPage();
                            },
                          ),
                        );
                      },
                      child: Text("Test Page"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
