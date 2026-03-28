import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/ptContrast.dart';

class PTReview {
  final int id;
  final int ptSessionId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final PT? pt;
  final PTContranst? con; 
  PTReview({
    required this.id,
    required this.ptSessionId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.pt,
    this.con,
  });
}