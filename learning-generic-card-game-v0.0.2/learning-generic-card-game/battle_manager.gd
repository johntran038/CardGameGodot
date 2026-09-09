extends Node

const CARD_SMALL_SCALE = 0.6
const DEFAULT_CARD_MOVE_SPEED = 0.2

signal on_end_opponent_turn

@onready var battle_timer: Timer = $"../BattleTimer"
@onready var card_slots: Node2D = $"../CardSlots"
var empty_diamond_card_slot = []

func _ready() -> void:
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	empty_diamond_card_slot = card_slots.get_children().filter(func(child): return child.name.begins_with("Opp"))
	print(empty_diamond_card_slot)

func opponent_turn():
	$"../EndTurn".disabled = true
	$"../EndTurn".visible = false
	
	battle_timer.start()
	await battle_timer.timeout
	
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		battle_timer.start()
		await battle_timer.timeout

	# Managing Opponent AI
	# Check if free diamond card slots, if not, end turn
	if empty_diamond_card_slot.size() == 0:
		end_opponent_turn()
		return
		
	# Play card
	await try_to_play_highest_attack_card()
	
	# End Turn
	# Reset player deck draw
	end_opponent_turn()

func try_to_play_highest_attack_card():
	# Choose random spot
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	var random_empty_diamond_card_slot = empty_diamond_card_slot.pop_at(randi_range(0,empty_diamond_card_slot.size()))
	# Play card with highest attack
	var highest_attack_card = opponent_hand[0]
	#. searches for the highest z index and returns that card
	for card in opponent_hand:
		if card.attack > highest_attack_card.attack:
			highest_attack_card = card
	
	var tween = get_tree().create_tween()
	tween.tween_property(highest_attack_card, "position", random_empty_diamond_card_slot.position, DEFAULT_CARD_MOVE_SPEED)
	highest_attack_card.get_node("AnimationPlayer").play("card_flip")
	
	# Remove card from opponent hand
	$"../OpponentHand".remove_card_from_hand(highest_attack_card)
	
	battle_timer.start()
	await battle_timer.timeout
	
func end_opponent_turn():
	$"../EndTurn".disabled = false
	$"../EndTurn".visible = true
	emit_signal("on_end_opponent_turn")

func _on_end_turn() -> void:
	opponent_turn()
