extends CharacterBody2D

@export var speed: float = 125.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# urutan frame untuk mode "step-per-press" (sesuaikan index sesuai sprite sheetmu)
var step_sequences = {
	"down": [1, 2, 3, 0],
	"up":   [1, 2, 3, 0],
	"left": [1, 2, 3, 0],
	"right":[1, 2, 3, 0]
}
var step_index_by_dir = {
	"down": 0,
	"up": 0,
	"left": 0,
	"right": 0
}

var current_dir: String = "down"
var can_move: bool = true
var current_npc: Node = null

func _ready():
	# connect ke ApaAja (singleton)
	ApaAja.interaksi_changed.connect(_on_interaksi_changed)
	_play_idle_for_dir()

func _physics_process(_delta: float) -> void:
	# jika dialog aktif -> stop movement & anim idle
	if not can_move:
		velocity = Vector2.ZERO
		_play_idle_for_dir()
		move_and_slide()
		return

	_handle_movement_input()
	move_and_slide()

	# tangani interaksi E: hanya jika tidak sedang interaksi global
	#if Input.is_action_just_pressed("Aksi"):
		#if current_npc != null and not ApaAja.is_interacting:
			#ApaAja.start_interaksi(current_npc)
	if Input.is_action_just_pressed("Aksi") and not ApaAja.is_interacting:
		if current_npc:
			ApaAja.start_interaksi(current_npc)

# movement input handling: gabungan "step" (just_pressed) dan hold (continuous)
func _handle_movement_input() -> void:
	var input_vector = Vector2.ZERO
	var is_moving = false

	# Prioritas just_pressed untuk step animation (single press)
	if Input.is_action_just_pressed("ui_down"):
		current_dir = "down"
		_do_step_animation("down")
		input_vector.y = 1.0
		is_moving = true
	elif Input.is_action_just_pressed("ui_up"):
		current_dir = "up"
		_do_step_animation("up")
		input_vector.y = -1.0
		is_moving = true
	elif Input.is_action_just_pressed("ui_left"):
		current_dir = "left"
		_do_step_animation("left")
		input_vector.x = -1.0
		is_moving = true
	elif Input.is_action_just_pressed("ui_right"):
		current_dir = "right"
		_do_step_animation("right")
		input_vector.x = 1.0
		is_moving = true
	else:
		# Hold untuk continuous walk
		if Input.is_action_pressed("ui_right"):
			current_dir = "right"
			input_vector.x = 1.0
			is_moving = true
		elif Input.is_action_pressed("ui_left"):
			current_dir = "left"
			input_vector.x = -1.0
			is_moving = true
		elif Input.is_action_pressed("ui_down"):
			current_dir = "down"
			input_vector.y = 1.0
			is_moving = true
		elif Input.is_action_pressed("ui_up"):
			current_dir = "up"
			input_vector.y = -1.0
			is_moving = true

	# set velocity berdasarkan input_vector
	velocity = input_vector * speed

	# Animasi: jika moving dan bukan karena just_pressed (step), mainkan continuous anim
	if is_moving and not _any_just_pressed():
		_play_continuous_anim()
	elif not is_moving:
		_play_idle_for_dir()

# coba mulai interaksi: cari Area2D (child Duck) pada posisi player
#func _try_start_interaction() -> void:
	#var space_state = get_world_2d().direct_space_state
	## cek pada titik player; argumen kedua = max_results (kecilkan bila perlu),
	## argumen terakhir true,true agar juga mendeteksi Area2D.
	#var results = space_state.intersect_point(global_position, 16, [], 0x7fffffff, true, true)
	#for r in results:
		#if not r.has("collider"):
			#continue
		#var col = r["collider"]
		## cek bila collider adalah Area2D child dari Duck
		#if col is Area2D and col.get_parent() and col.get_parent().name == "Duck":
			## mulai interaksi via singleton
			#ApaAja.start_interaksi(col.get_parent())
			#return
	## jika tidak ada npc -> do nothing (sesuai spesifikasi)

# helper untuk memeriksa apakah ada just_pressed aktif (agar tidak override step)
func _any_just_pressed() -> bool:
	return Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("Aksi")

# ketika spam (just_pressed) — tampilkan frame sesuai sequence
func _do_step_animation(dir: String) -> void:
	if not step_sequences.has(dir):
		return
	var seq = step_sequences[dir]
	var idx = step_index_by_dir[dir] % seq.size()
	var frame_to_show = seq[idx]

	match dir:
		"down":
			anim.animation = "f_walk"
		"up":
			anim.animation = "b_walk"
		"left":
			anim.animation = "L_walk"
		"right":
			anim.animation = "r_walk"

	# hentikan loop normal dan tunjukkan frame spesifik
	anim.stop()
	anim.frame = frame_to_show

	# next index untuk press berikutnya
	step_index_by_dir[dir] = (idx + 1) % seq.size()

# mainkan anim berjalan biasa ketika hold
func _play_continuous_anim() -> void:
	match current_dir:
		"right":
			anim.flip_h = false
			if anim.animation != "r_walk" or anim.stop:
				anim.play("r_walk")
		"left":
			anim.flip_h = false
			if anim.animation != "L_walk" or anim.stop:
				anim.play("L_walk")
		"down":
			anim.flip_h = false
			if anim.animation != "f_walk" or anim.stop:
				anim.play("f_walk")
		"up":
			anim.flip_h = false
			if anim.animation != "b_walk" or anim.stop:
				anim.play("b_walk")

# mainkan idle jika tidak bergerak
func _play_idle_for_dir() -> void:
	match current_dir:
		"right":
			if anim.animation != "r_idle" or anim.stop:
				anim.play("r_idle")
		"left":
			if anim.animation != "L_idle" or anim.stop:
				anim.play("L_idle")
		"down":
			if anim.animation != "f_idle" or anim.stop:
				anim.play("f_idle")
		"up":
			if anim.animation != "b_idle" or anim.stop:
				anim.play("b_idle")

# dipanggil saat ada perubahan interaksi global (kotakhitam & tekskata)
func _on_interaksi_changed(active: bool, _npc: Node):
	# jika kotakhitam & tekskata show -> movement disable
	can_move = not active
	
func set_near_npc(npc: Node):
	current_npc = npc

func clear_near_npc():
	current_npc = null
