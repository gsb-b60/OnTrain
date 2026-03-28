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


enum SessionState { booked, completed, canceled }






// class PTReview{
//   final int id;
//   final int 
// }
