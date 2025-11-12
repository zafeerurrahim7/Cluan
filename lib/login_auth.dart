///   Author: Zafeer Ur Rahim
///   Date: 11/11/2025
///   Description: Email login/signup using Supabase Auth UI
///                LLM: None
///   Changes: supabase connectivity
///   Bugs: None known
///   Reflection: While making this login screen, I learned how authentication actually works in apps.
///               Using Supabase FlutterAuthUI made it simple to build a real email login without
///               writing all the backend code myself.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'main.dart';

/// Class AuthGate
/// Shows Login if logged out, HomeScreen if already logged in.
/// It also rebuilds automatically when the auth state changes.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    // If already signed in go to home page.
    if (client.auth.currentSession != null) {
      return const HomeScreen();
    }

    // Listen for sign in and sign out state changes
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final event = snapshot.data?.event;

        if (event == AuthChangeEvent.signedIn) {
          return const HomeScreen();
        }
        // Show the login form
        return const LoginAuthScreen();
      },
    );
  }
}

/// Class LoginAuthScreen
/// Renders the Supabase email login signup UI.
/// On sign-up, a small message shown to check email for confirmation.
class LoginAuthScreen extends StatelessWidget {
  const LoginAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Cluans Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // Email sign in / sign up
                  SupaEmailAuth(
                    redirectTo: 'edu.uwosh.cluans://login-callback',
                    onSignInComplete: (_) {},
                    onSignUpComplete: (_) {
                      // Optional: show a snackbar like "Check your email to confirm"
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Check your email to confirm your account.',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Use your email to sign up or sign in. Answers are tied to your account.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
