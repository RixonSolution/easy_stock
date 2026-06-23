import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius)),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500, color: textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/onboarding');
            },
            child: Text('Log Out',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: dangerText)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Navy header ────────────────────────────────────────────────
          _ProfileHeader(
            shopName:  auth.shopName.isEmpty  ? 'My Shop'       : auth.shopName,
            ownerName: auth.ownerName.isEmpty ? 'Account Owner' : auth.ownerName,
            city:      auth.city.isEmpty      ? ''              : auth.city,
            initials:  auth.initials,
          ),

          // ── Scrollable body ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.receipt_long_rounded,
                            value: '21',
                            label: 'Total Orders',
                            iconColor: infoText,
                            iconBg: infoBg,
                            compact: true,
                            onTap: () => context.push('/orders'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            icon: Icons.store_rounded,
                            value: '4',
                            label: 'Distributors',
                            iconColor: purpleText,
                            iconBg: purpleBg,
                            compact: true,
                            onTap: () => context.push('/distributors'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle_rounded,
                            value: '18',
                            label: 'Completed',
                            iconColor: successText,
                            iconBg: successBg,
                            compact: true,
                            onTap: () => context.push('/orders', extra: 3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subscription card
                  GestureDetector(
                    onTap: () => context.push('/profile/subscription'),
                    child: _SubscriptionCard(
                      status: auth.subscriptionStatus,
                      planId: auth.subscriptionPlan,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ACCOUNT
                  _SectionLabel('ACCOUNT'),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.storefront_rounded,
                      label: 'Shop Details',
                      onTap: () => context.push('/profile/shop'),
                    ),
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Personal Info',
                      onTap: () => context.push('/profile/personal'),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () => context.push('/profile/password'),
                      last: true,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // PREFERENCES
                  _SectionLabel('PREFERENCES'),
                  _SettingsCard(children: [
                    _SwitchTile(
                      icon: Icons.notifications_outlined,
                      label: 'Push Notifications',
                      value: _notificationsOn,
                      onChanged: (v) =>
                          setState(() => _notificationsOn = v),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      trailing: Text(
                        'English',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: textSecondary),
                      ),
                      onTap: () => context.push('/profile/language'),
                      last: true,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // SUPPORT
                  _SectionLabel('SUPPORT'),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & FAQ',
                      onTap: () => context.push('/profile/faq'),
                    ),
                    _SettingsTile(
                      icon: Icons.headset_mic_outlined,
                      label: 'Contact Support',
                      onTap: () => context.push('/profile/support'),
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      label: 'Terms & Privacy',
                      onTap: () => context.push('/profile/terms'),
                      last: true,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Logout
                  GestureDetector(
                    onTap: _confirmLogout,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dangerBg,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                            color: dangerText.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: dangerText, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Log Out',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: dangerText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'EasyStock v1.0.0',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.shopName,
    required this.ownerName,
    required this.city,
    required this.initials,
  });

  final String shopName, ownerName, city, initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Orange initials avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                shopName,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: accentOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  size: 10, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ownerName,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white60),
                        ),
                        if (city.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: Colors.white38),
                              const SizedBox(width: 3),
                              Text(
                                '$city, Pakistan',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.white38),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subscription card ─────────────────────────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.status,
    required this.planId,
  });

  final SubscriptionStatus status;
  final String planId;

  String get _planLabel {
    switch (planId) {
      case 'business': return 'Business Plan';
      case 'basic':    return 'Basic Plan';
      default:         return 'Pro Plan';
    }
  }

  String get _statusStr {
    switch (status) {
      case SubscriptionStatus.active:   return 'active';
      case SubscriptionStatus.expiring: return 'expiring';
      case SubscriptionStatus.expired:  return 'expired';
      default:                          return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryNavy, lightNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: accentOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                status == SubscriptionStatus.none ? 'No Active Plan' : _planLabel,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              StatusPill(_statusStr),
            ],
          ),
          if (status != SubscriptionStatus.none) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white12),
            const SizedBox(height: 10),
            Text(
              'Tap to manage your subscription',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
            ),
          ],
        ],
      ),
    );
  }
}


// ── Settings helpers ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: textSecondary),
          ),
          title: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
          ),
          trailing: trailing ??
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          minLeadingWidth: 0,
        ),
        if (!last)
          const Divider(
              height: 1, indent: 64, endIndent: 0, color: borderColor),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: textSecondary),
          ),
          title: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
          ),
          trailing: Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: accentOrange,
              activeTrackColor: accentOrange.withValues(alpha: 0.25),
              inactiveThumbColor: textMuted,
              inactiveTrackColor: borderColor,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          minLeadingWidth: 0,
        ),
        const Divider(height: 1, indent: 64, color: borderColor),
      ],
    );
  }
}
