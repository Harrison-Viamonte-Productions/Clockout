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
onready var LangsOptions: OptionButton = $OptionsContainer/OptionsMenu/VBoxContainer/Languages/Langs;

var options_dialog_shown: bool = false; 

func _ready():
	add_to_group("has_lang_strings");
	
	$Buttons/NewGame.connect("pressed", self, "new_game");
	$QuitGame/QuitGame.connect("pressed", self, "quit_game");
	$Buttons/Options.connect("pressed", self, "open_options_dialog");
	$Buttons/LoadGame.connect("pressed", self, "open_loadgame_dialog");
	$Buttons/SaveGame.connect("pressed", self, "open_savegame_dialog");
	
	$OptionsContainer/OptionsMenu/HBoxContainer/ApplyChanges.connect("pressed", self, "apply_config_changes");
	
	load_langs();
	load_resolutions();
	
	$VersionLabel.text = ("VERSION: %s" % Game.VERSION);
	#unused yet
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys1.visible = false;
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys2.visible = false;
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys3.visible = false;
	$OptionsContainer/OptionsMenu/VBoxContainer/Keys4.visible = false;
	
	update_from_config();
	update_lang_strings();

func update_lang_strings():
	$Buttons/NewGame/ButtonLabel.text = Game.get_str("#str0001");
	$Buttons/LoadGame/ButtonLabel.text = Game.get_str("#str0002");
	$Buttons/SaveGame/ButtonLabel.text = Game.get_str("#str0003");
	$Buttons/Options/ButtonLabel.text = Game.get_str("#str0004");
	$QuitGame/QuitGame/ButtonLabel.text = Game.get_str("#str0005");
	$OptionsContainer/OptionsMenu/VBoxContainer/FullScreen/Label.text = Game.get_str("#str0006");
	$OptionsContainer/OptionsMenu/VBoxContainer/Resolutions/Label.text = Game.get_str("#str0007");
	$OptionsContainer/OptionsMenu/HBoxContainer/ApplyChanges.text = Game.get_str("#str0008");
	$OptionsContainer/OptionsMenu/VBoxContainer/Languages/Label.text = Game.get_str("#str0009");

func load_langs():
	LangsOptions.clear();
	var langs: Array = Game.Lang.get_langs();
	for lang in langs:
		LangsOptions.add_item(lang);
	LangsOptions.select(0);

func load_resolutions():
	ResolutionsOptions.clear();
	for res in resolutions:
		ResolutionsOptions.add_item(res);
	ResolutionsOptions.select(0);

func get_string_from_resoltion(res_vec: Vector2) -> String:
	return (str(int(res_vec.x)) + "x" + str(int(res_vec.y)));

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
	Game.Config.set_value("fullscreen", FullScreenCheckbox.pressed);
	Game.Config.set_value("resolution", get_resolution_from_string(resolutions[ResolutionsOptions.selected]));
	Game.Config.set_value("language", LangsOptions.get_item_text(LangsOptions.selected));
	Game.update_settings();
	Game.save_settings();

func set_ingame_mode():
	$BackgroundImage.modulate.a = 0.85;
	$BackgroundImage.modulate.r = 0.0;
	$BackgroundImage.modulate.g = 0.0;
	$BackgroundImage.modulate.b = 0.0;
	
func update_from_config():
	FullScreenCheckbox.pressed = Game.Config.get_value("fullscreen");
	var resolutionStr: String = get_string_from_resoltion(Game.Config.get_value("resolution"));
	for i in range(resolutions.size()):
		if resolutionStr == resolutions[i]:
			ResolutionsOptions.selected = i;
			break;

	var langs_data: Array = Game.Lang.get_langs();
	for i in range(langs_data.size()):
		if langs_data[i] == Game.Config.get_value("language"):
			LangsOptions.selected = i;
			break;