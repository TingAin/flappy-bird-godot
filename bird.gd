extends CharacterBody2D

const GRAVITY = 650
const JUMP_FORCE = -250 


func _physics_process(delta: float) -> void:
	# 重力
	velocity.y += GRAVITY * delta

	# 跳跃
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
	
	# 移动
	move_and_slide()
	
	# 碰撞检测
	_check_collision()
	
	# 边界检测
	_check_boundary()


func _check_collision() -> void:
	"""检测是否撞到管道"""
	if get_slide_collision_count() > 0:
		GameManager.game_over()


func _check_boundary() -> void:
	"""检测是否撞到边界"""
	var screen_size = get_viewport().get_visible_rect().size
	
	# 撞到天花板或地面
	if position.y < 0 or position.y > screen_size.y:
		GameManager.game_over()