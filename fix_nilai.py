import re

with open('lib/data/app_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# We want to replace all 'Nilai(' that don't have 'statusKrs' with ones that have 'statusKrs: 'valid''
parts = content.split('Nilai(')
new_parts = [parts[0]]
for part in parts[1:]:
    if 'statusKrs:' not in part:
        # replace the last '    ),' with '      statusKrs: 'valid',\n    ),'
        part = part.replace('\n    ),', ",\n      statusKrs: 'valid',\n    ),", 1)
    new_parts.append(part)

content = 'Nilai('.join(new_parts)

# Also fix the double commas that might have been introduced
content = content.replace(',,\n', ',\n')

with open('lib/data/app_data.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated app_data.dart')
