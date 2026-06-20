import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/distributor_avatar.dart';

// ── Mock catalogue (public so distributor detail can reference it) ─────────────
final catalogue = [
  ProductData(
    id: 'p1', name: 'Dulux Exterior Paint', brand: 'Dulux',
    category: 'Exterior', pricePerUnit: 2400,
    unit: '4L', colors: ['White', 'Cream', 'Light Grey', 'Beige'],
    sizes: ['1L – Rs. 700', '4L – Rs. 2,400', '16L – Rs. 8,800'],
    description:
        'Weather-resistant exterior emulsion for long-lasting protection against rain, UV, and algae.',
    inStock: true, minOrder: 2,
    avatarBg: const Color(0xFFEEF2F8), avatarFg: const Color(0xFF185FA5), initials: 'DU',
  ),
  ProductData(
    id: 'p2', name: 'Nippon Interior Emulsion', brand: 'Nippon',
    category: 'Interior', pricePerUnit: 1600,
    unit: '4L', colors: ['White', 'Ivory', 'Magnolia', 'Dove Grey', 'Sky Blue'],
    sizes: ['1L – Rs. 450', '4L – Rs. 1,600', '16L – Rs. 5,800'],
    description:
        'Smooth washable interior emulsion with low-VOC formula. Ideal for living rooms and bedrooms.',
    inStock: true, minOrder: 3,
    avatarBg: const Color(0xFFFFF8ED), avatarFg: const Color(0xFFD97706), initials: 'NP',
  ),
  ProductData(
    id: 'p3', name: 'Berger WeatherCoat', brand: 'Berger',
    category: 'Exterior', pricePerUnit: 2800,
    unit: '4L', colors: ['White', 'Off-White', 'Cream'],
    sizes: ['4L – Rs. 2,800', '16L – Rs. 10,200'],
    description:
        'All-weather exterior coat that forms a flexible film, bridging micro-cracks and resisting dampness.',
    inStock: true, minOrder: 2,
    avatarBg: const Color(0xFFF0EEFF), avatarFg: const Color(0xFF6C5CE7), initials: 'BG',
  ),
  ProductData(
    id: 'p4', name: 'Jotun Majestic True Beauty', brand: 'Jotun',
    category: 'Interior', pricePerUnit: 3200,
    unit: '4L', colors: ['Premium White', 'Linen', 'Pebble Shore', 'Morning Dew'],
    sizes: ['1L – Rs. 900', '4L – Rs. 3,200', '10L – Rs. 7,500'],
    description:
        'Premium interior paint with silk finish. Excellent coverage in 2 coats with outstanding stain resistance.',
    inStock: true, minOrder: 1,
    avatarBg: const Color(0xFFEAF8F2), avatarFg: const Color(0xFF1A8A5A), initials: 'JT',
  ),
  ProductData(
    id: 'p5', name: 'ICI Dulux Gloss', brand: 'ICI',
    category: 'Wood & Metal', pricePerUnit: 1100,
    unit: '1L', colors: ['White', 'Black', 'Mahogany', 'Walnut'],
    sizes: ['500ml – Rs. 600', '1L – Rs. 1,100', '4L – Rs. 3,800'],
    description:
        'High-gloss enamel for wood and metal surfaces. Durable, hard-wearing finish resistant to chipping.',
    inStock: false, minOrder: 2,
    avatarBg: const Color(0xFFFEF0EF), avatarFg: const Color(0xFFD94A3A), initials: 'IC',
  ),
  ProductData(
    id: 'p6', name: 'Sika Waterproofing Coat', brand: 'Sika',
    category: 'Waterproofing', pricePerUnit: 4500,
    unit: '5kg', colors: ['Grey', 'White'],
    sizes: ['5kg – Rs. 4,500', '20kg – Rs. 17,000'],
    description:
        'Cementitious waterproof coating for roofs, bathrooms, and basements. Two-component system for maximum durability.',
    inStock: true, minOrder: 1,
    avatarBg: const Color(0xFFEEF2F8), avatarFg: const Color(0xFF185FA5), initials: 'SK',
  ),
];

const _categories = ['All', 'Interior', 'Exterior', 'Wood & Metal', 'Waterproofing'];

class StockBrowseScreen extends StatefulWidget {
  const StockBrowseScreen({super.key, required this.distributorName});
  final String distributorName;

  @override
  State<StockBrowseScreen> createState() => _StockBrowseScreenState();
}

class _StockBrowseScreenState extends State<StockBrowseScreen> {
  String _category = 'All';
  String _search = '';

  List<ProductData> get _filtered => catalogue.where((p) {
        final matchCat = _category == 'All' || p.category == _category;
        final matchQ = _search.isEmpty ||
            p.name.toLowerCase().contains(_search.toLowerCase()) ||
            p.brand.toLowerCase().contains(_search.toLowerCase());
        return matchCat && matchQ;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

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
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Browse Stock',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                widget.distributorName,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: accentOrange.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(pillRadius),
                          ),
                          child: Text(
                            '${list.length} items',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search products or brands...',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white38),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.white54, size: 20),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category chips ─────────────────────────────────────────────
          Container(
            color: surfaceWhite,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((c) {
                  final active = c == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? primaryNavy : bgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active ? primaryNavy : borderColor),
                      ),
                      child: Text(
                        c,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: active ? Colors.white : textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(height: 1, color: borderColor),

          // ── Product grid ───────────────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('No products found',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _ProductCard(
                      product: list[i],
                      distributorName: widget.distributorName,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
      {required this.product, required this.distributorName});
  final ProductData product;
  final String distributorName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/product/${product.id}',
        extra: ProductDetailArg(
            product: product, distributorName: distributorName),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  DistributorAvatar(
                    initials: product.initials,
                    bg: product.avatarBg,
                    fg: product.avatarFg,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary),
                            ),
                          ),
                          if (!product.inStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: dangerBg,
                                borderRadius:
                                    BorderRadius.circular(pillRadius),
                              ),
                              child: Text('Out of stock',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: dangerText)),
                            ),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          '${product.brand}  ·  ${product.category}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.colors.take(3).join(' · ') +
                              (product.colors.length > 3 ? ' +${product.colors.length - 3}' : ''),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: borderColor),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'From Rs. ${product.pricePerUnit.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / ${product.unit}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryNavy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Min. ${product.minOrder} unit${product.minOrder > 1 ? "s" : ""}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: textSecondary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared data model ─────────────────────────────────────────────────────────
class ProductData {
  const ProductData({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.pricePerUnit,
    required this.unit,
    required this.colors,
    required this.sizes,
    required this.description,
    required this.inStock,
    required this.minOrder,
    required this.avatarBg,
    required this.avatarFg,
    required this.initials,
  });

  final String id, name, brand, category, unit, description, initials;
  final int pricePerUnit, minOrder;
  final List<String> colors, sizes;
  final bool inStock;
  final Color avatarBg, avatarFg;
}

class ProductDetailArg {
  const ProductDetailArg(
      {required this.product, required this.distributorName});
  final ProductData product;
  final String distributorName;
}
