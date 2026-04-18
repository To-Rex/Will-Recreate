import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extensions/context_extensions.dart';

class CancellationRulesSheet extends StatelessWidget {
  const CancellationRulesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'cancellation_rules'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildRule(context, 'cancellation_rule_1_title'.tr, 'cancellation_rule_1_desc'.tr),
          const SizedBox(height: 16),
          _buildRule(context, 'cancellation_rule_2_title'.tr, 'cancellation_rule_2_desc'.tr),
          const SizedBox(height: 16),
          _buildRule(context, 'cancellation_rule_3_title'.tr, 'cancellation_rule_3_desc'.tr),
          const SizedBox(height: 16),
          _buildRule(context, 'cancellation_rule_4_title'.tr, 'cancellation_rule_4_desc'.tr),
        ],
      ),
    );
  }

  Widget _buildRule(BuildContext context, String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: context.colors.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
