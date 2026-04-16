import 'package:flutter/material.dart';
import 'package:magika_dart/magika_dart.dart';

void main() {
  runApp(const MagikaExampleApp());
}

class MagikaExampleApp extends StatelessWidget {
  const MagikaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magika Dart Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MagikaHomePage(),
    );
  }
}

class MagikaHomePage extends StatefulWidget {
  const MagikaHomePage({super.key});

  @override
  State<MagikaHomePage> createState() => _MagikaHomePageState();
}

class _MagikaHomePageState extends State<MagikaHomePage> {
  late final Future<MagikaResult> _resultFuture;

  @override
  void initState() {
    super.initState();
    _resultFuture = _identifySample();
  }

  Future<MagikaResult> _identifySample() async {
    final magika = await Magika.create(
      predictionMode: PredictionMode.bestGuess,
    );
    return magika.identifyBytes('{"hello":"magika"}\n'.codeUnits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magika Dart Example')),
      body: FutureBuilder<MagikaResult>(
        future: _resultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Initialization failed: ${snapshot.error}',
                  key: const Key('magika-error'),
                ),
              ),
            );
          }

          final result = snapshot.requireData;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                key: const Key('magika-result'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('status=${result.status.name}', key: const Key('magika-status')),
                  const SizedBox(height: 8),
                  Text('model=${result.prediction.model.label}', key: const Key('magika-model')),
                  const SizedBox(height: 8),
                  Text('output=${result.prediction.output.label}', key: const Key('magika-output')),
                  const SizedBox(height: 8),
                  Text('score=${result.prediction.score}', key: const Key('magika-score')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
