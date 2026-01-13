// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_formio/flutter_formio.dart';

import 'custom_rating_component.dart';
import 'custom_textfield.dart';
import 'tr_localization.dart';

void main() {
  // ========================================
  // DEMO: Custom Component Registration
  // ========================================
  // This demonstrates the plugin system for registering custom components.
  // You can override default components or add completely new component types.

  // Example 1: Override the default 'textfield' component with a custom styled version
  ComponentFactory.register(
    'textfield',
    const CustomTextFieldBuilder(),
  );

  // Example 2: Register a new custom component type 'rating'
  ComponentFactory.register(
    'rating',
    const RatingComponentBuilder(),
  );

  // Alternative: Use FunctionComponentBuilder for simple cases
  // ComponentFactory.register(
  //   'rating',
  //   FunctionComponentBuilder((context) {
  //     return CustomRatingComponent(
  //       component: context.component,
  //       value: context.value,
  //       onChanged: context.onChanged,
  //     );
  //   }),
  // );

  // Or use initialize() to register multiple at once:
  // ComponentFactory.initialize({
  //   'textfield': const CustomTextFieldBuilder(),
  //   'rating': const RatingComponentBuilder(),
  // });

  // ========================================
  // Locale Configuration
  // ========================================
  // Use TurkishFormioLocalizations for Turkish, or create your own by implementing FormioLocalizations
  ComponentFactory.setLocale(const DefaultFormioLocalizations());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRedTheme = true;
  bool _isTurkish = false;

  ThemeData get _redRoundedTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
  );

  ThemeData get _purpleSquareTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.purple.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.purple, width: 2)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form.io Flutter Live Demo',
      theme: _isRedTheme ? _redRoundedTheme : _purpleSquareTheme,
      home: FormListPage(
        onThemeToggle: () {
          setState(() {
            _isRedTheme = !_isRedTheme;
          });
        },
        currentTheme: _isRedTheme ? 'Red Rounded' : 'Purple Square',
        onLanguageToggle: () {
          setState(() {
            _isTurkish = !_isTurkish;
            if (_isTurkish) {
              ComponentFactory.setLocale(const TurkishFormioLocalizations());
            } else {
              ComponentFactory.setLocale(const DefaultFormioLocalizations());
            }
          });
        },
        currentLanguage: _isTurkish ? 'TR' : 'EN',
      ),
    );
  }
}

class FormListPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final String currentTheme;
  final VoidCallback onLanguageToggle;
  final String currentLanguage;

  const FormListPage({super.key, required this.onThemeToggle, required this.currentTheme, required this.onLanguageToggle, required this.currentLanguage});

  @override
  State<FormListPage> createState() => _FormListPageState();
}

class _FormListPageState extends State<FormListPage> {
  List<FormModel> forms = [];
  bool isLoading = true;
  String? errorMessage;
  bool _loadFromAssets = false;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (_loadFromAssets) {
        final String response = await rootBundle.loadString('assets/example.json');
        final List<dynamic> data = jsonDecode(response);
        final fetchedForms = data.map((e) => FormModel.fromJson(e)).toList();

        setState(() {
          forms = fetchedForms;
          isLoading = false;
        });
        print('✅ Loaded ${forms.length} forms from assets');
      } else {
        ApiClient.setBaseUrl(Uri.parse('https://examples.form.io'));
        final formService = FormService(ApiClient());
        final fetchedForms = await formService.fetchForms();

        setState(() {
          forms = fetchedForms;
          isLoading = false;
        });

        print('✅ Loaded ${forms.length} forms from API');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load forms: $e';
        isLoading = false;
      });
      print('❌ Error loading forms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form.io Live Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_loadFromAssets ? Icons.cloud_download : Icons.storage),
            onPressed: () {
              setState(() {
                _loadFromAssets = !_loadFromAssets;
              });
              _loadForms();
            },
            tooltip: _loadFromAssets ? 'Switch to API' : 'Switch to Assets',
          ),
          TextButton(onPressed: widget.onLanguageToggle, child: Text(widget.currentLanguage, style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.palette), onPressed: widget.onThemeToggle, tooltip: 'Switch Theme: ${widget.currentTheme}'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadForms, tooltip: 'Reload forms'),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(_loadFromAssets ? 'Loading forms from Assets...' : 'Loading forms from API...')],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: _loadForms, icon: const Icon(Icons.refresh), label: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (forms.isEmpty) {
      return const Center(child: Text('No forms available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text('${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
            title: Text(form.title.isNotEmpty ? form.title : 'Untitled Form', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('Path: /${form.path}'), Text('Components: ${form.components.length}')]),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openForm(form),
          ),
        );
      },
    );
  }

  void _openForm(FormModel form) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FormDetailPage(form: form)));
  }
}

class FormDetailPage extends StatefulWidget {
  final FormModel form;

  const FormDetailPage({super.key, required this.form});

  @override
  State<FormDetailPage> createState() => _FormDetailPageState();
}

class _FormDetailPageState extends State<FormDetailPage> {
  Map<String, dynamic> formData = {};
  bool showJson = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.form.title.isNotEmpty ? widget.form.title : 'Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [IconButton(icon: Icon(showJson ? Icons.visibility_off : Icons.code), onPressed: () => setState(() => showJson = !showJson), tooltip: showJson ? 'Hide JSON' : 'Show JSON')],
      ),
      body: showJson ? _buildJsonView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form info card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Form Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ID: ${widget.form.id}'),
                  Text('Path: /${widget.form.path}'),
                  Text('Components: ${widget.form.components.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form renderer with optional custom callbacks
          FormRenderer(
            form: widget.form,
            initialData: formData,
            onChanged: (data) {
              setState(() => formData = data);
              print('📝 Form data changed: ${data.keys.join(', ')}');
            },
            onSubmit: (data) {
              print('✅ Form submitted!');
              print('📦 Submission data: ${jsonEncode(data)}');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Form "${widget.form.title}" submitted successfully!'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Submission Data'),
                              content: SingleChildScrollView(child: SelectableText(const JsonEncoder.withIndent('  ').convert(data), style: const TextStyle(fontFamily: 'monospace'))),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                            ),
                      );
                    },
                  ),
                ),
              );
            },
            onError: (error) {
              print('❌ Form submission error: $error');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $error'), backgroundColor: Colors.red));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Form Definition (JSON)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(const JsonEncoder.withIndent('  ').convert(widget.form.toJson()), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
          if (formData.isNotEmpty) ...[
            Text('Current Form Data', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(const JsonEncoder.withIndent('  ').convert(formData), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
