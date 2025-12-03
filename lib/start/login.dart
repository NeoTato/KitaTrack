import 'package:beehive/start/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'google_sign_in.dart';
import '../app_theme.dart';

class Login extends StatefulWidget {
  final String? prefilledEmail;
  final String? prefilledPassword;

  const Login({
    super.key, 
    this.prefilledEmail, 
    this.prefilledPassword
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  
  bool _obscurePassword = true; 
  bool isLoading = false;
  String? _authError; 

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      email.text = widget.prefilledEmail!;
    }
    if (widget.prefilledPassword != null) {
      password.text = widget.prefilledPassword!;
    }
  }

  Future<void> signIn() async {
    setState(() => _authError = null);

    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
             _authError = "Incorrect username/password";
          } else {
             _authError = e.message;
          }
          isLoading = false;
        });
        _formKey.currentState!.validate();
      } 
    }
  }

  Future<void> signInWithGoogle() async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    await provider.googleLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text("KitaTrack", style: AppTheme.headingStyle),
                    const SizedBox(height: 8),
                    Text("Digitize your daily operations", style: AppTheme.subHeadingStyle),
                    const SizedBox(height: 30),
            
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10, offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome Back", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.brownText)),
                            const SizedBox(height: 20),
            
                            Text("Email", style: AppTheme.labelStyle),
                            const SizedBox(height: 6),
                            
                            TextFormField(
                              controller: email,
                              decoration: AppTheme.inputDecoration("your@email.com", Icons.email_outlined),
                              onChanged: (val) {
                                if (_authError != null) setState(() => _authError = null);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please fill in all fields";
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return "Needs to be a valid email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
            
                            Text("Password", style: AppTheme.labelStyle),
                            const SizedBox(height: 6),
                            
                            TextFormField(
                              controller: password,
                              obscureText: _obscurePassword,
                              decoration: AppTheme.inputDecoration(
                                "Enter your password", 
                                Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (val) {
                                if (_authError != null) setState(() => _authError = null);
                              },
                              validator: (value) {
                                if (_authError != null) {
                                  return _authError;
                                }
                                if (value == null || value.isEmpty) {
                                  return "Please fill in all fields";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
            
                            ElevatedButton(
                              onPressed: signIn,
                              style: AppTheme.primaryButtonStyle,
                              child: const Text("Log In"),
                            ),
            
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: Divider(thickness: 0.5, color: Colors.grey[300])),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('Or', style: TextStyle(color: Colors.grey[500]))),
                                Expanded(child: Divider(thickness: 0.5, color: Colors.grey[300])),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: signInWithGoogle,
                              icon: SvgPicture.asset('assets/icons/google_icon.svg', height: 22, width: 22),
                              label: const Text("Sign in with Google"),
                              style: AppTheme.googleButtonStyle,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: "Register here",
                                      style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupPage()));
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}