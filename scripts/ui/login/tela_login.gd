extends VBoxContainer

const MENU_SCENE_PATH := "res://scenes/ui/MenuPrincipal.tscn"

@onready var login_input  = $campos/login
@onready var senha_input  = $campos/senha
@onready var erro_label   = $Erro
@onready var btn_entrar   = $botoes/entrar
@onready var btn_cadastro = $botoes/cadastro
@onready var btn_sair     = $botoes/sair

var usuario_node: Node = null

func _ready():
	erro_label.visible = false
	btn_entrar.grab_focus()
	btn_entrar.pressed.connect(_on_entrar_pressed)
	btn_cadastro.pressed.connect(_on_cadastro_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)

	usuario_node = ClassDB.instantiate("UsuarioNode")
	if usuario_node == null:
		mostrar_erro("Falha ao carregar autenticacao Rust")
		return
	add_child(usuario_node)

	if not SessionStore.garantir_arquivo_sessao():
		mostrar_erro("Falha ao preparar sessao")
		return

	if SessionStore.tem_sessao_valida_rust(usuario_node):
		call_deferred("ir_para_menu_principal")

func _on_entrar_pressed():
	var login = SessionStore.normalizar_login(login_input.text)
	var senha = senha_input.text

	if login.is_empty() or senha.is_empty():
		mostrar_erro("Preencha todos os campos")
		return

	limpar_erro()
	var usuario: Dictionary = usuario_node.call("login", login, senha)
	if usuario.is_empty():
		mostrar_erro("Login ou senha invalidos")
		return

	var login_autenticado := SessionStore.normalizar_login(str(usuario.get("login", login)))
	if not SessionStore.salvar_login_atual(login_autenticado):
		mostrar_erro("Falha ao salvar sessao")
		return

	ir_para_menu_principal()

func _on_cadastro_pressed():
	var login = SessionStore.normalizar_login(login_input.text)
	var senha = senha_input.text

	if login.is_empty() or senha.is_empty():
		mostrar_erro("Preencha todos os campos")
		return

	limpar_erro()
	var cadastro_ok: bool = usuario_node.call("registrar", login, login, senha)
	if not cadastro_ok:
		mostrar_erro("Login ja cadastrado")
		return

	if not SessionStore.salvar_login_atual(login):
		mostrar_erro("Falha ao salvar sessao")
		return

	ir_para_menu_principal()

func _on_sair_pressed():
	get_tree().quit()

func limpar_erro() -> void:
	erro_label.text = ""
	erro_label.visible = false

func ir_para_menu_principal() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func mostrar_erro(mensagem: String):
	erro_label.text = mensagem
	erro_label.visible = true
