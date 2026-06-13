import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/core/theme/app_theme.dart';
import './status_screen.dart';
import '../models/home_view.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 28),
              _buildTopBar(context),
              const Spacer(),
              _buildOrb(context),
              const SizedBox(height: 40),
              _buildStatusLabel(context),
              const SizedBox(height: 12),
              _buildConfigBadge(context),
              const Spacer(),
              _buildRunButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.studio.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(
              vm.studio.id,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.accent.withOpacity(0.8),
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
        const Spacer(),
        if (vm.isConnected)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
                value: vm,
                child: const StatusScreen(),
              )),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrb(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final isConnected = vm.isConnected;
    final isBusy = vm.isBusy;

    return _PulsingOrb(
      isConnected: isConnected,
      isBusy: isBusy,
    );
  }

  Widget _buildStatusLabel(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final labels = {
      VpnConnectionState.idle: 'Ready to connect',
      VpnConnectionState.pinging: 'Finding fastest server...',
      VpnConnectionState.connecting: 'Connecting...',
      VpnConnectionState.connected: 'Connected & Protected',
      VpnConnectionState.error: 'Connection failed',
    };

    final colors = {
      VpnConnectionState.idle: AppTheme.textMuted,
      VpnConnectionState.pinging: AppTheme.accent,
      VpnConnectionState.connecting: AppTheme.accent,
      VpnConnectionState.connected: AppTheme.success,
      VpnConnectionState.error: AppTheme.errorColor,
    };

    return Text(
      labels[vm.connectionState] ?? '',
      style: TextStyle(
        color: colors[vm.connectionState],
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildConfigBadge(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    if (vm.activeConfig == null) {
      return const SizedBox(height: 24);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(
            vm.activeConfig!.tag,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          if (vm.activeConfig?.pingMs != null) ...[
            const SizedBox(width: 8),
            Text(
              '${vm.activeConfig!.pingMs}ms',
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRunButton(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    if (vm.connectionState == VpnConnectionState.error) {
      return Column(
        children: [
          Text(
            vm.errorMessage ?? '',
            style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'RETRY',
            onTap: vm.connect,
            color: AppTheme.accent,
          ),
        ],
      );
    }

    if (vm.isConnected) {
      return _ActionButton(
        label: 'DISCONNECT',
        onTap: vm.disconnect,
        color: AppTheme.errorColor,
      );
    }

    return _ActionButton(
      label: vm.isBusy ? '...' : 'RUN',
      onTap: vm.isBusy ? null : vm.connect,
      color: AppTheme.accent,
      isLoading: vm.isBusy,
    );
  }
}

class _PulsingOrb extends StatefulWidget {
  const _PulsingOrb({required this.isConnected, required this.isBusy});

  final bool isConnected;
  final bool isBusy;

  @override
  State<_PulsingOrb> createState() => _PulsingOrbState();
}

class _PulsingOrbState extends State<_PulsingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isConnected
        ? AppTheme.success
        : widget.isBusy
            ? AppTheme.accent
            : const Color(0xFF3A3A55);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isConnected || widget.isBusy)
                Transform.scale(
                  scale: _pulse.value * 1.25,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.06),
                    ),
                  ),
                ),
              Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isConnected
                          ? Icons.shield_rounded
                          : Icons.shield_outlined,
                      size: 64,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
      ),
    );
  }
}