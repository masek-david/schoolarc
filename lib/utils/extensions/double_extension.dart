extension BetterDouble on double {
  /// Flips progress values between 0 to 1
  /// 
  /// For example: 0 -> 1; 1 -> 0; 0.3 -> 0.7, ...
  double get flipProgress {
    return (this - 1) * -1;
  }
}
