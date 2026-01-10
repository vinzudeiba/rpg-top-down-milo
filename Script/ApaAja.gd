# ApaAja.gd
# SignalBus: mengatur state interaksi (sesuai list).
extends Node

signal interaksi_changed(_active: bool, _npc: Node)
signal ui_interact_pressed()

var is_interacting: bool = false
var current_npc: Node = null

# Flag yang menandai interaksi baru saja dimulai (dipakai DialogManager agar tidak langsung advance)
var just_started: bool = false
var just_started_source: String = ""  # "key" atau "ui"

# frame counter untuk menjaga just_started selama beberapa frame
var just_started_frames: int = 0
const JUST_STARTED_FRAMES: int = 2

# cooldown berbasis frame untuk menghindari reopen instan setelah end_interaksi
var _cooldown_frames: int = 0
const INTERACT_COOLDOWN_FRAMES: int = 6  # kira-kira 6 frames (~0.1s pada 60fps)

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	# jalankan cooldown frame
	if _cooldown_frames > 0:
		_cooldown_frames -= 1
	# jalankan just_started frame counter
	if just_started_frames > 0:
		just_started_frames -= 1
		if just_started_frames == 0:
			# selesai periode "just started"
			just_started = false
			just_started_source = ""

# dipanggil oleh Player ketika detect tekan "E" (source = "key") atau oleh UI (source = "ui")
func start_interaksi(_npc: Node, source: String = "key"):
	print("[ApaAja] start_interaksi: ", _npc, " source=", source)
	if is_interacting:
		print("[ApaAja] start_interaksi: already interacting, ignored")
		return
	is_interacting = true
	current_npc = _npc
	# tandai supaya dialog manager dapat memilih apakah akan ignore press berikutnya
	just_started = true
	just_started_source = source
	just_started_frames = JUST_STARTED_FRAMES
	emit_signal("interaksi_changed", true, _npc)

func end_interaksi():
	print("[ApaAja] end_interaksi() called; is_interacting=", is_interacting)
	if not is_interacting:
		print("[ApaAja] end_interaksi: not interacting, ignored")
		return
	is_interacting = false
	# mulai cooldown agar press yang menutup dialog tidak langsung membuka lagi
	_cooldown_frames = INTERACT_COOLDOWN_FRAMES
	emit_signal("interaksi_changed", false, null)

# Dipanggil oleh Player/world/UI. Pass source "key" atau "ui".
func ui_interact(source: String = "key"):
	# jika cooldown aktif, abaikan request
	if _cooldown_frames > 0:
		print("[ApaAja] ui_interact() IGNORED due to cooldown frames=", _cooldown_frames, " current_npc=", str(current_npc))
		return

	print("[ApaAja] ui_interact() called; is_interacting=", is_interacting, " current_npc=", str(current_npc), " source=", source)
	if is_interacting:
		emit_signal("ui_interact_pressed")
		return
	if current_npc:
		start_interaksi(current_npc, source)
