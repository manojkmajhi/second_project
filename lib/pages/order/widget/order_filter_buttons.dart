import 'package:flutter/material.dart';

class OrderFilterButtons extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const OrderFilterButtons({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Pending', 'In Process', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.black : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black,
              ),
              onPressed: () => onFilterSelected(filter),
              child: Text(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}