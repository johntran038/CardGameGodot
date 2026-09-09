extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1

@onready var battle_manager: Node = $"../BattleManager"

var screen_size
var card_being_dragged
var is_hovering_on_card
var player_hand_reference
var played_diamond_card_this_turn = false
var players_turn = true

var card_size_default = Vector2(1, 1)
var card_size_hover = Vector2(1.1, 1.1)

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	battle_manager.on_end_opponent_turn.connect(_on_end_opponent_turn)

func _process(_delta: float) -> void:
	#. card drag mechanic
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y
		))

#func _input(event: InputEvent) -> void:
	##. on mouse press card
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.is_pressed():
			#var card = raycast_check_for_card()
			#if card:
				#start_dragging(card)
		#elif card_being_dragged:
			#finish_dragging()
			
func start_dragging(card):
	#. squish card indicate dragging
	card_being_dragged = card
	card.scale = card_size_default

func finish_dragging():
	#. revert card to hover size after dragging is done
	card_being_dragged.scale = card_size_hover
	var card_slot_found = raycast_check_for_card_slot()
	if !players_turn:
		return_card_to_hand(card_being_dragged)
		return
	if card_slot_found and not card_slot_found.card_in_slot:
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			if played_diamond_card_this_turn and card_being_dragged.card_type == "Diamond":
				return_card_to_hand(card_being_dragged)
				return
			#. card dropped in an empty slot
			card_being_dragged.z_index = -1
			card_being_dragged.card_in_slot_is_in = card_slot_found
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			card_being_dragged.position = card_slot_found.position
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			card_slot_found.card_in_slot = true
			if card_being_dragged.card_type == "Diamond":
				played_diamond_card_this_turn = true
			card_being_dragged = null
			return
	return_card_to_hand(card_being_dragged)
	
func return_card_to_hand(card):
	player_hand_reference.add_card_to_hand(card, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null
	

func connect_card_signals(card):
	card.connect("hover_on", on_hover)
	card.connect("hover_off", off_hover)
	
func on_left_click_released():
	if card_being_dragged:
		finish_dragging()

func on_hover(card):
	#. on hover, card gets bigger & goes on top
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
func off_hover(card):
	#. if no longer hover, card resets to default
	if card_being_dragged:
		return
	highlight_card(card, false)
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false
	
func highlight_card(card, hovered):
	#. changes size and index based on if its hovered
	if hovered:
		card.scale = card_size_hover
		card.z_index = 2
	else:
		card.scale = card_size_default
		card.z_index = 1

func raycast_check_for_card_slot():
	#. detects what the mouse is touching
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#. before returning, it selects card at the	 top of the pile (highest z index)
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	#. detects what the mouse is touching
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#. before returning, it selects card at the	 top of the pile (highest z index)
		return get_highest_z_card(result)
	return null
	
func get_highest_z_card(cards):
	#assume first index has highest z
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	#. searches for the highest z index and returns that card
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card 


func _on_end_opponent_turn():
	played_diamond_card_this_turn = false
	players_turn = true
