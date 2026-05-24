import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/localization_provider.dart';
import '../../shared/services/diagnosis_history_service.dart';
import '../diagnosis/diagnosis_result_screen.dart';

class MyDiagnosesScreen extends ConsumerWidget {
  const MyDiagnosesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    final diagnosesAsync = ref.watch(userDiagnosesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['my_diagnoses']!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: diagnosesAsync.when(
        data: (diagnoses) {
          if (diagnoses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No diagnoses saved yet.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diagnoses.length,
            itemBuilder: (context, index) {
              final diag = diagnoses[index];
              final dateStr = DateFormat.yMMMd().add_jm().format(diag.timestamp);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: diag.isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      image: diag.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(diag.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: diag.imageUrl == null
                        ? Icon(
                            diag.isHealthy ? Icons.eco : Icons.warning_amber_rounded,
                            color: diag.isHealthy ? const Color(0xFF1B5E20) : const Color(0xFFC62828),
                            size: 32,
                          )
                        : null,
                  ),
                  title: Text(
                    diag.diseaseName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diag.cropName, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: diag.isHealthy 
                          ? const Color(0xFF43A047).withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '${diag.confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: diag.isHealthy ? const Color(0xFF2E7D32) : Colors.orange[900],
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiagnosisResultScreen(
                          diseaseName: diag.diseaseName,
                          confidence: diag.confidence,
                          cropName: diag.cropName,
                          imagePath: diag.imageUrl ?? '', // Use url if available
                          severity: diag.severity,
                          initialData: diag.aiReportData, // Pass the saved report!
                          isFromHistory: true, // Prevent saving again
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
        error: (e, st) => Center(child: Text('Error loading diagnoses: $e')),
      ),
    );
  }
}
