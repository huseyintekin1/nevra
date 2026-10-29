import json
import pathlib
import re

root = pathlib.Path(".")
with open("Sources/NevraCore/Resources/Turkish.json", "r", encoding="utf-8") as f:
    turkish = json.load(f)

patterns = [
    re.compile(r'\b(?:Text|Label|Button|GroupBox|Picker|Toggle|Section)\s*\(\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r'\bLText\s*\(\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r'addItem\(withTitle:\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
]

untranslated = {}
for swift_file in (root / "Sources/NevraApp").rglob("*.swift"):
    content = swift_file.read_text(encoding="utf-8")
    for pat in patterns:
        for m in pat.finditer(content):
            val = m.group(1).replace(r'\"', '"').replace(r'\n', '\n')
            if not val or not re.search(r"[A-Za-z]{2,}", val):
                continue
            if val not in turkish and val.lower() not in [k.lower() for k in turkish]:
                untranslated[val] = swift_file.name

print(f"Total untranslated UI strings found: {len(untranslated)}")
for s, f in sorted(untranslated.items()):
    print(f"  [{f}] \"{s}\"")
