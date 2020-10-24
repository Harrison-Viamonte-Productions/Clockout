extends CanvasLayer

var resolutions: Array = [
	"640x360",
	"960x540",
	"1280x720",
	"1600x900",
	"1920x1080",
	"2240x1260",
	"2560x1440"
];

onready var ResolutionsOptions: OptionButton = $OptionsContainer/OptionsMenu/VBoxContainer/Resolutions/Resolutions;
onready var FullScreenCheckbox: CheckBox = $OptionsContainer/OptionsMenu/VBoxContainer/FullScreen/FullScreenCheckBox;

var options_dialog_shown: bool = false; 

func _ready():
	$Buttons/NewGame.connect("pressed", self, "new_game");
	$QuitGame/QuitGame.connect("pressed", self, "quit_game");
	$Buttons/Options.connect("pressed", self, "open_options_dialog");
	$Buttons/LoadGame.connect("pressed", self, "open_loadgame_dialog");
	$Buttons/SaveGame.connect("pressed", self, "open_savegame_dialog");
	
	$OptionsContainer/OptionsMenu/HBoxContainer/ApplyChanges.connect("pressed", self, "apply_config_changes");
	
	load_resolutions();
	ResolutionsOptions.select(0);
	$VersionLabel.text = ("VERSION: %s" % Game.VERSION);
	#unused yet
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys1.visible = false;
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys2.visible = false;
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys3.visible = false;
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys4.visible = false;

func load_resolutions():
	ResolutionsOptions.clear();
	for res in resolutions:
		ResolutionsOptions.add_item(res);

func get_resolution_from_string(res_str: String) -> Vector2:
	var str_array: PoolStringArray = res_str.split("x");
	return Vector2(int(str_array[0]),int(str_array[1]));

func quit_game():
	get_tree().quit();

func open_options_dialog():
	if !options_dialog_shown:
		$AnimationPlayer.play("show_options");
		options_dialog_shown = true;

func open_savegame_dialog():
	if options_dialog_shown:
		$AnimationPlayer.play("hide_options");
		options_dialog_shown = false;
		
func open_loadgame_dialog():
	if options_dialog_shown:
		$AnimationPlayer.play("hide_options");
		options_dialog_shown = false;

func new_game():
	get_tree().change_scene("res://src/Levels/DemoLevel.tscn");
	
func apply_config_changes():
	OS.window_fullscreen = FullScreenCheckbox.pressed;
	OS.set_window_size(get_resolution_from_string(resolutions[ResolutionsOptions.selected]));

func set_ingame_mode():
	$BackgroundImage.modulate.a = 0.85;
	$BackgroundImage.modulate.r = 0.0;
	$BackgroundImage.modulate.g = 0.0;
	$BackgroundImage.modulate.b = 0.0;
