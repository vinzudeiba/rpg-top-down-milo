# ApaAja.gd
# SignalBus: mengatur state interaksi (sesuai list).
extends Node

signal interaksi_changed(_active: bool, _npc: Node) 
# active = true saat mulai interaksi, false saat selesai. npc = node npc (mis. Duck) saat aktif.

var is_interacting: bool = false
var current_npc: Node = null

# dipanggil oleh Player ketika detect tekan "E" ketika di area npc
func start_interaksi(_npc: Node):
	if is_interacting:
		return
	is_interacting = true
	current_npc = _npc
	emit_signal("interaksi_changed", true, _npc)

# dipanggil ketika dialog selesai (DialogManager)
func end_interaksi():
	if not is_interacting:
		return
	is_interacting = false
	current_npc = null
	emit_signal("interaksi_changed", false, null)
