import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SavedFertilizerPlansScreen extends StatefulWidget {
  const SavedFertilizerPlansScreen({super.key});

  @override
  State<SavedFertilizerPlansScreen> createState() => _SavedFertilizerPlansScreenState();
}

class _SavedFertilizerPlansScreenState extends State<SavedFertilizerPlansScreen> {
  late Box _box;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    _box = await Hive.openBox('saved_plans');
    setState(() {
      _isLoading = false;
    });
  }

  void _deletePlan(int index) {
    _box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Fertilizer Plans',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _box.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No saved plans yet.', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _box.length,
                  itemBuilder: (context, index) {
                    final plan = _box.getAt(index) as Map;
                    return _buildPlanCard(plan, index);
                  },
                ),
    );
  }

  Widget _buildPlanCard(Map plan, int index) {
    final dateStr = plan['date'] ?? DateTime.now().toIso8601String();
    final date = DateTime.parse(dateStr);
    
    // Check if the plan is old format (just N, P, K) or new format (Urea, DAP, MOP)
    final hasCommercial = plan.containsKey('urea') && plan.containsKey('dap');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Color(0xFF1B5E20), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['cropName'] ?? 'Unknown Crop',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      DateFormat.yMMMd().format(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Plan?'),
                      content: const Text('Are you sure you want to delete this saved fertilizer plan?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            _deletePlan(index);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (plan.containsKey('area')) 
            Text('Plot Size: ${plan['area']} ${plan['areaUnit']}', style: const TextStyle(fontWeight: FontWeight.w500))
          else if (plan.containsKey('plants'))
            Text('Plants: ${plan['plants']}', style: const TextStyle(fontWeight: FontWeight.w500)),
            
          const Divider(height: 24),
          
          if (hasCommercial) ...[
            const Text('Recommended Fertilizers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _resultRow('Urea (46-0-0)', plan['urea'] ?? 0, Colors.blue),
            _resultRow('DAP (18-46-0)', plan['dap'] ?? 0, Colors.orange[800]!),
            _resultRow('MOP (0-0-60)', plan['mop'] ?? 0, Colors.green[700]!),
          ] else ...[
            const Text('Raw Nutrients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _resultRow('N (Nitrogen)', plan['n'] ?? 0, Colors.blue),
            _resultRow('P (Phosphorus)', plan['p'] ?? 0, Colors.orange[800]!),
            _resultRow('K (Potassium)', plan['k'] ?? 0, Colors.green[700]!),
          ],
        ],
      ),
    );
  }
  
  Widget _resultRow(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text('${val.toStringAsFixed(1)} kg',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
