extension StringUtils on String {
  String capitalizeFirst() {
    if (length <= 1) {
      return toUpperCase();
    }
    return replaceRange(0, 1, this[0].toUpperCase()).replaceAllMapped(
        RegExp(r'[\s-][a-z]'), (match) => match.group(0)!.toUpperCase());
  }
}
