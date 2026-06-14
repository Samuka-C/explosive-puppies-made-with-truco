class_name UmCard
extends Card

var snap_pos: Vector2
var snap_rot: float

@onready var title_label: Label = $Panel/MarginContainer/Front/Title
@onready var card_image: TextureRect = $Panel/MarginContainer/Front/TextureRect
@onready var back = $Panel/Back


func post_instantiate(w: World, id: int) -> void:
	world = w
	entity_id = id


func _ready() -> void:
	_apply_visual()


func _apply_visual() -> void:
	if world and entity_id >= 0 and world.entities.exists(entity_id):
		if not world.has_component(entity_id, BombCardComponent):
			return
		var comp = world.get_component(entity_id, CardComponent) as CardComponent
		var bomb = world.get_component(entity_id, BombCardComponent) as BombCardComponent
		if comp and bomb:
			_apply_from_component(comp, bomb)
			return


func update_visual() -> void:
	_apply_visual()


func _apply_from_component(comp: CardComponent, b_comp: BombCardComponent) -> void:
	var show_front = comp.face_up or comp.zone_id == multiplayer.get_unique_id()
	flip(not show_front)
	title_label.text = b_comp.card_name
	card_image.texture = b_comp.card_image


func _on_gui_input(event: InputEvent) -> void:
	if entity_id == -1 or not world:
		return
	world.events.on_card_input.emit(entity_id, event)


func _on_mouse_entered() -> void:
	if entity_id == -1 or not world:
		return
	world.events.on_card_mouse_entered.emit(entity_id)


func _on_mouse_exited() -> void:
	if entity_id == -1 or not world:
		return
	world.events.on_card_mouse_exited.emit(entity_id)


func card_is_focused(value: bool) -> void:
	z_index = 10 if value else 0


func flip(state: bool) -> void:
	back.visible = state


func move(dur: float, target: Vector2, start: Vector2 = position) -> void:
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "position", target, dur).set_trans(Tween.TRANS_CUBIC).from(
		start
	)
	await t.finished


func rotate(dur: float, target_rot: float) -> void:
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "rotation", target_rot, dur).set_trans(Tween.TRANS_CUBIC)
	await t.finished


func resize(s: float) -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(s, s), 0.4).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	await t.finished


func shake_negation() -> void:
	var intensity := 10.0
	var dur := 0.05
	var original_pos := snap_pos
	await move(dur, original_pos + Vector2(-intensity, 0))
	await move(dur, original_pos + Vector2(intensity, 0))
	await move(dur, original_pos + Vector2(-intensity * 0.8, 0))
	await move(dur, original_pos + Vector2(intensity * 0.8, 0))
	await move(dur, original_pos)
	await rotate(dur, deg_to_rad(-5))
	await rotate(dur, deg_to_rad(5))
	await rotate(dur, 0)


func shake_affirmation() -> void:
	var intensity := 8.0
	var dur := 0.05
	var original_pos := snap_pos
	await move(dur, original_pos + Vector2(0, -intensity))
	await move(dur, original_pos + Vector2(0, intensity))
	await move(dur, original_pos + Vector2(0, -intensity * 0.6))
	await move(dur, original_pos + Vector2(0, intensity * 0.6))
	await move(dur, original_pos)
	await rotate(dur, deg_to_rad(5))
	await rotate(dur, 0)
