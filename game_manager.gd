extends Node

# 信号：游戏结束
signal on_game_over
# 信号：速度提升
signal on_speed_up

# 当前分数
var score: int = 0
# 最高分
var best_score: int = 0
# 速度倍率
var speed_multiplier: float = 1.0


func reset_score() -> void:
	"""重置分数和速度"""
	score = 0
	speed_multiplier = 1.0


func add_score() -> void:
	"""加分并检查加速"""
	score += 1
	if score > best_score:
		best_score = score
	
	# 每3分加速一次
	if score % 3 == 0:
		speed_multiplier += 0.1
		on_speed_up.emit()


func game_over() -> void:
	"""游戏结束"""
	get_tree().paused = true
	on_game_over.emit()


func restart_game() -> void:
	"""重新开始游戏"""
	get_tree().paused = false
	reset_score()
	get_tree().reload_current_scene()
