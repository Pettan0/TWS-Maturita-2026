extends Button


func _ready() -> void:
	mouse_entered.connect(_button_enter)
	mouse_exited.connect(_button_exit)
	pressed.connect(btn_click)
	call_deferred("_init_pivot")

func _init_pivot():
	pivot_offset = size/2

func _button_enter():
	create_tween().tween_property(self, "offset_right", 261, 0.1).set_trans(Tween.TRANS_SINE)
	SoundManager.play_btn_hover_sfx()
	
func _button_exit():
	create_tween().tween_property(self, "offset_right", 231, 0.1).set_trans(Tween.TRANS_SINE)

func btn_click():
	SoundManager.play_btn_click_sfx()
