import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController villageName = TextEditingController();
  final TextEditingController personName = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void dispose() {
    villageName.dispose();
    personName.dispose();
    super.dispose();
  }

  // ================= EDIT DIALOG =================
  Future<void> showEditDialog({
    required String docId,
    required String collection,
    required String fieldName,
    required String oldValue,
  }) async {
    final TextEditingController editController = TextEditingController(
      text: oldValue,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isEmpty) return;

                await db.collection(collection).doc(docId).update({
                  fieldName: editController.text.trim(),
                  'Updated_At': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= FORM =================
            TextField(
              controller: villageName,
              decoration: const InputDecoration(
                labelText: 'Village Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: personName,
              decoration: const InputDecoration(
                labelText: 'Person Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                if (villageName.text.isEmpty || personName.text.isEmpty) return;

                await db.collection('village').add({
                  'Village': villageName.text,
                  'Created_At': FieldValue.serverTimestamp(),
                });

                await db.collection('person').add({
                  'Person': personName.text,
                  'Created_At': FieldValue.serverTimestamp(),
                });

                villageName.clear();
                personName.clear();
              },
              child: const Text("Submit"),
            ),

            const SizedBox(height: 30),

            // ================= VILLAGE LIST =================
            const Text(
              'Village List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: db.collection('village').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(doc['Village']),
                      subtitle: Text(
                        doc['Created_At']?.toDate().toString() ?? '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showEditDialog(
                                docId: doc.id,
                                collection: 'village',
                                fieldName: 'Village',
                                oldValue: doc['Village'],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await db
                                  .collection('village')
                                  .doc(doc.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // ================= PERSON LIST =================
            const Text(
              'Person List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: db.collection('person').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(doc['Person']),
                      subtitle: Text(
                        doc['Created_At']?.toDate().toString() ?? '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showEditDialog(
                                docId: doc.id,
                                collection: 'person',
                                fieldName: 'Person',
                                oldValue: doc['Person'],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await db
                                  .collection('person')
                                  .doc(doc.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
