extension NumFormatting on num {
  /// Format number with space separators: 1 000 000
  String formatWithSpaces() {
    return toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ' ',
    );
  }

  /// Format as price string: "1 000 000 so'm / tun"
  String get formatPrice => '${formatWithSpaces()} so\'m / tun';
}
