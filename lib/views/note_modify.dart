import 'package:animation/models/note.dart';
import 'package:animation/models/note_manipulation.dart';
import 'package:animation/service/notes_service.dart';
import 'package:flutter/material.dart';

class NoteModify extends StatefulWidget {

  final String noteID;
  NoteModify({required this.noteID});

  @override
  State<NoteModify> createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID != '';

  final service=NotesService();
  String? errorMessage; bool _addLoading=false;
  Note? note; bool _isLoading=false;
  TextEditingController _titleController=TextEditingController();
  TextEditingController _contentController=TextEditingController();

  @override
  void initState() {
    super.initState();
if(isEditing){
  setState(() { _isLoading=true; });

  service.getNote(widget.noteID).then((response){
    setState(() { _isLoading=false; });

    if(response.error){
      errorMessage=response.errorMessage??'an error occured';
    }
    note=response.data;
    _titleController.text=note!.noteTitle;
    _contentController.text=note!.noteContent;
  });
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit note' : 'Create note')),
      body: _isLoading?Center(child: CircularProgressIndicator()):
      Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(height: 9,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  style: TextStyle(fontSize: 21),
                  controller: _titleController,
                  decoration: InputDecoration(
                      hintText: 'Note title',
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: MediaQuery.of(context).size.height/1.31,width: double.infinity,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null, style: TextStyle(fontSize: 20),
                    controller: _contentController,
                    decoration: InputDecoration(
                        hintText: 'Note content',
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none
                    ),
                  ),
                ),
              ),

              Spacer(),
               Container(
                width: double.infinity,
                height: 50,decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     Colors.pink,Colors.cyan
                   ]
                 )
               ),
                child: RaisedButton(
                  child: Text('Submit', style: TextStyle(color: Colors.white,fontSize: 20)),
                  color: Colors.transparent,
                  onPressed: () async{
                    if(isEditing){

                      final noteUpdate = NoteManipulation(
                          noteTitle: _titleController.text,
                          noteContent: _contentController.text);
                      setState(()=> _addLoading=true);
                      final result = await service.updateNote(widget.noteID,noteUpdate);
                      setState(()=> _addLoading=false);
                      var content;
                      if(result.error){
                        content=result.errorMessage??'an error occered';
                      }else{
                        content='note updated';
                      }
                      showDialog(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: Text('Done'),
                                content:Text(content),
                                actions: <Widget>[
                                  FlatButton(onPressed: ()=>Navigator.of(context).pop(), child: Text('ok'))
                                ],
                              )).then((data) {
                        if(result.data!){
                          Navigator.of(context).pop(false);
                        }
                      });

                    }else {
                      final noteInsert = NoteManipulation(
                          noteTitle: _titleController.text,
                          noteContent: _contentController.text);
                      setState(()=> _addLoading=true);
                      final result = await service.createNote(noteInsert);
                      setState(()=> _addLoading=false);
                      String content=result.error?(result.errorMessage??"an error occured"):'note added';
                      showDialog(context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: Text('Done'),
                                content:Text(content),
                                actions: <Widget>[
                                  FlatButton(onPressed: ()=>Navigator.of(context).pop(), child: Text('ok'))
                                ],
                              )).then((data) {
                                if(result.data!){
                                  Navigator.of(context).pop(_titleController.text);
                                }
                              });
                    }
                  },
                ),
              )
            ],
          ),
          _addLoading?Center(child: CircularProgressIndicator()):SizedBox()
        ],
      ),
    );
  }
}