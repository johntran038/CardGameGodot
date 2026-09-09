extends Node2D

const CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn"
const CARD_DRAW_SPEED = 0.3
const STARTING_HAND_SIZE = 5

var opponent_deck = ["1_diamond", "2_diamond", "2_diamond", "2_diamond", "2_diamond", "3_diamond", "6_club", "7_club"]
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opponent_deck.shuffle()
	$RichTextLabel.text = str(opponent_deck.size())
	card_database_reference = preload("res://Scripts/card_database.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()

func draw_card():
		
	var card_drawn = opponent_deck.pop_front()
	
	if opponent_deck.size() == 0:
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(opponent_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://assets/cards/"+card_drawn+".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	if card_database_reference.CARDS.has(card_drawn):
		new_card.attack = card_database_reference.CARDS[card_drawn][0]
		new_card.get_node("Attack").text = str(new_card.attack)
		new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn][1])
		new_card.card_type = str(card_database_reference.CARDS[card_drawn][2])
	else:
		new_card.attack = 0
		new_card.get_node("Attack").text = "0"
		new_card.get_node("Health").text = "0"
		
	
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
