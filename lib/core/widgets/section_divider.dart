import 'package:flutter/material.dart';

/// Takrorlanadigan bo'lim ajratgich — listing_detail va boshqa screenlarda
/// bir xil Divider patterni qo'llaniladi, DRY prinsipi uchun ajratildi.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
    );
  }
}
