import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPostPage extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.postData,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController tagsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.postData['title']);
    descController = TextEditingController(text: widget.postData['description']);
    tagsController = TextEditingController(text: widget.postData['tags']);
  }

  Future<void> _updatePost() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({
          'title': titleController.text,
          'description': descController.text,
          'tags': tagsController.text,
          'updatedAt': Timestamp.now(),
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    final inputdecoration = InputDecoration(
      border: inputBorder,
      focusedBorder: inputBorder,
      enabledBorder: inputBorder,
      filled: true,
      contentPadding: const EdgeInsets.all(8),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: inputdecoration.copyWith(
                  labelText: 'Title',
                  hintText: 'Edit title',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: descController,
                decoration: inputdecoration.copyWith(
                  labelText: 'Description',
                  hintText: 'Edit description',
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: tagsController,
                decoration: inputdecoration.copyWith(
                  labelText: 'Tags',
                  hintText: 'Edit tags',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter tags' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePost,
                child: const Text('Update Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
