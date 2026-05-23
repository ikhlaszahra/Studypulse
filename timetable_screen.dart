import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_widgets.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final _fs = FirestoreService();
  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String _selectedDay = 'Mon';

  void _showAddDialog() {
    final subjectCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    String selectedDay = _selectedDay;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Class',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: StatefulBuilder(builder: (ctx, setSt) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _days
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setSt(() => selectedDay = v!),
                ),
                const SizedBox(height: 12),
                CustomTextField(label: 'Subject', controller: subjectCtrl,
                    prefixIcon: Icons.book_outlined),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Time (e.g. 9:00 AM)',
                  controller: timeCtrl,
                  prefixIcon: Icons.access_time_rounded,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Room / Location',
                  controller: roomCtrl,
                  prefixIcon: Icons.location_on_outlined,
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.timetableColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (subjectCtrl.text.isEmpty || timeCtrl.text.isEmpty) return;
              await _fs.addTimetableEntry({
                'day': selectedDay,
                'subject': subjectCtrl.text,
                'time': timeCtrl.text,
                'room': roomCtrl.text,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗓 Timetable'),
        backgroundColor: AppColors.timetableColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.timetableColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Class', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            color: AppColors.timetableColor.withOpacity(0.08),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: _days.map((day) {
                final selected = _selectedDay == day;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.timetableColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Classes list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fs.getTimetableEntries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snapshot.data?.docs ?? [];
                final filtered = all.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return d['day'] == _selectedDay;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available_rounded,
                            size: 64,
                            color:
                                AppColors.timetableColor.withOpacity(0.3)),
                        const SizedBox(height: 14),
                        Text('No classes on $_selectedDay',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text('Tap + to add a class',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _ClassCard(
                      subject: data['subject'] ?? '',
                      time: data['time'] ?? '',
                      room: data['room'] ?? '',
                      onDelete: () => _fs.deleteTimetableEntry(doc.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.subject,
    required this.time,
    required this.room,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: AppColors.timetableColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.timetableColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(time,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    if (room.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(room,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 22),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
