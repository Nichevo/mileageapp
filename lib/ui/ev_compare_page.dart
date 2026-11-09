import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/ev_costs.dart';
import 'format.dart';

/// "Would an EV pay off?": your last year of driving, costed as an EV.
class EvComparePage extends StatefulWidget {
  const EvComparePage({super.key});
  @override
  State<EvComparePage> createState() => _EvComparePageState();
}

class _EvComparePageState extends State<EvComparePage> {
  double _kwhPer100 = 17;
  double _homeShare = 0.85;
  double _publicPerKwh = 0.75;
  double _rucPer1000 = rucEvPer1000;
  final _extra = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final homePerKwh = scope.settings.homeRateCents / 100;
    return Scaffold(
      appBar: AppBar(title: const Text('Would an EV pay off?')),
      body: StreamBuilder<List<EnergyEvent>>(
        stream: scope.repo.watchEvents(scope.settings.activeVehicleId!),
        builder: (context, snap) {
          final rows = Repository.toFuelRows(snap.data ?? const []);
          final d = recentDriving(rows, now: DateTime.now());
          if (d == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('This needs a few fill-ups on the current vehicle, so it can see how far you drive and what fuel costs you.'),
            );
          }
          final perYear = 365 / d.days;
          final km = d.km * perYear, fuel = d.cost * perYear;
          final ev = evEstimate(km: km, kwhPer100: _kwhPer100, homeShare: _homeShare, homePerKwh: homePerKwh, publicPerKwh: _publicPerKwh, rucPer1000: _rucPer1000);
          final saving = fuel - ev.total;
          final extra = double.tryParse(_extra.text.replaceAll(RegExp(r'[\$,]'), ''));
          final payback = extra != null && extra > 0 && saving > 0 ? extra / saving : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Your driving: ${fmtKm(km)} km a year${d.days < 360 ? ' (from ${d.days} days of fill-ups)' : ''}, '
                'costing ${fmtMoney0(fuel)} in fuel.',
                style: t.bodyLarge,
              ),
              const SizedBox(height: 12),
              Card(
                color: saving > 0 ? cs.primaryContainer : cs.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _row('Fuel now', fmtMoney0(fuel), t),
                    _row('EV charging', fmtMoney0(ev.energyCost), t),
                    _row('Road user charges', fmtMoney0(ev.ruc), t),
                    const Divider(),
                    _row('EV total', fmtMoney0(ev.total), t),
                    const SizedBox(height: 8),
                    Text(
                      saving > 0 ? 'An EV would save about ${fmtMoney0(saving)} a year' : 'An EV would cost about ${fmtMoney0(-saving)} a year more',
                      style: t.titleMedium,
                    ),
                    Text('${fmtMoney0(saving * 5)} over 5 years, at today\'s prices', style: t.bodySmall),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _extra,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Extra the EV costs to buy \$ (optional)',
                  helperText: payback == null ? 'After trading in your car' : 'Pays back in about ${payback.toStringAsFixed(1)} years',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Text('Assumptions', style: t.titleSmall),
              _slider('EV energy use', '${_kwhPer100.toStringAsFixed(0)} kWh/100 km', _kwhPer100, 12, 25, 13, (v) => _kwhPer100 = v,
                  help: 'Small EVs use about 14, SUVs and utes 20 or more'),
              _slider('Charged at home', '${(_homeShare * 100).round()}%', _homeShare, 0, 1, 20, (v) => _homeShare = v,
                  help: 'At your home rate of ${scope.settings.homeRateCents.toStringAsFixed(0)}c/kWh'),
              _slider('Public charging', '\$${_publicPerKwh.toStringAsFixed(2)}/kWh', _publicPerKwh, 0.3, 1.2, 18, (v) => _publicPerKwh = v,
                  help: 'Fast DC chargers are usually 70 to 80c'),
              _slider('Road user charges', '\$${_rucPer1000.toStringAsFixed(0)} per 1,000 km', _rucPer1000, 0, 120, 24, (v) => _rucPer1000 = v,
                  help: 'Light EVs pay \$76 (plug-in hybrids \$38) since April 2024. Check NZTA for changes.'),
              const SizedBox(height: 8),
              Text(
                'Leaves out the purchase price, insurance, servicing (usually less for an EV), tyres and battery wear.',
                style: t.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, TextTheme t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Expanded(child: Text(label)), Text(value, style: t.titleSmall)]),
      );

  Widget _slider(String label, String value, double v, double min, double max, int divisions, void Function(double) set, {String? help}) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Row(children: [Expanded(child: Text(label)), Text(value, style: t.titleSmall)]),
      Slider(value: v.clamp(min, max), min: min, max: max, divisions: divisions, onChanged: (x) => setState(() => set(x))),
      if (help != null) Text(help, style: t.bodySmall),
    ]);
  }

  @override
  void dispose() {
    _extra.dispose();
    super.dispose();
  }
}
