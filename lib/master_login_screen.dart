import 'package:flutter/material.dart';
import 'core_ai_panel.dart';

class MasterLoginScreen extends StatefulWidget {
  const MasterLoginScreen({super.key});

  @override
  State<MasterLoginScreen> createState() => _MasterLoginScreenState();
}

class _MasterLoginScreenState extends State<MasterLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final String _masterPassword = 'A1!xN3'; // 🔒 Change this monthly

  void _verifyPassword() {
    if (_passwordController.text == _masterPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CoreAIPanel()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Incorrect Master Password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: () => _showLoginPopup(context),
        child: const SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                right: 16,
                top: 40,
                child: Icon(Icons.lock_outline, color: Colors.grey, size: 28),
              ),
              Center(
                child: Text(
                  '🔒 Long press lock to login',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("🔐 Master Login", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Enter 6-digit code",
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyPassword();
            },
            child: const Text("Unlock"),
          )
        ],
      ),
    );
  }
}
