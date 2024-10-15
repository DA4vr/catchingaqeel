extends Node2D


"""
obstacles
"""
var bat_scene = preload("res://bat.tscn")
var afif_scene= preload("res://afif.tscn")
var boyonbench_scene = preload("res://obstacles/boyonbench.tscn")
var girl_scene = preload("res://obstacles/girl.tscn")
var npcs = preload ("res://obstacles/npcs.tscn")
var palm = preload("res://obstacles/palm.tscn")
var highscore: int
var obstacles_type := [afif_scene,girl_scene ]
var obstacles: Array
var bat_heights := [360,400]

"""
variables
"""
const character_start_pos = Vector2i(150,485)
const cam_start_pos = Vector2i(576,324) 
var score: int
const score_modifier : int = 10
const speed_modifier: int =5000
var speed : float
const start_speed: float = 12.0
const max_speed : int = 25
var screen_size :Vector2i
var ground_height : int
var game_running : bool
var last_obs
var difficulty
const max_difficulty: int = 2
var final_score: int
"""
functions
"""
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height  = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)

	new_game()
	
	$GameOver.get_node("RichTextLabel").hide()
	$HUD.get_node("TextureRect/Control/zero").hide()
	$HUD.get_node("TextureRect/Control/moneyhoney").hide()
	$HUD.get_node("TextureRect/Control/yesterday").hide()
	$HUD.get_node("TextureRect/Control/oldpeople").hide()
	

func new_game():
	score = 0
	show_score()
	difficulty = 0
	game_running = false
	get_tree().paused = false
	$GameOver.get_node("RichTextLabel").hide()
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	$HUD.get_node("TextureRect/Control/zero").hide()
	$HUD.get_node("TextureRect/Control/yesterday").hide()
	$HUD.get_node("TextureRect/Control/oldpeople").hide()	
	$HUD.get_node("TextureRect/Control/moneyhoney").hide()	
	$CharacterBody2D.position = character_start_pos
	$CharacterBody2D.velocity = Vector2i(0,0)
	$Camera2D.position = cam_start_pos
	$Ground.position = Vector2i(0,0)
	$HUD.get_node("START").show()
	$HUD.get_node("LEADERBOARD").show()
	$HUD.get_node("AnimatedSprite2D").show()
	$HUD.get_node("Score Label").hide()
	$HUD.get_node("TITLE").show()	
	$HUD.get_node("TextureRect/Control/zero").hide()
	$HUD.get_node("TextureRect/Control/face me").show()
	$GameOver.get_node("TextureRect").hide()
	$GameOver.get_node("TextureRect2").hide()
	$GameOver.get_node("Button").hide()
	$HUD.get_node("TextureRect/Control/yesterday").hide()

"""
_process function
"""

func _process(delta):
	if game_running:
		#adding this so the player can run faster the more score he has
		speed = start_speed + score/ speed_modifier
		if speed > max_speed:
			speed = max_speed
		adjust_difficulty()
		generate_obs()
		$CharacterBody2D.position.x += speed
		$Camera2D.position.x +=speed
		
		score +=speed
		show_score()
		#updaye ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
				$Ground.position.x += screen_size.x
		$HUD.get_node("TextureRect/Control/zero").show()
		$HUD.get_node("TextureRect/Control/moneyhoney").hide()
		$HUD.get_node("TextureRect/Control/yesterday").hide()
		$HUD.get_node("TextureRect/Control/face me").hide()
		$HUD.get_node("TextureRect/Control/oldpeople").hide()
		#remove obstacles
		for obs in obstacles :
			if obs.position.x <($Camera2D.position.x - screen_size.x):
				obs.queue_free()
				obstacles.erase(obs)
		 
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("Score Label").show()
			$HUD.get_node("START").hide()
			$HUD.get_node("LEADERBOARD").hide()
			$HUD.get_node("TITLE").hide()
	final_score = score/score_modifier
	if final_score < 500 and final_score > 0:
		$HUD.get_node("TextureRect/Control/zero").hide()
		$HUD.get_node("TextureRect/Control/yesterday").show()
	elif final_score > 500 and final_score < 1000:
		$HUD.get_node("TextureRect/Control/zero").hide()
		$HUD.get_node("TextureRect/Control/yesterday").hide()
		$HUD.get_node("TextureRect/Control/oldpeople").show()
	elif final_score > 500 and final_score < 1000:
		$HUD.get_node("TextureRect/Control/zero").hide()
		$HUD.get_node("TextureRect/Control/yesterday").hide()
		$HUD.get_node("TextureRect/Control/oldpeople").hide()	
		$HUD.get_node("TextureRect/Control/moneyhoney").show()	

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(200,300):
		"""
		pick from the array randomly
		"""
		var obs_type = obstacles_type[randi()% obstacles_type.size()]
		var obs
		var max_obs = difficulty + 1
		"""
		store that into the obs variable
		"""
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x: int = $Camera2D.position.x + screen_size.x + (i * 100)
			var obs_y: int = screen_size.y - ground_height - (obs_height * obs_scale.y/1.5) + 5
			"""
			set last_obs = obs , to avoid repetition
			"""
			last_obs = obs
			add_obs(obs, obs_x , obs_y)
		#spawn bird
		if difficulty == max_difficulty:
			if (randi() % 2) == 0:
				obs = bat_scene.instantiate()
				var obs_x: int = screen_size.x + score + 100 
				var obs_y: int = bat_heights[randi() % bat_heights.size()]
				add_obs(obs, obs_x , obs_y)
func hit_obs(body):
	if body.name == "CharacterBody2D":
		game_over()

func game_over():
	get_tree().paused = true
	$butonup.play()
		# Only play if not already playing
	if not get_node("butonup").is_playing():
		get_node("butonup").play()
	
	game_running = false
	check_highscore()

	$GameOver.get_node("TextureRect").show()
	$GameOver.get_node("TextureRect2").show()
	$GameOver.get_node("Button").show()
	$GameOver.get_node("RichTextLabel").show() 
func add_obs(obs , x , y):
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func show_score():
	$HUD.get_node("Score Label").text = "SCORE: " + str(score/score_modifier) 
func adjust_difficulty():
	difficulty = score /speed_modifier
	if difficulty > max_difficulty:
		difficulty = max_difficulty
	
func check_highscore():
	if score > highscore:
		highscore = score
		$HUD.get_node("LEADERBOARD").text = "LEADERBOARD: " + str(highscore/score_modifier) 
