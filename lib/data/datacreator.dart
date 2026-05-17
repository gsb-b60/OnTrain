import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/ptContrast.dart';

class DataCreator {
  static final _db = DataCreator._internal();
  factory DataCreator() {
    return _db;
  }
  DataCreator._internal();

  //  final _db=openDataBase(
  //   join(await getDatabasespath)
  //  );

  final List<PTContranst> ptContracts = [
    PTContranst(
      id: 1,
      ptid: 1,
      userId: 100,
      startTime: DateTime(2024, 1, 10),
      endTime: DateTime(2024, 3, 10),
      createdAt: DateTime(2024, 1, 5),
    ),
    PTContranst(
      id: 2,
      ptid: 2,
      userId: 101,
      startTime: DateTime(2024, 1, 15),
      endTime: DateTime(2024, 4, 15),
      createdAt: DateTime(2024, 1, 10),
    ),
    PTContranst(
      id: 3,
      ptid: 3,
      userId: 102,
      startTime: DateTime(2024, 2, 1),
      endTime: DateTime(2024, 3, 1),
      createdAt: DateTime(2024, 1, 28),
    ),
    PTContranst(
      id: 4,
      ptid: 1,
      userId: 103,
      startTime: DateTime(2024, 2, 5),
      endTime: DateTime(2024, 5, 5),
      createdAt: DateTime(2024, 2, 1),
    ),
    PTContranst(
      id: 5,
      ptid: 4,
      userId: 104,
      startTime: DateTime(2024, 2, 20),
      endTime: DateTime(2024, 4, 20),
      createdAt: DateTime(2024, 2, 18),
    ),
    PTContranst(
      id: 6,
      ptid: 5,
      userId: 105,
      startTime: DateTime(2024, 3, 1),
      endTime: DateTime(2024, 6, 1),
      createdAt: DateTime(2024, 2, 25),
    ),
    PTContranst(
      id: 7,
      ptid: 2,
      userId: 106,
      startTime: DateTime(2024, 3, 10),
      endTime: DateTime(2024, 5, 10),
      createdAt: DateTime(2024, 3, 5),
    ),
    PTContranst(
      id: 8,
      ptid: 6,
      userId: 107,
      startTime: DateTime(2024, 3, 15),
      endTime: DateTime(2024, 4, 15),
      createdAt: DateTime(2024, 3, 12),
    ),
    PTContranst(
      id: 9,
      ptid: 7,
      userId: 108,
      startTime: DateTime(2024, 4, 1),
      endTime: DateTime(2024, 6, 1),
      createdAt: DateTime(2024, 3, 28),
    ),
    PTContranst(
      id: 10,
      ptid: 8,
      userId: 109,
      startTime: DateTime(2024, 4, 10),
      endTime: DateTime(2024, 5, 10),
      createdAt: DateTime(2024, 4, 5),
    ),
    PTContranst(
      id: 11,
      ptid: 9,
      userId: 110,
      startTime: DateTime(2024, 4, 20),
      endTime: DateTime(2024, 7, 20),
      createdAt: DateTime(2024, 4, 15),
    ),
    PTContranst(
      id: 12,
      ptid: 10,
      userId: 100,
      startTime: DateTime(2024, 5, 1),
      endTime: DateTime(2024, 6, 1),
      createdAt: DateTime(2024, 4, 28),
    ),
    PTContranst(
      id: 13,
      ptid: 1,
      userId: 101,
      startTime: DateTime(2024, 5, 10),
      endTime: DateTime(2024, 8, 10),
      createdAt: DateTime(2024, 5, 5),
    ),
    PTContranst(
      id: 14,
      ptid: 3,
      userId: 102,
      startTime: DateTime(2024, 5, 15),
      endTime: DateTime(2024, 6, 15),
      createdAt: DateTime(2024, 5, 10),
    ),
    PTContranst(
      id: 15,
      ptid: 4,
      userId: 103,
      startTime: DateTime(2024, 6, 1),
      endTime: DateTime(2024, 9, 1),
      createdAt: DateTime(2024, 5, 28),
    ),
  ];
}
