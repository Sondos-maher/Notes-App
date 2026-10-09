part of 'note_cubit.dart';

@immutable
sealed class NoteState {}

final class NoteInitial extends NoteState {}

final class NoteLoadingState extends NoteState {}

final class NoteSuccessState extends NoteState {}

final class NoteEmptyState extends NoteState {}

final class NoteAddState extends NoteState {}

final class NoteClearAllState extends NoteState {}

final class NoteDeleteNoteState extends NoteState {}
final class NoteErrorState extends NoteState {
  final String message;

  NoteErrorState(this.message);
}