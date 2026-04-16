import 'package:file_picker/file_picker.dart';
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
  Magika? _magika;
  MagikaResult? _result;
  Object? _error;
  bool _initializing = true;
  bool _picking = false;
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final magika = await Magika.create(
        predictionMode: PredictionMode.bestGuess,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _magika = magika;
        _initializing = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initializing = false;
        _error = error;
      });
    }
  }

  Future<void> _pickAndIdentifyFile() async {
    if (_magika == null || _picking) {
      return;
    }

    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      final picked = await FilePicker.platform.pickFiles(
        withData: false,
      );
      final path = picked?.files.single.path;
      if (path == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _picking = false;
        });
        return;
      }

      final result = await _magika!.identifyPath(path);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedPath = path;
        _result = result;
        _picking = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _picking = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magika Dart Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              key: const Key('pick-file-button'),
              onPressed: _initializing || _picking || _magika == null ? null : _pickAndIdentifyFile,
              child: Text(_picking ? 'Picking file...' : 'Pick file'),
            ),
            const SizedBox(height: 16),
            if (_initializing)
              const Center(
                child: CircularProgressIndicator(key: Key('magika-loading')),
              )
            else if (_error != null)
              Text(
                'Operation failed: $_error',
                key: const Key('magika-error'),
              )
            else if (_result == null)
              const Text(
                'Pick a file to classify it with Magika.',
                key: Key('magika-idle'),
              )
            else
              Column(
                key: const Key('magika-result'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPath != null) Text('path=$_selectedPath', key: const Key('magika-path')),
                  const SizedBox(height: 8),
                  Text('status=${_result!.status.name}', key: const Key('magika-status')),
                  const SizedBox(height: 8),
                  Text('model=${_result!.prediction.model.label}', key: const Key('magika-model')),
                  const SizedBox(height: 8),
                  Text('output=${_result!.prediction.output.label}', key: const Key('magika-output')),
                  const SizedBox(height: 8),
                  Text('score=${_result!.prediction.score}', key: const Key('magika-score')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
