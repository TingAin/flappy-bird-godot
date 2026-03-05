extends Node2D

# 预加载管道场景
const PIPE_SCENE = preload("res://pipe.tscn")

# 配置参数
@export var base_pipe_speed: float = 150.0   # 基础管道速度
@export var spawn_interval: float = 2.0
@export var pipe_gap: float = 150.0
@export var gap_move_speed: float = 80.0

# 当前管道速度（会被加速影响）
var _current_pipe_speed: float = 150.0

# 内部变量
var _spawn_timer: float = 0.0
var _current_gap_y: float = 320.0

# UI 节点引用
@onready var score_label: Label = $CanvasLayer/UI/ScoreLabel
@onready var game_over_panel: Control = $CanvasLayer/UI/GameOver
@onready var score_info: Label = $CanvasLayer/UI/GameOver/ScoreInfo


func _ready() -> void:
	# 连接信号
	GameManager.on_game_over.connect(_on_game_over)
	GameManager.on_speed_up.connect(_on_speed_up)
	# 游戏开始时重置
	GameManager.reset_score()
	_current_pipe_speed = base_pipe_speed
	_update_score_display()
	game_over_panel.visible = false


func _on_game_over() -> void:
	"""游戏结束信号回调"""
	show_game_over()


func _on_speed_up() -> void:
	"""加速信号回调"""
	_current_pipe_speed = base_pipe_speed * GameManager.speed_multiplier
	print("加速！当前速度倍率: ", GameManager.speed_multiplier)


func _process(delta: float) -> void:
	# 如果游戏暂停，不处理
	if get_tree().paused:
		return
	
	_spawn_timer += delta
	
	if _spawn_timer >= spawn_interval:
		_spawn_pipe_pair()
		_spawn_timer = 0.0
	
	_move_pipes(delta)
	_check_score()


func _spawn_pipe_pair() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_x = screen_size.x + 50
	
	var margin = 80
	var min_gap_y = pipe_gap / 2 + margin
	var max_gap_y = screen_size.y - pipe_gap / 2 - margin
	
	var screen_center_y = screen_size.y / 2
	var target_gap_y = randfn(screen_center_y, screen_size.y / 3.0)
	target_gap_y = clamp(target_gap_y, min_gap_y, max_gap_y)
	
	var direction = sign(target_gap_y - _current_gap_y)
	_current_gap_y += direction * gap_move_speed
	_current_gap_y = clamp(_current_gap_y, min_gap_y, max_gap_y)
	
	var gap_center_y = _current_gap_y
	var pipe_height = screen_size.y
	
	# 上管道
	var top_pipe = PIPE_SCENE.instantiate()
	$Pipes.add_child(top_pipe)
	top_pipe.position = Vector2(spawn_x, gap_center_y - pipe_gap / 2 - pipe_height)
	top_pipe.is_bottom = false
	top_pipe.get_node("ColorRect").size.y = pipe_height
	top_pipe.get_node("CollisionShape2D").shape.size.y = pipe_height
	top_pipe.get_node("CollisionShape2D").position.y = pipe_height / 2
	
	# 下管道
	var bottom_pipe = PIPE_SCENE.instantiate()
	$Pipes.add_child(bottom_pipe)
	bottom_pipe.position = Vector2(spawn_x, gap_center_y + pipe_gap / 2)
	bottom_pipe.is_bottom = true
	bottom_pipe.get_node("ColorRect").size.y = pipe_height
	bottom_pipe.get_node("CollisionShape2D").shape.size.y = pipe_height
	bottom_pipe.get_node("CollisionShape2D").position.y = pipe_height / 2


func _move_pipes(delta: float) -> void:
	for pipe in $Pipes.get_children():
		pipe.position.x -= _current_pipe_speed * delta
		if pipe.position.x < -100:
			pipe.queue_free()


func _check_score() -> void:
	var bird = $CharacterBody2D
	
	for pipe in $Pipes.get_children():
		if not pipe.scored and bird.position.x > pipe.position.x + 50:
			pipe.scored = true
			if pipe.is_bottom:
				GameManager.add_score()
				_update_score_display()


func _update_score_display() -> void:
	"""更新分数显示"""
	score_label.text = str(GameManager.score)


func show_game_over() -> void:
	"""显示游戏结束界面"""
	score_info.text = "Score: %d" % GameManager.score
	game_over_panel.visible = true


func _on_restart_button_pressed() -> void:
	"""重新开始按钮点击"""
	GameManager.restart_game()
