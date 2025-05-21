extends Node2D

##################################################
var n_n_label_node: Label
var two_opt_label_node: Label

##################################################
func _ready() -> void:
	n_n_label_node = $MarginContainer/VBoxContainer/NNLabel
	two_opt_label_node = $"MarginContainer/VBoxContainer/2OptLabel"

##################################################
func _process(delta: float) -> void:
	n_n_label_node.text = "NN Distance: " + str(int(GM.get_n_n_total_distance()))
	two_opt_label_node.text = "2-Opt Distance: " + str(int(GM.get_two_opt_total_distance()))
