extends Control

const SHIP_SCALE := Vector2(0.17, 0.17)
const MOVE_DURATION := 1.0

@onready var progress_line: Line2D = $ProgressLine
@onready var ship_sprite: Sprite2D = $Ship
@onready var marker_facil: Label = $IAFacil
@onready var marker_intermediaria: Label = $IAIntermediaria
@onready var marker_dificil: Label = $IADificil
@onready var hud_hint: Label = $HUD/Hint

var stage_positions: Array[Vector2] = []
var current_stage := 0
var active_tween: Tween

func _ready() -> void:
	ship_sprite.scale = SHIP_SCALE
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_layout()
	_set_stage(0, false)
	hud_hint.text = "Mock campanha: 0=inicio | 1=IA facil | 2=IA intermediaria | 3=IA dificil | ESC=voltar"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_0:
				set_stage_0()
			KEY_1:
				set_stage_1()
			KEY_2:
				set_stage_2()
			KEY_3:
				set_stage_3()
			KEY_ESCAPE:
				get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_viewport_size_changed() -> void:
	var previous_position := ship_sprite.global_position
	var previous_stage := current_stage
	_update_layout()

	# Preserva o estágio atual após resize; fallback pela posição anterior.
	if previous_stage >= 0 and previous_stage < stage_positions.size():
		ship_sprite.global_position = stage_positions[previous_stage]
	else:
		ship_sprite.global_position = previous_position

func _update_layout() -> void:
	var size := get_viewport_rect().size
	var x_center := size.x * 0.52

	var start := Vector2(x_center, size.y * 0.83)
	var facil := Vector2(x_center, size.y * 0.66)
	var intermediaria := Vector2(x_center, size.y * 0.48)
	var dificil := Vector2(x_center, size.y * 0.30)

	stage_positions = [start, facil, intermediaria, dificil]

	marker_facil.position = facil + Vector2(-40.0, -56.0)
	marker_intermediaria.position = intermediaria + Vector2(-75.0, -56.0)
	marker_dificil.position = dificil + Vector2(-45.0, -56.0)

	progress_line.points = PackedVector2Array([dificil, intermediaria, facil, start])

func _set_stage(stage: int, animate: bool) -> void:
	if stage < 0 or stage >= stage_positions.size():
		return

	current_stage = stage
	var target_position := stage_positions[stage]

	if is_instance_valid(active_tween):
		active_tween.kill()

	if animate:
		active_tween = create_tween()
		active_tween.set_trans(Tween.TRANS_SINE)
		active_tween.set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(ship_sprite, "global_position", target_position, MOVE_DURATION)
	else:
		ship_sprite.global_position = target_position

func set_stage_0() -> void:
	_set_stage(0, true)

func set_stage_1() -> void:
	_set_stage(1, true)

func set_stage_2() -> void:
	_set_stage(2, true)

func set_stage_3() -> void:
	_set_stage(3, true)
