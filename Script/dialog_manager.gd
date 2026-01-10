extends CanvasLayer

@export var text_speed: float = 0.1  # seconds per character
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
var is_typing: bool = false
var total_chars: int = 0

# local flag: ignore exactly one advance press right after opening dialog (only for key-source)
var _ignore_next_press: bool = false

func _ready() -> void:
	kotakhitam.visible = false
	tekskata.visible = false
	ApaAja.interaksi_changed.connect(_on_interaksi_changed)
	ApaAja.ui_interact_pressed.connect(_on_ui_interact_pressed)
	print("[DialogManager] ready; connected to ApaAja signals")

func _on_interaksi_changed(active: bool, npc: Node):
	print("[DialogManager] interaksi_changed:", active, " npc=", npc)
	if active and npc == null:
		print("[DialogManager] WARNING: interaksi_changed active but npc is null")
		return

	if active:
		kotakhitam.show()
		tekskata.show()

		var npc_name = str(npc.name)
		current_lines = dialog_data.get(npc_name, []).duplicate()
		current_index = 0

		print("[DialogManager] npc.name='", npc_name, "'; current_lines.size=", current_lines.size())

		if current_lines.is_empty():
			ApaAja.end_interaksi()
			return

		_start_line(current_lines[current_index])

		# only ignore the next press if the interaction was started by a physical key
		_ignore_next_press = ApaAja.just_started and ApaAja.just_started_source == "key"
		# DO NOT clear ApaAja.just_started here — let singleton manage its frames
	else:
		_close_dialog()

func _start_line(line_text: String) -> void:
	current_text = line_text
	tekskata.clear()
	tekskata.bbcode_text = current_text
	time_elapsed = 0.0
	is_typing = true
	total_chars = current_text.length()
	if total_chars > 0:
		tekskata.visible_ratio = 0.0
	else:
		tekskata.visible_ratio = 1.0
		is_typing = false

func _input(event: InputEvent) -> void:
	if not kotakhitam.visible:
		return
	if event.is_action_pressed("Aksi"):
		if _consume_ignore():
			return
		_handle_interact_press()

func _handle_interact_press() -> void:
	if is_typing:
		tekskata.visible_ratio = 1.0
		is_typing = false
		time_elapsed = total_chars * text_speed
	else:
		current_index += 1
		if current_index < current_lines.size():
			_start_line(current_lines[current_index])
		else:
			ApaAja.end_interaksi()

func _on_ui_interact_pressed() -> void:
	if not kotakhitam.visible:
		return
	if _consume_ignore():
		return
	_handle_interact_press()

func _process(delta: float) -> void:
	if kotakhitam.visible and is_typing and total_chars > 0:
		time_elapsed += delta
		var chars_shown = int(floor(time_elapsed / text_speed))
		chars_shown = clamp(chars_shown, 0, total_chars)
		tekskata.visible_ratio = float(chars_shown) / float(max(total_chars, 1))
		if chars_shown >= total_chars:
			is_typing = false
			tekskata.visible_ratio = 1.0

	# polling physical key fallback, but respect ignore flag
	if kotakhitam.visible:
		if _ignore_next_press:
			# don't poll/advance until we've consumed ignore
			return
		if Input.is_action_just_pressed("Aksi"):
			_handle_interact_press()

func _consume_ignore() -> bool:
	if _ignore_next_press:
		_ignore_next_press = false
		print("[DialogManager] consumed ignore of initial press")
		return true
	return false

func _close_dialog() -> void:
	kotakhitam.hide()
	tekskata.hide()
	tekskata.clear()
	current_lines.clear()
	current_index = 0
	current_text = ""
	time_elapsed = 0.0
	is_typing = false
	total_chars = 0
	_ignore_next_press = false
