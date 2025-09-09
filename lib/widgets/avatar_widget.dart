import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    this.height,
    this.width,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final void Function(String) onUpload;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;
      await supabase.storage.from('images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: imageFile.mimeType),
          );
      final imageUrlResponse = await supabase.storage
          .from('images')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      widget.onUpload(imageUrlResponse);
    } on StorageException catch (error) {
      if (mounted) {
        print(error);
      }
    } catch (error) {
      if (mounted) {
        print(error);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _isLoading ? null : _upload,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.height ?? 80),
          child: Container(
            height: widget.height ?? 80,
            width: widget.width ?? 80,
            color: Colors.grey.shade300,
            child: (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.indigo,
                  )
                : Image.network(
                    widget.imageUrl!,
                    width: widget.width ?? 80,
                    height: widget.height ?? 80,
                    fit: BoxFit.cover,
                  ),
          ),
        ));
  }
}
