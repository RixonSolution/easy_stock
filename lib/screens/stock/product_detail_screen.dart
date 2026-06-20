import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/qty_stepper.dart';
import 'stock_browse_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.arg});
  final ProductDetailArg arg;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _qty = 1;

  ProductData get _p => widget.arg.product;

  // Color map for paint swatches
  static const _colorHexMap = {
    'White': Color(0xFFF8F8F8),
    'Off-White': Color(0xFFF5F0E8),
    'Cream': Color(0xFFFFF5D6),
    'Ivory': Color(0xFFFFF8DC),
    'Magnolia': Color(0xFFF5F0E0),
    'Beige': Color(0xFFF5F5DC),
    'Light Grey': Color(0xFFD3D3D3),
    'Dove Grey': Color(0xFFB5B5B5),
    'Grey': Color(0xFF9E9E9E),
    'Sky Blue': Color(0xFF87CEEB),
    'Morning Dew': Color(0xFFB2DFDB),
    'Linen': Color(0xFFFAF0E6),
    'Pebble Shore': Color(0xFFD2B48C),
    'Premium White': Color(0xFFFFFAFA),
    'Black': Color(0xFF212121),
    'Mahogany': Color(0xFF8B1A1A),
    'Walnut': Color(0xFF6B3A2A),
  };

  Color _swatchColor(String name) =>
      _colorHexMap[name] ?? const Color(0xFFEEEEEE);

  bool _isDark(Color c) =>
      c.computeLuminance() < 0.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Navy header ────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            _p.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Brand + category chips
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(children: [
                        _HeaderChip(_p.brand),
                        const SizedBox(width: 8),
                        _HeaderChip(_p.category),
                        if (!_p.inStock) ...[
                          const SizedBox(width: 8),
                          _HeaderChip('Out of Stock', danger: true),
                        ],
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large colour preview box
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    height: 160,
                    decoration: BoxDecoration(
                      color: _swatchColor(
                          _p.colors[_selectedColorIndex]),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_paint_rounded,
                          size: 36,
                          color: _isDark(
                                  _swatchColor(_p.colors[_selectedColorIndex]))
                              ? Colors.white54
                              : textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _p.colors[_selectedColorIndex],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isDark(
                                    _swatchColor(_p.colors[_selectedColorIndex]))
                                ? Colors.white70
                                : textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Colour selector ────────────────────────────────────
                  _SectionCard(
                    label: 'Select Colour  (${_p.colors.length} shades)',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_p.colors.length, (i) {
                        final selected = i == _selectedColorIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColorIndex = i),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _swatchColor(_p.colors[i]),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? accentOrange
                                        : borderColor,
                                    width: selected ? 2.5 : 1,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: accentOrange
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 52,
                                child: Text(
                                  _p.colors[i],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: selected
                                        ? accentOrange
                                        : textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Size selector ──────────────────────────────────────
                  _SectionCard(
                    label: 'Select Size',
                    child: Column(
                      children: List.generate(_p.sizes.length, (i) {
                        final selected = i == _selectedSizeIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSizeIndex = i),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryNavy.withValues(alpha: 0.05)
                                  : bgColor,
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              border: Border.all(
                                color: selected ? primaryNavy : borderColor,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  size: 18,
                                  color: selected ? primaryNavy : textMuted,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _p.sizes[i],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? textPrimary
                                        : textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Qty stepper ────────────────────────────────────────
                  _SectionCard(
                    label: 'Quantity',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Min. order: ${_p.minOrder} unit${_p.minOrder > 1 ? "s" : ""}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                        QtyStepper(
                          qty: _qty,
                          min: _p.minOrder,
                          onChanged: (v) => setState(() => _qty = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Description ────────────────────────────────────────
                  _SectionCard(
                    label: 'Description',
                    child: Text(
                      _p.description,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Distributor info ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 18, color: textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sold by ${widget.arg.distributorName}',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: textSecondary),
                          ),
                        ),
                        Text(
                          'Verified',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: successText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: successText),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA bar ─────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).padding.bottom + 14,
        ),
        decoration: BoxDecoration(
          color: surfaceWhite,
          border: const Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            // Price total
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: textSecondary)),
                Text(
                  'Rs. ${(_p.pricePerUnit * _qty).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _p.inStock ? () => _showAddedToCart(context) : null,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: Text(_p.inStock ? 'Add to Order' : 'Out of Stock'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  disabledBackgroundColor: borderColor,
                  disabledForegroundColor: textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedToCart(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_p.name} (${_p.colors[_selectedColorIndex]}, ${_p.sizes[_selectedSizeIndex].split(' –')[0]}) ×$_qty added to order',
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View Order',
          textColor: accentOrange,
          onPressed: () => context.go('/orders'),
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(this.label, {this.danger = false});
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: danger
            ? dangerText.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(pillRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: danger ? const Color(0xFFFFCDD2) : Colors.white70,
        ),
      ),
    );
  }
}
