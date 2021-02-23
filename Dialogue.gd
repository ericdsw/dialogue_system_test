class_name Dialogue
extends Control

onready var pause_calculator := get_node("PauseCalculator") as PauseCalculator
onready var content := get_node("Content") as RichTextLabel
onready var voice_player := get_node("DialogueVoicePlayer") as AudioStreamPlayer
onready var type_timer := get_node("TypeTyper") as Timer
onready var pause_timer := get_node("PauseTimer") as Timer

var _playing_voice := false
var _random_number_gen := RandomNumberGenerator.new()

signal message_completed()

# ================================ Lifecycle ================================ #

func _ready() -> void:
	_random_number_gen.randomize()

# ================================= Public ================================== #

func update_message(message: String) -> void:
	
	content.bbcode_text = pause_calculator.extract_pauses_from_string(message)
	content.visible_characters = 0
	
	type_timer.start()
	
	_playing_voice = true
	voice_player.play(0)

# ================================ Callbacks ================================ #

func _on_TypeTyper_timeout() -> void:
	pause_calculator.check_at_position(content.visible_characters)
	if content.visible_characters < content.text.length():
		content.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()
		emit_signal("message_completed")

func _on_DialogueVoicePlayer_finished() -> void:
	if _playing_voice:
		voice_player.play(0)

func _on_PauseCalculator_pause_requested(duration: float) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()

func _on_PauseTimer_timeout() -> void:
	_playing_voice = true
	voice_player.play(0)
	type_timer.start()
