import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/status_pill.dart';
import 'profile_widgets.dart';
import 'subscription_payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Set to true when user taps "I've Paid" — cleared once admin activates
  bool _paymentSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sub = context.watch<SubscriptionProvider>();

    // If admin activated the plan, clear local pending state
    if (_paymentSubmitted && sub.canAccess) {
      _paymentSubmitted = false;
    }

    // Also drive pending banner from Firestore payments (survives hot reload)
    final hasPendingPayment = sub.payments.any(
      (p) => p['status'] == 'pending',
    );
    final showPendingBanner = _paymentSubmitted || hasPendingPayment;

    final comingFromApproval =
        auth.verificationStatus == VerificationStatus.approved &&
            !sub.canAccess;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Subscription & Plans'),
          Expanded(
            child: sub.monthlyPlan == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Approval congratulations banner
                        if (comingFromApproval &&
                            sub.lifecycle == SubLifecycle.trial) ...[
                          _banner(
                            icon: Icons.check_circle_rounded,
                            color: successText,
                            bg: successBg,
                            title: 'Account Approved!',
                            body:
                                'Your shop has been verified. You have ${sub.daysLeft ?? 0} trial days — subscribe anytime to keep access.',
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Lifecycle status banner
                        _LifecycleBanner(sub: sub),

                        // Payment pending banner
                        if (showPendingBanner) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: warningBg,
                              borderRadius:
                                  BorderRadius.circular(cardRadius),
                              border: Border.all(
                                  color: warningText.withValues(alpha: 0.3)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.schedule_rounded,
                                  color: warningText, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Under Review',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: warningText),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Your payment has been submitted. EasyStock will activate your plan within a few hours after verification.',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: warningText,
                                          height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Active plan card
                        _ActivePlanCard(sub: sub),
                        const SizedBox(height: 20),

                        Text('Choose Plan',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textMuted,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 10),

                        // Plan cards
                        if (sub.monthlyPlan != null)
                          _PlanCard(
                            plan: sub.monthlyPlan!,
                            isActive: sub.planKey == 'shop_monthly',
                            onTap: () => _selectPlan(
                                context, auth, sub, sub.monthlyPlan!),
                          ),
                        if (sub.yearlyPlan != null)
                          _PlanCard(
                            plan: sub.yearlyPlan!,
                            isActive: sub.planKey == 'shop_yearly',
                            badge: _savingsBadge(
                                sub.monthlyPlan, sub.yearlyPlan),
                            onTap: () => _selectPlan(
                                context, auth, sub, sub.yearlyPlan!),
                          ),

                        // Billing history
                        if (sub.payments.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Billing History',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textMuted,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          _BillingHistory(payments: sub.payments),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPlan(BuildContext context, AuthProvider auth,
      SubscriptionProvider sub, PlanInfo plan) async {
    if (sub.planKey == plan.key &&
        (sub.lifecycle == SubLifecycle.active ||
            sub.lifecycle == SubLifecycle.expiring ||
            sub.lifecycle == SubLifecycle.trial)) {
      return;
    }
    final paid = await context.push<bool>(
      '/subscription/payment',
      extra: SubscriptionPaymentArg(
        planKey: plan.key,
        planLabel: plan.label,
        price: plan.price,
        billingMonths: plan.billingMonths,
      ),
    );
    if (paid == true && mounted) {
      setState(() => _paymentSubmitted = true);
    }
  }

  String? _savingsBadge(PlanInfo? monthly, PlanInfo? yearly) {
    if (monthly == null || yearly == null) return null;
    final monthlyYear = monthly.price * 12;
    if (monthlyYear <= 0) return null;
    final saving =
        ((monthlyYear - yearly.price) / monthlyYear * 100).round();
    if (saving <= 0) return null;
    return 'Save $saving%';
  }

  Widget _banner({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(height: 2),
              Text(body,
                  style:
                      GoogleFonts.inter(fontSize: 12, color: color, height: 1.4)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Lifecycle banner ───────────────────────────────────────────────────────────
class _LifecycleBanner extends StatelessWidget {
  const _LifecycleBanner({required this.sub});
  final SubscriptionProvider sub;

  @override
  Widget build(BuildContext context) {
    switch (sub.lifecycle) {
      case SubLifecycle.trial:
        return _banner(
          icon: Icons.access_time_filled_rounded,
          color: infoText,
          bg: infoBg,
          title: 'Trial Active — ${sub.daysLeft ?? 0} days left',
          body:
              'You\'re on a free trial. Subscribe before your trial ends to keep access.',
        );
      case SubLifecycle.expiring:
        return _banner(
          icon: Icons.warning_amber_rounded,
          color: warningText,
          bg: warningBg,
          title: 'Subscription Expiring — ${sub.daysLeft ?? 0} days left',
          body: 'Renew now to avoid losing access to your wholesalers.',
        );
      case SubLifecycle.grace:
        return _banner(
          icon: Icons.warning_rounded,
          color: dangerText,
          bg: dangerBg,
          title: 'Grace Period — ${sub.daysLeft ?? 0} days left',
          body:
              'Your subscription expired. You still have limited access — renew immediately.',
        );
      case SubLifecycle.paymentRequired:
        return _banner(
          icon: Icons.lock_rounded,
          color: warningText,
          bg: warningBg,
          title: 'No Active Subscription',
          body: 'Choose a plan below to unlock the full app.',
        );
      case SubLifecycle.expired:
        return _banner(
          icon: Icons.block_rounded,
          color: dangerText,
          bg: dangerBg,
          title: 'Subscription Expired',
          body: 'Your access has been blocked. Renew your subscription.',
        );
      case SubLifecycle.suspended:
        return _banner(
          icon: Icons.block_rounded,
          color: dangerText,
          bg: dangerBg,
          title: 'Account Suspended',
          body: 'Contact EasyStock support to restore your account.',
        );
      case SubLifecycle.active:
      case SubLifecycle.unknown:
      case SubLifecycle.pendingApproval:
        return const SizedBox.shrink();
    }
  }

  Widget _banner({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(height: 2),
              Text(body,
                  style:
                      GoogleFonts.inter(fontSize: 12, color: color, height: 1.4)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Active plan card ───────────────────────────────────────────────────────────
class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({required this.sub});
  final SubscriptionProvider sub;

  @override
  Widget build(BuildContext context) {
    final hasActivePlan = sub.planKey.isNotEmpty &&
        (sub.lifecycle == SubLifecycle.active ||
            sub.lifecycle == SubLifecycle.expiring ||
            sub.lifecycle == SubLifecycle.trial ||
            sub.lifecycle == SubLifecycle.grace);

    if (!hasActivePlan) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                color: textMuted, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No Active Plan',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textSecondary)),
                Text('Select a plan below to get started',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: textMuted)),
              ],
            ),
          ),
        ]),
      );
    }

    final plan = sub.planKey == 'shop_yearly'
        ? sub.yearlyPlan
        : sub.monthlyPlan;
    final label = plan?.shortLabel ?? sub.planKey;
    final statusStr = _statusString(sub.lifecycle);

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
      child: Row(children: [
        const Icon(Icons.workspace_premium_rounded,
            color: accentOrange, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Plan',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              if (sub.subscriptionEnd != null)
                Text(
                    'Renews ${_formatDate(sub.subscriptionEnd!)}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white38)),
              if (sub.trialEnd != null && sub.planKey.isEmpty)
                Text(
                    'Trial ends ${_formatDate(sub.trialEnd!)}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white38)),
            ],
          ),
        ),
        StatusPill(statusStr),
      ]),
    );
  }

  String _statusString(SubLifecycle l) {
    switch (l) {
      case SubLifecycle.active:
        return 'active';
      case SubLifecycle.expiring:
        return 'expiring';
      case SubLifecycle.trial:
        return 'trial';
      case SubLifecycle.grace:
        return 'grace';
      default:
        return 'active';
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

// ── Plan card ──────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.onTap,
    this.badge,
  });
  final PlanInfo plan;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  Color get _color =>
      plan.key == 'shop_yearly' ? const Color(0xFF1A8A5A) : const Color(0xFF185FA5);
  Color get _bg =>
      plan.key == 'shop_yearly' ? const Color(0xFFEAF8F2) : const Color(0xFFEEF2F8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
              color: isActive ? _color : borderColor,
              width: isActive ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.workspace_premium_rounded,
                      color: _color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.shortLabel,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary)),
                      Row(children: [
                        Text(plan.priceLabel,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _color)),
                        Text('  ${plan.periodLabel}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: textSecondary)),
                      ]),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8F2),
                      borderRadius: BorderRadius.circular(pillRadius),
                    ),
                    child: Text(badge!,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A8A5A))),
                  )
                else if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(pillRadius),
                    ),
                    child: Text('Current',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _color)),
                  ),
              ]),
            ),
            const Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...plan.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Icon(Icons.check_circle_rounded,
                              size: 14, color: _color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(f,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: textPrimary)),
                          ),
                        ]),
                      )),
                  if (!isActive) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _color,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius)),
                        ),
                        child: Text('Get Started',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Billing history ────────────────────────────────────────────────────────────
class _BillingHistory extends StatelessWidget {
  const _BillingHistory({required this.payments});
  final List<Map<String, dynamic>> payments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: List.generate(payments.length, (i) {
          final p = payments[i];
          final status = p['status'] as String? ?? 'pending';
          final planKey = p['planKey'] as String? ?? '';
          final amount = (p['amount'] as num?)?.toInt() ?? 0;
          final method = p['method'] as String? ?? '';
          final createdAt = p['createdAt'];
          final dateStr = createdAt is Timestamp
              ? _fmt(createdAt.toDate())
              : '—';

          final planLabel = planKey == 'shop_yearly'
              ? 'Retailer Yearly'
              : 'Retailer Monthly';

          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(children: [
                const Icon(Icons.receipt_outlined,
                    size: 16, color: textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planLabel,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textPrimary)),
                      Text('$dateStr · $method',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary)),
                    ],
                  ),
                ),
                Text('Rs. $amount',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(width: 8),
                _StatusBadge(status: status),
              ]),
            ),
            if (i < payments.length - 1)
              const Divider(height: 1, indent: 42, color: borderColor),
          ]);
        }),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'confirmed' => (successBg, successText, 'Paid'),
      'pending' => (warningBg, warningText, 'Pending'),
      'rejected' => (dangerBg, dangerText, 'Rejected'),
      _ => (bgColor, textSecondary, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(pillRadius),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
