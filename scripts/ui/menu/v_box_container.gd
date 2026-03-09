extends VBoxContainer

const LOGIN_SCENE_PATH := "res://scenes/ui/TelaLogin.tscn"

func _ready():
	$start.grab_focus()

	if not $start.pressed.is_connected(_on_start_pressed):
		$start.pressed.connect(_on_start_pressed)
	if not $dinamico.pressed.is_connected(_on_dinamico_pressed):
		$dinamico.pressed.connect(_on_dinamico_pressed)
	if not $ranking.pressed.is_connected(_on_ranking_pressed):
		$ranking.pressed.connect(_on_ranking_pressed)
	if not $conquistas.pressed.is_connected(_on_conquistas_pressed):
		$conquistas.pressed.connect(_on_conquistas_pressed)
	if not $sair.pressed.is_connected(_on_sair_pressed):
		$sair.pressed.connect(_on_sair_pressed)

func _on_start_pressed():
	CampaignState.iniciar_nova_campanha()
	get_tree().change_scene_to_file("res://scenes/modo_campanha.tscn")

func _on_dinamico_pressed():
	CampaignState.iniciar_nova_campanha_dinamica()
	get_tree().change_scene_to_file("res://scenes/modo_campanha.tscn")

func _on_ranking_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/tela_ranking.tscn")

func _on_conquistas_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/CenaConquistas.tscn")

func _on_sair_pressed():
	SessionStore.limpar_sessao()
	get_tree().change_scene_to_file(LOGIN_SCENE_PATH)
