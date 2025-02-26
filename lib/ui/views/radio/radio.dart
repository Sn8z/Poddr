import 'package:flutter/material.dart';
import 'package:poddr/ui/components/ui/carousel.dart';
import 'package:poddr/ui/components/ui/tag.dart';

class RadioDiscoveryView extends StatelessWidget {
  const RadioDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PoddrCarousel(
              children: List.generate(
                30,
                (index) => PoddrTag(
                  title: "Test$index",
                  color: const Color.fromARGB(255, 167, 55, 55),
                ),
              ).toList(),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Radio Discovery",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const ListTile(
                    title: Text("Radio Discovery"),
                    subtitle: Text("Radio Discovery"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
