import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utmhub/widgets/text_field_input.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': titleController.text,
        'description': descController.text,
        'tags': tagsController.text,
        'createdAt': Timestamp.now(),
      });

      // Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Add Post')),
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
                  hintText: 'Enter title',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: descController,
                decoration: inputdecoration.copyWith(
                  labelText: 'Description',
                  hintText: 'Enter description',
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter description'
                            : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: tagsController,
                decoration: inputdecoration.copyWith(
                  labelText: 'Tags',
                  hintText: 'Enter tags',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter tags' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPost,
                child: const Text('Post'),
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
