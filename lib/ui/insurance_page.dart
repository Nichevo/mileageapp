import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import 'format.dart';

const coverLabels = <String, String>{
  'comprehensive': 'Comprehensive',
  'third_party_fire_theft': 'Third party, fire and theft',
  'third_party': 'Third party',
};

/// Yearly premium, whichever way it's paid.
double? yearlyPremium(InsurancePolicy p) =>
    p.premium == null ? null : (p.premiumPeriod == 'month' ? p.premium! * 12 : p.premium!);

class InsurancePage extends StatelessWidget {
  const InsurancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    return StreamBuilder<List<InsurancePolicy>>(
      stream: scope.repo.watchPolicies(scope.settings.activeVehicleId!),
      builder: (context, snap) {
        final list = snap.data ?? const <InsurancePolicy>[];
        final current = list.isEmpty ? null : list.first;
        return Scaffold(
          appBar: AppBar(title: const Text('Insurance')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PolicyForm(renewFrom: current))),
            icon: const Icon(Icons.add),
            label: Text(current == null ? 'Add policy' : 'Renewal'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              if (snap.hasData && current == null)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Add your current policy to keep the insured value, premium, excess and renewal date in one place. At each renewal, tap Renewal so the history of insured value builds up.'),
                ),
              if (current != null) _currentCard(context, current),
              if (list.where((p) => p.insuredValue != null).length >= 2) ...[
                const SizedBox(height: 12),
                Text('Insured value over time', style: t.titleSmall),
                const SizedBox(height: 8),
                SizedBox(height: 160, child: _valueChart(context, list)),
              ],
              if (list.length > 1) ...[
                const SizedBox(height: 16),
                Text('History', style: t.titleSmall),
                for (final p in list.skip(1))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${p.insurer} · ${fmtDate(p.startAt)}'),
                    subtitle: Text([
                      if (p.insuredValue != null) 'insured ${fmtMoney0(p.insuredValue!)}',
                      if (yearlyPremium(p) != null) '${fmtMoney0(yearlyPremium(p)!)} a year',
                      if (p.excess != null) 'excess ${fmtMoney0(p.excess!)}',
                    ].join(' · ')),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PolicyForm(policy: p))),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _currentCard(BuildContext context, InsurancePolicy p) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final days = p.renewAt?.difference(DateTime(today.year, today.month, today.day)).inDays;
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(width: 130, child: Text(label, style: t.bodySmall)),
            Expanded(child: Text(value, style: t.bodyLarge)),
          ]),
        );
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PolicyForm(policy: p))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.insurer, style: t.titleLarge),
              Text(coverLabels[p.cover] ?? p.cover, style: t.bodyMedium),
              const SizedBox(height: 12),
              if (p.insuredValue != null)
                row('Insured for', '${fmtMoney0(p.insuredValue!)}${p.valueType == null ? '' : ' (${p.valueType} value)'}'),
              if (p.premium != null)
                row('Premium', '${fmtMoney(p.premium!)} a ${p.premiumPeriod}${p.premiumPeriod == 'month' ? ' (${fmtMoney0(yearlyPremium(p)!)} a year)' : ''}'),
              if (p.excess != null) row('Excess', fmtMoney0(p.excess!)),
              if (p.policyNumber != null) row('Policy number', p.policyNumber!),
              if (p.renewAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(children: [
                    SizedBox(width: 130, child: Text('Renews', style: t.bodySmall)),
                    Text(fmtDate(p.renewAt!), style: t.bodyLarge),
                    const SizedBox(width: 8),
                    if (days != null)
                      Text(
                        days < 0 ? '${-days} days ago' : 'in $days days',
                        style: t.bodyMedium?.copyWith(color: days <= 30 ? (days < 0 ? cs.error : Colors.orange.shade700) : cs.outline),
                      ),
                  ]),
                ),
              if (p.notes != null) ...[const SizedBox(height: 8), Text(p.notes!, style: t.bodySmall)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueChart(BuildContext context, List<InsurancePolicy> list) {
    final cs = Theme.of(context).colorScheme;
    final pts = list.where((p) => p.insuredValue != null).toList().reversed.toList();
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 44, getTitlesWidget: (v, m) => Text('\$${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10))),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (v, m) {
              final i = v.round();
              if (i < 0 || i >= pts.length || v != i.toDouble()) return const SizedBox();
              return Text("'${pts[i].startAt.year % 100}", style: const TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => [for (final s in spots) LineTooltipItem(fmtMoney0(s.y), const TextStyle(color: Colors.white))],
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].insuredValue!)],
          color: cs.primary,
          barWidth: 2.5,
        ),
      ],
    ));
  }
}

class PolicyForm extends StatefulWidget {
  final InsurancePolicy? policy; // edit
  final InsurancePolicy? renewFrom; // new period, pre-filled from the last one
  const PolicyForm({super.key, this.policy, this.renewFrom});
  @override
  State<PolicyForm> createState() => _PolicyFormState();
}

class _PolicyFormState extends State<PolicyForm> {
  late final InsurancePolicy? _base = widget.policy ?? widget.renewFrom;
  late final _insurer = TextEditingController(text: _base?.insurer ?? '');
  late final _number = TextEditingController(text: _base?.policyNumber ?? '');
  late final _value = TextEditingController(text: _base?.insuredValue?.round().toString() ?? '');
  late final _premium = TextEditingController(text: widget.policy?.premium?.toString() ?? '');
  late final _excess = TextEditingController(text: _base?.excess?.round().toString() ?? '');
  late final _notes = TextEditingController(text: widget.policy?.notes ?? '');
  late String _cover = _base?.cover ?? 'comprehensive';
  late String? _valueType = _base?.valueType ?? 'agreed';
  late String _period = _base?.premiumPeriod ?? 'year';
  late DateTime _start = widget.policy?.startAt ?? widget.renewFrom?.renewAt ?? DateTime.now();
  late DateTime? _renew = widget.policy?.renewAt ?? DateTime(_start.year + 1, _start.month, _start.day);

  double? _num(TextEditingController c) => double.tryParse(c.text.replaceAll(r'$', '').replaceAll(',', '').trim());

  Future<void> _save() async {
    if (_insurer.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add the insurer\'s name')));
      return;
    }
    final scope = AppScope.of(context);
    await scope.repo.upsertPolicy(InsurancePoliciesCompanion.insert(
      id: widget.policy?.id ?? newId(),
      vehicleId: scope.settings.activeVehicleId!,
      insurer: _insurer.text.trim(),
      cover: Value(_cover),
      policyNumber: Value(_number.text.trim().isEmpty ? null : _number.text.trim()),
      insuredValue: Value(_num(_value)),
      valueType: Value(_valueType),
      premium: Value(_num(_premium)),
      premiumPeriod: Value(_period),
      excess: Value(_num(_excess)),
      startAt: _start,
      renewAt: Value(_renew),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await AppScope.of(context).repo.deletePolicy(widget.policy!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<DateTime?> _pick(DateTime initial) =>
      showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1990), lastDate: DateTime(2100));

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.policy != null ? 'Edit policy' : (widget.renewFrom != null ? 'Renewal' : 'Insurance policy')),
        actions: [if (widget.policy != null) IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _insurer, decoration: const InputDecoration(labelText: 'Insurer', border: border)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _cover,
            decoration: const InputDecoration(labelText: 'Cover', border: border),
            items: [for (final e in coverLabels.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() => _cover = v ?? 'comprehensive'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _value, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Insured value \$', border: border))),
            const SizedBox(width: 12),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [ButtonSegment(value: 'agreed', label: Text('Agreed')), ButtonSegment(value: 'market', label: Text('Market'))],
              selected: {_valueType ?? 'agreed'},
              onSelectionChanged: (s) => setState(() => _valueType = s.first),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _premium, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Premium \$', border: border))),
            const SizedBox(width: 12),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [ButtonSegment(value: 'year', label: Text('/ year')), ButtonSegment(value: 'month', label: Text('/ month'))],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _excess, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Excess \$', border: border)),
          const SizedBox(height: 12),
          TextField(controller: _number, decoration: const InputDecoration(labelText: 'Policy number (stays on this phone)', border: border)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text('Starts ${fmtDate(_start)}'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await _pick(_start);
              if (d != null) setState(() => _start = d);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_repeat),
            title: Text(_renew == null ? 'Renewal date: not set' : 'Renews ${fmtDate(_renew!)}'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await _pick(_renew ?? _start);
              if (d != null) setState(() => _renew = d);
            },
          ),
          TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', border: border)),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
