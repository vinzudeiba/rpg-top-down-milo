# ApaAja.gd
# SignalBus: mengatur state interaksi (sesuai list).
extends Node

signal interaksi_changed(_active: bool, _npc: Node)
signal ui_interact_pressed() # baru: dipancarkan saat tombol UI "E" ditekan ketika sedang interaksi
# active = true saat mulai interaksi, false saat selesai. npc = node npc (mis. Duck) saat aktif.

var is_interacting: bool = false
var current_npc: Node = null

# Flag yang menandai interaksi baru saja dimulai (dipakai DialogManager agar tidak langsung advance)
var just_started: bool = false

# cooldown berbasis frame untuk menghindari reopen instan setelah end_interaksi
var _cooldown_frames: int = 0
const INTERACT_COOLDOWN_FRAMES: int = 6  # kira-kira 6 frames (~0.1s pada 60fps)
func _ready() -> void:
		# enable processing agar frame cooldown berjalan
		set_process(true)
func _process(_delta: float) -> void:
		if _cooldown_frames > 0:
			_cooldown_frames -= 1

# dipanggil oleh Player ketika detect tekan "E" ketika di area npc
func start_interaksi(_npc: Node):
	print("[ApaAja] start_interaksi: ", _npc)
	if is_interacting:
		print("[ApaAja] start_interaksi: already interacting, ignored")
		return
	is_interacting = true
	current_npc = _npc
	# tandai supaya dialog manager mengabaikan press berikutnya yang sama
	just_started = true
	emit_signal("interaksi_changed", true, _npc)

# dipanggil ketika dialog selesai (DialogManager)
func end_interaksi():
	print("[ApaAja] end_interaksi() called; is_interacting=", is_interacting)
	if not is_interacting:
		print("[ApaAja] end_interaksi: not interacting, ignored")
		return
	is_interacting = false
# mulai cooldown agar press yang menutup dialog tidak langsung membuka lagi
	_cooldown_frames = INTERACT_COOLDOWN_FRAMES
		# jangan clear current_npc di sini; biarkan Player.set_near_npc/clear_near_npc yg mengatur
	emit_signal("interaksi_changed", false, null)

# Baru: dipanggil oleh UI Button (world.gd) untuk request interaksi dari UI
func ui_interact():
	# jika cooldown aktif, abaikan request
	if _cooldown_frames > 0:
		print("[ApaAja] ui_interact() IGNORED due to cooldown frames=", _cooldown_frames, " current_npc=", str(current_npc))
		return
	print("[ApaAja] ui_interact() called; is_interacting=", is_interacting, " current_npc=", str(current_npc))
	# jika sedang interaksi -> minta dialog manager lanjut / finish
	if is_interacting:
		emit_signal("ui_interact_pressed")
		return
	# jika tidak sedang interaksi -> coba start dengan current_npc (jika ada)
	if current_npc:
		start_interaksi(current_npc)
