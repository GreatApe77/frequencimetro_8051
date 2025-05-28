import 'package:flutter/material.dart';

class FrequencimetroPage extends StatelessWidget {
  const FrequencimetroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Frequencímetro')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('700000 Hz', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 20),
            FilledButton(onPressed: () {}, child: Text('Realizar medição')),
            //
          ],
        ),
      ),
    );
  }
}
