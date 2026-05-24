import os

LOCALIZATION_KEYS = {
    'Crops': "strings['lib_crops'] ?? 'Crops'",
    'Learn about optimal growing conditions, soil parameters, crop companions and rotation for successful cultivation.': "strings['lib_crops_desc'] ?? 'Learn about optimal growing conditions, soil parameters, crop companions and rotation for successful cultivation.'",
    'Fertilizer Calculator': "strings['lib_fert_calc'] ?? 'Fertilizer Calculator'",
    'See relevant information on': "strings['lib_see_info'] ?? 'See relevant information on'",
    'Nutrient quantities': "strings['lib_nutrient_qty'] ?? 'Nutrient quantities'",
    'Nitrogen': "strings['lib_nitrogen'] ?? 'Nitrogen'",
    'Phosphorus': "strings['lib_phosphorus'] ?? 'Phosphorus'",
    'Potassium': "strings['lib_potassium'] ?? 'Potassium'",
    'per plant': "strings['lib_per_plant'] ?? 'per plant'",
    'Number of plants': "strings['lib_num_plants'] ?? 'Number of plants'",
    'Plot size': "strings['lib_plot_size'] ?? 'Plot size'",
    'Plants': "strings['lib_plants'] ?? 'Plants'",
    'Acres': "strings['lib_acres'] ?? 'Acres'",
    'Hectares': "strings['lib_hectares'] ?? 'Hectares'",
    'Calculate': "strings['lib_calculate'] ?? 'Calculate'",
    'Total fertilizer needed': "strings['lib_total_fert'] ?? 'Total fertilizer needed'",
    'Application Schedule': "strings['lib_app_schedule'] ?? 'Application Schedule'",
    'Save Plan': "strings['lib_save_plan'] ?? 'Save Plan'",
    'Application Tips': "strings['lib_app_tips'] ?? 'Application Tips'",
    'Search crops...': "strings['lib_search_crops'] ?? 'Search crops...'",
    'Pests & Diseases': "strings['lib_pests_diseases'] ?? 'Pests & Diseases'",
    'Common Threats': "strings['lib_common_threats'] ?? 'Common Threats'",
    'Symptoms': "strings['lib_symptoms'] ?? 'Symptoms'",
    'Treatment & Prevention': "strings['lib_treatment'] ?? 'Treatment & Prevention'",
    'Cultivation Tips': "strings['lib_cultivation_tips'] ?? 'Cultivation Tips'",
    'Essential guides for farming success': "strings['lib_cultivation_desc'] ?? 'Essential guides for farming success'",
    'Add Crops': "strings['lib_add_crops'] ?? 'Add Crops'",
    'Select the crops you want to track': "strings['lib_select_crops'] ?? 'Select the crops you want to track'"
}

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # Imports
    if 'flutter_riverpod' not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../../core/localization_provider.dart';")
    else:
        if 'localization_provider.dart' not in content:
            content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../../core/localization_provider.dart';")

    # State replacements
    if 'extends StatelessWidget' in content:
        content = content.replace('extends StatelessWidget', 'extends ConsumerWidget')
        content = content.replace('Widget build(BuildContext context) {', 'Widget build(BuildContext context, WidgetRef ref) {\n    ref.watch(localizationProvider);\n    final strings = ref.watch(localizationProvider.notifier).strings;')
    
    if 'extends StatefulWidget' in content:
        content = content.replace('extends StatefulWidget', 'extends ConsumerStatefulWidget')
    if 'extends State<' in content:
        content = content.replace('extends State<', 'extends ConsumerState<')
        if 'Widget build(BuildContext context) {' in content:
            content = content.replace('Widget build(BuildContext context) {', 'Widget build(BuildContext context) {\n    ref.watch(localizationProvider);\n    final strings = ref.watch(localizationProvider.notifier).strings;')
        elif 'Widget build(BuildContext ctx) {' in content: # specific for nested states
            content = content.replace('Widget build(BuildContext ctx) {', 'Widget build(BuildContext ctx) {\n    // ref is available in ConsumerState\n    ref.watch(localizationProvider);\n    final strings = ref.watch(localizationProvider.notifier).strings;')

    # String replacements
    for key, val in LOCALIZATION_KEYS.items():
        # Handle simple string matches inside Text('Key') or Text("Key")
        # Text('xxx')
        content = content.replace(f"Text('{key}'", f"Text({val}")
        content = content.replace(f"Text(\"{key}\"", f"Text({val}")
        
        # specific for hintText: 'xxx'
        content = content.replace(f"hintText: '{key}'", f"hintText: {val}")

    # Write back
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

# Target files
base_dir = r"c:\Users\Placi\OneDrive\Desktop\AgriDx project 1\flutter_application_1\lib\features\library"
files = [
    "crop_list_screen.dart",
    "fertilizer_calculator_screen.dart",
    "pests_diseases_screen.dart",
    "cultivation_tips_screen.dart",
    "crop_selector_screen.dart"
]

for f in files:
    update_file(os.path.join(base_dir, f))
