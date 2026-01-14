enum PTState { unactive, active, accepted }

class PT {
  final int id;
  final String name;
  final String Pnum;
  final String email;
  final String address;
  final DateTime createdAt;
  final PTState state;

  PT({
    required this.name,
    required this.Pnum,
    required this.email,
    required this.address,
    required this.createdAt,
    required this.id,
    required this.state,
  });
}
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

class PTContranst {
  final int id;
  final int ptid;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  PTContranst({
    required this.id,
    required this.ptid,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });
}

enum SessionState { booked, completed, canceled }

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
  final User? user;

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

class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });
}

// class PTReview{
//   final int id;
//   final int 
// }
