extends Node

const SESSION_FILE_PATH := "res://dados/usuario_atual.json"

func normalizar_login(login: String) -> String:
	return login.strip_edges().to_upper()

func garantir_arquivo_sessao() -> bool:
	var root_dir := DirAccess.open("res://")
	if root_dir == null:
		return false

	if not root_dir.dir_exists("dados"):
		var mkdir_error := root_dir.make_dir("dados")
		if mkdir_error != OK:
			return false

	if FileAccess.file_exists(SESSION_FILE_PATH):
		return true

	var file := FileAccess.open(SESSION_FILE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string("{}")
	file.close()
	return true

func ler_sessao() -> Dictionary:
	var file := FileAccess.open(SESSION_FILE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var content := file.get_as_text().strip_edges()
	file.close()
	if content.is_empty():
		return {}

	var parser := JSON.new()
	var err := parser.parse(content)
	if err != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {}

	return parser.data

func salvar_sessao(data: Dictionary) -> bool:
	var file := FileAccess.open(SESSION_FILE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true

func ler_login_atual() -> String:
	var sessao := ler_sessao()
	return normalizar_login(str(sessao.get("login", "")))

func salvar_login_atual(login: String) -> bool:
	return salvar_sessao({"login": normalizar_login(login)})

func limpar_sessao() -> void:
	salvar_sessao({})

func tem_sessao_valida_rust(usuario_node: Node) -> bool:
	var login := ler_login_atual()
	if login.is_empty():
		return false

	var usuario: Dictionary = usuario_node.call("buscar_por_login", login)
	if usuario.is_empty():
		limpar_sessao()
		return false

	return true
