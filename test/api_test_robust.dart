// Comprehensive Form.io API Integration Test
// Run with: dart run test/api_test_robust.dart

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';

class TestApiClient {
  final Dio dio;

  TestApiClient(String baseUrl)
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500, // Don't throw on 4xx errors
        ));

  void setAuthToken(String token) {
    dio.options.headers['x-jwt-token'] = token;
  }

  void clearAuthToken() {
    dio.options.headers.remove('x-jwt-token');
  }
}

class TestResults {
  int passed = 0;
  int failed = 0;
  int skipped = 0;

  void pass(String test) {
    passed++;
    print('   ✅ $test');
  }

  void fail(String test, dynamic error) {
    failed++;
    print('   ❌ $test - Error: $error');
  }

  void skip(String test, String reason) {
    skipped++;
    print('   ⏭️  $test - Skipped: $reason');
  }

  void summary() {
    print('\n${'=' * 60}');
    print('📊 TEST SUMMARY');
    print('=' * 60);
    print('✅ Passed: $passed');
    print('❌ Failed: $failed');
    print('⏭️  Skipped: $skipped');
    print('📈 Total: ${passed + failed + skipped}');
    final successRate = passed / (passed + failed) * 100;
    print('🎯 Success Rate: ${successRate.toStringAsFixed(1)}%');
  }
}

void main() async {
  print('🚀 Form.io API Integration Test Suite\n');
  print('Testing against: https://examples.form.io');

  // Configuration - Replace with your Form.io server credentials
  const baseUrl = 'https://examples.form.io';
  const email = 'test@example.com';
  const password = 'YOUR_PASSWORD_HERE';

  final client = TestApiClient(baseUrl);
  final results = TestResults();

  String? authToken;
  String? userId;
  Map<String, dynamic>? testForm;

  try {
    // ========================================================================
    // TEST GROUP 1: Authentication
    // ========================================================================
    print('🔐 TEST GROUP 1: Authentication');
    print('─' * 60);

    // Test 1.1: Login
    try {
      final response = await client.dio.post('/user/login', data: {
        'data': {'email': email, 'password': password},
      });

      authToken = response.headers.value('x-jwt-token');
      userId = response.data['_id'];

      if (authToken != null && userId != null) {
        client.setAuthToken(authToken);
        results.pass('Login with credentials');
        print('      Token: ${authToken.substring(0, 30)}...');
        print('      User ID: $userId');
      } else {
        results.fail('Login', 'No token or user ID in response');
      }
    } catch (e) {
      results.fail('Login', e);
    }

    // Test 1.2: Get Current User
    if (authToken != null) {
      try {
        final response = await client.dio.get('/current');
        if (response.statusCode == 200) {
          results.pass('Get current user');
          print('      Email: ${response.data['data']?['email']}');
        } else {
          results.fail('Get current user', 'Status: ${response.statusCode}');
        }
      } catch (e) {
        results.fail('Get current user', e);
      }
    } else {
      results.skip('Get current user', 'No auth token');
    }

    // ========================================================================
    // TEST GROUP 2: Form Operations
    // ========================================================================
    print('\n📋 TEST GROUP 2: Form Operations');
    print('─' * 60);

    // Test 2.1: List Forms
    List<dynamic> forms = [];
    try {
      final response = await client.dio.get('/form');
      if (response.statusCode == 200 && response.data is List) {
        forms = response.data as List;
        results.pass('List all forms');
        print('      Retrieved: ${forms.length} forms');

        // Find a non-system form for testing
        testForm = forms.firstWhere(
          (f) => !(f['path'] as String).contains('admin') && !(f['path'] as String).contains('user') && !(f['path'] as String).contains('role'),
          orElse: () => forms.isNotEmpty ? forms.first : null,
        );

        if (testForm != null) {
          print('      Test form: ${testForm['title']} (${testForm['path']})');
        }
      } else {
        results.fail('List forms', 'Invalid response');
      }
    } catch (e) {
      results.fail('List forms', e);
    }

    // Test 2.2: Get Form by ID
    if (testForm != null) {
      try {
        final formId = testForm['_id'];
        final response = await client.dio.get('/form/$formId');
        if (response.statusCode == 200) {
          results.pass('Get form by ID');
          print('      ID: $formId');
          print('      Components: ${(response.data['components'] as List?)?.length ?? 0}');
        } else {
          results.fail('Get form by ID', 'Status: ${response.statusCode}');
        }
      } catch (e) {
        results.fail('Get form by ID', e);
      }
    } else {
      results.skip('Get form by ID', 'No test form available');
    }

    // ========================================================================
    // TEST GROUP 3: Submission Operations
    // ========================================================================
    print('\n📨 TEST GROUP 3: Submission Operations');
    print('─' * 60);

    String? submissionId;
    String? testFormPath;

    if (testForm != null) {
      testFormPath = testForm['path'];

      // Test 3.1: Create Submission
      try {
        final response = await client.dio.post(
          '$testFormPath/submission',
          data: {
            'data': {
              'test': 'API Test ${DateTime.now().toIso8601String()}',
            },
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          submissionId = response.data['_id'];
          results.pass('Create submission');
          print('      ID: $submissionId');
        } else {
          results.fail('Create submission', 'Status: ${response.statusCode}');
        }
      } catch (e) {
        results.fail('Create submission', e);
      }

      // Test 3.2: List Submissions
      try {
        final response = await client.dio.get(
          '$testFormPath/submission',
          queryParameters: {'limit': 5},
        );

        if (response.statusCode == 200 && response.data is List) {
          results.pass('List submissions');
          print('      Count: ${(response.data as List).length}');
        } else {
          results.fail('List submissions', 'Invalid response');
        }
      } catch (e) {
        results.fail('List submissions', e);
      }

      // Test 3.3: Update Submission (PUT)
      if (submissionId != null) {
        try {
          final response = await client.dio.put(
            '$testFormPath/submission/$submissionId',
            data: {
              'data': {
                'test': 'Updated via PUT',
                'timestamp': DateTime.now().toIso8601String(),
              },
            },
          );

          if (response.statusCode == 200) {
            results.pass('Update submission (PUT)');
          } else {
            results.fail('Update submission (PUT)', 'Status: ${response.statusCode}');
          }
        } catch (e) {
          results.fail('Update submission (PUT)', e);
        }

        // Test 3.4: Partial Update (PATCH)
        try {
          final response = await client.dio.patch(
            '$testFormPath/submission/$submissionId',
            data: {
              'data': {
                'patchField': 'Patched value',
              },
            },
          );

          if (response.statusCode == 200) {
            results.pass('Partial update (PATCH)');
          } else {
            results.fail('Partial update (PATCH)', 'Status: ${response.statusCode}');
          }
        } catch (e) {
          results.fail('Partial update (PATCH)', e);
        }

        // Test 3.5: Get Submission by ID
        try {
          final response = await client.dio.get(
            '$testFormPath/submission/$submissionId',
          );

          if (response.statusCode == 200) {
            results.pass('Get submission by ID');
          } else {
            results.fail('Get submission by ID', 'Status: ${response.statusCode}');
          }
        } catch (e) {
          results.fail('Get submission by ID', e);
        }

        // Test 3.6: Delete Submission
        try {
          final response = await client.dio.delete(
            '$testFormPath/submission/$submissionId',
          );

          if (response.statusCode == 200 || response.statusCode == 204) {
            results.pass('Delete submission');
          } else {
            results.fail('Delete submission', 'Status: ${response.statusCode}');
          }
        } catch (e) {
          results.fail('Delete submission', e);
        }
      } else {
        results.skip('Update submission (PUT)', 'No submission created');
        results.skip('Partial update (PATCH)', 'No submission created');
        results.skip('Get submission by ID', 'No submission created');
        results.skip('Delete submission', 'No submission created');
      }
    } else {
      results.skip('Create submission', 'No test form');
      results.skip('List submissions', 'No test form');
      results.skip('Update submission (PUT)', 'No test form');
      results.skip('Partial update (PATCH)', 'No test form');
      results.skip('Get submission by ID', 'No test form');
      results.skip('Delete submission', 'No test form');
    }

    // ========================================================================
    // TEST GROUP 4: Action Management
    // ========================================================================
    print('\n⚡ TEST GROUP 4: Action Management');
    print('─' * 60);

    String? actionId;

    if (testForm != null) {
      final formId = testForm['_id'];

      // Test 4.1: List Actions
      try {
        final response = await client.dio.get('/form/$formId/action');
        if (response.statusCode == 200 && response.data is List) {
          results.pass('List actions');
          print('      Count: ${(response.data as List).length}');
        } else {
          results.fail('List actions', 'Invalid response');
        }
      } catch (e) {
        results.fail('List actions', e);
      }

      // Test 4.2: Create Action
      try {
        final response = await client.dio.post(
          '/form/$formId/action',
          data: {
            'title': 'Test Action ${DateTime.now().millisecondsSinceEpoch}',
            'name': 'testAction${DateTime.now().millisecondsSinceEpoch}',
            'handler': 'email',
            'method': ['create'],
            'priority': 10,
            'enabled': false,
            'settings': {
              'to': 'test@example.com',
              'from': 'noreply@example.com',
              'subject': 'Test',
              'message': 'Test message',
            },
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          actionId = response.data['_id'];
          results.pass('Create action');
          print('      ID: $actionId');
        } else {
          results.fail('Create action', 'Status: ${response.statusCode}');
        }
      } catch (e) {
        results.fail('Create action', e);
      }

      // Test 4.3: Update Action
      if (actionId != null) {
        try {
          final response = await client.dio.put(
            '/form/$formId/action/$actionId',
            data: {
              'title': 'Updated Test Action',
              'name': 'testAction${DateTime.now().millisecondsSinceEpoch}',
              'handler': 'email',
              'method': ['create', 'update'],
              'priority': 5,
              'enabled': false,
              'settings': {
                'to': 'updated@example.com',
                'from': 'noreply@spinex.io',
                'subject': 'Updated',
                'message': 'Updated message',
              },
            },
          );

          if (response.statusCode == 200) {
            results.pass('Update action');
          } else {
            results.fail('Update action', 'Status: ${response.statusCode}');
          }
        } catch (e) {
          results.fail('Update action', e);
        }

        // Test 4.4: Delete Action
        try {
          final response = await client.dio.delete('/form/$formId/action/$actionId');
          if (response.statusCode == 200 || response.statusCode == 204) {
            results.pass('Delete action');
          } else {
            results.fail('Delete action', 'Status: ${response.statusCode}');
          }
        } catch (e) {
          results.fail('Delete action', e);
        }
      } else {
        results.skip('Update action', 'No action created');
        results.skip('Delete action', 'No action created');
      }
    } else {
      results.skip('List actions', 'No test form');
      results.skip('Create action', 'No test form');
      results.skip('Update action', 'No test form');
      results.skip('Delete action', 'No test form');
    }

    // ========================================================================
    // TEST GROUP 5: Logout
    // ========================================================================
    print('\n🚪 TEST GROUP 5: Logout');
    print('─' * 60);

    try {
      final response = await client.dio.get('/user/logout');
      if (response.statusCode == 200) {
        client.clearAuthToken();
        results.pass('Logout');
      } else {
        results.fail('Logout', 'Status: ${response.statusCode}');
      }
    } catch (e) {
      results.fail('Logout', e);
    }

    // Display final summary
    results.summary();

    print('\n✅ Test suite completed successfully!');
  } catch (e, stackTrace) {
    print('\n❌ CRITICAL ERROR: $e');
    print('Stack trace:');
    print(stackTrace);
    results.summary();
    exit(1);
  }
}
