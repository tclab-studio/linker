import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/core/theme/app_theme.dart';
import '../models/home_view.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimary,
        ),
        title: const Text(
          'Connection Status',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: context.read<HomeViewModel>(),
        builder: (context, _) {
          final vm = context.read<HomeViewModel>();

          if (!vm.isConnected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) Navigator.pop(context);
            });
          }

          final config = vm.activeConfig;
          final status = vm.v2rayStatus;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildConnectedBanner(context),
                  const SizedBox(height: 32),
                  _buildStats(context, config, status),
                  const Spacer(),
                  _buildDisconnectButton(context, vm),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectedBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppTheme.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You\'re protected no cap 🛡️',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Traffic encrypted & routing through VPN',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, activeConfig, status) {
    final vm = context.read<HomeViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STATS', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.location_on_rounded,
          label: 'Server',
          value: activeConfig?.tag ?? '—',
          iconColor: AppTheme.accent,
        ),
        const SizedBox(height: 10),
        _StatCard(
          icon: Icons.speed_rounded,
          label: 'Latency',
          value: activeConfig?.pingMs != null
              ? '${activeConfig!.pingMs}ms'
              : '—',
          iconColor: AppTheme.success,
        ),
        const SizedBox(height: 10),
        _StatCard(
          icon: Icons.upload_rounded,
          label: 'Upload',
          value: status != null ? _formatBytes(status.upload) : '—',
          iconColor: const Color(0xFF818CF8),
        ),
        const SizedBox(height: 10),
        _StatCard(
          icon: Icons.download_rounded,
          label: 'Download',
          value: status != null ? _formatBytes(status.download) : '—',
          iconColor: const Color(0xFF34D399),
        ),
        const SizedBox(height: 10),
        _StatCard(
          icon: Icons.dns_rounded,
          label: 'Protocol',
          value: activeConfig?.protocol.toUpperCase() ?? '—',
          iconColor: const Color(0xFFFBBF24),
        ),
        const SizedBox(height: 10),
        _StatCard(
          icon: Icons.badge_rounded,
          label: 'Studio',
          value: vm.studio.id,
          iconColor: AppTheme.textMuted,
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  Widget _buildDisconnectButton(BuildContext context, HomeViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () async {
          await vm.disconnect();
          if (context.mounted) Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          side: const BorderSide(color: AppTheme.errorColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'DISCONNECT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
