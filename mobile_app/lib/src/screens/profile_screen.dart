import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/profile/profile_cubit.dart';
import '../cubits/profile/profile_state.dart';
import '../di/service_locator.dart';
import '../models/auth_session.dart';
import '../utils/toast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.session,
    required this.onSessionUpdated,
    super.key,
  });

  final AuthSession session;
  final Future<void> Function(AuthSession session) onSessionUpdated;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        authApi: sl(),
        session: session,
        onSessionUpdated: onSessionUpdated,
      ),
      child: BlocConsumer<ProfileCubit, ProfileState>(
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
            p.session != n.session ||
            p.isSavingName != n.isSavingName ||
            p.isRequestingEmailChange != n.isRequestingEmailChange,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: _ProfileForm(session: state.session),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.session});

  final AuthSession session;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.user.name);
    _emailController = TextEditingController(text: widget.session.user.email);
  }

  @override
  void didUpdateWidget(_ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.user.name != widget.session.user.name) {
      _nameController.text = widget.session.user.name;
    }
    if (oldWidget.session.user.email != widget.session.user.email) {
      _emailController.text = widget.session.user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileCubit>().state;
    final user = state.session.user;

    return ListView(
      children: [
        Text('Account', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: state.isSavingName
              ? null
              : () => context.read<ProfileCubit>().saveName(_nameController.text),
          child: Text(state.isSavingName ? 'Saving...' : 'Update name'),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: state.isRequestingEmailChange
              ? null
              : () => context
                  .read<ProfileCubit>()
                  .requestEmailChange(_emailController.text),
          child: Text(
            state.isRequestingEmailChange
                ? 'Sending...'
                : 'Send email change verification',
          ),
        ),
        if (user.pendingEmail != null && user.pendingEmail!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Pending email verification: ${user.pendingEmail}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: const Color(0xFF475569)),
          ),
        ],
      ],
    );
  }
}
