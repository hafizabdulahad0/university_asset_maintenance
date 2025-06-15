import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickMedia(bool video) async {
    final picker = ImagePicker();
    final picked = await (video
      ? picker.pickVideo(source: ImageSource.gallery)
      : picker.pickImage(source: ImageSource.gallery));
    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
        _isVideo = video;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final comp = Complaint(
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim(),
      status: 'unassigned',
      teacherId: user.id!,
      mediaPath: _mediaFile?.path,
      mediaIsVideo: _isVideo,
    );
    await context.read<ComplaintProvider>().addComplaint(comp);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _titleCtl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v!.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  controller: _descCtl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                      onPressed: () => _pickMedia(false),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.videocam),
                      label: const Text('Pick Video'),
                      onPressed: () => _pickMedia(true),
                    ),
                  ],
                ),
                if (_mediaFile != null) ...[
                  const SizedBox(height: 12),
                  _isVideo
                    ? const Icon(Icons.videocam, size: 48)
                    : Image.file(_mediaFile!, height: 120),
                ],
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}
