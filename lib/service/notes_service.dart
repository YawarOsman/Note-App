import 'dart:convert';

import 'package:animation/models/note.dart';
import 'package:animation/models/note_manipulation.dart';
import 'package:http/http.dart' as http;
import 'package:animation/models/api_response.dart';
import 'package:animation/models/note_for_listing.dart';

class NotesService{

  static const API='https://tq-notes-api-jkrgrdggbq-el.a.run.app';
  static const headers={
    'apikey':'734425fa-5994-4239-a01e-c0b96cf97e07',
    'Content-Type':'application/json'
  };

  Future<APIResponse<List<NoteForListing>>>  getNotesList(){
    return http.get(Uri.parse(API+'/notes'),headers: headers)
     .then((data) {
         if(data.statusCode==200){
           final jsonData = jsonDecode(data.body);
           final notes = <NoteForListing>[];
           for(var item in jsonData){
             final note=NoteForListing(
               noteID: item['noteID'],
               noteTitle: item['noteTitle'],
               createDateTime: DateTime.parse(item['createDateTime']),
               latestEditDateTime: item['latestEditDateTime']!=null?DateTime.parse(item['latestEditDateTime']):null
             );
             notes.add(note);
           }
           return APIResponse<List<NoteForListing>>(data: notes);
         }else{
           return APIResponse<List<NoteForListing>>(error: true,errorMessage: 'an error occured');
         }
     }).catchError((Object error) {
      return APIResponse<List<NoteForListing>>(error: true,errorMessage: 'an error occured or catched');
    });
  }

  Future<APIResponse<Note>>  getNote(String noteID){
    return http.get(Uri.parse(API+'/notes/'+noteID),headers: headers)
        .then((data) {
      if(data.statusCode==200){
        final jsonData = jsonDecode(data.body);
          final note=Note(
              noteID: jsonData['noteID'],
              noteTitle: jsonData['noteTitle'],
              noteContent: jsonData['noteContent'],
              createDateTime: DateTime.parse(jsonData['createDateTime']),
              latestEditDateTime: jsonData['latestEditDateTime']!=null?DateTime.parse(jsonData['latestEditDateTime']):null
          );

        return APIResponse<Note>(data: note);
      }else{
        return APIResponse<Note>(error: true,errorMessage: 'an error occured');
      }
    }).catchError((Object error) {
      return APIResponse<Note>(error: true,errorMessage: 'an error occured or catched');
    });
  }

  Future<APIResponse<bool>>  createNote(NoteManipulation item){
    return http.post(Uri.parse(API+'/notes'),headers: headers,body: json.encode(item.toJson()))
        .then((data) {
      if(data.statusCode==201){
        return APIResponse<bool>(data: true);
      }else{
        return APIResponse<bool>(error: true,errorMessage: 'an error occured');
      }
    }).catchError((Object error) {
      return APIResponse<bool>(error: true,errorMessage: 'an error occured or catched');
    });
  }

  Future<APIResponse<bool>>  updateNote(String noteID,NoteManipulation item){
    return http.put(Uri.parse(API+'/notes/'+noteID),headers: headers,body: json.encode(item.toJson()))
        .then((data) {
      if(data.statusCode==204){
        return APIResponse<bool>(data: true);

      }else{
        return APIResponse<bool>(error: true,errorMessage: 'an error occured');
      }
    }).catchError((Object error) {
      return APIResponse<bool>(error: true,errorMessage: 'an error occured or catched');
    });
  }

  Future<APIResponse<bool>>  deleteNote(String noteID){
    return http.delete(Uri.parse(API+'/notes/'+noteID),headers: headers)
        .then((data) {
      if(data.statusCode==204){
        return APIResponse<bool>(data: true);

      }else{
        return APIResponse<bool>(error: true,errorMessage: 'an error occured');
      }
    }).catchError((Object error) {
      return APIResponse<bool>(error: true,errorMessage: 'an error occured or catched');
    });
  }


}