extends Control

@export var score_label: Label
@export var best_score_label: Label


func update_score_labels(score: int) -> void:
	score_label.text = "Score: %d" % score
	best_score_label.text = "Best Score: %d" % Global.best_score
