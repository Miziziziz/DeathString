extends Control

func _ready():
	$CanvasLayer/VBoxContainer/GraphicsHigh.connect("button_up", self, "set_graphics_high")
	$CanvasLayer/VBoxContainer/GraphicsMed.connect("button_up", self, "set_graphics_med")
	$CanvasLayer/VBoxContainer/GraphicsLow.connect("button_up", self, "set_graphics_low")
	$CanvasLayer/Play.connect("button_up", self, "play")

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("continue"):
		LevelManager.load_next_level()

func set_graphics_low():
	LevelManager.set_graphics_low()
	$CanvasLayer/GraphicsSetting.text = "Current setting: Low"
	
func set_graphics_med():
	LevelManager.set_graphics_med()
	$CanvasLayer/GraphicsSetting.text = "Current setting: Med"
	
func set_graphics_high():
	LevelManager.set_graphics_high()
	$CanvasLayer/GraphicsSetting.text = "Current setting: High"

func play():
	LevelManager.load_next_level()
