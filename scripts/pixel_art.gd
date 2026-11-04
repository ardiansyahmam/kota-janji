## PixelArt — membangun ImageTexture dari peta string (1 char = 1 pixel).
class_name PixelArt

const PALETTE := {
	"R": Color(1.0, 0.278, 0.341),   # merah (topi, hati)
	"S": Color(1.0, 0.85, 0.627),    # kulit
	"B": Color(0.20, 0.50, 0.95),    # biru (baju Jaka)
	"D": Color(0.45, 0.44, 0.60),    # abu (celana)
	"K": Color(0.05, 0.05, 0.10),    # hitam (mata, lubang)
	"Y": Color(1.0, 0.824, 0.247),   # kuning (koin)
	"W": Color(1.0, 0.965, 0.898),   # krem (kertas, bubble)
	"G": Color(0.18, 0.80, 0.443),   # hijau
	"g": Color(0.10, 0.45, 0.27),    # hijau gelap
	"O": Color(1.0, 0.55, 0.10),     # oranye (lentera)
}

static func texture_from_map(rows: Array, px: int = 8) -> ImageTexture:
	var h := rows.size()
	var w := String(rows[0]).length()
	var img := Image.create(w * px, h * px, false, Image.FORMAT_RGBA8)
	for y in h:
		var row := String(rows[y])
		for x in w:
			var ch := row[x]
			if ch == ".":
				continue
			var col: Color = PALETTE.get(ch, Color.WHITE)
			for dy in px:
				for dx in px:
					img.set_pixel(x * px + dx, y * px + dy, col)
	var tex := ImageTexture.create_from_image(img)
	return tex

static func sprite(rows: Array, px: int = 8) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = texture_from_map(rows, px)
	s.centered = false
	return s

## Peta sprite standar (sesuai Figma: topi merah, baju biru).
const HERO := [
	".RRR.",
	"RRRRR",
	".SSS.",
	".KSK.",
	".BBB.",
	"SBBBS",
	".D.D.",
	".D.D.",
]

static func hero_texture(cap: String = "R", shirt: String = "B") -> ImageTexture:
	var rows := []
	for r in HERO:
		var row := String(r).replace("R", cap).replace("B", shirt)
		rows.append(row)
	return texture_from_map(rows, 8)

const HEART := [
	"RR.RR",
	"RRRRR",
	"RRRRR",
	".RRR.",
	"..R..",
]

const COIN := [
	".Y.",
	"YYY",
	".Y.",
]

const DOC := [
	"WWWWW",
	"WDDDW",
	"WDDDW",
	"WWWWW",
	"WWWWW",
	"WWWWW",
]
