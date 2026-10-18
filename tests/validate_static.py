"""Portable integrity checks, not Windows integration tests.
Run: python tests/validate_static.py
Optional PS grammar: pip install tree-sitter tree-sitter-powershell
"""
from pathlib import Path
import csv,ipaddress,json,re
root=Path(__file__).resolve().parents[1]
c=json.loads((root/'config/topology.json').read_text())
assert c['domain']=='corp.lab.test'
ips=[x['ip'] for x in c['nodes']]
assert len(ips)==len(set(ips))
for n in c['nodes']:
 net=ipaddress.ip_network(n['ip']+'/24',strict=False)
 assert ipaddress.ip_address(n['gateway']) in net
 assert ipaddress.ip_address(n['ip']) in ipaddress.ip_network('10.77.0.0/16')
print('PASS topology consistency')
for file in root.rglob('*.md'):
 for url in re.findall(r'\]\(([^)]+)\)',file.read_text()):
  if '://' not in url and not url.startswith('#'):
   assert (file.parent/url.split('#')[0]).exists(),(file,url)
print('PASS local Markdown links')
for file in (root/'templates').glob('*.csv'):
 rows=list(csv.reader(file.open()))
 assert all(len(x)==len(rows[0]) for x in rows),(file,[len(x) for x in rows])
print('PASS CSV schemas')
ledger=list(csv.DictReader((root/'templates/execution-ledger.csv').open()))
assert all(x['status']=='NOT RUN' for x in ledger)
print('PASS execution status remains unclaimed')
try:
 from tree_sitter import Language,Parser
 import tree_sitter_powershell
except ImportError:
 print('SKIP PowerShell grammar: optional parser not installed')
else:
 parser=Parser(Language(tree_sitter_powershell.language()))
 for file in (root/'scripts').glob('*.ps1'):
  tree=parser.parse(file.read_bytes())
  assert not tree.root_node.has_error, (file,tree.root_node)
 print('PASS PowerShell tree-sitter grammar (9 scripts; not runtime validation)')
