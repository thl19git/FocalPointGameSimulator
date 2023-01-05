public int clamp(int low, int high, int value) {
  return min(high, max(value, low));
}
