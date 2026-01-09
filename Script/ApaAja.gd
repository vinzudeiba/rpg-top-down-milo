# ApaAja.gd
# SignalBus: mengatur state interaksi (sesuai list).
extends Node

signal interaksi_changed(_active: bool, _npc: Node)
signal ui_interact_pressed() # baru: dipancarkan saat tombol UI "E" ditekan ketika sedang interaksi
# active = true saat mulai interaksi, false saat selesai. npc = node npc (mis. Duck) saat aktif.

var is_interacting: bool = false
var current_npc: Node = null

# dipanggil oleh Player ketika detect tekan "E" ketika di area npc
func start_interaksi(_npc: Node):
	print("[ApaAja] start_interaksi: ", _npc)
	if is_interacting:
		print("[ApaAja] start_interaksi: already interacting, ignored")
		return
	is_interacting = true
	current_npc = _npc
	emit_signal("interaksi_changed", true, _npc)

# dipanggil ketika dialog selesai (DialogManager)
func end_interaksi():
	print("[ApaAja] end_interaksi() called; is_interacting=", is_interacting)
	if not is_interacting:
		print("[ApaAja] end_interaksi: not interacting, ignored")
		return
	is_interacting = false
	#current_npc = null
	emit_signal("interaksi_changed", false, null)

# Baru: dipanggil oleh UI Button (world.gd) untuk request interaksi dari UI
func ui_interact():
	print("[ApaAja] ui_interact() called; is_interacting=", is_interacting, " current_npc=", str(current_npc))
	# jika sedang interaksi -> minta dialog manager lanjut / finish
	if is_interacting:
		emit_signal("ui_interact_pressed")
		return
	# jika tidak sedang interaksi -> coba start dengan current_npc (jika ada)
	if current_npc:
		start_interaksi(current_npc)
