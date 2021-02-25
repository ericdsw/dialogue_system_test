class_name Dialogue
extends Control

onready var pause_calculator := get_node("PauseCalculator") as PauseCalculator
onready var content := get_node("Content") as RichTextLabel
onready var voice_player := get_node("DialogueVoicePlayer") as AudioStreamPlayer
onready var type_timer := get_node("TypeTyper") as Timer
onready var pause_timer := get_node("PauseTimer") as Timer

var _playing_voice := false

signal message_completed()

# Swaps the current message with the one provided, and start the typing logic
func update_message(message: String) -> void:
	
	# Pause detection logic
	content.bbcode_text = pause_calculator.extract_pauses_from_string(message)
	content.visible_characters = 0
	
	type_timer.start()
	
	_playing_voice = true
	voice_player.play(0)

# Returns true if there are no pending characters to show
func message_is_fully_visible() -> bool:
	return content.visible_characters >= content.text.length() - 1

# Called when the timer responsible for showing characters calls its timeout
func _on_TypeTyper_timeout() -> void:
	pause_calculator.check_at_position(content.visible_characters)
	if content.visible_characters < content.text.length():
		content.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()
		emit_signal("message_completed")

# Called when the voice player finishes playing the voice clip
func _on_DialogueVoicePlayer_finished() -> void:
	if _playing_voice:
		voice_player.play(0)

# Called when the pause calculator node requests a pause
func _on_PauseCalculator_pause_requested(duration: float) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()

# Called when the pause timer finishes
func _on_PauseTimer_timeout() -> void:
	_playing_voice = true
	voice_player.play(0)
	type_timer.start()

