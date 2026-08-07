import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/section_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.postType), icon: const Icon(Icons.add))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
        CalendarDatePicker(initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 730)), onDateChanged: (_) {}),
        const SizedBox(height: 14),
        Text("Aujourd'hui", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SectionCard(onTap: () => Navigator.pushNamed(context, AppRoutes.calendarDetail), child: const ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text('10')), title: Text('5 astuces productivité'), subtitle: Text('Instagram · 10:00'), trailing: Chip(label: Text('Programmé')))),
        const SizedBox(height: 10),
        SectionCard(onTap: () => Navigator.pushNamed(context, AppRoutes.calendarDetail), child: const ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text('14')), title: Text('Coulisses du podcast'), subtitle: Text('TikTok · 14:30'), trailing: Chip(label: Text('À valider')))),
      ]),
    );
  }
}
