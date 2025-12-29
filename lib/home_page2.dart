import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String? editingId; // 🔥 track which row is editing
  final TextEditingController editController = TextEditingController();

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inline Edit CRUD')),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final bool isEditing = editingId == doc.id;

              return ListTile(
                title: isEditing
                    ? TextField(
                        controller: editController,
                        autofocus: true,
                        onSubmitted: (value) async {
                          if (value.trim().isEmpty) return;

                          await db.collection('users').doc(doc.id).update({
                            'name': value,
                          });

                          editingId = null;
                          editController.clear();
                          setState(() {});
                        },
                      )
                    : Text(doc['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isEditing ? Icons.check : Icons.edit),
                      onPressed: () async {
                        if (isEditing) {
                          if (editController.text.trim().isEmpty) return;

                          await db.collection('users').doc(doc.id).update({
                            'name': editController.text.trim(),
                          });

                          editingId = null;
                          editController.clear();
                        } else {
                          editingId = doc.id;
                          editController.text = doc['name'];
                        }
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await db.collection('users').doc(doc.id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
