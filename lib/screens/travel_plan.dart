import 'package:flutter/material.dart';
import '../widgets/main_navigation_bar.dart';

class TravelPlanScreen extends StatelessWidget {
  const TravelPlanScreen({super.key});

  final List<Map<String, String>> plans = const [
    {
      'title': 'Trip to Baguio',
      'date': 'May 12, 2025',
      'image': 'https://res.klook.com/image/upload/Mobile/City/dqm8q1e6jyqaxapkgqy3.jpg',
    },
    {
      'title': 'Beach Day La Union',
      'date': 'June 8, 2025',
      'image': 'https://shoestringdiary.wordpress.com/wp-content/uploads/2018/11/immuki15ss_diaries.jpg',
    },
    {
      'title': 'Vigan Heritage Tour',
      'date': 'July 22, 2025',
      'image': 'https://upload.wikimedia.org/wikipedia/commons/b/bd/Calle_Crisologo%2C_Vigan%2C_Philippines_%2850025182191%29.jpg',
    },
  ];

  void _handleNavTap(BuildContext context, int index) {
    if (index == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add Button Pressed')));
    }
    // index 0 and 2 will be handled in main screen
  }

  void _handleSeeAll(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('pressed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Good morning,",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Justin Peña",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF14645B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Upcoming Travel Plan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _handleSeeAll(context),
                        child: const Text("See all"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/1/13/Kayangan_Lake%2C_Coron_-_Palawan.jpg',
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Trip to Palawan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "April 30, 2025",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 16,
                          child: Row(
                            children: List.generate(3, (index) {
                              return Padding(
                                padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, size: 14, color: Colors.grey),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "All Travel Plans",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return TravelPlanItem(
                          title: plan['title']!,
                          date: plan['date']!,
                          imageUrl: plan['image']!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          MainNavigationBar(
            selectedIndex: 0,
            onButtonPressed: (index) => _handleNavTap(context, index),
          ),
        ],
      ),
    );
  }
}

class TravelPlanItem extends StatelessWidget {
  final String title;
  final String date;
  final String imageUrl;

  const TravelPlanItem({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.white),
          ),
        ),
      ),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: Color(0xFF14645B)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('More options Pressed')),
          );
        },
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('pressed')),
        );
      },
    );
  }
}
