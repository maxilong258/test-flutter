import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_of_my_test/components/logout_dialog.dart';
import 'package:flutter_of_my_test/routes/index.dart';
import 'package:flutter_of_my_test/services/auth/auth_service.dart';
import 'package:flutter_of_my_test/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_of_my_test/services/auth/bloc/auth_event.dart';
import 'package:flutter_of_my_test/services/cloud/cloud_note.dart';
import 'package:flutter_of_my_test/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_of_my_test/views/notes/notes_list.dart';

enum MenuAction { logout }

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Notes'), actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    if (context.mounted) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: MenuAction.logout,
                child: Text('Log out'),
              )
            ],
          )
        ]),
        body: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: userId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allNotes = snapshot.data as Iterable<CloudNote>;
                    return NotesList(
                        notes: allNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(
                              documentId: note.documentId);
                        },
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note);
                        });
                  } else {
                    return const CircularProgressIndicator();
                  }
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
