import 'package:ontrain/data/object/pt.dart';

class PTSpecialties{
  final int id;
  final int PTID;
  final String title;
  final String Notes;
  final PT? pt;

  PTSpecialties({
    required this.id,
    required this.PTID,
    required this.title,
    required this.Notes,
    this.pt,
  });
}