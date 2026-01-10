extends CanvasLayer

@export var text_speed: float = 0.05  # seconds per character (lebih kecil = lebih cepat)
@onready var kotakhitam = $DialogPanel
@onready var tekskata = $RichTextLabel

var dialog_data := {
	"Duck": ["Quack", "Nice Weather"]
}

# runtime state
var current_lines: Array = []
var current_index: int = 0
var current_text: String = ""
var time_elapsed: float = 0.0
var is_typing: bool = false   # true = sedang mengetik huruf demi huruf
var total_chars: int = 0

func _ready() -> void:
	kotakhitam.visible = false
	tekskata.visible = false
	# connect ke signal autoload (langsung, tanpa callable)
	ApaAja.interaksi_changed.connect(_on_interaksi_changed)
	# baru: connect ke UI-interact signal sehingga tombol UI bisa meng-advance dialog
	ApaAja.ui_interact_pressed.connect(_on_ui_interact_pressed)
	print("[DialogManager] ready; connected to ApaAja signals")

func _on_interaksi_changed(active: bool, npc: Node):
	print("[DialogManager] interaksi_changed:", active, " npc=", npc)	# safety: jika active true tapi npc null -> log & abort
	if active and npc == null:
		print("[DialogManager] WARNING: interaksi_changed active but npc is null")
		return
		
	if active:
		kotakhitam.show()
		tekskata.show()

		var npc_name = str(npc.name)
		print("[DialogManager] npc.name='", npc_name, "'; dialog_data.has=", dialog_data.has(npc_name))
		current_lines = dialog_data.get(npc_name, []).duplicate()
		current_index = 0
		
		print("[DialogManager] current_lines.size=", current_lines.size())
		if current_lines.is_empty():
			print("[DialogManager] no dialog lines found for", npc_name, " -> ending interaksi")
			ApaAja.end_interaksi()
			return

		_start_line(current_lines[current_index])
	else:
		_close_dialog()
		
func _start_line(line_text: String) -> void:
	current_text = line_text
	tekskata.clear()            # bersihkan buffer richtext
	tekskata.bbcode_text = current_text  # set full text but we'll control visible_ratio
	# reset timing
	time_elapsed = 0.0
	is_typing = true
	total_chars = current_text.length()
	# mulai dari 0 terlihat
	if total_chars > 0:
		tekskata.visible_ratio = 0.0
	else:
		tekskata.visible_ratio = 1.0
		is_typing = false

func _input(event: InputEvent) -> void:
	# hanya tangani tombol E saat panel tampil
	if not kotakhitam.visible:
		return
# tangani hanya action press dari input event (keyboard)
	if event.is_action_pressed("Aksi"):
		_handle_interact_press()

# handler terpisah: dipakai oleh _input dan juga oleh UI via ApaAja.ui_interact_pressed
func _handle_interact_press() -> void:
	if is_typing:
		# finish immediately
		tekskata.visible_ratio = 1.0
		is_typing = false
		time_elapsed = total_chars * text_speed
	else:
		# teks sudah penuh -> lanjut ke baris berikutnya atau selesai
		current_index += 1
		if current_index < current_lines.size():
			_start_line(current_lines[current_index])
		else:
			# tidak ada dialog lagi -> akhiri interaksi dan hide UI
			ApaAja.end_interaksi()

# baru: handler untuk UI "E" yang memanggil ApaAja.ui_interact()
func _on_ui_interact_pressed() -> void:
	print("[DialogManager] ui_interact_pressed received; kotak visible=", kotakhitam.visible, " is_typing=", is_typing)
	# UI request hanya valid jika kotak dialog sedang ditampilkan
	if not kotakhitam.visible:
		return
	_handle_interact_press()

func _process(delta: float) -> void:
	# jika sedang mengetik, maju tipe berdasarkan seconds-per-char
	if kotakhitam.visible and is_typing and total_chars > 0:
		time_elapsed += delta
		# berapa huruf yang harus ditampilkan sekarang (integer)
		var chars_shown = int(floor(time_elapsed / text_speed))
		# clamp agar tidak melebihi total_chars
		chars_shown = clamp(chars_shown, 0, total_chars)
		# set visible_ratio sebagai proporsi karakter yang tampak
		tekskata.visible_ratio = float(chars_shown) / float(max(total_chars, 1))
		# jika sudah penuh -> stop typing (tunggu E untuk lanjut)
		if chars_shown >= total_chars:
			is_typing = false
			tekskata.visible_ratio = 1.0
			
func _close_dialog() -> void:
	kotakhitam.hide()
	tekskata.hide()
	tekskata.clear()
	# hanya clear salinan current_lines, jangan memodifikasi dialog_data
	current_lines.clear()
	current_index = 0
	current_text = ""
	time_elapsed = 0.0
	is_typing = false
	total_chars = 0
