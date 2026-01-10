extends Node2D

#add variable
@onready var exit_button: NodePath = "UI Button/ExitButton"
@onready var u: NodePath = "UI Button/U"
@onready var d: NodePath = "UI Button/D"
@onready var l: NodePath = "UI Button/L"
@onready var r: NodePath = "UI Button/R"
@onready var e: NodePath = "UI Button/E"


	
#exit button
func _on_exit_button_pressed():
	get_tree().quit()

#up button
func _on_u_button_down() -> void:
	Input.action_press("ui_up")
func _on_u_button_up() -> void:
	Input.action_release("ui_up")
#down button
func _on_d_button_down() -> void:
	Input.action_press("ui_down")
func _on_d_button_up() -> void:
	Input.action_release("ui_down")
#left button
func _on_l_button_down() -> void:
	Input.action_press("ui_left")
func _on_l_button_up() -> void:
	Input.action_release("ui_left")
#right button
func _on_r_button_down() -> void:
	Input.action_press("ui_right")
func _on_r_button_up() -> void:
	Input.action_release("ui_right")
	
#E button
func _on_e_pressed() -> void:
	print("[world] UI E pressed")
	ApaAja.ui_interact("ui")
