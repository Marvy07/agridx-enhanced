import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'crops_data.dart';
import 'saved_fertilizer_plans_screen.dart';

enum InputMode { plants, area }
enum AreaUnit { acres, hectares }

class FertilizerCalculatorScreen extends ConsumerStatefulWidget {
  final CropDetails? initialCrop;

  const FertilizerCalculatorScreen({super.key, this.initialCrop});

  @override
  ConsumerState<FertilizerCalculatorScreen> createState() => _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends ConsumerState<FertilizerCalculatorScreen> {
  Map<String, String> get strings => ref.watch(localizationProvider.notifier).strings;
  
  late CropDetails _selectedCrop;
  InputMode _inputMode = InputMode.plants;
  AreaUnit _areaUnit = AreaUnit.acres;

  int _plantCount = 0;
  double _areaValue = 0.0;
  String _soilType = 'Loam';
  
  final List<String> _soilTypes = ['Sandy', 'Loam', 'Clay'];

  double? _totalN;
  double? _totalP;
  double? _totalK;
  double? _ureaNeeded;
  double? _dapNeeded;
  double? _mopNeeded;
  int _calculatedPlants = 0;

  @override
  void initState() {
    super.initState();
    _selectedCrop = widget.initialCrop ?? availableCrops.first;
  }

  void _calculate() {
    double areaHectares = 0.0;

    if (_inputMode == InputMode.plants) {
      if (_plantCount <= 0) {
        _showError('Please enter the number of plants');
        return;
      }
      _calculatedPlants = _plantCount;
      double acres = _calculatedPlants / _selectedCrop.plantsPerAcre;
      areaHectares = acres / 2.471;
    } else {
      if (_areaValue <= 0) {
        _showError('Please enter the plot size');
        return;
      }
      double acres = _areaUnit == AreaUnit.acres ? _areaValue : _areaValue * 2.471;
      _calculatedPlants = (acres * _selectedCrop.plantsPerAcre).round();
      areaHectares = _areaUnit == AreaUnit.hectares ? _areaValue : _areaValue / 2.471;
    }

    double nBase = _parseValue(_selectedCrop.n) * areaHectares;
    double pBase = _parseValue(_selectedCrop.p) * areaHectares;
    double kBase = _parseValue(_selectedCrop.k) * areaHectares;

    if (_soilType == 'Sandy') {
      nBase *= 1.15; // Sandy soils leach nitrogen fast, require more.
      kBase *= 1.10;
    }

    double dapNeeded = pBase / 0.46;
    double nFromDap = dapNeeded * 0.18;
    
    double remainingN = nBase - nFromDap;
    if (remainingN < 0) remainingN = 0;
    double ureaNeeded = remainingN / 0.46;
    
    double mopNeeded = kBase / 0.60;

    setState(() {
      _totalN = nBase;
      _totalP = pBase;
      _totalK = kBase;
      _ureaNeeded = ureaNeeded;
      _dapNeeded = dapNeeded;
      _mopNeeded = mopNeeded;
    });
  }

  double _parseValue(String val) {
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _savePlan() async {
    final box = await Hive.openBox('saved_plans');
    final plan = {
      'cropName': _selectedCrop.name,
      'date': DateTime.now().toIso8601String(),
      'plants': _calculatedPlants,
      if (_inputMode == InputMode.area) 'area': _areaValue,
      if (_inputMode == InputMode.area) 'areaUnit': _areaUnit == AreaUnit.acres ? 'Acres' : 'Hectares',
      'n': _totalN,
      'p': _totalP,
      'k': _totalK,
      'urea': _ureaNeeded,
      'dap': _dapNeeded,
      'mop': _mopNeeded,
      'soilType': _soilType,
    };
    await box.add(plan);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fertilizer plan saved successfully!'), backgroundColor: Color(0xFF1B5E20)),
    );
  }

  void _showCropSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _CropSelectorSheet(
        selectedCrop: _selectedCrop,
        onCropSelected: (crop) {
          setState(() {
            _selectedCrop = crop;
            _totalN = null;
            _totalP = null;
            _totalK = null;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fertilizer Calculator', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedFertilizerPlansScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCropHeader(),
            const SizedBox(height: 24),
            _buildStepHeader('1', 'Nutrient requirements'),
            const SizedBox(height: 12),
            _buildNPKRow(),
            const SizedBox(height: 28),
            _buildInputModeToggle(),
            const SizedBox(height: 16),
            if (_inputMode == InputMode.plants) _buildPlantCounter() else _buildAreaInput(),
            const SizedBox(height: 16),
            _buildSoilTypeDropdown(),
            const SizedBox(height: 24),
            _buildCalculateButton(),
            const SizedBox(height: 24),
            if (_totalN != null) ...[
              _buildResultsCard(),
              const SizedBox(height: 16),
              _buildSaveButton(),
            ],
            const SizedBox(height: 24),
            _buildTipsCard(),
            const SizedBox(height: 24),
            Center(child: _buildLandscapeIllustration()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCropHeader() {
    return Row(
      children: [
        const Expanded(child: Text('See relevant information on', style: TextStyle(color: Colors.grey, fontSize: 13))),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _showCropSelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Text(_selectedCrop.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(_selectedCrop.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepHeader(String num, String title) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildNPKRow() {
    return Row(
      children: [
        Expanded(child: _buildNPKCard('Nitrogen', _selectedCrop.n, Colors.blue[50]!, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildNPKCard('Phosphorus', _selectedCrop.p, Colors.orange[50]!, Colors.orange[700]!)),
        const SizedBox(width: 12),
        Expanded(child: _buildNPKCard('Potassium', _selectedCrop.k, Colors.green[50]!, Colors.green)),
      ],
    );
  }

  Widget _buildNPKCard(String label, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: text, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value.split(' ')[0], style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.bold)),
          Text('kg/ha base', style: TextStyle(color: Colors.black45, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildInputModeToggle() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _toggleItem('Number of plants', InputMode.plants)),
          Expanded(child: _toggleItem('Plot size', InputMode.area)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, InputMode mode) {
    bool active = _inputMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _inputMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.black : Colors.grey[600])),
      ),
    );
  }

  Widget _buildPlantCounter() {
    return Row(
      children: [
        _circleBtn(Icons.remove, () { if (_plantCount > 0) setState(() => _plantCount -= 100); }),
        Expanded(
          child: Column(
            children: [
              Text('$_plantCount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(strings['lib_plants'] ?? 'Plants', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        _circleBtn(Icons.add, () => setState(() => _plantCount += 100)),
      ],
    );
  }

  Widget _buildAreaInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _unitTab('Acres', AreaUnit.acres),
            const SizedBox(width: 12),
            _unitTab('Hectares', AreaUnit.hectares),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: '0.0', border: InputBorder.none),
          onChanged: (v) => _areaValue = double.tryParse(v) ?? 0,
        ),
      ],
    );
  }

  Widget _unitTab(String label, AreaUnit unit) {
    bool active = _areaUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _areaUnit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFF1B5E20) : Colors.grey[300]!),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey[600], fontSize: 12)),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF1B5E20), size: 28),
      ),
    );
  }

  Widget _buildSoilTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.landscape, color: Colors.brown[600]),
          const SizedBox(width: 16),
          const Text('Soil Type:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _soilType,
                isExpanded: true,
                items: _soilTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _soilType = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(strings['lib_calculate'] ?? 'Calculate', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 10),
              const Text('Shopping List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('For $_calculatedPlants ${_selectedCrop.name} plants (${_soilType} soil)', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          
          const SizedBox(height: 20),
          _resultRow('Urea (46-0-0)', _ureaNeeded!, Colors.blue),
          const SizedBox(height: 12),
          _resultRow('DAP (18-46-0)', _dapNeeded!, Colors.orange[800]!),
          const SizedBox(height: 12),
          _resultRow('MOP (0-0-60)', _mopNeeded!, Colors.green[700]!),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Application Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          
          if (_soilType == 'Sandy') ...[
            _scheduleItem('Week 1 (Planting)', '25%', 'DAP + MOP + 1/4 Urea'),
            _scheduleItem('Week 4 (Vegetative)', '25%', '1/4 Urea'),
            _scheduleItem('Week 6 (Pre-flower)', '25%', '1/4 Urea'),
            _scheduleItem('Week 8 (Flowering)', '25%', '1/4 Urea'),
          ] else ...[
            _scheduleItem('Week 1 (Planting)', '40%', 'All DAP + All MOP + 1/2 Urea'),
            _scheduleItem('Week 4 (Vegetative)', '30%', '1/4 Urea'),
            _scheduleItem('Week 8 (Flowering)', '30%', '1/4 Urea'),
          ],
        ],
      ),
    );
  }

  Widget _resultRow(String label, double val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text('${val.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _scheduleItem(String time, String pct, String amnt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(time, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Text(pct, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(amnt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _savePlan,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1B5E20),
          side: const BorderSide(color: Color(0xFF1B5E20)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(strings['lib_save_plan'] ?? 'Save Plan', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: ExpansionTile(
        title: Text(strings['lib_app_tips'] ?? 'Application Tips', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        leading: const Icon(Icons.lightbulb_outline, color: Colors.orangeAccent),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(_selectedCrop.applicationTips, style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLandscapeIllustration() {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(height: 40, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(50)))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniTree(40),
              _miniTree(60),
              _miniTree(35),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniTree(double h) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 30, height: h, decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(15))),
        Container(width: 4, height: 8, color: Colors.grey[300]),
      ],
    );
  }
}

class _CropSelectorSheet extends ConsumerStatefulWidget {
  final CropDetails selectedCrop;
  final ValueChanged<CropDetails> onCropSelected;

  const _CropSelectorSheet({required this.selectedCrop, required this.onCropSelected});

  @override
  ConsumerState<_CropSelectorSheet> createState() => _CropSelectorSheetState();
}

class _CropSelectorSheetState extends ConsumerState<_CropSelectorSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? availableCrops
        : availableCrops.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (ctx, scroll) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, color: Colors.grey[300]),
            const SizedBox(height: 20),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search crops...',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                controller: scroll,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final crop = filtered[i];
                  bool sel = crop.name == widget.selectedCrop.name;
                  return GestureDetector(
                    onTap: () => widget.onCropSelected(crop),
                    child: Container(
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFE8F5E9) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: sel ? Border.all(color: const Color(0xFF1B5E20), width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(crop.emoji, style: const TextStyle(fontSize: 32)),
                          Text(crop.name, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
