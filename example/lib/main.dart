import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form.io Flutter Live Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FormListPage(),
    );
  }
}

class FormListPage extends StatefulWidget {
  const FormListPage({super.key});

  @override
  State<FormListPage> createState() => _FormListPageState();
}

class _FormListPageState extends State<FormListPage> {
  List<FormModel> forms = [];
  bool isLoading = true;
  String? errorMessage;

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
      ApiClient.setBaseUrl(Uri.parse('https://examples.form.io'));
      final formService = FormService(ApiClient());
      final fetchedForms = await formService.fetchForms();
      
      setState(() {
        forms = fetchedForms;
        isLoading = false;
      });
      
      print('✅ Loaded ${forms.length} forms from API');
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadForms,
            tooltip: 'Reload forms',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading forms from API...'),
          ],
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
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadForms,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (forms.isEmpty) {
      return const Center(
        child: Text('No forms available'),
      );
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
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              form.title.isNotEmpty ? form.title : 'Untitled Form',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Path: /${form.path}'),
                Text('Components: ${form.components.length}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openForm(form),
          ),
        );
      },
    );
  }

  void _openForm(FormModel form) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormDetailPage(form: form),
      ),
    );
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
        actions: [
          IconButton(
            icon: Icon(showJson ? Icons.visibility_off : Icons.code),
            onPressed: () => setState(() => showJson = !showJson),
            tooltip: showJson ? 'Hide JSON' : 'Show JSON',
          ),
        ],
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
                  Text(
                    'Form Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${widget.form.id}'),
                  Text('Path: /${widget.form.path}'),
                  Text('Components: ${widget.form.components.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Form renderer
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
                        builder: (context) => AlertDialog(
                          title: const Text('Submission Data'),
                          content: SingleChildScrollView(
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(data),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            onError: (error) {
              print('❌ Form submission error: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Submission failed: $error'),
                  backgroundColor: Colors.red,
                ),
              );
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
          Text(
            'Form Definition (JSON)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(widget.form.toJson()),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (formData.isNotEmpty) ...[
            Text(
              'Current Form Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(formData),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
