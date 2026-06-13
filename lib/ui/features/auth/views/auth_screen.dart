import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/studio.dart';
import '../../../../models/vpn_config.dart';
import '../../../../models/home_view.dart';
import '../../../../screens/home_screen.dart';
import '../view_models/auth_view.dart';
import '../../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  Future<void> _checkSavedSession() async {
    final vm = context.read<AuthViewModel>();
    final session = await vm.checkSavedSession();
    if (session.studioId != null && mounted) {
      _controller.text = session.studioId!;
    }
  }

  Future<void> _onSubmit() async {
    final id = _controller.text.trim();
    if (id.isEmpty) return;
    _focusNode.unfocus();

    final vm = context.read<AuthViewModel>();
    final result = await vm.verify(id);
    if (result != null && mounted) {
      _navigateHome(result.studio, result.configs);
    }
  }

  void _navigateHome(Studio studio, List<VpnConfig> configs) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) => HomeViewModel(
            repository: ctx.read(),
            vpnService: ctx.read(),
            studio: studio,
            configs: configs,
          ),
          child: const HomeScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              _buildHeader(),
              const SizedBox(height: 56),
              _buildInput(),
              const SizedBox(height: 16),
              _buildError(),
              const Spacer(),
              _buildButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.accentGlow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: AppTheme.accent,
            size: 26,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter Studio ID',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Drop your Studio ID to unlock VPN access no cap',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'STUDIO-XXXX',
        hintStyle: const TextStyle(
          color: AppTheme.textMuted,
          letterSpacing: 1.5,
        ),
        filled: true,
        fillColor: AppTheme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: const Icon(
          Icons.tag_rounded,
          color: AppTheme.textMuted,
          size: 20,
        ),
      ),
      textCapitalization: TextCapitalization.characters,
      onSubmitted: (_) => _onSubmit(),
    );
  }

  Widget _buildError() {
    return ListenableBuilder(
      listenable: context.read<AuthViewModel>(),
      builder: (context, _) {
        final vm = context.read<AuthViewModel>();
        if (vm.errorMessage == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.errorColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return ListenableBuilder(
      listenable: context.read<AuthViewModel>(),
      builder: (context, _) {
        final vm = context.read<AuthViewModel>();
        final isLoading = vm.state == AuthState.loading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'VERIFY',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
