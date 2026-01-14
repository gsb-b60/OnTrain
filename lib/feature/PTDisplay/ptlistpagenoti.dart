import 'package:flutter/material.dart';
import 'package:ontrain/data/object/pt.dart';

class PTListNoti extends ChangeNotifier {
  List<PTSession> sessions = [
    PTSession(
      id: 1,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 5),
      startTime: DateTime(2026, 1, 5, 7, 0),
      endTime: DateTime(2026, 1, 5, 9, 0),
      notes: 'note for session 1',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 2,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 6, 18, 0),
      endTime: DateTime(2026, 1, 6, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 3,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 8, 18, 0),
      endTime: DateTime(2026, 1, 8, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 4,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 8, 9, 0),
      endTime: DateTime(2026, 1, 8, 11, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 5,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 9, 18, 0),
      endTime: DateTime(2026, 1, 9, 20, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 6,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 10, 18, 0),
      endTime: DateTime(2026, 1, 10, 20, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 7,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 12, 18, 0),
      endTime: DateTime(2026, 1, 12, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 8,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 13, 18, 0),
      endTime: DateTime(2026, 1, 13, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
  ];
  List<PTSession> GetInComingList()
  {
    return sessions.where((s)=>s.state==SessionState.booked).toList();
  }
  List<PTSession> GetCompleteList()
  {
    return sessions.where((s)=>s.state==SessionState.completed).toList();
  }
  List<PTSession> GetCancelList()
  {
    return sessions.where((s)=>s.state==SessionState.canceled).toList();
  }
}
