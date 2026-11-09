import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../domain/places.dart';
import 'trip_map.dart';

/// Asks for a place name. Returns null on cancel.
Future<String?> askPlaceName(BuildContext context, {String initial = ''}) async {
  final ctl = TextEditingController(text: initial);
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Place name'),
      content: TextField(
        controller: ctl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'e.g. Gym, Mum\'s, Beach', border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
      ],
    ),
  );
  return ok == true && ctl.text.trim().isNotEmpty ? ctl.text.trim() : null;
}

/// Your named places: rename or remove them.
class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});
  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final places = settings.places;
    return Scaffold(
      appBar: AppBar(title: const Text('Places')),
      body: places.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No places yet. Once a few trips start or end at the same spot, the Trips page asks you to name it.'),
            )
          : ListView(children: [
              for (final p in places)
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(p.name),
                  subtitle: Text('Within ${placeRadiusM.round()} m of the spot on the map'),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (c) => SafeArea(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(height: 200, child: TripMap(route: [LatLng(p.lat, p.lon)], follow: true)),
                        ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: const Text('Rename'),
                          onTap: () async {
                            Navigator.pop(c);
                            final n = await askPlaceName(context, initial: p.name);
                            if (n == null) return;
                            await settings.setPlaces([for (final x in settings.places) x.id == p.id ? Place(p.id, n, p.lat, p.lon) : x]);
                            setState(() {});
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Remove'),
                          onTap: () async {
                            Navigator.pop(c);
                            await settings.setPlaces([for (final x in settings.places) if (x.id != p.id) x]);
                            setState(() {});
                          },
                        ),
                      ]),
                    ),
                  ),
                ),
            ]),
    );
  }
}
