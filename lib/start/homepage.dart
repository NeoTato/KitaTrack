import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'google_sign_in.dart';
import '../app_theme.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;

  String getDisplayName() {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return "User";
  }

  Future<void> signout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final googleProvider = Provider.of<GoogleSignInProvider>(context, listen: false);
      await googleProvider.logout();

      if (mounted) {
        Navigator.pop(context); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out')),
      );
    }
  }

  void _showSDGPopup(String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryOrange),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(description, style: const TextStyle(fontSize: 15, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: AppTheme.primaryOrange)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "KitaTrack",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.brownText,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // WELCOME CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Welcome, ${getDisplayName()}!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brownText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ready to manage your karenderya?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepOrange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SDG HEADER
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Our Purpose",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brownText,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildHeroSDGCard(
                "Our Purpose",
                "Digitizing daily operations for small Karenderya owners.",
                "This application streamlines record-keeping by allowing owners to log ingredients, update prices, and automatically compute net profit, empowering them to manage their businesses competitively."
              ),

              const Spacer(), 

              // SDG HEADER
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Our Mission",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brownText,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildHeroSDGCard(
                "SDG 12: Responsible Consumption",
                "Ensure sustainable consumption and production patterns.",
                "We align with SDG 12 by helping local eateries (Karenderyas) track inventory efficiently, reducing food waste and optimizing resource usage for a more sustainable business model."
              ),

              const Spacer(), 

              // LOGOUT BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: signout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSDGCard(String title, String shortDesc, String fullDesc) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showSDGPopup(title, fullDesc),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.public, color: AppTheme.primaryOrange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brownText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                shortDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // "Learn More" Link
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Tap to learn more",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryOrange),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}