import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/user.dart';

class PTSession {
  final int id;
  final int ptContranstId;
  final DateTime sessionDate;
  final DateTime startTime;
  final DateTime endTime;
  final String notes;
  final DateTime createdAt;
  final int rate = 0;
  final int order = 0;
  SessionState state = SessionState.booked;
  final PT? pt;
  final UserData? user;

  PTSession({
    required this.id,
    required this.ptContranstId,
    required this.sessionDate,
    required this.notes,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    this.pt,
    this.user,
  });
}
