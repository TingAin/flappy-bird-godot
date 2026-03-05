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


func _check_collision() -> void:
	"""检测是否撞到管道"""
	var collision_count = get_slide_collision_count()
	
	if collision_count > 0:
		# 撞到了东西
		print("游戏结束！撞到了管道")
		get_tree().paused = true
