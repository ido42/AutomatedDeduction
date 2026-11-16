"""Write one TPTP problem file per conjecture of FoodChains.p.

Food Chains conjectures get only the axioms above them.
Freshwater Pond conjectures get all the axioms.
Each file also gets a "_negated" twin, for checking non-theorems.

Usage:  python3 split_conjectures.py FoodChains.p
Then:   vampire --mode casc -t 300 problems/pond_5.p
"""
import os, re, sys

def formulas(text):
    body = "\n".join(l for l in text.splitlines() if not l.lstrip().startswith("%"))
    head = re.compile(r"tff\(\s*(\w+)\s*,\s*(\w+)\s*,")
    i, out = 0, []
    while (m := head.search(body, i)):
        depth, j = 0, m.start()
        while True:
            depth += {"(": 1, ")": -1}.get(body[j], 0)
            if depth == 0 and body[j] == ")":
                break
            j += 1
        out.append((m.group(1), m.group(2), body[m.start():j + 2]))
        i = j + 2
    return out

forms = formulas(open(sys.argv[1]).read())
pond_start = [n for n, _, _ in forms].index("algae_type")
os.makedirs("problems", exist_ok=True)
for k, (name, role, text) in enumerate(forms):
    if role != "conjecture":
        continue
    axioms = [f for i, (_, r, f) in enumerate(forms)
              if r != "conjecture" and (k > pond_start or i < k)]
    inner = re.match(r"tff\(\s*\w+\s*,\s*\w+\s*,(.*)\)\.\s*$", text, re.S).group(1)
    negated = "tff(%s_negated,conjecture,\n    ~ (%s) )." % (name, inner.strip())
    for suffix, conj in (("", text), ("_negated", negated)):
        with open("problems/%s%s.p" % (name, suffix), "w") as f:
            f.write("\n\n".join(axioms + [conj]) + "\n")
print("Wrote", len(os.listdir("problems")), "files to problems/")
