extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DRAW_SPEED = 0.3
const STARTING_HAND_SIZE = 5

@onready var battle_manager: Node = $"../BattleManager"

var player_deck = ["1_diamond", "2_diamond", "2_diamond", "2_diamond", "2_diamond", "3_diamond", "6_club", "7_club"]
var card_database_reference
var drawn_card_this_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://Scripts/card_database.gd")
	battle_manager.on_end_opponent_turn.connect(_on_end_opponent_turn)
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	drawn_card_this_turn = true
	
func draw_card():
	if drawn_card_this_turn:
		return
	drawn_card_this_turn = true
	var card_drawn = player_deck.pop_front()
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://assets/cards/"+card_drawn+".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	if card_database_reference.CARDS.has(card_drawn):
		new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn][0])
		new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn][1])
		new_card.card_type = str(card_database_reference.CARDS[card_drawn][2])
	else:
		new_card.get_node("Attack").text = "0"
		new_card.get_node("Health").text = "0"
		
	
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func _on_end_opponent_turn():
	drawn_card_this_turn = false
