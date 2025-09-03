import 'package:meesign_core/meesign_core.dart';

enum ShareWarningType { manyShares, unnecessaryShares, atLeastTwoShares }

class ShareWarningData {
  final ShareWarningType warningType;
  final List<String>? warningParams;

  ShareWarningData(this.warningType, [this.warningParams]);
}

// TODO: offer fix application?
ShareWarningData? getSharesWarning({
  required List<Member> members,
  required int shareCount,
  required int threshold,
  required int minThreshold,
  required Protocol protocol,
}) {
  if (shareCount < 2) {
    return ShareWarningData(ShareWarningType.atLeastTwoShares);
  }

  final gcd = members.fold(threshold, (gcd, m) => gcd.gcd(m.shares));
  // fix must satisfy fix * _threshold ~/ gcd >= _minThreshold
  final fix = (minThreshold * gcd / threshold).ceil();
  if (members.length > 1 && fix < gcd) {
    final newThreshold = fix * threshold ~/ gcd;
    final newShares = members.map((m) => fix * m.shares ~/ gcd).join(', ');

    return ShareWarningData(
      ShareWarningType.unnecessaryShares,
      [newThreshold.toString(), newShares],
    );
  }

  if (shareCount > 20 && protocol == Protocol.gg18) {
    return ShareWarningData(ShareWarningType.manyShares);
  }

  return null;
}
