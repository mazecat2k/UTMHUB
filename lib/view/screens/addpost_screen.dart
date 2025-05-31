import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/post_viewmodel.dart';

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

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitPost(PostViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.createPost(
        title: titleController.text,
        description: descController.text,
        tags: tagsController.text,
      );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Add Post')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (viewModel.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter title',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !viewModel.isLoading,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !viewModel.isLoading,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'Enter tags (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !viewModel.isLoading,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter tags' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _submitPost(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}