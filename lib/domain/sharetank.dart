/// Z Sharetank: fuel bought ahead at a locked price and drawn down at the
/// pump later. Purchases are used first in, first out, so each fill-up is
/// costed at what its litres actually cost.
library;

class ShareLot {
  final DateTime at;
  final double litres;
  final double cost;
  const ShareLot(this.at, this.litres, this.cost);
  double get pricePerL => litres > 0 ? cost / litres : 0;
}

class ShareDraw {
  final String id;
  final DateTime at;
  final double litres;
  const ShareDraw(this.id, this.at, this.litres);
}

class ShareLedger {
  /// What is left of each purchase, oldest first.
  final List<ShareLot> remaining;
  /// What each fill-up's Sharetank litres cost, by fill-up id.
  final Map<String, double> drawCost;
  /// Fill-ups (by id) with litres no purchase covers, and how many.
  final Map<String, double> drawShort;
  const ShareLedger(this.remaining, this.drawCost, [this.drawShort = const {}]);

  /// Litres drawn that weren't covered by a purchase (history logged before
  /// the purchases were entered).
  double get uncovered => drawShort.values.fold(0.0, (a, b) => a + b);

  double get balance => remaining.fold(0.0, (a, l) => a + l.litres);
  double get value => remaining.fold(0.0, (a, l) => a + l.cost);
  double? get averagePrice => balance > 0 ? value / balance : null;

  /// The cost of drawing [litres] next, at the locked prices left. Litres
  /// beyond the balance are returned in `short`.
  ({double cost, double short}) costOf(double litres) {
    var need = litres, cost = 0.0;
    for (final l in remaining) {
      if (need <= 0) break;
      final take = need < l.litres ? need : l.litres;
      cost += take * l.pricePerL;
      need -= take;
    }
    return (cost: cost, short: need > 1e-9 ? need : 0);
  }

  /// Runs purchases and draws in date order (a purchase on the same day as a
  /// draw counts first).
  static ShareLedger run(List<ShareLot> lots, List<ShareDraw> draws) {
    final queue = [...lots.where((l) => l.litres > 0)]..sort((a, b) => a.at.compareTo(b.at));
    final rem = <ShareLot>[];
    final cost = <String, double>{};
    final short = <String, double>{};
    var li = 0;
    final sortedDraws = [...draws.where((d) => d.litres > 0)]..sort((a, b) => a.at.compareTo(b.at));
    for (final d in sortedDraws) {
      final day = DateTime(d.at.year, d.at.month, d.at.day + 1);
      while (li < queue.length && queue[li].at.isBefore(day)) {
        rem.add(queue[li++]);
      }
      var need = d.litres, c = 0.0;
      while (need > 1e-9 && rem.isNotEmpty) {
        final l = rem.first;
        if (l.litres <= need + 1e-9) {
          c += l.cost;
          need -= l.litres;
          rem.removeAt(0);
        } else {
          final p = l.pricePerL;
          c += need * p;
          rem[0] = ShareLot(l.at, l.litres - need, l.cost - need * p);
          need = 0;
        }
      }
      if (need > 1e-9) short[d.id] = need;
      cost[d.id] = c;
    }
    rem.addAll(queue.skip(li));
    return ShareLedger(rem, cost, short);
  }
}

/// Cost of a fill-up that drew [shareLitres] from Sharetank at [shareCost],
/// with the rest of [litres] paid at [pumpPrice] per litre.
double sharetankFillCost({required double litres, required double shareLitres, required double shareCost, required double? pumpPrice}) {
  final rest = litres - shareLitres;
  return shareCost + (rest > 0 && pumpPrice != null ? rest * pumpPrice : 0);
}
