class_name PlayerUI
extends CanvasLayer

static var _instance: PlayerUI

@export var info_fade_in_duration: float = 0.2
@export var info_fade_out_duration: float = 0.2

@onready var _info_message: MarginContainer = $InfoMessage
@onready var _info_message_label: RichTextLabel = $InfoMessage/PanelContainer/MarginContainer/RichTextLabel

var _info_tween: Tween


func _ready() -> void:
	_instance = self
	_clear_info_message_immediate()


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


static func show_info_message(message: String) -> void:
	if _instance == null:
		push_warning("PlayerUI.show_info_message() called before PlayerUI is ready.")
		return
	_instance._show_info_message(message)


static func clear_info_message() -> void:
	if _instance == null:
		return
	_instance._clear_info_message()


func _show_info_message(message: String) -> void:
	_info_message_label.text = message
	_info_message.visible = true
	_kill_info_tween()
	_info_tween = create_tween()
	_info_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_info_tween.tween_property(_info_message, "modulate:a", 1.0, info_fade_in_duration)


func _clear_info_message() -> void:
	if not _info_message.visible:
		_info_message_label.text = ""
		return
	_kill_info_tween()
	_info_tween = create_tween()
	_info_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_info_tween.tween_property(_info_message, "modulate:a", 0.0, info_fade_out_duration)
	_info_tween.finished.connect(_on_info_hidden, CONNECT_ONE_SHOT)


func _clear_info_message_immediate() -> void:
	_kill_info_tween()
	_info_message.modulate.a = 0.0
	_info_message_label.text = ""
	_info_message.visible = false


func _on_info_hidden() -> void:
	_info_message_label.text = ""
	_info_message.visible = false


func _kill_info_tween() -> void:
	if _info_tween == null:
		return
	_info_tween.kill()
	_info_tween = null
