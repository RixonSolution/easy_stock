import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';

enum PillSize { small, medium }

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key, this.size = PillSize.medium});

  final String status;
  final PillSize size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    final fontSize = size == PillSize.small ? 11.0 : 12.0;
    final hPad = size == PillSize.small ? 8.0 : 10.0;
    final vPad = size == PillSize.small ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(pillRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  static (Color, Color, String) _resolve(String status) {
    return switch (status.toLowerCase()) {
      'requested'          => (purpleBg,  purpleText, 'Requested'),
      'approved'           => (successBg, successText,'Approved'),
      'payment_confirmed'  => (infoBg,    infoText,   'Payment Confirmed'),
      'out_for_delivery'   => (warningBg, warningText,'Out for Delivery'),
      'delivered'          => (successBg, successText,'Delivered'),
      'completed'          => (successBg, successText,'Completed'),
      'cancelled'          => (dangerBg,  dangerText, 'Cancelled'),
      'rejected'           => (dangerBg,  dangerText, 'Rejected'),
      'pending'            => (warningBg, warningText,'Pending'),
      'active'             => (successBg, successText,'Active'),
      'trial'              => (infoBg,    infoText,   'Trial'),
      'expiring'           => (warningBg, warningText,'Expiring'),
      'grace'              => (dangerBg,  dangerText, 'Grace Period'),
      'expired'            => (dangerBg,  dangerText, 'Expired'),
      'connected'          => (successBg, successText,'Connected'),
      _                    => (infoBg,    infoText,   status),
    };
  }
}
