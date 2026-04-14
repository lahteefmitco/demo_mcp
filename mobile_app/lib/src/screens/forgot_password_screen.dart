import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/forgot_password/forgot_password_cubit.dart';
import '../cubits/forgot_password/forgot_password_state.dart';
import '../di/service_locator.dart';
import '../utils/toast.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(authApi: sl()),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (p, n) => p.toastNonce != n.toastNonce,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg == null || msg.isEmpty) return;
          if (state.toastIsError) {
            AppToast.error(context, msg);
          } else {
            AppToast.success(context, msg);
          }
        },
        buildWhen: (p, n) =>
            p.isSubmitting != n.isSubmitting || p.message != n.message,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Forgot Password')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _ForgotPasswordForm(message: state.message),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm({required this.message});

  final String? message;

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ForgotPasswordCubit>();
    if (cubit.state.isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }
    await cubit.submit(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ForgotPasswordCubit>().state;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Registered email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: Text(
                state.isSubmitting ? 'Please wait...' : 'Send reset email',
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(widget.message!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
