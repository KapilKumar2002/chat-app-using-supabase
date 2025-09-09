import 'package:flutter/material.dart';

class SelectProfileImageScreen extends StatefulWidget {
  final Function(String value) selectImage;
  const SelectProfileImageScreen({super.key, required this.selectImage});
  @override
  _SelectProfileImageScreenState createState() =>
      _SelectProfileImageScreenState();
}

class _SelectProfileImageScreenState extends State<SelectProfileImageScreen> {
  // Replace these with your real image URLs
  final allImages = [
    "https://images.unsplash.com/photo-1603415526960-f7e0328c63b1?w=500&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=500&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1595152772835-219674b2a8a6",
    "https://images.unsplash.com/photo-1607746882042-944635dfe10e",
    "https://images.unsplash.com/photo-1580489944761-15a19d654956",
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
    "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
    "https://images.unsplash.com/photo-1517841905240-472988babdf9",
    "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e"
  ];

  String? selectedUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Select Profile Image'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: GridView.builder(
          itemCount: allImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final url = allImages[index];
            final isSelected = url == selectedUrl;

            return GestureDetector(
              onTap: () {
                widget.selectImage(url);
                setState(() {});
                Navigator.pop(context);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedUrl != null
              ? () {
                  Navigator.pop(context, selectedUrl);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Confirm Selection',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
