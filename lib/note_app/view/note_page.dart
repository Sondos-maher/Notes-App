
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core-helper/hive_helper.dart';
import '../cubits/note_cubit.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  static const Color primaryColor = Color(0xff7567C8);
  static const Color backgroundColor = Color(0xffFFF9F6);

  final List<Color> noteColors = const [
    Color(0xffFFF1D6),
    Color(0xffE6F0FF),
    Color(0xffE3F5EA),
    Color(0xffF0E7FF),
    Color(0xffFFE7E9),
  ];


  Widget _networkImage({
    required double size,
  }) {
    return Image.network(
      'https://img.icons8.com/fluency/96/notebook.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.menu_book_rounded,
          size: size * 0.8,
          color: primaryColor,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<NoteCubit>().getNotes();
  }


  void _showAddNoteDialog() {
    _controller.clear();

    _showNoteDialog(
      title: 'Create New Note',
      buttonText: 'Add Note',
      onPressed: () {
        if (_key.currentState!.validate()) {
          context.read<NoteCubit>().addNote(
            _controller.text.trim(),
          );
          Navigator.pop(context);
        }
      },
    );
  }


  void _showUpdateNoteDialog(int index) {
    _controller.text = HiveHelper.myNotes[index];

    _showNoteDialog(
      title: 'Edit Your Note',
      buttonText: 'Save Changes',
      onPressed: () {
        if (_key.currentState!.validate()) {
          context.read<NoteCubit>().updateNote(
            index,
            _controller.text.trim(),
          );
          Navigator.pop(context);
        }
      },
    );
  }


  void _showNoteDialog({
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Form(
          key: _key,
          child: AlertDialog(
            backgroundColor: const Color(0xffFFFCFA),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff292633),
              ),
            ),
            content: TextFormField(
              controller: _controller,
              maxLines: 6,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write something first';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: const TextStyle(
                  color: Color(0xffAAA5B5),
                ),
                filled: true,
                fillColor: const Color(0xffF5F1FA),
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: primaryColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(
              18,
              0,
              18,
              18,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xff8D8798),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _controller.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,


      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 105,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xffF0E7FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _networkImage(size: 36),
              ),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Notes',
              style: TextStyle(
                color: Color(0xff292633),
                fontSize: 29,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Capture your thoughts ✨',
              style: TextStyle(
                color: Color(0xff91899F),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                tooltip: 'Clear all notes',
                onPressed: HiveHelper.myNotes.isEmpty
                    ? null
                    : _showClearAllDialog,
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Color(0xffE77983),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),


      body: BlocBuilder<NoteCubit, NoteState>(
        builder: (context, state) {
          if (state is NoteLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (state is NoteEmptyState ||
              HiveHelper.myNotes.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              100,
            ),
            itemCount: HiveHelper.myNotes.length,
            itemBuilder: (context, index) {
              return _noteCard(index);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,
        backgroundColor: primaryColor,
        elevation: 5,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 27,
        ),
        label: const Text(
          'New Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }


  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFFCFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Clear all notes?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff292633),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete all your notes?',
            style: TextStyle(
              color: Color(0xff777180),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<NoteCubit>().clearAllNotes();
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE77983),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }




  Widget _emptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xffF0E7FF),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Center(
                child: Image.network(
                  'https://img.icons8.com/fluency/240/spiral-bound-booklet.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.menu_book_rounded,
                      size: 120,
                      color: Color(0xff7567C8),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Your Little Journal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xff292633),
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'A quiet place for your thoughts,\n'
                  'little ideas, and everyday moments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff91899F),
                fontSize: 14,
                height: 1.8,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffF0E7FF).withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Every thought deserves a place',
                    style: TextStyle(
                      color: Color(0xff7567C8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteCard(int index) {
    final note = HiveHelper.myNotes[index];
    final cardColor = noteColors[index % noteColors.length];

    return Dismissible(
      key: ValueKey('$note$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: const Color(0xffE77983),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        context.read<NoteCubit>().deleteNote(index);
      },
      child: GestureDetector(
        onTap: () => _showUpdateNoteDialog(index),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _networkImage(size: 30),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: 'Note options',
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xff777180),
                      size: 27,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showUpdateNoteDialog(index);
                      } else if (value == 'delete') {
                        context.read<NoteCubit>().deleteNote(index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: primaryColor,
                            ),
                            SizedBox(width: 10),
                            Text('Edit note'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Color(0xffE77983),
                            ),
                            SizedBox(width: 10),
                            Text('Delete note'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                note,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff35313D),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 17,
                    color: Color(0xff91899F),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tap to edit',
                    style: TextStyle(
                      color: Color(0xff91899F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}