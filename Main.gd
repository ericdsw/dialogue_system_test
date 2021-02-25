extends Control

onready var dialogue_manager := get_node("DialogueManager") as DialogueManager
onready var dialogue_position := get_node("DialoguePosition").position as Vector2
onready var next_label := get_node("NextLabel") as Label

# Hide the next label on start
func _ready() -> void:
	next_label.visible = false

# Called when the funny button is pressed
func _on_FunnyButton_pressed() -> void:
	dialogue_manager.show_messages([
		"So,{p=0.5} you decided for a funny message...",
		"let's see...",
		"...",
		"Bro,{p=0.5} you are putting me on the spotlight",
		"[shake rate=20 level=10]NO IM NOT NERVOUS,{p=0.2} YOU ARE NERVOUS,{p=0.5} SHUT UP![/shake]"
	], dialogue_position)

# Called when the sad button is pressed
func _on_SadButton_pressed() -> void:
	dialogue_manager.show_messages([
		"Why on earth would you want to hear a sad message?",
		"Like,{p=0.5} just look around us!",
		"I don't think we need more sad stuff so...",
		"[wave]I'm gonna sing a song instead~[/wave]",
		"[wave]About{p=1.0} eh...[/wave]",
		"nevermind..."
	], dialogue_position)

# Called when the weird button is pressed
func _on_WeirdButton_pressed() -> void:
	dialogue_manager.show_messages([
		"Anatidaephobia is the fear that, somewhere,{p=0.2} at any given time",
		"[wave amplitude=10]a [rainbow]duck[/rainbow] is watching you...[/wave]",
		"MENACINGLY",
		"But seriously, if a duck was randomly watching me{p=0.2} I would freak out too...",
		"At least it's not a goose,{p=0.2} now THAT's [shake rate=20 level=10]terrifying[/shake]"
	], dialogue_position)

func _on_DialogueManager_message_completed() -> void:
	next_label.visible = true

func _on_DialogueManager_message_requested() -> void:
	next_label.visible = false

func _on_DialogueManager_finished() -> void:
	next_label.visible = false
