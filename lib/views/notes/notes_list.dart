import 'package:flutter/material.dart';
import 'package:flutter_of_my_test/components/delete_dialog.dart';
import 'package:flutter_of_my_test/services/cloud/cloud_note.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesList extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesList(
      {super.key,
      required this.notes,
      required this.onDeleteNote,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes.elementAt(index);
          return ListTile(
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteNote(note);
                  }
                },
                icon: const Icon(Icons.delete)),
          );
        });
  }
}
