import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';

class SortOption {
  final String title;
  final String? order;
  SortOption({required this.title, this.order});
}

class SortBottomSheet extends StatefulWidget {
  final String? initialOrder;
  final Function(String?) onSortSelected;

  const SortBottomSheet({super.key, this.initialOrder, required this.onSortSelected});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  String? _selectedOrder;

  List<SortOption> _getOptions() => [
    SortOption(title: 'sort_expensive_first'.tr, order: '-order_price'),
    SortOption(title: 'sort_cheap_first'.tr, order: 'order_price'),
    SortOption(title: 'sort_top_rated'.tr, order: '-average_rating'),
    SortOption(title: 'sort_min_rating'.tr, order: 'average_rating'),
    SortOption(title: 'sort_most_reviews'.tr, order: '-comment_count'),
    SortOption(title: 'sort_least_reviews'.tr, order: 'comment_count'),
    SortOption(title: 'sort_alphabetical_az'.tr, order: 'title'),
    SortOption(title: 'sort_alphabetical_za'.tr, order: '-title'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedOrder = widget.initialOrder;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'sort_title'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'sort_by_criteria'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sort options list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _getOptions().length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final option = _getOptions()[index];
                final isSelected = _selectedOrder == option.order;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedOrder = option.order);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Show results button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSortSelected(_selectedOrder);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'show_results'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Reset all button
          Center(
            child: TextButton(
              onPressed: () {
                setState(() => _selectedOrder = null);
                widget.onSortSelected(null);
                Navigator.pop(context);
              },
              child: Text(
                'reset_all'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
