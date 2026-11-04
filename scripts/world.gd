## World — membangun level dari data + semua sistem gameplay.
class_name World
extends Node2D

signal collected(kind: String, total: int)
signal hearts_changed(hearts: int)
signal level_completed(stats: Dictionary)
signal player_died
signal checkpoint_saved(text: String)
signal hint(text: String)
signal boss_defeated

var level_num := 1
var data := {}
var player: Player
var hearts := 3
var counts := {}
var coins := 0
var total_coins_in_level := 0
var time_sec := 0.0
var playing := false
var respawn_point := Vector2(60, 700)
var carried_docs := 0
var deliveries := 0
var mask_time := 0.0
var boss: Boss
var boss_beaten := false
var _bank_idx := 0
var _bubble_timer := 0.0
var _near_npc: Node2D = null
var _haze_drain := 0.0
var _bus_timer := 0.0
var _bus_on := true
var _bus_body: StaticBody2D
var _bus_visual: ColorRect
var _bus_sign: Label
var _confetti := []
var _paper_timer := 0.0
var _chaser_cd := 0.0

func setup(lnum: int, pl: Player) -> void:
	level_num = lnum
	data = Levels.get_level(lnum)
	player = pl
	add_child(player)
	player.position = Vector2(60, 700)
	respawn_point = player.position
	var cam := Camera2D.new()
	cam.position = Vector2(195, 422)
	cam.limit_left = 0
	cam.limit_right = int(data["width"])
	cam.limit_top = 0
	cam.limit_bottom = 844
	add_child(cam)
	cam.make_current()
	_build_ground()
	_build_platforms()
	_build_pickups()
	_build_checkpoints()
	_build_npcs()
	_build_hazards()
	_build_boss()
	_build_door()
	_build_lamps()
	playing = true

func get_darkness_alpha() -> float:
	if level_num == 4:
		var need := int(data["required"].get("bohlam", 8))
		var got: int = counts.get("bohlam", 0)
		return 0.55 * (1.0 - float(got) / float(need))
	return 0.0

func get_haze_alpha() -> float:
	return 0.22 if level_num == 7 else 0.0

func _solid(parent: Node, x: float, y: float, w: float, h: float, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = Vector2(x + w / 2.0, y + h / 2.0)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, h)
	col.shape = shape
	body.add_child(col)
	var vis := ColorRect.new()
	vis.position = Vector2(x, y)
	vis.size = Vector2(w, h)
	vis.color = color
	body.set_meta("vis", vis)
	add_child(vis)
	add_child(body)
	return body

func _build_ground() -> void:
	for seg in data["ground"]:
		var x0: float = seg[0]
		var x1: float = seg[1]
		_solid(self, x0, 780, x1 - x0, 64, Color(0.18, 0.80, 0.443))

func _build_platforms() -> void:
	for p in data.get("platforms", []):
		_solid(self, float(p[0]), float(p[1]), float(p[2]), 20, Color(0.13, 0.12, 0.30))

func _area(x: float, y: float, w: float, h: float) -> Area2D:
	var a := Area2D.new()
	a.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, h)
	col.shape = shape
	a.add_child(col)
	add_child(a)
	return a

func _pickup(kind: String, x: float, y: float) -> void:
	var node := Node2D.new()
	node.position = Vector2(x, y)
	var spr := Sprite2D.new()
	match kind:
		"doc", "stamp", "ticket", "banner", "stage":
			spr.texture = PixelArt.texture_from_map(PixelArt.DOC, 6)
		"coin":
			spr.texture = PixelArt.texture_from_map(PixelArt.COIN, 8)
		"bohlam":
			spr.texture = PixelArt.texture_from_map([".Y.", "YYY", ".Y."], 8)
		"mask":
			spr.texture = PixelArt.texture_from_map(["WWWWW", "WDDDW", "WWWWW"], 8)
		"heart":
			spr.texture = PixelArt.texture_from_map(PixelArt.HEART, 6)
	node.add_child(spr)
	var area := Area2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(36, 36)
	col.shape = shape
	area.add_child(col)
	node.add_child(area)
	area.body_entered.connect(func(b: Node2D): _on_pickup(b, kind, node))
	add_child(node)

func _on_pickup(body: Node2D, kind: String, node: Node2D) -> void:
	if body != player or not playing:
		return
	node.queue_free()
	if kind == "coin":
		coins += 1
		SFX.play(self, "coin")
		collected.emit("coin", coins)
		return
	if kind == "heart":
		hearts = min(3, hearts + 1)
		hearts_changed.emit(hearts)
		SFX.play(self, "checkpoint")
		return
	if kind == "mask":
		mask_time = 30.0
		SFX.play(self, "doc")
		hint.emit("Masker dipakai — 30 detik aman dari asap.")
		return
	if level_num == 8 and kind == "doc":
		carried_docs += 1
		SFX.play(self, "doc")
		collected.emit("carried", carried_docs)
		return
	counts[kind] = counts.get(kind, 0) + 1
	SFX.play(self, "doc")
	collected.emit(kind, counts[kind])

func _build_pickups() -> void:
	var kind_map := {"docs": "doc", "stamps": "stamp", "bohlam": "bohlam", "coins": "coin", "tickets": "ticket", "banners": "banner", "stage": "stage", "masks": "mask", "hearts": "heart"}
	for key in kind_map:
		for pos in data.get(key, []):
			_pickup(kind_map[key], float(pos[0]), float(pos[1]))
	total_coins_in_level = data.get("coins", []).size()

func _build_checkpoints() -> void:
	for x in data.get("checkpoints", []):
		var flag := ColorRect.new()
		flag.position = Vector2(float(x), 700)
		flag.size = Vector2(8, 80)
		flag.color = Color(0.18, 0.80, 0.443)
		add_child(flag)
		var area := _area(float(x), 740, 60, 80)
		area.body_entered.connect(func(b: Node2D, px: float = float(x)): _on_checkpoint(b, px))

func _on_checkpoint(body: Node2D, x: float) -> void:
	if body != player:
		return
	if respawn_point.x != x:
		respawn_point = Vector2(x, 700)
		checkpoint_saved.emit("POSKO TERSIMPAN")
		SFX.play(self, "checkpoint")

func _build_npcs() -> void:
	var caps := ["G", "Y", "R"]
	var shirts := ["B", "Y", "G"]
	var i := 0
	for x in data.get("npcs", []):
		var npc := Node2D.new()
		npc.position = Vector2(float(x), 780)
		var spr := Sprite2D.new()
		spr.texture = PixelArt.hero_texture(caps[i % 3], shirts[i % 3])
		spr.centered = false
		spr.position = Vector2(-20, -64)
		npc.add_child(spr)
		var panel := ColorRect.new()
		panel.position = Vector2(-80, -150)
		panel.size = Vector2(200, 62)
		panel.color = Color(1.0, 0.965, 0.898)
		panel.visible = false
		npc.add_child(panel)
		var lab := Label.new()
		lab.position = Vector2(-72, -144)
		lab.size = Vector2(184, 56)
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lab.add_theme_font_size_override("font_size", 20)
		lab.add_theme_color_override("font_color", Color(0.05, 0.05, 0.10))
		lab.visible = false
		npc.add_child(lab)
		npc.set_meta("panel", panel)
		npc.set_meta("label", lab)
		npc.set_meta("bank_i", 0)
		add_child(npc)
		i += 1

func _build_hazards() -> void:
	for z in data.get("slow_zones", []):
		var vis := ColorRect.new()
		vis.position = Vector2(float(z[0]), 500)
		vis.size = Vector2(float(z[1]), 280)
		vis.color = Color(0.45, 0.30, 0.70, 0.35)
		add_child(vis)
	for z in data.get("haze_zones", []):
		var vis := ColorRect.new()
		vis.position = Vector2(float(z[0]), 400)
		vis.size = Vector2(float(z[1]), 380)
		vis.color = Color(0.85, 0.70, 0.30, 0.25)
		add_child(vis)
	for x in data.get("chasers", []):
		var ch := Node2D.new()
		ch.position = Vector2(float(x), 780)
		var spr := Sprite2D.new()
		spr.texture = PixelArt.hero_texture("D", "D")
		spr.centered = false
		spr.position = Vector2(-20, -64)
		ch.add_child(spr)
		var area := Area2D.new()
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(40, 64)
		col.shape = shape
		area.add_child(col)
		ch.add_child(area)
		area.body_entered.connect(func(b: Node2D): _on_chaser_touch(b))
		ch.set_meta("is_chaser", true)
		add_child(ch)
	if data.has("bus"):
		var b: Dictionary = data["bus"]
		_bus_body = _solid(self, float(b["x"]), float(b["y"]), float(b["w"]), 60, Color(1.0, 0.824, 0.247))
		_bus_sign = Label.new()
		_bus_sign.position = Vector2(float(b["x"]), float(b["y"]) - 40)
		_bus_sign.add_theme_font_size_override("font_size", 18)
		add_child(_bus_sign)

func _on_chaser_touch(body: Node2D) -> void:
	if body == player:
		damage_player()

func _build_boss() -> void:
	if not data.has("boss"):
		return
	var bd: Dictionary = data["boss"]
	boss = Boss.new()
	boss.setup(String(bd["type"]), float(bd["x"]), 780)
	boss.player_touched.connect(_on_boss_touch)
	add_child(boss)
	if boss.boss_type == "mesin":
		var box_area := _area(float(bd["x"]) - 220, 700, 80, 80)
		var box_vis := ColorRect.new()
		box_vis.position = Vector2(float(bd["x"]) - 220, 700)
		box_vis.size = Vector2(80, 80)
		box_vis.color = Color(0.13, 0.12, 0.30)
		add_child(box_vis)
		var box_lab := Label.new()
		box_lab.text = "KOTAK FAKTA"
		box_lab.position = Vector2(float(bd["x"]) - 230, 670)
		box_lab.add_theme_font_size_override("font_size", 14)
		add_child(box_lab)
		box_area.body_entered.connect(func(b: Node2D): _on_fakta_box(b))

func _on_fakta_box(body: Node2D) -> void:
	if body != player or carried_docs <= 0:
		return
	carried_docs -= 1
	deliveries += 1
	SFX.play(self, "win")
	collected.emit("carried", carried_docs)
	hint.emit("Dokumen diserahkan ke Kotak Fakta (%d/3)." % deliveries)
	if deliveries >= 3 and boss != null:
		boss.defeated.emit()
		boss_beaten = true
		boss.queue_free()
		boss = null
		_finish_level()

func _on_boss_touch() -> void:
	if boss == null:
		return
	if boss.boss_type == "pagar":
		if player.velocity.y > 0 and player.position.y < boss.position.y - 30:
			player.velocity.y = -500
			boss.take_hit()
			SFX.play(self, "hurt")
			if boss.hp <= 0:
				boss_beaten = true
				boss_defeated.emit()
		else:
			damage_player()
	else:
		damage_player()

func _build_door() -> void:
	var dx := float(data["width"]) - 100
	var vis := ColorRect.new()
	vis.position = Vector2(dx, 680)
	vis.size = Vector2(50, 100)
	vis.color = Color(1.0, 0.824, 0.247)
	add_child(vis)
	var area := _area(dx, 730, 60, 100)
	area.body_entered.connect(func(b: Node2D): _on_door(b))

func _on_door(body: Node2D) -> void:
	if body != player or not playing:
		return
	if boss != null and not boss_beaten:
		hint.emit("Kalahkan boss dulu!")
		return
	var req: Dictionary = data.get("required", {})
	for kind in req:
		if counts.get(kind, 0) < int(req[kind]):
			hint.emit("Butuh %s %d/%d." % [kind, counts.get(kind, 0), int(req[kind])])
			return
	_finish_level()

func _build_lamps() -> void:
	if level_num != 4:
		return
	for x in [300, 900, 1500, 2100]:
		var pole := ColorRect.new()
		pole.position = Vector2(float(x), 560)
		pole.size = Vector2(8, 220)
		pole.color = Color(0.45, 0.44, 0.60)
		add_child(pole)
		var head := ColorRect.new()
		head.position = Vector2(float(x) - 14, 540)
		head.size = Vector2(36, 20)
		head.color = Color(1.0, 0.824, 0.247)
		add_child(head)

func damage_player() -> void:
	if player.invulnerable or not playing:
		return
	hearts -= 1
	hearts_changed.emit(hearts)
	SFX.play(self, "hurt")
	player.set_invulnerable(1.0)
	player.velocity.y = -400
	if hearts <= 0:
		playing = false
		player_died.emit()
	else:
		player.position = respawn_point

func _process(delta: float) -> void:
	if not playing:
		return
	time_sec += delta
	mask_time = max(0.0, mask_time - delta)
	# Kamera mengikuti pemain.
	for cam in get_children():
		if cam is Camera2D:
			cam.position.x = clamp(player.position.x, 195, float(data["width"]) - 195)
			cam.position.y = 422
	# Jatuh ke lubang.
	if player.position.y > 950:
		hearts -= 1
		hearts_changed.emit(hearts)
		SFX.play(self, "hurt")
		if hearts <= 0:
			playing = false
			player_died.emit()
		else:
			player.position = respawn_point
	# Zona lambat (L2).
	player.slow_factor = 1.0
	for z in data.get("slow_zones", []):
		if player.position.x >= float(z[0]) and player.position.x <= float(z[0]) + float(z[1]):
			player.slow_factor = 0.5
	# Zona asap (L7).
	var in_haze := false
	for z in data.get("haze_zones", []):
		if player.position.x >= float(z[0]) and player.position.x <= float(z[0]) + float(z[1]):
			in_haze = true
	if in_haze and mask_time <= 0.0:
		_haze_drain += delta
		if _haze_drain >= 10.0:
			_haze_drain = 0.0
			damage_player()
	else:
		_haze_drain = 0.0
	# Bus (L5).
	if _bus_body != null:
		var b: Dictionary = data["bus"]
		_bus_timer += delta
		var cycle := float(b["on_time"]) + float(b["off_time"])
		var t := fmod(_bus_timer, cycle)
		var on := t < float(b["on_time"])
		var vis: ColorRect = _bus_body.get_meta("vis")
		vis.visible = on
		_bus_body.get_child(0).disabled = not on
		if _bus_sign != null:
			if on:
				_bus_sign.text = "BUS DATANG!"
			else:
				_bus_sign.text = "Bus berikutnya: %ds" % int(float(b["off_time"]) - (t - float(b["on_time"])))
	# Chaser (L2) bergerak ke pemain.
	for ch in get_children():
		if ch.has_meta("is_chaser"):
			if abs(player.position.x - ch.position.x) < 400:
				var d: float = sign(player.position.x - ch.position.x)
				ch.position.x += d * 30 * delta
	# Boss aktif saat pemain mendekat.
	if boss != null and not boss._active and player.position.x > boss.position.x - 300:
		boss._active = true
	# Kertas Mesin Janji (L8).
	if boss != null and boss.boss_type == "mesin" and boss._active:
		_paper_timer += delta
		if _paper_timer > 3.0:
			_paper_timer = 0.0
			_spawn_paper()
	# Bubble NPC.
	_update_bubbles(delta)
	# Confetti (L6).
	for c in _confetti:
		c["node"].position.y += 120 * delta
		c["life"] -= delta
		if c["life"] <= 0:
			c["node"].queue_free()
	_confetti = _confetti.filter(func(c): return c["life"] > 0)

func _spawn_paper() -> void:
	var p := Node2D.new()
	p.position = boss.position + Vector2(0, -60)
	var vis := ColorRect.new()
	vis.size = Vector2(26, 32)
	vis.color = Color(1.0, 0.965, 0.898)
	p.add_child(vis)
	var area := Area2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(26, 32)
	col.shape = shape
	area.add_child(col)
	p.add_child(area)
	area.body_entered.connect(func(b: Node2D, n: Node2D = p): _on_paper_touch(b, n))
	p.set_meta("life", 8.0)
	add_child(p)

func _on_paper_touch(body: Node2D, node: Node2D) -> void:
	if body == player:
		node.queue_free()
		damage_player()

func _update_bubbles(delta: float) -> void:
	var best: Node2D = null
	var best_d := 120.0
	for ch in get_children():
		if ch.has_meta("panel"):
			var d: float = abs(player.position.x - ch.position.x)
			if d < best_d:
				best_d = d
				best = ch
	if best != _near_npc:
		if _near_npc != null:
			_near_npc.get_meta("panel").visible = false
			_near_npc.get_meta("label").visible = false
		_near_npc = best
		_bubble_timer = 0.0
		if best != null:
			_show_bubble(best)
	elif best != null:
		_bubble_timer += delta
		if _bubble_timer >= 5.0:
			_bubble_timer = 0.0
			_show_bubble(best)

func _show_bubble(npc: Node2D) -> void:
	var bank: Array = Levels.COMPLAINTS[level_num]
	var i: int = npc.get_meta("bank_i")
	var panel: ColorRect = npc.get_meta("panel")
	var lab: Label = npc.get_meta("label")
	lab.text = bank[i % bank.size()]
	npc.set_meta("bank_i", i + 1)
	panel.visible = true
	lab.visible = true

func _finish_level() -> void:
	if not playing:
		return
	playing = false
	var stars := 1
	if total_coins_in_level > 0 and coins >= total_coins_in_level / 2:
		stars += 1
	if hearts >= 2 and time_sec <= float(data["par_time"]):
		stars += 1
	if level_num == 6:
		_celebrate()
	SFX.play(self, "win")
	level_completed.emit({
		"level": level_num, "time": time_sec, "coins": coins,
		"hearts": hearts, "stars": stars,
	})

func _celebrate() -> void:
	for i in 40:
		var c := ColorRect.new()
		c.size = Vector2(10, 14)
		c.color = Color(1.0, 0.824, 0.247) if i % 2 == 0 else Color(1.0, 0.278, 0.341)
		c.position = Vector2(player.position.x - 100 + (i * 7) % 200, 300 - (i % 5) * 20)
		add_child(c)
		_confetti.append({"node": c, "life": 3.0})
