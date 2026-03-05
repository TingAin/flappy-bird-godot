extends CharacterBody2D

const GRAVITY = 650
const JUMP_FORCE = -350 


func _physics_process(delta: float) -> void:
    # 重力
    velocity.y += GRAVITY * delta

    # 跳跃
    if Input.is_action_just_pressed("ui_accept"):
        velocity.y = JUMP_FORCE
    
    # 移动！
    move_and_slide()