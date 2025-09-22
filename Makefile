.PHONY: help lint test build clean install-deps

# Variáveis
PROJECT_NAME = coffee-hunter
SCHEME = "coffee-hunter"
DESTINATION = "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0"

help: ## Mostra a ajuda com todos os comandos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install-deps: ## Instala as dependências do projeto (SwiftLint)
	@echo "Instalando dependências..."
	@which -s swiftlint || brew install swiftlint

lint: ## Executa o SwiftLint
	@echo "Executando SwiftLint..."
	@swiftlint --strict

lint-fix: ## Corrige automaticamente os problemas do SwiftLint que são possíveis
	@echo "Corrigindo problemas do SwiftLint..."
	@swiftlint --fix && swiftlint

build: ## Compila o projeto
	@echo "Compilando o projeto..."
	@xcodebuild clean build \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination $(DESTINATION) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

test: ## Executa todos os testes (Unit + UI)
	@echo "Executando testes..."
	@xcodebuild clean test \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination $(DESTINATION) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

test-unit: ## Executa apenas os testes unitários
	@echo "Executando testes unitários..."
	@xcodebuild clean test \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination $(DESTINATION) \
		-skip-testing:$(PROJECT_NAME)TestsUI \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

test-ui: ## Executa apenas os testes de UI
	@echo "Executando testes de UI..."
	@xcodebuild clean test \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination $(DESTINATION) \
		-only-testing:$(PROJECT_NAME)TestsUI \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

clean: ## Limpa os arquivos de build
	@echo "Limpando arquivos de build..."
	@xcodebuild clean \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination $(DESTINATION)

ci: install-deps lint test ## Executa todas as verificações de CI localmente (igual ao GitHub Actions)