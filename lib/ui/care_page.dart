import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../domain/care.dart';
import 'format.dart';
import 'insurance_page.dart';
import 'service_page.dart';
import 'tyres_page.dart';

/// One thing that needs attention soon.
class CareAlert {
  final IconData icon;
  final String title, detail;
  final DueState state;
  final DateTime? when;
  final WidgetBuilder open;
  const CareAlert(this.icon, this.title, this.detail, this.state, this.when, this.open);
}

/// Gathers what's due: schedule items, insurance renewal, tyre check.
List<CareAlert> careAlerts({
  required List<ServiceItem> items,
  required List<InsurancePolicy> policies,
  required List<TyreCheck> checks,
  required List<EnergyEvent> events,
  bool includeOk = false,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final driving = drivingNow(events);
  final out = <CareAlert>[];
  for (final i in items) {
    final d = dueOf(i, driving);
    if (d.state == DueState.unknown) continue;
    if (!includeOk && d.state == DueState.ok) continue;
    out.add(CareAlert(kindIcon(i.kind), i.name, dueText(d), d.state, d.expectedAt, (_) => const ServicePage()));
  }
  final p = policies.firstOrNull;
  if (p?.renewAt != null) {
    final days = p!.renewAt!.difference(today).inDays;
    final state = days < 0 ? DueState.overdue : (days <= 30 ? DueState.soon : DueState.ok);
    if (includeOk || state != DueState.ok) {
      out.add(CareAlert(Icons.shield_outlined, 'Insurance renewal', '${p.insurer} renews ${fmtDate(p.renewAt!)}${days >= 0 ? ' · in $days days' : ''}', state, p.renewAt,
          (_) => const InsurancePage()));
    }
  }
  if (checks.isNotEmpty) {
    final days = today.difference(checks.first.at).inDays;
    if (days > tyreCheckEveryDays) {
      out.add(CareAlert(Icons.tire_repair, 'Tyre pressures', 'Last checked $days days ago', DueState.soon, checks.first.at.add(const Duration(days: tyreCheckEveryDays)),
          (_) => const TyresPage()));
    }
  }
  out.sort((a, b) {
    final s = a.state.index.compareTo(b.state.index);
    if (s != 0) return s;
    if (a.when == null || b.when == null) return a.when == null ? 1 : -1;
    return a.when!.compareTo(b.when!);
  });
  return out;
}

/// Streams everything [careAlerts] needs and hands it to [builder].
class CareAlertsBuilder extends StatelessWidget {
  final bool includeOk;
  final Widget Function(BuildContext, List<CareAlert>?) builder;
  const CareAlertsBuilder({super.key, this.includeOk = false, required this.builder});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return StreamBuilder<List<ServiceItem>>(
      stream: scope.repo.watchServiceItems(vid),
      builder: (context, items) => StreamBuilder<List<InsurancePolicy>>(
        stream: scope.repo.watchPolicies(vid),
        builder: (context, policies) => StreamBuilder<List<TyreCheck>>(
          stream: scope.repo.watchTyreChecks(vid),
          builder: (context, checks) => StreamBuilder<List<EnergyEvent>>(
            stream: scope.repo.watchEvents(vid, kind: null),
            builder: (context, events) {
              if (!items.hasData || !policies.hasData || !checks.hasData || !events.hasData) return builder(context, null);
              return builder(
                context,
                careAlerts(items: items.data!, policies: policies.data!, checks: checks.data!, events: events.data!, includeOk: includeOk),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget alertTile(BuildContext context, CareAlert a) => ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(a.icon, color: dueColor(context, a.state)),
      title: Text(a.title),
      subtitle: Text(a.detail),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: a.open)),
    );

/// Home screen card listing what's due. Hidden when nothing is.
class ComingUpCard extends StatelessWidget {
  const ComingUpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CareAlertsBuilder(builder: (context, alerts) {
      if (alerts == null || alerts.isEmpty) return const SizedBox.shrink();
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coming up', style: Theme.of(context).textTheme.titleSmall),
              for (final a in alerts.take(4)) alertTile(context, a),
              if (alerts.length > 4)
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CarCarePage())),
                  child: Text('${alerts.length - 4} more'),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class CarCarePage extends StatelessWidget {
  const CarCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Car care')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.build_outlined),
                title: const Text('Service schedule'),
                subtitle: const Text('WOF, rego, oil changes and other regular jobs'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServicePage())),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Insurance'),
                subtitle: const Text('Insured value, premium, excess and renewal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsurancePage())),
              ),
              ListTile(
                leading: const Icon(Icons.tire_repair),
                title: const Text('Tyres'),
                subtitle: const Text('Pressure checks and tyre sets'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TyresPage())),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          CareAlertsBuilder(
            includeOk: true,
            builder: (context, alerts) {
              if (alerts == null) return const SizedBox.shrink();
              if (alerts.isEmpty) {
                return Text('Nothing scheduled yet. Open the service schedule to add the usual jobs.', style: t.bodyMedium);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next up', style: t.titleSmall),
                  for (final a in alerts) alertTile(context, a),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
