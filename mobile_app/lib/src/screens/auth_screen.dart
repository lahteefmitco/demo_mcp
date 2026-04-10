import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../di/service_locator.dart';
import '../models/auth_session.dart';
import '../utils/toast.dart';
import 'forgot_password_screen.dart';
import 'local_database_viewer_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({required this.onAuthenticated, super.key});

  final Future<void> Function(AuthSession session) onAuthenticated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AuthCubit(authApi: sl(), onAuthenticated: onAuthenticated),
      child: BlocConsumer<AuthCubit, AuthState>(
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
            p.isLogin != n.isLogin ||
            p.isSubmitting != n.isSubmitting ||
            p.infoMessage != n.infoMessage,
        builder: (context, state) {
          return Scaffold(
            appBar: kDebugMode
                ? AppBar(
                    automaticallyImplyLeading: false,
                    title: const Text(
                      'DEBUG',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.table_rows_outlined),
                        tooltip: 'Local finance database',
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const LocalDatabaseViewerScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : null,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: (55.w).clamp(320.0, 520.0),
                        ),
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: _AuthForm(theme: theme),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.theme});

  final ThemeData theme;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<AuthCubit>();
    if (cubit.state.isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    await cubit.submit(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final state = context.watch<AuthCubit>().state;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.lock_person_outlined,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            state.isLogin ? 'Sign in' : 'Create account',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.isLogin
                ? 'Only verified users can sign in.'
                : 'After signup, we will send a verification email before first login.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF475569),
            ),
          ),
          if (state.infoMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(state.infoMessage!),
            ),
          ],
          const SizedBox(height: 24),
          if (!state.isLogin) ...[
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (state.isLogin) return null;
                if (value == null || value.trim().length < 2) {
                  return 'Enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
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
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: Text(
                state.isSubmitting
                    ? 'Please wait...'
                    : state.isLogin
                        ? 'Sign in'
                        : 'Create account',
              ),
            ),
          ),
          if (state.isLogin) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                child: const Text('Forgot password?'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => context
                        .read<AuthCubit>()
                        .resendVerification(_emailController.text),
                child: const Text('Resend verification email'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed:
                  state.isSubmitting ? null : () => context.read<AuthCubit>().toggleMode(),
              child: Text(
                state.isLogin
                    ? 'Need an account? Sign up'
                    : 'Already have an account? Sign in',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
