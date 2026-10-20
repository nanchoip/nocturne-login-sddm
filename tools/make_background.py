#!/usr/bin/env python3
"""Genera el fondo por defecto (colinas y sol malva, paleta Catppuccin Mocha).

Uso:  python tools/make_background.py
"""
import os
import random

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "nocturne-login", "backgrounds", "default.png")
W, H = 1920, 1080

im = Image.new("RGB", (W, H), (30, 30, 46))
d = ImageDraw.Draw(im, "RGBA")

random.seed(7)
for _ in range(140):
    x, y = random.randint(0, W), random.randint(0, int(H * 0.55))
    r = random.choice((1, 1, 2))
    d.ellipse((x - r, y - r, x + r, y + r), fill=(205, 214, 244, random.randint(60, 160)))

cx, cy = int(W * 0.36), int(H * 0.58)
d.ellipse((cx - 190, cy - 190, cx + 190, cy + 190), fill=(245, 194, 231, 70))
d.ellipse((cx - 120, cy - 120, cx + 120, cy + 120), fill=(203, 166, 247, 130))

d.polygon([(0, 690), (260, 520), (520, 660), (800, 480), (1080, 690), (1380, 540),
           (1650, 660), (W, 590), (W, H), (0, H)], fill=(49, 50, 68, 255))
d.polygon([(0, 830), (320, 700), (640, 820), (960, 690), (1280, 820), (1600, 710),
           (W, 800), (W, H), (0, H)], fill=(69, 71, 90, 190))
d.polygon([(0, 950), (420, 880), (840, 960), (1260, 890), (1680, 955), (W, 920),
           (W, H), (0, H)], fill=(24, 24, 37, 255))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
im.save(OUT, optimize=True)
print("Fondo creado:", OUT, os.path.getsize(OUT) // 1024, "KB")
