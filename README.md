# Coffee Hunter

A SwiftUI app that helps you discover and track coffee shops near you using MapKit.

## Features

- Find nearby coffee shops on a map
- Save favorite coffee shops
- Track visit history
- Achievement system
- Premium features

## Development

### Requirements

- Xcode 15.0+
- iOS 17.0+
- SwiftUI
- MapKit

### Setup

1. Clone the repository
2. Open `coffee-hunter.xcodeproj` in Xcode
3. Build and run the project

## Testing

The project includes both unit tests and UI tests:

### Unit Tests

- ViewModel tests for core business logic
- Service layer tests for data operations
- Run tests with `Cmd + U` in Xcode or through CI

### UI Tests

Basic UI tests covering main user flows:

- Tab navigation
- Coffee shop selection
- Favorites management
- Profile actions

## CI/CD

This project uses GitHub Actions for continuous integration and delivery.

### CI Workflow

The CI pipeline runs on every pull request and push to main, performing:

1. SwiftLint

   - Code style checking
   - Runs first for fast feedback

2. Unit Tests

   - Core functionality testing
   - Runs after SwiftLint passes

3. UI Tests
   - Main user flow testing
   - Runs in parallel with unit tests

### Running Locally

O projeto inclui um Makefile para facilitar a execução de comandos comuns. Para ver todos os comandos disponíveis:

```bash
make help
```

Comandos principais:

```bash
# Instalar dependências (SwiftLint)
make install-deps

# Executar SwiftLint
make lint

# Compilar o projeto
make build

# Executar todos os testes
make test

# Executar apenas testes unitários
make test-unit

# Executar apenas testes de UI
make test-ui

# Executar todas as verificações de CI localmente
make ci
```

### Pull Request Guidelines

1. Ensure all tests pass locally before pushing
2. Fix any SwiftLint warnings/errors
3. Add tests for new features
4. Update documentation as needed
