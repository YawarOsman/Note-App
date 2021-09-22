class Note{
  String noteID;
  String noteTitle;
  String noteContent;
  DateTime createDateTime;
  DateTime? latestEditDateTime;

  Note({required this.noteID, required this.noteTitle,required this.noteContent, required this.createDateTime,  this.latestEditDateTime});
}