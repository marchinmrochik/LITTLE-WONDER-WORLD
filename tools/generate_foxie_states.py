"""Derive project-original expression/pose variants from the approved Foxie vector."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
folder = ROOT / "assets/characters"
base = (folder / "foxie.svg").read_text(encoding="utf-8")
left_eye = '<ellipse cx="182" cy="232" rx="18" ry="23" fill="#293d39"/>'
right_eye = '<ellipse cx="324" cy="232" rx="18" ry="23" fill="#293d39"/>'
left_closed = '<path d="M164 236q18-18 36 0" fill="none" stroke="#293d39" stroke-width="7" stroke-linecap="round"/>'
right_closed = '<path d="M306 236q18-18 36 0" fill="none" stroke="#293d39" stroke-width="7" stroke-linecap="round"/>'
left_light = '<ellipse cx="176" cy="225" rx="6" ry="8" fill="#fffdf4"/>'
right_light = '<ellipse cx="318" cy="225" rx="6" ry="8" fill="#fffdf4"/>'
right_arm = '<path d="M314 396c27 11 44 47 33 62-10 15-25 8-39-8l-19-36" fill="#e78a50"/>'
wave_arm = '<path d="M306 406c31-7 54-40 58-80 2-20 28-18 27 4-1 65-28 112-66 122z" fill="#e78a50"/><ellipse cx="377" cy="321" rx="17" ry="20" fill="#efab70"/>'
left_arm = '<path d="M185 399c-27 12-39 56-29 70 12 15 32 6 43-13l18-44" fill="#ee9a5a"/>'
raised_left = '<path d="M194 403c-35-12-53-42-53-80-1-22-29-23-31 1-4 59 26 110 64 128z" fill="#ee9a5a"/><ellipse cx="125" cy="319" rx="17" ry="20" fill="#f3b77b"/>'
happy = base.replace(left_eye, left_closed).replace(right_eye, right_closed).replace(left_light, "").replace(right_light, "")
happy = happy.replace('<path d="M254 297v12m0 0q-12 13-24 2m24-2q11 13 24 2" fill="none" stroke="#915b42" stroke-width="5" stroke-linecap="round"/>', '<path d="M233 309q21 32 42 0z" fill="#915b42"/><path d="M243 321q12-8 24 0" stroke="#eeb3a2" stroke-width="6" stroke-linecap="round"/>')
variants = {
    "happy": happy,
    "waving": base.replace(right_arm, wave_arm),
    "thinking": base.replace('M165 196q17-12 30 0M310 196q17-12 30 0', 'M165 190q17-7 30 4M310 195q17-19 30-6'),
    "encouraging": base.replace(left_eye, left_closed).replace(left_light, ""),
    "celebrating": happy.replace(right_arm, wave_arm).replace(left_arm, raised_left),
}
for state, svg in variants.items():
    (folder / f"foxie_{state}.svg").write_text(svg, encoding="utf-8")
print("Generated five Foxie states; approved idle/resting assets retained.")
