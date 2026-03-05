extends Node2D

# 预加载管道场景
const PIPE_SCENE = preload("res://pipe.tscn")

# 配置参数（可以在检查器中调整）
@export var pipe_speed: float = 200.0      # 管道移动速度
@export var spawn_interval: float = 2.0    # 生成间隔（秒）
@export var pipe_gap: float = 150.0        # 上下管道间隙
@export var gap_move_speed: float = 80.0   # gap位置变化速度

# 内部变量
var _spawn_timer: float = 0.0
var _current_gap_y: float = 320.0  # 当前间隙位置（屏幕中心）


func _process(delta: float) -> void:
	# 1. 计时器累加
	_spawn_timer += delta
	
	# 2. 如果到达生成间隔，生成管道
	if _spawn_timer >= spawn_interval:
		_spawn_pipe_pair()
		_spawn_timer = 0.0  # 重置计时器
	
	# 3. 移动所有管道
	_move_pipes(delta)


func _spawn_pipe_pair() -> void:
	"""生成一对管道（上管道 + 下管道）"""
	# 获取屏幕尺寸
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_x = screen_size.x + 50  # 屏幕右边外侧
	
	# 计算间隙的安全范围（避免间隙太靠边）
	var margin = 80  # 边距
	var min_gap_y = pipe_gap / 2 + margin
	var max_gap_y = screen_size.y - pipe_gap / 2 - margin
	
	# ===== 新算法：正态分布 + 平滑移动 =====
	# 1. 使用正态分布生成目标位置（以屏幕中心为均值，标准差为屏幕高度的1/3）
	var screen_center_y = screen_size.y / 2
	var target_gap_y = randfn(screen_center_y, screen_size.y / 3.0)
	# 限制在安全范围内
	target_gap_y = clamp(target_gap_y, min_gap_y, max_gap_y)
	
	# 2. 当前位置向目标位置小幅移动
	var direction = sign(target_gap_y - _current_gap_y)  # 移动方向
	_current_gap_y += direction * gap_move_speed
	# 限制在安全范围内
	_current_gap_y = clamp(_current_gap_y, min_gap_y, max_gap_y)
	
	var gap_center_y = _current_gap_y
	# ===== 算法结束 =====
	
	# 管道高度 = 屏幕高度，确保填满
	var pipe_height = screen_size.y
	
	# 生成上管道（管道底部紧贴间隙上方）
	var top_pipe = PIPE_SCENE.instantiate()
	$Pipes.add_child(top_pipe)
	top_pipe.position = Vector2(spawn_x, gap_center_y - pipe_gap / 2 - pipe_height)
	# 设置管道视觉大小
	top_pipe.get_node("ColorRect").size.y = pipe_height
	top_pipe.get_node("CollisionShape2D").shape.size.y = pipe_height
	top_pipe.get_node("CollisionShape2D").position.y = pipe_height / 2
	
	# 生成下管道（管道顶部紧贴间隙下方）
	var bottom_pipe = PIPE_SCENE.instantiate()
	$Pipes.add_child(bottom_pipe)
	bottom_pipe.position = Vector2(spawn_x, gap_center_y + pipe_gap / 2)
	# 设置管道视觉大小
	bottom_pipe.get_node("ColorRect").size.y = pipe_height
	bottom_pipe.get_node("CollisionShape2D").shape.size.y = pipe_height
	bottom_pipe.get_node("CollisionShape2D").position.y = pipe_height / 2


func _move_pipes(delta: float) -> void:
	"""移动并清理管道"""
	for pipe in $Pipes.get_children():
		# 向左移动
		pipe.position.x -= pipe_speed * delta
		
		# 如果离开屏幕，销毁
		if pipe.position.x < -100:
			pipe.queue_free()