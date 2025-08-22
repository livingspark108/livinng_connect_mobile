import 'package:flutter/material.dart';



class VedaBaseScreen extends StatelessWidget {
  const VedaBaseScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> books = const [
    {
      'title': 'Chant and be Happy',
      'subtitle': 'Book',
      'image': 'assets/book_cover.png',
    },
    {
      'title': 'Morning Walk at snow l..',
      'subtitle': 'Book',
      'image': 'assets/book_cover.png',
    },
    {
      'title': 'Gauranga Bhajan',
      'subtitle': 'Book',
      'image': 'assets/book_cover.png',
    },
    {
      'title': 'The perfection of Yoga',
      'subtitle': 'Book',
      'image': 'assets/book_cover.png',
    },
    {
      'title': 'The perfection of yoga',
      'subtitle': 'Book',
      'image': 'assets/book_cover.png',
    },
    {
      'title': 'Krsna, the supreme perso',
      'subtitle': 'Book',
      'image': 'assets/book_cover.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("VedaBase (Copy)"),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: books.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final book = books[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      book['image']!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  book['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Book",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}