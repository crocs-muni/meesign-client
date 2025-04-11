import 'package:meesign_core/meesign_core.dart';

// TODO: offer fix application?
({String title, String text})? getSharesWarning({
  required List<Member> members,
  required int shareCount,
  required int threshold,
  required int minThreshold,
  required Protocol protocol,
}) {
  final gcd = members.fold(threshold, (gcd, m) => gcd.gcd(m.shares));
  // fix must satisfy fix * _threshold ~/ gcd >= _minThreshold
  final fix = (minThreshold * gcd / threshold).ceil();
  if (members.length > 1 && fix < gcd) {
    final newThreshold = fix * threshold ~/ gcd;
    final newShares = members.map((m) => fix * m.shares ~/ gcd).join(', ');
    return (
      title: 'Unnecessarily many shares',
      text: 'You can achieve the same voting rights distribution by setting '
          'threshold to $newThreshold and shares to ($newShares). '
          'This may improve performance.',
    );
  }

  if (shareCount > 20 && protocol == Protocol.gg18) {
    return (
      title: 'Many shares',
      text: 'You may experience degraded performance with certain protocols '
          'if the share count is too high. Consider removing some members or '
          'lowering the number of shares they receive if this poses an issue.',
    );
  }

  return null;
}
