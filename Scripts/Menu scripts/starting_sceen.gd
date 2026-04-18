extends Control

@onready var krocky: TextureRect = $Slide2/krocky
@onready var slide_2: Panel = $Slide2
@onready var label1: Label = $Slide2/Label1
@onready var label2: Label = $Slide2/Label2


func _ready() -> void:
	create_tween().tween_property(krocky, "modulate:a", 0.0, 0.0).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property(label1, "modulate:a", 0.0, 0.0).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property(label2, "modulate:a", 0.0, 0.0).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(0.5).timeout
	create_tween().tween_property(krocky, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)

	await get_tree().create_timer(1.5).timeout
	create_tween().tween_property(label1, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(3.0).timeout
	create_tween().tween_property(label2, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(1.5).timeout
	create_tween().tween_property(slide_2, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Menu/Main menu.tscn")

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://Menu/Main menu.tscn")
