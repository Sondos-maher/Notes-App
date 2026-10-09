import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../core-helper/hive_helper.dart';

part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(NoteInitial());

  // Get Notes
  Future<void> getNotes() async {
    emit(NoteLoadingState());

    try {
      await HiveHelper.getNotes();

      if (HiveHelper.myNotes.isEmpty) {
        emit(NoteEmptyState());
      } else {
        emit(NoteSuccessState());
      }
    } catch (e) {
      emit(NoteErrorState(e.toString()));
    }
  }

  // Add Note
  Future<void> addNote(String text) async {
    await HiveHelper.addNote(text);
    emit(NoteAddState());
  }

  // Clear All Notes
  Future<void> clearAllNotes() async {
    await HiveHelper.deleteAllNotes();
    emit(NoteClearAllState());
  }

  // Update Note
  Future<void> updateNote(int index, String text) async {
    await HiveHelper.updateNote(index, text);
    emit(NoteAddState());
  }

  // Delete Note
  Future<void> deleteNote(int index) async {
    await HiveHelper.deleteNote(index);
    emit(NoteDeleteNoteState());
  }
}