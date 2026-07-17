from PIL import Image, ImageDraw

for size in (48, 96):
    s = size
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    pad = max(2, s // 24)
    radius = s // 5
    d.rounded_rectangle((pad, pad, s-pad-1, s-pad-1), radius=radius, fill=(13,13,13,255), outline=(255,255,255,255), width=max(1,s//32))
    pts = [(int(.57*s), int(.18*s)), (int(.31*s), int(.53*s)), (int(.46*s), int(.53*s)), (int(.39*s), int(.81*s)), (int(.70*s), int(.40*s)), (int(.53*s), int(.40*s))]
    d.polygon(pts, fill=(255,255,255,255))
    im.save(f'/data/dulban/firefox-extension/icon{size}.png')
