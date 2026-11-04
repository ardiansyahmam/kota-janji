## SaveSys — simpan lokal JSON (user://save.json). Tanpa akun, tanpa server.
class_name SaveSys

const PATH := "user://save.json"

static func default_data() -> Dictionary:
	return {
		"version": 1,
		"unlocked_level": 1,
		"stars": {},
		"total_coins": 0,
		"settings": {"sfx": true, "music": true, "vibrate": true, "reduced_motion": false},
		"jokes_found": [],
	}

static func load_data() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return default_data()
	var f := FileAccess.open(PATH, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		var d := default_data()
		d.merge(parsed, true)
		return d
	return default_data()

static func save_data(data: Dictionary) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()
