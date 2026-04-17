class_name GravityCore
extends Node3D

@export var shifts: Array[GravityShiftStep] = []

func _on_area_3d_body_entered(body):
	var player := body as PlayerCharacter
	if player == null:
		return
	if player.gravity_component == null:
		return
	if player.gravity_component.gravityCoreHandler == null:
		return
	player.gravity_component.gravityCoreHandler.set_current_gravity_core(self)
	PlayerUI.show_info_message("Press RT/Shift to change gravity")


func _on_area_3d_body_exited(body):
	var player := body as PlayerCharacter
	if player == null:
		return
	if player.gravity_component == null:
		return
	if player.gravity_component.gravityCoreHandler == null:
		return
	if player.gravity_component.gravityCoreHandler.current_gravity_core == self:
		player.gravity_component.gravityCoreHandler.clear_current_gravity_core()
		PlayerUI.clear_info_message()
