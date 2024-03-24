extends Node

var stump_scene = preload("res://scenes/stunp.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var obstacle_types := [stump_scene,rock_scene,barrel_scene]
var obstacles : Array
var bird_heights := [512,120]

const DINO_START_POS := Vector2i(-352,152)
const CAM_START_POS := Vector2i(0,0)
var difficulty
const MAX_DIFFICULTY : int = 2 
var score : int
var speed: float
const SCORE_MODIFIER : int = 10
const SPEED_MODIFIER : int = 5000

const START_SPEED : float = 5.0
const MAX_SPEED : int = 10.0
var screen_size : Vector2i
var game_running : bool
var ground_height : int
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	#reset the nodes
	score = 0
	show_score()
	game_running = false
	difficulty = 0

	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(32,-1032)
	$Bg.offset = Vector2i(0,-700)

	$HUD.get_node("StartLabel").show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		generate_obs()

		#move dino and camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed

		score += speed
		show_score()

		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x

		for obs in obstacles:
			print(obs.position.x, " ", $Camera2D.position.x - screen_size.x)
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#generate ground obstacles
	print(obstacles.is_empty())
	print("1: ", last_obs)
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var max_obs = difficulty + 1
		var obs
		var enemy_count = range(randi() % max_obs +1)
		print("enemy", enemy_count)
		for i in enemy_count:
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 50)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) - 400
			last_obs = obs.duplicate(true)
			print("2: ", last_obs.position.x)
			add_obs(obs, obs_x, obs_y)
		if difficulty == 0:#MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE:" + str(score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
