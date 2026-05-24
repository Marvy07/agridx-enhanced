import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    if (file.path.contains('localization_provider.dart')) continue;
    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('ref.read(localizationProvider.notifier).strings')) {
      content = content.replaceAll('ref.read(localizationProvider.notifier).strings', 'ref.watch(localizationProvider.notifier).strings');
      modified = true;
    }

    if (content.contains('Widget build(BuildContext context, WidgetRef ref) {') && 
        content.contains('localizationProvider.notifier') && 
        !content.contains('ref.watch(localizationProvider);')) {
      content = content.replaceFirst('Widget build(BuildContext context, WidgetRef ref) {', 'Widget build(BuildContext context, WidgetRef ref) {\n    ref.watch(localizationProvider);');
      modified = true;
    }

    if (content.contains('builder: (context, ref, child) {') && 
        content.contains('localizationProvider.notifier') && 
        !content.contains('ref.watch(localizationProvider);')) {
      content = content.replaceFirst('builder: (context, ref, child) {', 'builder: (context, ref, child) {\n    ref.watch(localizationProvider);');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Modified ${file.path}');
    }
  }
}
