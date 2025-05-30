import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/report_viewmodel.dart';

class ReportDialog extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const ReportDialog({
    Key? key,
    required this.postId,
    required this.postData,
  }) : super(key: key);

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Why are you reporting this post?'),
              const SizedBox(height: 10),
              TextFormField(
                maxLines: 3,
                onChanged: (value) => setState(() => _reason = value),
                decoration: const InputDecoration(
                  hintText: 'Enter reason for reporting',
                  border: OutlineInputBorder(),
                ),
              ),
              if (viewModel.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.reportPost(
                        postId: widget.postId,
                        reason: _reason ?? '',
                        postTitle: widget.postData['title'],
                        postAuthor: widget.postData['authorName'],
                      );

                      if (success && mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post reported successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Report'),
            ),
          ],
        );
      },
    );
  }
}