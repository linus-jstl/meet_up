import 'package:flutter/material.dart';
import 'package:meet_up/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      if (isLogin) {
        // LOGIN
        await Supabase.instance.client.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (!mounted) return;

      } else {
        // REGISTRATION
        final response =
            await Supabase.instance.client.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (!mounted) return;

        if (response.session == null) {
          setState(() {
            successMessage =
                'Account created! Please check your email to confirm your account.';
          });
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomePage(),
            ),
          );
        }
      }
    } on AuthException catch (error) {
      setState(() {
        errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Something went wrong.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void switchMode() {
    setState(() {
      isLogin = !isLogin;
      errorMessage = null;
      successMessage = null;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin ? 'Welcome back!' : 'Create your account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 32),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            if (successMessage != null)
              Text(
                successMessage!,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        isLogin
                            ? 'Login'
                            : 'Create Account',
                      ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: isLoading ? null : switchMode,
              child: Text(
                isLogin
                    ? 'Create a new account'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
