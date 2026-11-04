## SFX — bunyi chiptune prosedural (tanpa file audio eksternal).
class_name SFX

static func _wav(freq: float, dur: float, vol: float = 0.5, wave: int = 0) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var v := 0.0
		if wave == 0:
			v = sin(TAU * freq * t)
		else:
			v = 1.0 if fmod(t * freq, 1.0) < 0.5 else -1.0
		var s := int(v * vol * 30000)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	return wav

static func play(parent: Node, kind: String) -> void:
	if parent == null:
		return
	var p := AudioStreamPlayer.new()
	match kind:
		"jump":
			p.stream = _wav(520, 0.12, 0.4)
		"coin":
			p.stream = _wav(1040, 0.09, 0.4)
		"doc":
			p.stream = _wav(780, 0.12, 0.4)
		"hurt":
			p.stream = _wav(160, 0.25, 0.5, 1)
		"checkpoint":
			p.stream = _wav(660, 0.2, 0.4)
		"win":
			p.stream = _wav(880, 0.4, 0.4)
		"click":
			p.stream = _wav(440, 0.06, 0.3)
		"dash":
			p.stream = _wav(300, 0.12, 0.3, 1)
		_:
			p.stream = _wav(440, 0.1, 0.3)
	parent.add_child(p)
	p.play()
	p.finished.connect(func(): p.queue_free())
