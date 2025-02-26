import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/carousel.dart';
import 'package:poddr/ui/components/widgets/tag.dart';

class RadioDiscoveryView extends StatelessWidget {
  const RadioDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Radio"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {},
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
      ),
    );
  }
}
