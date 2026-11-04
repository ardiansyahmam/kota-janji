## Player — gerakan platformer: lari, lompat (coyote + buffer), dash.
class_name Player
extends CharacterBody2D

signal jumped
signal dashed
signal hurt

const SPEED := 220.0
const JUMP_VELOCITY := -720.0
const GRAVITY := 1800.0
const DASH_SPEED := 520.0
const DASH_TIME := 0.18
const DASH_COOLDOWN := 1.5
const COYOTE_TIME := 0.10
const BUFFER_TIME := 0.10

var slow_factor := 1.0
var touch_dir := 0
var touch_jump_queued := false
var touch_dash_queued := false
var invulnerable := false

var _coyote := 0.0
var _buffer := 0.0
var _dash_time := 0.0
var _dash_cd := 0.0
var _dash_dir := 1
var _blink := 0.0
var _sprite: Sprite2D

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = PixelArt.hero_texture()
	_sprite.centered = false
	_sprite.position = Vector2(-30, -96)
	_sprite.scale = Vector2(1.5, 1.5)
	add_child(_sprite)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(54, 90)
	col.shape = shape
	col.position = Vector2(0, -48)
	add_child(col)

func queue_touch_jump() -> void:
	touch_jump_queued = true

func _physics_process(delta: float) -> void:
	var dir := 0
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if Input.is_action_pressed("move_right"):
		dir += 1
	if dir == 0:
		dir = touch_dir
	if Input.is_action_just_pressed("jump") or touch_jump_queued:
		_buffer = BUFFER_TIME
		touch_jump_queued = false
	_buffer = max(0.0, _buffer - delta)
	_coyote = COYOTE_TIME if is_on_floor() else max(0.0, _coyote - delta)
	_dash_cd = max(0.0, _dash_cd - delta)
	if (Input.is_action_just_pressed("dash") or touch_dash_queued) and _dash_cd <= 0.0:
		touch_dash_queued = false
		_dash_time = DASH_TIME
		_dash_cd = DASH_COOLDOWN
		_dash_dir = dir if dir != 0 else _dash_dir
		dashed.emit()
	velocity.y += GRAVITY * delta
	if _dash_time > 0.0:
		_dash_time -= delta
		velocity.x = _dash_dir * DASH_SPEED
		velocity.y = 0.0
	else:
		velocity.x = dir * SPEED * slow_factor
	if _buffer > 0.0 and (_coyote > 0.0 or is_on_floor()):
		velocity.y = JUMP_VELOCITY
		_buffer = 0.0
		_coyote = 0.0
		jumped.emit()
	move_and_slide()
	if invulnerable:
		_blink += delta
		_sprite.modulate.a = 0.4 if int(_blink * 10) % 2 == 0 else 1.0
	else:
		_sprite.modulate.a = 1.0

func set_invulnerable(t: float) -> void:
	invulnerable = true
	get_tree().create_timer(t).timeout.connect(func(): invulnerable = false)
