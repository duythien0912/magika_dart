import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:magika_dart/magika_dart.dart';

void main() {
  runApp(const MagikaExampleApp());
}

String _formatError(Object error) {
  if (error is MagikaConfigurationException) {
    return error.message;
  }
  return error.toString();
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
  static const String _sampleText = 'hello from magika example';

  Magika? _magika;
  MagikaResult? _result;
  Object? _error;
  bool _initializing = true;
  bool _picking = false;
  bool _classifyingSample = false;
  String? _selectedPath;
  String? _sampleInput;

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
    if (_magika == null || _picking || _classifyingSample) {
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
        _sampleInput = null;
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

  Future<void> _identifySampleText() async {
    if (_magika == null || _initializing || _picking || _classifyingSample) {
      return;
    }

    setState(() {
      _classifyingSample = true;
      _error = null;
    });

    try {
      final result = await _magika!.identifyString(_sampleText);
      if (!mounted) {
        return;
      }
      setState(() {
        _classifyingSample = false;
        _sampleInput = _sampleText;
        _selectedPath = null;
        _result = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _classifyingSample = false;
        _error = error;
      });
    }
  }

  List<Widget> _buildResultDetails(MagikaResult result) {
    final directLabel = result.prediction.direct?.label ?? 'none';
    return <Widget>[
      if (_selectedPath != null) Text('path=$_selectedPath', key: const Key('magika-path')),
      if (_sampleInput != null) Text('input=$_sampleInput', key: const Key('magika-input')),
      const SizedBox(height: 8),
      Text('status=${result.status.name}', key: const Key('magika-status')),
      const SizedBox(height: 8),
      Text('model=${result.prediction.model.label}', key: const Key('magika-model')),
      const SizedBox(height: 8),
      Text('direct=$directLabel', key: const Key('magika-direct')),
      const SizedBox(height: 8),
      Text('output=${result.prediction.output.label}', key: const Key('magika-output')),
      const SizedBox(height: 8),
      Text('description=${result.prediction.output.description}', key: const Key('magika-description')),
      const SizedBox(height: 8),
      Text('mimeType=${result.prediction.output.mimeType}', key: const Key('magika-mime-type')),
      const SizedBox(height: 8),
      Text('group=${result.prediction.output.group}', key: const Key('magika-group')),
      const SizedBox(height: 8),
      Text('isText=${result.prediction.output.isText}', key: const Key('magika-is-text')),
      const SizedBox(height: 8),
      Text('didFallback=${result.prediction.didFallback}', key: const Key('magika-did-fallback')),
      const SizedBox(height: 8),
      Text('overwriteReason=${result.prediction.overwriteReason.name}', key: const Key('magika-overwrite-reason')),
      const SizedBox(height: 8),
      Text('score=${result.prediction.score}', key: const Key('magika-score')),
    ];
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  key: const Key('pick-file-button'),
                  onPressed: _initializing || _picking || _classifyingSample || _magika == null
                      ? null
                      : _pickAndIdentifyFile,
                  child: Text(_picking ? 'Picking file...' : 'Pick file'),
                ),
                FilledButton.tonal(
                  key: const Key('sample-text-button'),
                  onPressed: _initializing || _picking || _classifyingSample || _magika == null
                      ? null
                      : _identifySampleText,
                  child: Text(_classifyingSample ? 'Classifying sample...' : 'Classify sample text'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_initializing)
              const Center(
                child: CircularProgressIndicator(key: Key('magika-loading')),
              )
            else if (_error != null)
              Text(
                'Operation failed: ${_formatError(_error!)}',
                key: const Key('magika-error'),
              )
            else if (_result == null)
              const Text(
                'Pick a file or classify sample text with Magika.',
                key: Key('magika-idle'),
              )
            else
              Column(
                key: const Key('magika-result'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildResultDetails(_result!),
              ),
          ],
        ),
      ),
    );
  }
}
