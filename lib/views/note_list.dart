import 'package:animation/models/api_response.dart';
import 'package:animation/service/notes_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:animation/models/note_for_listing.dart';
import 'package:animation/views/note_delete.dart';
import 'note_delete.dart';
import 'note_modify.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteList extends StatefulWidget {

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final service=NotesService();bool isLoading=false;
  List<NoteForListing> notes=[];  List<NoteForListing> searchNote=[];
  APIResponse<List<NoteForListing>>? apiResponse;
  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void initState() {
    getNotes();
    super.initState();
  }

  getNotes()async{
    setState(() { isLoading=true; });
    apiResponse=await service.getNotesList();
     for(int i=0;i<apiResponse!.data!.length;i++){
       notes.add(
           NoteForListing(
               noteID: apiResponse!.data![i].noteID,
               noteTitle: apiResponse!.data![i].noteTitle,
               createDateTime: apiResponse!.data![i].createDateTime,
               latestEditDateTime: apiResponse!.data![i].latestEditDateTime
           ));
       searchNote.add(notes[i]);
     }
    setState(() { isLoading=false; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (_){
            if(isLoading){
              return Center(child: CircularProgressIndicator());
            }
            if(apiResponse!.error){
              return Center(child: Text(apiResponse!.errorMessage??'errrrr'));
            }

            return notes.length>=1?Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(alignment: Alignment.center,
                    width: double.infinity,height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: TextField(
                      onChanged: (value)async{
                        if(value==''){
                         searchNote=[];
                         notes.forEach((element) {
                           searchNote.add(element);
                         });

                        }else{
                          searchNote=[];
                          notes.forEach((element) {
                            if(element.noteTitle.contains(value)){
                              searchNote.add(element);
                            }
                          });

                        }
                        setState(() { });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search',hintStyle: TextStyle(fontSize: 17),
                        prefixIcon: Icon(Icons.search),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchNote.length,
                    itemBuilder: (_, index) {
                      return Dismissible(
                        key: Key(searchNote[index].noteID),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {   },

                        confirmDismiss: (direction) async {
                          final result = await showDialog(
                              context: context, builder: (_) => NoteDelete());

                          if (result) {
                            final deleteResult = await service.deleteNote(searchNote[index].noteID);
                            apiResponse=await service.getNotesList();setState(() { });
                            var message;
                            if (deleteResult != null && deleteResult.data == true) {
                              message = 'note was deleted successfully';
                              notes.removeAt(index);  searchNote.removeAt(index);
                            } else {
                              message = deleteResult.errorMessage ?? 'An error occured';
                            }
                            Flushbar(

                              backgroundColor: Colors.white30,
                              message:  "$message",messageSize: 17,
                              duration:  Duration(seconds: 2),
                            ).show(context);

                            return deleteResult.data ?? false;
                          }
                          return result;
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.cyan
                          ),
                          padding: EdgeInsets.only(left: 16),
                          child: Align(
                            child: Icon(Icons.delete, color: Colors.white,size: 30,),
                            alignment: Alignment.centerLeft,),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(6),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(width: 1,color: Colors.white30)
                            ),
                            child: ListTile(
                              title: Text(
                                searchNote[index].noteTitle,
                                style: GoogleFonts.openSans(fontSize: 21),
                              ),
                              subtitle: Text(
                                'last edited on: ${formatDateTime(searchNote[index].latestEditDateTime??
                                    searchNote[index].createDateTime)}',
                                style: TextStyle(fontSize: 15),),
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => NoteModify(noteID: searchNote[index].noteID)))
                                .then((value) async{
                                  apiResponse=await service.getNotesList();
                                    notes.replaceRange(index, index+1, [
                                      NoteForListing(
                                          noteID: apiResponse!.data![index].noteID,
                                          noteTitle: apiResponse!.data![index].noteTitle,
                                          createDateTime: apiResponse!.data![index].createDateTime,
                                          latestEditDateTime: apiResponse!.data![index].latestEditDateTime
                                      )
                                    ]);
                                    searchNote.replaceRange(index, index+1, [notes[index]]);
                                  setState(()  {});
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ):Center(
              child: Column(
                children: [
                  Spacer(),
                  Text('there is no note...',style: TextStyle(fontSize: 18),),
                  SizedBox(height: 200,),
                  Spacer(),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.cyan,
          onPressed: () {
            Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => NoteModify(noteID: '',)))
            .then((value) async{
              notes=[];searchNote=[];
              getNotes();
            });
          },
          child: Icon(Icons.add,size: 30,),
        ),

      ),
    );
  }
}