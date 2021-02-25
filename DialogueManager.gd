class_name DialogueManager
extends Node

const DIALOGUE_SCENE := preload("res://Dialogue.tscn")

onready var opacity_tween := get_node("OpacityTween") as Tween

signal message_requested()
signal message_completed()
signal finished()

var _messages := []
var _active_dialogue_offset := 0
var _is_active := false

var cur_dialogue_instance: Dialogue

# This input lifecycle method will be used to detect whether we press the "enter" key
func _input(event: InputEvent) -> void:
	if (
		event.is_pressed() and 
		!event.is_echo() and
		event is InputEventKey and 
		(event as InputEventKey).scancode == KEY_ENTER and
		_is_active and
		cur_dialogue_instance.message_is_fully_visible()
	):
		if _active_dialogue_offset < _messages.size() - 1:
			_active_dialogue_offset += 1
			_show_current()
		else:
			_hide()

# This will queue a set of messages, and will spawn the dialogue at the provided position
func show_messages(message_list: Array, position: Vector2) -> void:
	
	if _is_active:
		return
	_is_active = true
	
	_messages = message_list
	_active_dialogue_offset = 0
	
	var _dialogue = DIALOGUE_SCENE.instance()
	get_tree().get_root().add_child(_dialogue)
	
	_dialogue.modulate.a = 0
	_dialogue.rect_global_position = position
	_dialogue.connect("message_completed", self, "_on_message_completed")
	
	cur_dialogue_instance = _dialogue
	
	opacity_tween.interpolate_property(
		_dialogue, "modulate:a", 0.0, 1.0, 0.2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	opacity_tween.start()
	yield(opacity_tween, "tween_all_completed")
	
	_show_current()

# Updates the dialogue with the message for the current offset
func _show_current() -> void:
	emit_signal("message_requested")
	cur_dialogue_instance.update_message(_messages[_active_dialogue_offset])

# Hide the current dialogue, and finish the process
func _hide() -> void:
	
	cur_dialogue_instance.disconnect("message_completed", self, "_on_message_completed")
	
	opacity_tween.interpolate_property(
		cur_dialogue_instance, "modulate:a", 1.0, 0.0, 0.2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	opacity_tween.start()
	yield(opacity_tween, "tween_all_completed")
	cur_dialogue_instance.queue_free()
	cur_dialogue_instance = null
	_is_active = false
	emit_signal("finished")

# Called when the message finishes typing on the dialogue
func _on_message_completed() -> void:
	emit_signal("message_completed")

