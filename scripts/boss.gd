## Boss — dua tipe: "pagar" (lompat di kepala, 3 HP) dan "mesin" (antar dokumen).
class_name Boss
extends Node2D

signal defeated
signal player_touched

var boss_type := "pagar"
var hp := 3
var _dir := -1
var _shoot_timer := 0.0
var _telegraph := 0.0
var _body: Area2D
var _visual: ColorRect
var _active := false

func setup(btype: String, x: float, ground_y: float) -> void:
	boss_type = btype
	position = Vector2(x, ground_y)
	var label := Label.new()
	label.text = "PAGAR PROYEK" if btype == "pagar" else "MESIN JANJI"
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(-60, -140)
	add_child(label)
	_visual = ColorRect.new()
	_visual.size = Vector2(100, 110)
	_visual.color = Color(0.45, 0.44, 0.60) if btype == "pagar" else Color(1.0, 0.824, 0.247)
	_visual.position = Vector2(-50, -110)
	add_child(_visual)
	_body = Area2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(100, 110)
	col.shape = shape
	_body.add_child(col)
	_body.body_entered.connect(_on_body_entered)
	add_child(_body)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_touched.emit()

func take_hit() -> void:
	hp -= 1
	_visual.modulate = Color(1, 0.5, 0.5)
	get_tree().create_timer(0.2).timeout.connect(func(): _visual.modulate = Color.WHITE)
	if hp <= 0:
		defeated.emit()
		queue_free()

func _process(delta: float) -> void:
	if not _active:
		return
	if boss_type == "pagar":
		position.x += _dir * 40 * delta
		if position.x < 2000 or position.x > 2300:
			_dir *= -1
