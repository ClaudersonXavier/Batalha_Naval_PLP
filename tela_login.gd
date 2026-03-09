extends VBoxContainer

const AUTH_DIR_PATH := "res://dados_autenticacao"
const USERS_CSV_PATH := AUTH_DIR_PATH + "/usuarios.csv"
const CURRENT_USER_PATH := AUTH_DIR_PATH + "/usuario_logado.txt"
const RANKS_CSV_PATH := AUTH_DIR_PATH + "/ranks.csv"
const MENU_SCENE_PATH := "res://MenuPrincipal.tscn"

@onready var login_input  = $campos/login
@onready var senha_input  = $campos/senha
@onready var erro_label   = $Erro
@onready var btn_entrar   = $botoes/entrar
@onready var btn_cadastro = $botoes/cadastro
@onready var btn_sair     = $botoes/sair

func _ready():
	erro_label.visible = false
	btn_entrar.grab_focus()
	btn_entrar.pressed.connect(_on_entrar_pressed)
	btn_cadastro.pressed.connect(_on_cadastro_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)

	if not garantir_estrutura_arquivos():
		mostrar_erro("Falha ao preparar arquivos de autenticacao")
		return

	if tem_sessao_valida():
		call_deferred("ir_para_menu_principal")

func _on_entrar_pressed():
	var login = normalizar_login(login_input.text)
	var senha = senha_input.text

	if login.is_empty() or senha.is_empty():
		mostrar_erro("Preencha todos os campos")
		return

	limpar_erro()
	var usuarios := ler_usuarios()

	if not usuarios.has(login):
		mostrar_erro("Login ou senha invalidos")
		return

	if usuarios[login] != senha:
		mostrar_erro("Login ou senha invalidos")
		return

	if not salvar_usuario_logado(login):
		mostrar_erro("Falha ao salvar sessao")
		return

	ir_para_menu_principal()

func _on_cadastro_pressed():
	var login = normalizar_login(login_input.text)
	var senha = senha_input.text

	if login.is_empty() or senha.is_empty():
		mostrar_erro("Preencha todos os campos")
		return

	limpar_erro()
	var usuarios := ler_usuarios()

	if usuarios.has(login):
		mostrar_erro("Login ja cadastrado")
		return

	if not salvar_usuario(login, senha):
		mostrar_erro("Falha ao cadastrar usuario")
		return

	if not salvar_usuario_logado(login):
		mostrar_erro("Falha ao salvar sessao")
		return

	ir_para_menu_principal()

func _on_sair_pressed():
	get_tree().quit()

func normalizar_login(login: String) -> String:
	return login.strip_edges().to_upper()

func garantir_estrutura_arquivos() -> bool:
	var auth_dir_name := AUTH_DIR_PATH.trim_prefix("res://")
	var root_dir := DirAccess.open("res://")
	if root_dir == null:
		return false

	if not root_dir.dir_exists(auth_dir_name):
		var mkdir_error := root_dir.make_dir(auth_dir_name)
		if mkdir_error != OK:
			return false

	return garantir_arquivo(USERS_CSV_PATH) and garantir_arquivo(CURRENT_USER_PATH) and garantir_arquivo(RANKS_CSV_PATH)

func garantir_arquivo(path: String) -> bool:
	if FileAccess.file_exists(path):
		return true

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.close()
	return true

func ler_usuarios() -> Dictionary:
	var usuarios := {}
	var file := FileAccess.open(USERS_CSV_PATH, FileAccess.READ)
	if file == null:
		return usuarios

	while not file.eof_reached():
		var linha := file.get_line().strip_edges()
		if linha.is_empty():
			continue

		var partes := linha.split(";", false, 1)
		if partes.size() < 2:
			continue

		var login := normalizar_login(partes[0])
		var senha := partes[1]
		if not login.is_empty():
			usuarios[login] = senha

	file.close()
	return usuarios

func salvar_usuario(login: String, senha: String) -> bool:
	var conteudo := ""
	if FileAccess.file_exists(USERS_CSV_PATH):
		var read_file := FileAccess.open(USERS_CSV_PATH, FileAccess.READ)
		if read_file == null:
			return false
		conteudo = read_file.get_as_text()
		read_file.close()

	if not conteudo.is_empty() and not conteudo.ends_with("\n"):
		conteudo += "\n"

	conteudo += "%s;%s\n" % [normalizar_login(login), senha]

	var write_file := FileAccess.open(USERS_CSV_PATH, FileAccess.WRITE)
	if write_file == null:
		return false
	write_file.store_string(conteudo)
	write_file.close()
	return true

func ler_usuario_logado() -> String:
	var file := FileAccess.open(CURRENT_USER_PATH, FileAccess.READ)
	if file == null:
		return ""

	var login := normalizar_login(file.get_as_text())
	file.close()
	return login

func salvar_usuario_logado(login: String) -> bool:
	var file := FileAccess.open(CURRENT_USER_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(normalizar_login(login))
	file.close()
	return true

func limpar_usuario_logado() -> void:
	var file := FileAccess.open(CURRENT_USER_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string("")
	file.close()

func tem_sessao_valida() -> bool:
	var login_logado := ler_usuario_logado()
	if login_logado.is_empty():
		return false

	var usuarios := ler_usuarios()
	if usuarios.has(login_logado):
		return true

	limpar_usuario_logado()
	return false

func limpar_erro() -> void:
	erro_label.text = ""
	erro_label.visible = false

func ir_para_menu_principal() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func mostrar_erro(mensagem: String):
	erro_label.text = mensagem
	erro_label.visible = true
