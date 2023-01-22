extension StringUtils on String {
  String capitalizeFirst() {
    if (length > 1) {
      return "${this[0].toUpperCase()}${substring(1)}";
    } else {
      return toUpperCase();
    }
  }
}
