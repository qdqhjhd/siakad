import re

with open('lib/data/app_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

mock_pending = """
    Nilai(
      nim: '2024010001',
      idKelasKuliah: 'IF-05',
      kodeMataKuliah: 'ILKOM305',
      namaMataKuliah: 'Keamanan Siber',
      sksMataKuliah: 3,
      statusKrs: 'pending',
    ),
"""

# Just add this to the end of daftarNilai list, before the last ];
content = content.replace('  ];\n}', mock_pending + '  ];\n}')

with open('lib/data/app_data.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Added mock pending data')
