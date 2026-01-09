# Duck.gd
# Hanya mengatur: initanda (label "press e") tampil/hidden berdasarkan proximity & kotakhitam/tekskata state.
extends Node2D

@onready var area: Area2D = $Area2D
@onready var initanda: Label = $Label    # label "press e" yang dinamakan "initanda"

var player_near: bool = false

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)
	# dengarkan state interaksi (/kotakhitam & tekskata) lewat ApaAja
	ApaAja.interaksi_changed.connect(_on_interaksi_changed)

func _on_area_body_entered(body: Node):
	# jika player masuk area -> tandai dekat, update visibility
	if body.name == "Player":
		player_near = true
		if body.has_method("set_near_npc"):
			body.set_near_npc(self)
		_update_initanda_visibility()

func _on_area_body_exited(body: Node):
	# player keluar area -> sembunyikan
	if body.name == "Player":
		player_near = false
		if body.has_method("clear_near_npc"):
			body.clear_near_npc()
		_update_initanda_visibility()

func _on_interaksi_changed(_active: bool, _npc: Node):
	# jika kotakhitam & tekskata tampil (active true), initanda harus hide.
	# jika hide (active false) dan player dekat -> show
	_update_initanda_visibility()

func _update_initanda_visibility():
	# initanda show hanya jika player dekat AND tidak sedang interaksi (kotakhitam+tekskata hide)
	if player_near and not ApaAja.is_interacting:
		initanda.visible = true
	else:
		initanda.visible = false
