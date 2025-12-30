import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/language_provider.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hover_scale_card.dart';
import '../widgets/glass_icon.dart';

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
              decoration:
                  const InputDecoration(labelText: "Title (e.g., Rent)"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && _selectedDay != null) {
                final key = DateTime(
                    _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                HistoryService().addDeadline(titleController.text, key);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDeadline,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          HoverScaleCard(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                // Shadows handled by HoverScaleCard
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
                  if (_calendarFormat != format)
                    setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  weekendTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.redAccent),

                  // Custom Today Decoration (Soft Glow)
                  todayDecoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]),
                  todayTextStyle: const TextStyle(
                      color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),

                  // Custom Selected Decoration
                  selectedDecoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ]),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.take(3).map((_) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppTheme
                                    .warningOrange, // Alert color for deadlines
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text("Select a day",
                        style: TextStyle(color: Colors.grey[400])))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return HoverScaleCard(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              GlassIcon(
                                icon: Icons.notifications_active_outlined,
                                color:
                                    index % 2 == 0 ? Colors.red : Colors.blue,
                                size: 48,
                                iconSize: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event['title'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    if (event['desc'] != null &&
                                        event['desc']!.isNotEmpty)
                                      Text(event['desc']!,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
