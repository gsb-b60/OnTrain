import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/UI/favoriteBtn.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/controller/calendarController.dart';
import 'package:ontrain/controller/ptController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/ptSession.dart';
import 'package:ontrain/data/object/time_slot.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.pt});
  final PT pt;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Bookingcontroller>().fetchBookingsForPT(widget.pt.id);
      context.read<Bookingcontroller>().fetchServicePackages(widget.pt.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 40),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppGradients.brand),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.light),
                    ),
                    Expanded(
                      child: Container(
                        height: 33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.greyAqua,
                        ),
                        child: Center(
                          child: Text(
                            widget.pt.name,
                            style: TextStyle(
                              color: AppColors.aquaTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    favoriteIconBtn(pt: widget.pt),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<Bookingcontroller>(
              builder: (context, bookingController, child) {
                return TableCalendarBooking(
                  pt: widget.pt,
                  ptBookings: bookingController.ptBookings,
                  slotsForDate: bookingController.slotsForDate,
                  onDateSelected: (date) {
                    context
                        .read<Bookingcontroller>()
                        .fetchAvailableSlotsForPT(ptId: widget.pt.id, date: date);
                  },
                  onSlotTap: (slot) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm booking'),
                        content: Text(
                          'Book ${DateFormat('HH:mm').format(slot.startAt)} - '
                          '${DateFormat('HH:mm').format(slot.endAt)} with '
                          '${slot.servicePackage?.name ?? 'this package'} '
                          '(${slot.servicePackage != null ? (slot.servicePackage!.priceCents / 100).toStringAsFixed(0) : '?'} VND) '
                          'on ${DateFormat('dd/MM/yyyy').format(slot.startAt)}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !mounted) return;
                    final ok = await context
                        .read<Bookingcontroller>()
                        .createBookingFromSlot(slot.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Session booked for ${DateFormat('HH:mm').format(slot.startAt)}'
                              : 'Booking failed: ${context.read<Bookingcontroller>().error ?? 'unknown error'}',
                        ),
                      ),
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

class TableCalendarBooking extends StatefulWidget {
  const TableCalendarBooking({
    super.key,
    required this.pt,
    required this.ptBookings,
    required this.slotsForDate,
    required this.onDateSelected,
    required this.onSlotTap,
  });
  final PT pt;
  final List<Booking> ptBookings;
  final List<TimeSlot> slotsForDate;
  final void Function(DateTime) onDateSelected;
  final void Function(TimeSlot) onSlotTap;

  @override
  State<TableCalendarBooking> createState() => _TableCalendarBookingState();
}

class _TableCalendarBookingState extends State<TableCalendarBooking> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  bool isSlotBooked(TimeSlot slot) {
    return widget.ptBookings.any((session) {
      final start = session.startAt;
      final end = session.endAt;

      if (!isSameDay(start, _selectedDay)) {
        return false;
      }

      return slot.startAt.hour >= start.hour && slot.startAt.hour < end.hour;
    });
  }

  @override
  void initState() {
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final groupedSlots = <String, List<TimeSlot>>{};
    for (final slot in widget.slotsForDate) {
      final pkgName = slot.servicePackage?.name ?? 'General';
      groupedSlots.putIfAbsent(pkgName, () => []).add(slot);
    }

    return Column(
      children: [
        TableCalendar(
          eventLoader: (day) {
            return widget.ptBookings
                .where((session) => isSameDay(session.startAt, day))
                .toList();
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          weekNumbersVisible: true,
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: AppColors.aquaTeal,
              shape: BoxShape.circle,
            ),
            markerSize: 6,
            todayDecoration: BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.aquaTeal,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: AppColors.black),
            weekendTextStyle: TextStyle(color: AppColors.aquaTeal),
            outsideTextStyle: TextStyle(color: Colors.grey),
          ),
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            formatButtonVisible: true,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: AppColors.aquaTeal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: AppColors.aquaTeal,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: AppColors.aquaTeal,
            ),
            decoration: BoxDecoration(),
          ),
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          headerVisible: true,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected(selectedDay);
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        if (groupedSlots.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.aquaTeal.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No available slots for this day',
                    style: TextStyle(
                      color: AppColors.gray700,
                      fontSize: AppSizes.medium,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: groupedSlots.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: AppColors.aquaTeal,
                          fontSize: AppSizes.medium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((slot) {
                        final booked = isSlotBooked(slot);
                        return BookingBlock(
                          slot: slot,
                          isBooked: booked,
                          onTap: booked ? null : () => widget.onSlotTap(slot),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class BookingBlock extends StatelessWidget {
  const BookingBlock({
    super.key,
    required this.slot,
    required this.isBooked,
    this.onTap,
  });
  final TimeSlot slot;
  final bool isBooked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pkg = slot.servicePackage;
    final priceText = pkg != null
        ? '${(pkg.priceCents / 100).toStringAsFixed(0)} VND'
        : '';
    final durationText = '${slot.durationMinutes} min';

    return Material(
      child: InkWell(
        onTap: isBooked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isBooked ? AppColors.light : AppColors.aquaTeal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBooked ? AppColors.greyAqua : AppColors.aquaTeal,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('HH:mm').format(slot.startAt)} - ${DateFormat('HH:mm').format(slot.endAt)}',
                style: TextStyle(
                  color: isBooked ? AppColors.aquaTeal : AppColors.light,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (priceText.isNotEmpty)
                Text(
                  priceText,
                  style: TextStyle(
                    color: isBooked ? AppColors.gray700 : AppColors.light,
                    fontSize: 12,
                  ),
                ),
              Text(
                durationText,
                style: TextStyle(
                  color: isBooked ? AppColors.gray500 : AppColors.light.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
              if (isBooked)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Booked',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}