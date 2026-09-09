extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

@onready var battle_manager: Node = $"../BattleManager"

var card_mananger_reference
var deck_reference
var players_turn = true

func _ready() -> void:
	card_mananger_reference = $"../CardManager"
	deck_reference = $"../Deck"
	battle_manager.on_end_opponent_turn.connect(_on_end_opponent_turn)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	#. detects what the mouse is touching
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_mananger_reference.start_dragging(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK and players_turn:
			deck_reference.draw_card()

func _on_end_turn() -> void:
	players_turn = false

func _on_end_opponent_turn():
	players_turn = true
