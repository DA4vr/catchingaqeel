extends CharacterBody2D

var GRAVITY : int = 4200
const JUMP_SPEED: int = -1300

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	# Check if on the floor (running or standing)
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$runcol.disabled = false
			# Handle jumping
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_SPEED
				$AudioStreamPlayer.play()

			# Handle ducking on the ground
			if Input.is_action_pressed("duck"):
				$AnimatedSprite2D.play("duck")
				$ducksound.play()
			else:
				$AnimatedSprite2D.play("run")
				$runcol.disabled = true
	
	# If in the air (jumping or falling)
	else:
		if Input.is_action_pressed("duck"):
			GRAVITY = 9800
			$AnimatedSprite2D.play("duck")
			$ducksound.play()
		else:
			GRAVITY = 4200
			$AnimatedSprite2D.play("jump")

	move_and_slide()
