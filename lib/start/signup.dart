import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login.dart';
import 'google_sign_in.dart';
import '../app_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus(); 

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();

          await _firestore.collection('users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await _auth.signOut();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Login(
                prefilledEmail: _emailController.text.trim(),
                prefilledPassword: _passwordController.text.trim(),
              ),
            ),
          );
        }

      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Signup failed')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
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
                            const Text("Create Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.brownText)),
                            const SizedBox(height: 20),
            
                            Text("Full Name", style: AppTheme.labelStyle),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              decoration: AppTheme.inputDecoration("Enter your name", Icons.person_outline),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
            
                            Text("Email", style: AppTheme.labelStyle),
                            const SizedBox(height: 6),
                            
                            TextFormField(
                              controller: _emailController,
                              decoration: AppTheme.inputDecoration("your@email.com", Icons.email_outlined),
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
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: AppTheme.inputDecoration(
                                "Create a password", 
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please fill in all fields";
                                }
                                if (value.length < 6) {
                                  return "Password needs to be at least 6 characters long";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
            
                            Text("Confirm Password", style: AppTheme.labelStyle),
                            const SizedBox(height: 6),
                            
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: AppTheme.inputDecoration(
                                "Confirm your password", 
                                Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please fill in all fields";
                                }
                                if (value != _passwordController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
            
                            ElevatedButton(
                              onPressed: _signUp,
                              style: AppTheme.primaryButtonStyle,
                              child: const Text("Sign Up"),
                            ),
                            
                            const SizedBox(height: 20),
                            Row(children: [Expanded(child: Divider(thickness: 0.5, color: Colors.grey[300])), Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('Or', style: TextStyle(color: Colors.grey[500]))), Expanded(child: Divider(thickness: 0.5, color: Colors.grey[300]))]),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(onPressed: _signUpWithGoogle, icon: SvgPicture.asset('assets/icons/google_icon.svg', height: 22, width: 22), label: const Text("Sign up with Google"), style: AppTheme.googleButtonStyle),
                            const SizedBox(height: 24),
                            Center(child: RichText(text: TextSpan(text: "Already registered? ", style: TextStyle(color: Colors.grey[600], fontSize: 14), children: [TextSpan(text: "Log in here", style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold), recognizer: TapGestureRecognizer()..onTap = () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));},),]),),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}