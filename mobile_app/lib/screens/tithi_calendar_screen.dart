import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class TithiCalendarScreen extends StatefulWidget {
  const TithiCalendarScreen({super.key});

  @override
  State<TithiCalendarScreen> createState() => _TithiCalendarScreenState();
}

class _TithiCalendarScreenState extends State<TithiCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Events: Date -> List of Events
  final Map<DateTime, List<Map<String, String>>> _events = {
    DateTime(DateTime.now().year, DateTime.now().month, 11): [
      {'title': 'GSTR-1 Due', 'desc': 'Outward supplies for prev month'}
    ],
    DateTime(DateTime.now().year, DateTime.now().month, 20): [
      {'title': 'GSTR-3B Due', 'desc': 'Pay Tax & File Return'}
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    // Check key by normalizing to midnight to match map keys if necessary
    // However, simplified check:
    final events = _events[DateTime(day.year, day.month, day.day)] ?? [];
    return events;
  }

  void _addDeadline() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.t('add_deadline') ?? "Add Deadline"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title (e.g., Rent)"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && _selectedDay != null) {
                final key = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                setState(() {
                  if (_events[key] == null) {
                    _events[key] = [];
                  }
                  _events[key]!.add({
                    'title': titleController.text,
                    'desc': descController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(lang.t('deadlines')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDeadline,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              eventLoader: _getEventsForDay,
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _selectedDay == null 
              ? Center(child: Text("Select a day", style: TextStyle(color: Colors.grey[400])))
              : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: index % 2 == 0 ? const Color(0xFFFFF4F2) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_active_outlined, 
                          color: index % 2 == 0 ? Colors.red : Colors.blue
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (event['desc'] != null && event['desc']!.isNotEmpty)
                              Text(event['desc']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
