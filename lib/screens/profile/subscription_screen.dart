import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_pill.dart';
import 'profile_widgets.dart';
import 'subscription_payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selected;   // null = no active plan
  String? _pendingId;  // plan waiting for payment confirmation

  late final AuthProvider _auth;

  static const _plans = [
    _Plan(
      id: 'basic',
      name: 'Basic',
      price: 'Free',
      sub: 'Forever free',
      color: Color(0xFF6C5CE7),
      bg: Color(0xFFF0EEFF),
      features: [
        'Up to 2 distributors',
        'Up to 10 orders/month',
        'Basic order tracking',
        'Email support',
      ],
      missing: ['Payment integration', 'Analytics', 'Priority support'],
    ),
    _Plan(
      id: 'pro',
      name: 'Pro',
      price: 'Rs. 2,500',
      sub: 'per month',
      color: Color(0xFF185FA5),
      bg: Color(0xFFEEF2F8),
      features: [
        'Up to 10 distributors',
        'Unlimited orders',
        'Full order tracking',
        'Payment via EasyPaisa/JazzCash',
        'WhatsApp notifications',
        'Email & chat support',
      ],
      missing: ['Advanced analytics'],
    ),
    _Plan(
      id: 'business',
      name: 'Business',
      price: 'Rs. 5,000',
      sub: 'per month',
      color: Color(0xFF1A8A5A),
      bg: Color(0xFFEAF8F2),
      features: [
        'Unlimited distributors',
        'Unlimited orders',
        'Advanced analytics & reports',
        'Multi-user access',
        'Priority 24/7 support',
        'Custom integrations',
        'Dedicated account manager',
      ],
      missing: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    // Sync local selected plan with real subscription state
    if (_auth.subscriptionStatus == SubscriptionStatus.active) {
      _selected = 'pro'; // mock: treat pro as the default active plan
    }
    _auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!mounted) return;
    if (_auth.subscriptionStatus == SubscriptionStatus.active) {
      setState(() {
        _selected = _pendingId ?? 'pro';
        _pendingId = null;
      });
      // Navigate to home once subscription is active
      Future.microtask(() {
        if (mounted) context.go('/home');
      });
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _selectPlan(_Plan plan) async {
    if (plan.id == _selected) return;
    if (_pendingId == plan.id) return;

    final isUpgrade = _selected == null ||
        _plans.indexWhere((p) => p.id == plan.id) >
            _plans.indexWhere((p) => p.id == _selected);

    final paid = await context.push<bool>(
      '/subscription/payment',
      extra: SubscriptionPaymentArg(
        planId: plan.id,
        planName: plan.name,
        planPrice: plan.price,
        planColor: plan.color,
        isUpgrade: isUpgrade,
      ),
    );

    if (paid == true && mounted) {
      setState(() => _pendingId = plan.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final comingFromApproval = auth.verificationStatus == VerificationStatus.approved &&
        auth.subscriptionStatus != SubscriptionStatus.active;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Subscription & Plans'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Approval congratulations banner ──────────────────────
                  if (comingFromApproval) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: successBg,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                            color: successText.withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded,
                            color: successText, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Account Approved!',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: successText)),
                              const SizedBox(height: 2),
                              Text(
                                'Your shop has been verified. Choose a plan below to unlock the full app.',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: successText,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],

                  // ── Active plan banner (or no-plan card) ─────────────────
                  if (_selected != null) ...[
                    Container(
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
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.white54)),
                              Text(
                                _plans
                                    .firstWhere((p) => p.id == _selected)
                                    .name,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const StatusPill('active'),
                      ]),
                    ),
                  ] else ...[
                    Container(
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
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: textMuted)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),

                  Text('Choose Plan',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),

                  // ── Payment pending banner ────────────────────────────────
                  if (_pendingId != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: warningBg,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                            color: warningText.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.schedule_rounded,
                                color: warningText, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment Pending Verification',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: warningText)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Your ${_plans.firstWhere((p) => p.id == _pendingId).name} plan payment is being reviewed. It will activate automatically once confirmed.',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: warningText,
                                        height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          // Demo simulation
                          GestureDetector(
                            onTap: () => _auth.simulateSubscriptionActivated(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: surfaceWhite,
                                borderRadius:
                                    BorderRadius.circular(buttonRadius),
                                border: Border.all(
                                    color: warningText.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_circle_rounded,
                                      size: 14, color: warningText),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Demo: Admin Confirms Payment',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: warningText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Plan cards ────────────────────────────────────────────
                  ..._plans.map((plan) => _PlanCard(
                        plan: plan,
                        isActive: plan.id == _selected,
                        isPending: plan.id == _pendingId,
                        noActivePlan: _selected == null,
                        onTap: () => _selectPlan(plan),
                      )),

                  // ── Billing history (only when subscribed) ────────────────
                  if (_selected != null) ...[
                    const SizedBox(height: 20),
                    Text('Billing History',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          ...[
                            ('Jun 2026', 'Pro Plan', 'Rs. 2,500', true),
                            ('May 2026', 'Pro Plan', 'Rs. 2,500', true),
                            ('Apr 2026', 'Pro Plan', 'Rs. 2,500', true),
                          ].mapIndexed((i, r) => Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(children: [
                                    const Icon(Icons.receipt_outlined,
                                        size: 16, color: textMuted),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(r.$2,
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: textPrimary)),
                                          Text(r.$1,
                                              style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Text(r.$3,
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: successBg,
                                        borderRadius:
                                            BorderRadius.circular(pillRadius),
                                      ),
                                      child: Text('Paid',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: successText)),
                                    ),
                                  ]),
                                ),
                                if (i < 2)
                                  const Divider(
                                      height: 1,
                                      indent: 42,
                                      color: borderColor),
                              ])),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.isPending,
    required this.noActivePlan,
    required this.onTap,
  });
  final _Plan plan;
  final bool isActive, isPending, noActivePlan;
  final VoidCallback onTap;

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
              color: isPending
                  ? warningText
                  : isActive
                      ? plan.color
                      : borderColor,
              width: (isActive || isPending) ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: plan.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.workspace_premium_rounded,
                      color: plan.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary)),
                      Row(children: [
                        Text(plan.price,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: plan.color)),
                        if (plan.sub.isNotEmpty)
                          Text('  ${plan.sub}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: textSecondary)),
                      ]),
                    ],
                  ),
                ),
                if (isPending)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: warningBg,
                      borderRadius: BorderRadius.circular(pillRadius),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: warningText),
                      const SizedBox(width: 4),
                      Text('Pending',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: warningText)),
                    ]),
                  )
                else if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: plan.bg,
                      borderRadius: BorderRadius.circular(pillRadius),
                    ),
                    child: Text('Current',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: plan.color)),
                  ),
              ]),
            ),
            const Divider(height: 1, color: borderColor),
            // Features
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...plan.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Icon(Icons.check_circle_rounded,
                              size: 14, color: plan.color),
                          const SizedBox(width: 8),
                          Text(f,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: textPrimary)),
                        ]),
                      )),
                  ...plan.missing.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          const Icon(Icons.remove_circle_outline_rounded,
                              size: 14, color: textMuted),
                          const SizedBox(width: 8),
                          Text(f,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: textMuted)),
                        ]),
                      )),
                  if (!isActive) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: isPending
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: warningBg,
                                borderRadius:
                                    BorderRadius.circular(buttonRadius),
                                border: Border.all(
                                    color: warningText.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.schedule_rounded,
                                      size: 15, color: warningText),
                                  const SizedBox(width: 6),
                                  Text('Payment Under Review',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: warningText)),
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: plan.color,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(buttonRadius)),
                              ),
                              child: Text(
                                noActivePlan
                                    ? 'Get Started'
                                    : plan.id == 'basic'
                                        ? 'Downgrade to Basic'
                                        : 'Upgrade to ${plan.name}',
                                style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
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

class _Plan {
  const _Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.sub,
    required this.color,
    required this.bg,
    required this.features,
    required this.missing,
  });
  final String id, name, price, sub;
  final Color color, bg;
  final List<String> features, missing;
}

extension on Iterable<Object?> {
  Iterable<T> mapIndexed<T>(T Function(int i, dynamic e) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
