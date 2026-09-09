extends Node2D

signal hover_on
signal hover_off

var hand_position
var card_in_slot_is_in
var card_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#all cards must be child of card manager
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	pass # Replace with function body.
	emit_signal("hover_on", self)

func _on_area_2d_mouse_shape_exited(shape_idx: int) -> void:
	pass # Replace with function body.
	emit_signal("hover_off", self)
