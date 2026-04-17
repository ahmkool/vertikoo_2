class_name GravityCoreHandler
extends Node

var current_gravity_core: GravityCore

func set_current_gravity_core(gravity_core: GravityCore) -> void:
	current_gravity_core = gravity_core

func clear_current_gravity_core() -> void:
	current_gravity_core = null
