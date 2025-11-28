.PHONY: help build run send test lint check clean shell ci

# Default target
help:
	@echo "Secret Santa Application - Docker Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  make build    - Build the Docker image"
	@echo "  make run      - Run in dry-run mode (preview pairings)"
	@echo "  make send     - Run in LIVE mode (send emails)"
	@echo "  make test     - Run the test suite"
	@echo "  make lint     - Run RuboCop linter"
	@echo "  make check    - Verify config files exist"
	@echo "  make shell    - Open interactive shell in container"
	@echo "  make ci       - Run all checks (test + lint)"
	@echo "  make clean    - Remove Docker image"
	@echo ""
	@echo "Configuration:"
	@echo "  Requires .env and config/event.yml in current directory"
	@echo "  Pairings saved to ~/.secret_santa_pairings/"

# Build the Docker image
build:
	@echo "🔨 Building Secret Santa Docker image..."
	docker build -t secret-santa:latest .
	@echo "✅ Build complete!"

# Run in dry-run mode (DOITLIVE=false)
run: check build
	@echo "🎄 Running Secret Santa in dry-run mode..."
	@mkdir -p ~/.secret_santa_pairings
	docker run --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(PWD)/.env:/app/.env:ro \
		-v $(PWD)/config/event.yml:/app/config/event.yml:ro \
		-v ~/.secret_santa_pairings:/home/santauser/.secret_santa_pairings \
		-e PAIRINGS_DIR=/home/santauser/.secret_santa_pairings \
		-e DOITLIVE=false \
		secret-santa:latest

# Run in LIVE mode (DOITLIVE=true) - sends actual emails
send: check build
	@echo "📧 Running Secret Santa in LIVE mode - SENDING EMAILS!"
	@read -p "Are you sure you want to send emails? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@mkdir -p ~/.secret_santa_pairings
	docker run --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(PWD)/.env:/app/.env:ro \
		-v $(PWD)/config/event.yml:/app/config/event.yml:ro \
		-v ~/.secret_santa_pairings:/home/santauser/.secret_santa_pairings \
		-e PAIRINGS_DIR=/home/santauser/.secret_santa_pairings \
		-e DOITLIVE=true \
		secret-santa:latest

# Run tests
test: build
	@echo "🧪 Running tests..."
	docker run --rm -t \
		--user $(shell id -u):$(shell id -g) \
		secret-santa:latest \
		ruby test/run.rb

# Run RuboCop linter
lint: build
	@echo "🔍 Running RuboCop..."
	docker run --rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(PWD):/app:ro \
		secret-santa:latest \
		rubocop

# Run all CI checks
ci: check test lint
	@echo ""
	@echo "✅ All CI checks passed!"

# Clean up Docker image
clean:
	@echo "🗑️  Removing Secret Santa Docker image..."
	docker rmi secret-santa:latest || true
	@echo "✅ Cleanup complete!"

# Quick check - verify config files exist
check:
	@echo "🔍 Checking configuration files..."
	@test -f .env || (echo "❌ .env file not found! Copy from .env.example" && exit 1)
	@test -f config/event.yml || (echo "❌ config/event.yml not found! Copy from config/event.example.yml" && exit 1)
	@echo "✅ Configuration files found!"

# Open interactive shell in container
shell: build
	@echo "🐚 Opening shell in container..."
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		-v $(PWD)/.env:/app/.env:ro \
		-v $(PWD)/config/event.yml:/app/config/event.yml:ro \
		secret-santa:latest \
		/bin/bash
