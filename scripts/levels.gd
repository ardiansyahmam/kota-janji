## Levels — data 8 level + bank keluhan warga (6 per level, sesuai spec).
class_name Levels

const COMPLAINTS := {
	1: [
		"Lubang ini sudah langganan, tiap hujan jadi kolam.",
		"Motor saya oleng tiap lewat sini, Pak!",
		"Katanya ditambal bulan lalu. Ini tambalannya mana?",
		"Anak saya jatuh dari sepeda di sini kemarin.",
		"Mobil lewat, air lubang nyiprat ke warung saya.",
		"Sudah tiga kali lapor, balasannya: 'diproses'.",
	],
	2: [
		"Rapat dari pagi, keputusannya... besok katanya.",
		"Saya antre dari jam 8, dipanggil jam 2.",
		"Syaratnya nambah terus, tiap datang beda lagi.",
		"Fotokopi 10 rangkap, ujungnya cuma distempel.",
		"Nomor antrean saya loncat terus, entah kenapa.",
		"Ruang tunggunya panas, kipasnya pajangan.",
	],
	3: [
		"Katanya selesai tahun lalu. Ini tahun apa?",
		"Pagar proyeknya lebih awet dari proyeknya.",
		"Debu dari sini masuk rumah tiap hari.",
		"Jalan ditutup setahun, muternya jauh sekali.",
		"Alat beratnya tidur, tukangnya entah ke mana.",
		"Papan proyeknya sudah luntur, tulisannya hilang.",
	],
	4: [
		"Lampu mati, pulang malam jadi uji nyali.",
		"Sudah lapor, katanya 'menunggu giliran'.",
		"Anak saya takut lewat sini kalau sudah magrib.",
		"Lampu sebelah nyala, yang sini kok gelap terus?",
		"Jualan saya sepi, pembeli takut mampir gelap-gelap.",
		"Tiangnya ada, lampunya... pensiun?",
	],
	5: [
		"Busnya lewat... kemarin. Hari ini belum.",
		"Jadwal di halte cuma pajangan, busnya suka-suka.",
		"Ojek harganya naik kalau bus tak datang-datang.",
		"Saya nunggu sejam, yang lewat cuma debu.",
		"Halte-nya ada, atapnya bocor, bangkunya patah.",
		"Sekolah anak saya jauh, angkotnya jarang.",
	],
	6: [
		"Dulu rame, sekarang cuma angin yang nonton.",
		"Rumputnya tinggi, gawangnya tinggal tiang.",
		"Katanya mau ada event, tahun berganti, event tak datang.",
		"Pedagang di sini gulung tikar satu per satu.",
		"Tiketnya dicetak, penontonnya... mana?",
		"Anak saya tanya: stadion ini buat apa, Yah?",
	],
	7: [
		"Asap masuk rumah lagi, masker tinggal dua.",
		"Anak saya batuk semalaman, sekolah diliburkan.",
		"Jemuran tak pernah kering, baunya asap semua.",
		"Posko bagi masker, antreannya panjang sekali.",
		"Tiap tahun begini, tiap tahun juga menunggu.",
		"Saya cuma minta udara bersih, itu saja.",
	],
	8: [
		"Janjinya dicetak, buktinya masih dicari.",
		"Spanduknya baru, isinya janji lama.",
		"Peresmian sudah tiga kali, gedungnya itu-itu juga.",
		"Saya simpan semua janji, tebalnya sudah kayak buku.",
		"Katanya 'segera', segera itu kapan?",
		"Pita digunting, masalahnya tetap di sini.",
	],
}

static func _coins(xs: Array) -> Array:
	var out := []
	for x in xs:
		out.append([x, 730])
	return out

static func get_level(n: int) -> Dictionary:
	match n:
		1:
			return {
				"name": "LEVEL 1 — JALAN BERLUBANG",
				"objective": "Kumpulkan 10 Dokumen Hilang",
				"width": 2800, "par_time": 180,
				"ground": [[0, 500], [620, 1200], [1320, 1900], [2020, 2800]],
				"platforms": [[300, 620, 120], [900, 540, 120], [1500, 620, 120], [2200, 540, 120]],
				"docs": [[350, 580], [700, 730], [950, 500], [1100, 730], [1400, 580], [1600, 730], [1800, 730], [2100, 500], [2350, 730], [2600, 730]],
				"coins": _coins([200, 450, 800, 1050, 1300, 1550, 1750, 2000, 2250, 2500, 2700]),
				"checkpoints": [1250, 2050],
				"npcs": [450, 1500, 2400],
				"required": {"doc": 10},
				"hearts": [[1700, 620]],
			}
		2:
			return {
				"name": "LEVEL 2 — KANTOR RAPAT",
				"objective": "Kumpulkan 5 Stempel Sakti",
				"width": 2600, "par_time": 200,
				"ground": [[0, 2600]],
				"platforms": [[400, 620, 120], [1000, 540, 120], [1600, 620, 120], [2100, 540, 120]],
				"stamps": [[450, 580], [1050, 500], [1300, 730], [1650, 580], [2150, 500]],
				"coins": _coins([200, 700, 1200, 1800, 2300]),
				"slow_zones": [[800, 300], [1700, 300]],
				"chasers": [900, 1800],
				"checkpoints": [1300],
				"npcs": [600, 1500, 2200],
				"required": {"stamp": 5},
				"hearts": [[2000, 620]],
			}
		3:
			return {
				"name": "LEVEL 3 — PROYEK MANGKRAK",
				"objective": "Kalahkan Pagar Proyek",
				"width": 2400, "par_time": 220,
				"ground": [[0, 2000]],
				"platforms": [[300, 620, 120], [550, 480, 120], [800, 340, 120], [1100, 480, 120], [1400, 620, 120], [1700, 480, 120]],
				"coins": _coins([200, 600, 900, 1200, 1500, 1800]),
				"checkpoints": [1000],
				"npcs": [500, 1300],
				"boss": {"type": "pagar", "x": 2150},
				"required": {},
				"hearts": [[1600, 440]],
			}
		4:
			return {
				"name": "LEVEL 4 — KOTA GELAP",
				"objective": "Kumpulkan 8 bohlam",
				"width": 2600, "par_time": 200,
				"ground": [[0, 2600]],
				"platforms": [[500, 620, 120], [1100, 540, 120], [1700, 620, 120]],
				"bohlam": [[300, 730], [600, 580], [900, 730], [1200, 500], [1500, 730], [1800, 580], [2100, 730], [2400, 730]],
				"coins": _coins([200, 800, 1400, 2000]),
				"checkpoints": [1300],
				"npcs": [700, 1600, 2200],
				"required": {"bohlam": 8},
				"hearts": [[1000, 620]],
			}
		5:
			return {
				"name": "LEVEL 5 — HALTE SEPI",
				"objective": "Naik bus & sampai ujung",
				"width": 2600, "par_time": 220,
				"ground": [[0, 1100], [1500, 2600]],
				"platforms": [[400, 620, 120], [800, 540, 120]],
				"bus": {"x": 1100, "y": 620, "w": 340, "on_time": 6.0, "off_time": 10.0},
				"coins": _coins([200, 600, 1000, 1700, 2100, 2400]),
				"checkpoints": [1000, 1600],
				"npcs": [500, 900, 2000],
				"required": {},
				"hearts": [[1900, 620]],
			}
		6:
			return {
				"name": "LEVEL 6 — STADION SEPI",
				"objective": "Tiket 3, spanduk 3, panggung 3",
				"width": 2600, "par_time": 220,
				"ground": [[0, 2600]],
				"platforms": [[400, 620, 140], [900, 480, 140], [1400, 620, 140], [1900, 480, 140]],
				"tickets": [[450, 580], [1450, 580], [2300, 730]],
				"banners": [[950, 440], [1950, 440], [1200, 730]],
				"stage": [[600, 730], [1700, 730], [2100, 730]],
				"coins": _coins([200, 800, 1500, 2200]),
				"checkpoints": [1300],
				"npcs": [700, 1600, 2200],
				"required": {"ticket": 3, "banner": 3, "stage": 3},
				"hearts": [[1000, 620]],
			}
		7:
			return {
				"name": "LEVEL 7 — LANGIT KUNING",
				"objective": "Sampai ke posko akhir",
				"width": 2600, "par_time": 220,
				"ground": [[0, 2600]],
				"platforms": [[500, 620, 120], [1100, 540, 120], [1700, 620, 120]],
				"haze_zones": [[600, 500], [1500, 500]],
				"masks": [[700, 730], [1100, 500], [1600, 730], [2100, 730]],
				"coins": _coins([200, 800, 1400, 2000]),
				"checkpoints": [700, 1500, 2200],
				"npcs": [500, 1300, 2000],
				"required": {},
				"hearts": [[1000, 620]],
			}
		8:
			return {
				"name": "LEVEL 8 — GEDUNG JANJI",
				"objective": "Serahkan 3 Dokumen ke Kotak Fakta",
				"width": 2400, "par_time": 260,
				"ground": [[0, 2400]],
				"platforms": [[400, 620, 120], [1000, 540, 120], [1500, 620, 120]],
				"coins": _coins([200, 800, 1400, 1800]),
				"checkpoints": [1200],
				"npcs": [600, 1400],
				"boss": {"type": "mesin", "x": 2050},
				"required": {},
				"hearts": [[1600, 580]],
			}
	return get_level(1)
