import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    # 1. Remove 'const' before Text(...) if it contains 'strings['
    content = re.sub(r'const\s+Text\(\s*strings\[', r'Text(strings[', content)
    
    # 2. Add 'strings' to helper methods that use it
    # Find all method definitions
    methods = re.findall(r'(Widget\s+_[a-zA-Z0-9_]+\s*\([^)]*\))\s*\{', content)
    for method in methods:
        method_body_start = content.find(method) + len(method)
        # Find next method or end of file to isolate body
        next_method_match = re.search(r'\n\s*Widget\s+_[a-zA-Z0-9_]+\s*\(', content[method_body_start:])
        method_body_end = method_body_start + next_method_match.start() if next_method_match else len(content)
        
        body = content[method_body_start:method_body_end]
        if 'strings[' in body:
            # Method uses strings, but does it have it in params?
            if 'Map<String, String> strings' not in method:
                # Add strings to params
                if '(' in method and ')' in method:
                    new_method = method.replace(')', ', required Map<String, String> strings)') if '}' not in method else method
                    if '{' in method and '}' in method and 'required' not in method: # basic params
                        if method.endswith('()'):
                            new_method = method.replace('()', '(Map<String, String> strings)')
                        else:
                            new_method = method.replace(')', ', Map<String, String> strings)')
                    
                    # Update method definition
                    content = content.replace(method, new_method)
                    
                    # Now update all CALLS to this method
                    method_name = re.search(r'(_[a-zA-Z0-9_]+)', method).group(1)
                    # This is tricky with regex, instead we can just do a hack:
                    # In ConsumerWidget/ConsumerState, instead of passing strings, let's just 
                    # define a getter if it's a ConsumerState.

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")

base_dir = r"c:\Users\Placi\OneDrive\Desktop\AgriDx project 1\flutter_application_1\lib\features\library"
for f in os.listdir(base_dir):
    if f.endswith('.dart'):
        fix_file(os.path.join(base_dir, f))
