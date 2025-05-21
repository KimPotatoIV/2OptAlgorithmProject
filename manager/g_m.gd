extends Node

##################################################
var generate_stage: int = 0
var n_n_total_distance: float = 0.0
var two_opt_total_distance: float = 0.0

##################################################
func get_generate_stage() -> int:
	return generate_stage

##################################################
func set_generate_stage(generate_stage_value: int) -> void:
	generate_stage = generate_stage_value

##################################################
func get_n_n_total_distance() -> float:
	return n_n_total_distance

##################################################
func get_two_opt_total_distance() -> float:
	return two_opt_total_distance

##################################################
func set_n_n_total_distance(n_n_total_distance_value: float) -> void:
	n_n_total_distance = n_n_total_distance_value

##################################################
func set_two_opt_total_distance(two_opt_total_distance_value: float) -> void:
	two_opt_total_distance = two_opt_total_distance_value
