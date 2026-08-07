import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'sarah@socialflow.ai');
  final _password = TextEditingController(text: 'password');

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).login(email: _email.text, password: _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      final message = ref.read(authControllerProvider).error.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bon retour !')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text('Connectez-vous pour continuer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _email, validator: Validators.email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail')),
                  const SizedBox(height: 14),
                  TextFormField(controller: _password, validator: (value) => Validators.required(value, label: 'Le mot de passe'), obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: auth.isLoading ? null : _login, child: auth.isLoading ? const CircularProgressIndicator() : const Text('Se connecter')),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('ou continuer avec', textAlign: TextAlign.center)),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                OutlinedButton(onPressed: _login, child: const Text('Google')),
                OutlinedButton(onPressed: _login, child: const Text('Facebook')),
                OutlinedButton(onPressed: _login, child: const Text('Apple')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
