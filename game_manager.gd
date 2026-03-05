extends Node

# 信号：游戏结束
signal on_game_over

# 当前分数
var score: int = 0
# 最高分
var best_score: int = 0


func reset_score() -> void:
	"""重置分数"""
	score = 0


func add_score() -> void:
	"""加分"""
	score += 1
	if score > best_score:
		best_score = score


func game_over() -> void:
	"""游戏结束"""
	get_tree().paused = true
	on_game_over.emit()


func restart_game() -> void:
	"""重新开始游戏"""
	get_tree().paused = false
	reset_score()
	get_tree().reload_current_scene()
