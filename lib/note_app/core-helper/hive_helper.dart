import 'package:hive/hive.dart';

class HiveHelper {
  static const String noteBox = "Note_Box";
  static const String noteKey = "Note_Key";

  static List<String> myNotes = [];

  // ================= GET NOTES =================

  static Future<void> getNotes() async {
    final box = Hive.box(noteBox);

    final data = box.get(
      noteKey,
      defaultValue: <String>[],
    );

    myNotes = List<String>.from(data);
  }

  // ================= ADD NOTE =================

  static Future<void> addNote(String note) async {
    myNotes.add(note);

    final box = Hive.box(noteBox);

    await box.put(
      noteKey,
      myNotes,
    );
  }

  // ================= DELETE NOTE =================

  static Future<void> deleteNote(int index) async {
    if (index < 0 || index >= myNotes.length) {
      return;
    }

    myNotes.removeAt(index);

    final box = Hive.box(noteBox);

    await box.put(
      noteKey,
      myNotes,
    );
  }

  // ================= DELETE ALL NOTES =================

  static Future<void> deleteAllNotes() async {
    myNotes.clear();

    final box = Hive.box(noteBox);

    await box.put(
      noteKey,
      myNotes,
    );
  }

  // ================= UPDATE NOTE =================

  static Future<void> updateNote(
      int index,
      String text,
      ) async {
    if (index < 0 || index >= myNotes.length) {
      return;
    }

    myNotes[index] = text;

    final box = Hive.box(noteBox);

    await box.put(
      noteKey,
      myNotes,
    );
  }
}