## Main — manajer layar: loading, start, game, pause, settings, selesai, game over.
extends Node

const BG := Color(0.078, 0.071, 0.20)
const PANEL := Color(0.13, 0.12, 0.30)
const CREAM := Color(1.0, 0.965, 0.898)
const YELLOW := Color(1.0, 0.824, 0.247)
const RED := Color(1.0, 0.278, 0.341)
const GREEN := Color(0.18, 0.80, 0.443)
const DIM := Color(0.45, 0.44, 0.60)

var save_data := {}
var current_level := 1
var world: World
var player: Player
var screens := {}
var game_holder: Node2D
var hud_hearts: Label
var hud_coins: Label
var hud_req: Label
var hud_timer: Label
var hud_hint: Label
var hint_timer := 0.0
var darkness_overlay: ColorRect
var haze_overlay: ColorRect
var font_title: Font
var font_body: Font
var ui_layer: CanvasLayer
var complete_title: Label
var complete_stats: Label
var complete_next: Button
var _smoke := false

func _ready() -> void:
	_smoke = OS.has_environment("KJ_SMOKE")
	_setup_input()
	_load_fonts()
	save_data = SaveSys.load_data()
	_build_screens()
	if _smoke:
		print("KJ_SMOKE_RUNNING")
		_start_level(1)
		get_tree().create_timer(5.0).timeout.connect(func(): print("KJ_SMOKE_DONE"); get_tree().quit())
	else:
		_show("loading")
		get_tree().create_timer(1.4).timeout.connect(func(): _show("start"))

func _setup_input() -> void:
	var defs := {
		"move_left": [KEY_LEFT, KEY_A],
		"move_right": [KEY_RIGHT, KEY_D],
		"jump": [KEY_SPACE, KEY_W, KEY_UP],
		"dash": [KEY_SHIFT, KEY_J],
		"pause": [KEY_P, KEY_ESCAPE],
	}
	for action in defs:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in defs[action]:
			var ev := InputEventKey.new()
			ev.keycode = k
			InputMap.action_add_event(action, ev)

func _load_fonts() -> void:
	if ResourceLoader.exists("res://assets/fonts/PressStart2P-Regular.ttf"):
		font_title = load("res://assets/fonts/PressStart2P-Regular.ttf")
	if ResourceLoader.exists("res://assets/fonts/VT323-Regular.ttf"):
		font_body = load("res://assets/fonts/VT323-Regular.ttf")

func _bg(parent: Node) -> void:
	var r := ColorRect.new()
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.color = BG
	parent.add_child(r)

func _label(parent: Node, text: String, size: int, color: Color, x: float, y: float, title_font := false, w: float = 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title_font and font_title != null:
		l.add_theme_font_override("font", font_title)
	elif font_body != null:
		l.add_theme_font_override("font", font_body)
	if w > 0:
		l.size = Vector2(w, 0)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(l)
	return l

func _button(parent: Control, text: String, x: float, y: float, cb: Callable, fill: Color = YELLOW, txt_color: Color = BG) -> Button:
	var b := Button.new()
	b.text = text
	b.position = Vector2(x, y)
	b.size = Vector2(300, 52)
	b.add_theme_font_size_override("font_size", 14)
	if font_title != null:
		b.add_theme_font_override("font", font_title)
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = CREAM
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_color_override("font_color", txt_color)
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

func _screen(name: String) -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.visible = false
	add_child(c)
	screens[name] = c
	return c

func _show(name: String) -> void:
	for k in screens:
		screens[k].visible = (k == name)
	if ui_layer != null:
		ui_layer.visible = (name == "game")

func _build_screens() -> void:
	# LOADING
	var s := _screen("loading")
	_bg(s)
	_label(s, "KOTA", 56, YELLOW, 95, 260, true)
	_label(s, "JANJI", 56, CREAM, 85, 330, true)
	_label(s, "PETUALANGAN ANGGARAN", 22, GREEN, 45, 410, true)
	_label(s, "MEMUAT DUNIA...", 24, CREAM, 105, 520)
	_label(s, "Tips: jalan berlubang bukan rintangan, tapi fitur.", 20, DIM, 30, 570, false, 330)
	# START
	s = _screen("start")
	_bg(s)
	_label(s, "KOTA", 56, YELLOW, 95, 150, true)
	_label(s, "JANJI", 56, CREAM, 85, 220, true)
	_label(s, "PETUALANGAN ANGGARAN", 20, GREEN, 15, 300, true, 360)
	var card := ColorRect.new()
	card.position = Vector2(45, 380)
	card.size = Vector2(300, 90)
	card.color = PANEL
	s.add_child(card)
	var lvl: Dictionary = Levels.get_level(int(save_data.get("unlocked_level", 1)))
	_label(s, "LEVEL %d" % int(save_data.get("unlocked_level", 1)), 20, YELLOW, 61, 392, true)
	_label(s, String(lvl["objective"]), 22, CREAM, 61, 420, false, 268)
	_button(s, "▶  MULAI PETUALANGAN", 45, 500, func(): _start_level(int(save_data.get("unlocked_level", 1))))
	_button(s, "LANJUTKAN", 45, 564, func(): _start_level(int(save_data.get("unlocked_level", 1))), PANEL, CREAM)
	_button(s, "PENGATURAN", 45, 628, func(): _show("settings"), PANEL, CREAM)
	_label(s, "Satir fiksi — tokoh & instansi dalam game ini rekaan.", 18, DIM, 45, 710, false, 300)
	# GAME
	s = _screen("game")
	game_holder = Node2D.new()
	s.add_child(game_holder)
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	ui_layer.follow_viewport_enabled = false
	add_child(ui_layer)
	_bg(ui_layer)
	hud_hearts = _label(ui_layer, "NYAWA 3", 26, RED, 16, 14)
	hud_coins = _label(ui_layer, "KOIN 0", 22, CREAM, 200, 18)
	hud_req = _label(ui_layer, "", 22, YELLOW, 16, 48)
	hud_timer = _label(ui_layer, "00:00", 22, CREAM, 300, 48)
	hud_timer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	hud_timer.offset_left = -110
	hud_timer.offset_top = 48
	hud_timer.offset_right = -16
	hud_timer.offset_bottom = 70
	var pause_btn := Button.new()
	pause_btn.text = "II"
	pause_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_btn.offset_left = -60
	pause_btn.offset_top = 14
	pause_btn.offset_right = -16
	pause_btn.offset_bottom = 58
	pause_btn.pressed.connect(_open_pause)
	ui_layer.add_child(pause_btn)
	hud_hint = _label(ui_layer, "", 22, YELLOW, 45, 100, false, 300)
	hud_hint.visible = false
	darkness_overlay = ColorRect.new()
	darkness_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	darkness_overlay.color = Color(0, 0, 0, 0)
	darkness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(darkness_overlay)
	haze_overlay = ColorRect.new()
	haze_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	haze_overlay.color = Color(0.85, 0.70, 0.30, 0)
	haze_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(haze_overlay)
	_touch_button(ui_layer, "KIRI", Control.PRESET_BOTTOM_LEFT, 16, 92, func(): _touch_dir(-1), func(): _touch_dir(0))
	_touch_button(ui_layer, "KANAN", Control.PRESET_BOTTOM_LEFT, 100, 176, func(): _touch_dir(1), func(): _touch_dir(0))
	_touch_button(ui_layer, "DASH", Control.PRESET_BOTTOM_RIGHT, -176, -100, func(): _touch_dash(), func(): pass)
	_touch_button(ui_layer, "LOMPAT", Control.PRESET_BOTTOM_RIGHT, -92, -16, func(): _touch_jump(), func(): pass)
	# PAUSE
	s = _screen("pause")
	_set_always(s)
	_bg(s)
	_label(s, "JEDA", 44, YELLOW, 130, 250, true)
	_button(s, "▶  LANJUTKAN", 45, 360, _close_pause)
	_button(s, "↻  ULANGI LEVEL", 45, 424, func(): _close_pause(); _start_level(current_level), PANEL, CREAM)
	_button(s, "MENU UTAMA", 45, 488, func(): _close_pause(); _show("start"), PANEL, CREAM)
	# SETTINGS
	s = _screen("settings")
	_bg(s)
	_label(s, "PENGATURAN", 32, YELLOW, 60, 120, true)
	_settings_row(s, 220, "SUARA", "sfx")
	_settings_row(s, 280, "MUSIK", "music")
	_settings_row(s, 340, "GETAR", "vibrate")
	_settings_row(s, 400, "GERAKAN REDAH", "reduced_motion")
	_button(s, "KEMBALI", 45, 490, func(): _show("start"), PANEL, CREAM)
	# COMPLETE
	s = _screen("complete")
	_bg(s)
	complete_title = _label(s, "LEVEL SELESAI!", 36, YELLOW, 30, 200, true)
	complete_stats = _label(s, "", 24, CREAM, 45, 300, false, 300)
	complete_next = _button(s, "➜  LEVEL BERIKUTNYA", 45, 520, func(): _start_level(current_level + 1))
	_button(s, "ULANGI LEVEL", 45, 584, func(): _start_level(current_level), PANEL, CREAM)
	_button(s, "MENU UTAMA", 45, 648, func(): _show("start"), PANEL, CREAM)
	# GAME OVER
	s = _screen("gameover")
	_bg(s)
	_label(s, "JAKA TUMBANG!", 32, RED, 40, 280, true)
	_label(s, "Jangan menyerah — warga menantimu.", 22, CREAM, 45, 340, false, 300)
	_button(s, "↻  ULANGI LEVEL", 45, 420, func(): _start_level(current_level))
	_button(s, "MENU UTAMA", 45, 484, func(): _show("start"), PANEL, CREAM)

func _set_always(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	for ch in node.get_children():
		_set_always(ch)

func _settings_row(parent: Control, y: float, label_text: String, key: String) -> void:
	_label(parent, label_text, 24, CREAM, 45, y + 10)
	var b := Button.new()
	b.text = "ON" if bool(save_data["settings"].get(key, true)) else "OFF"
	b.position = Vector2(285, y)
	b.size = Vector2(60, 40)
	b.pressed.connect(func():
		var st: Dictionary = save_data["settings"]
		st[key] = not bool(st.get(key, true))
		b.text = "ON" if bool(st[key]) else "OFF"
		SaveSys.save_data(save_data)
	)
	parent.add_child(b)

func _touch_button(parent: Node, text: String, preset: int, off_l: float, off_r: float, down_cb: Callable, up_cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.set_anchors_preset(preset)
	b.offset_left = off_l
	b.offset_top = -92
	b.offset_right = off_r
	b.offset_bottom = -16
	b.add_theme_font_size_override("font_size", 26)
	if font_body != null:
		b.add_theme_font_override("font", font_body)
	var sb := StyleBoxFlat.new()
	sb.bg_color = YELLOW
	sb.border_color = CREAM
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_stylebox_override("pressed", sb)
	b.add_theme_stylebox_override("hover", sb)
	b.add_theme_stylebox_override("focus", sb)
	b.add_theme_stylebox_override("disabled", sb)
	b.add_theme_color_override("font_color", BG)
	b.add_theme_color_override("font_pressed_color", BG)
	b.add_theme_color_override("font_hover_color", BG)
	b.add_theme_color_override("font_focus_color", BG)
	b.add_theme_color_override("font_disabled_color", BG)
	b.modulate = Color(1, 1, 1, 0.75)
	b.button_down.connect(down_cb)
	b.button_up.connect(up_cb)
	parent.add_child(b)

func _touch_dir(d: int) -> void:
	if player != null:
		player.touch_dir = d

func _touch_jump() -> void:
	if player != null:
		player.queue_touch_jump()

func _touch_dash() -> void:
	if player != null:
		player.touch_dash_queued = true

func _open_pause() -> void:
	if world == null or not world.playing:
		return
	get_tree().paused = true
	_show("pause")

func _close_pause() -> void:
	get_tree().paused = false
	_show("game")

func _clear_game() -> void:
	for ch in game_holder.get_children():
		ch.queue_free()
	world = null
	player = null

func _start_level(n: int) -> void:
	_clear_game()
	await get_tree().process_frame
	current_level = n
	player = Player.new()
	world = World.new()
	game_holder.add_child(world)
	world.setup(n, player)
	world.collected.connect(_on_collected)
	world.hearts_changed.connect(func(h: int): _update_hearts(h))
	world.checkpoint_saved.connect(func(t: String): _show_hint(t))
	world.hint.connect(func(t: String): _show_hint(t))
	world.player_died.connect(func(): _show("gameover"))
	world.level_completed.connect(_on_level_completed)
	_show("game")
	_update_hearts(world.hearts)
	_update_hud()

func _update_hearts(h: int) -> void:
	if hud_hearts != null:
		hud_hearts.text = "NYAWA %d" % h

func _on_collected(kind: String, total: int) -> void:
	_update_hud()

func _update_hud() -> void:
	if world == null:
		return
	hud_coins.text = "KOIN %d" % world.coins
	var req_text := ""
	var req: Dictionary = world.data.get("required", {})
	for kind in req:
		req_text += "%s %d/%d  " % [kind, world.counts.get(kind, 0), int(req[kind])]
	if world.level_num == 8:
		req_text += "DOKUMEN %d  SERAHKAN %d/3" % [world.carried_docs, world.deliveries]
	hud_req.text = req_text

func _show_hint(text: String) -> void:
	hud_hint.text = text
	hud_hint.visible = true
	hint_timer = 2.5

func _on_level_completed(stats: Dictionary) -> void:
	var lvl: int = stats["level"]
	var stars: int = stats["stars"]
	var sd: Dictionary = save_data
	sd["unlocked_level"] = maxi(int(sd.get("unlocked_level", 1)), mini(8, lvl + 1))
	var st: Dictionary = sd["stars"]
	st[str(lvl)] = maxi(int(st.get(str(lvl), 0)), stars)
	sd["total_coins"] = int(sd.get("total_coins", 0)) + int(stats["coins"])
	SaveSys.save_data(sd)
	save_data = sd
	if lvl == 8:
		complete_title.text = "KOTA JANJI BERUBAH JADI KOTA BUKTI!"
	else:
		complete_title.text = "LEVEL SELESAI!"
	var star_line := "★".repeat(stars) + "☆".repeat(3 - stars)
	complete_stats.text = "%s\nWaktu %02d:%02d\nKoin %d\nHati %d" % [
		star_line, int(stats["time"]) / 60, int(stats["time"]) % 60,
		int(stats["coins"]), int(stats["hearts"])]
	complete_next.visible = lvl < 8
	_show("complete")

func _process(delta: float) -> void:
	if hint_timer > 0:
		hint_timer -= delta
		if hint_timer <= 0:
			hud_hint.visible = false
	if world != null and world.playing:
		var t := int(world.time_sec)
		hud_timer.text = "%02d:%02d" % [t / 60, t % 60]
		darkness_overlay.color.a = world.get_darkness_alpha()
		haze_overlay.color.a = world.get_haze_alpha()
		_update_hud()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and screens.get("game") != null and screens["game"].visible:
		_open_pause()
