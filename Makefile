.PHONY: help build run send test clean

# Default target
help:
	@echo "Secret Santa Application - Docker Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  make build    - Build the Docker image"
	@echo "  make run      - Run in dry-run mode (preview pairings)"
	@echo "  make send     - Run in LIVE mode (send emails)"
	@echo "  make test     - Run the test suite"
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
run:
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
send:
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
test:
	@echo "🧪 Running tests..."
	docker run --rm \
		--user $(shell id -u):$(shell id -g) \
		secret-santa:latest \
		ruby test/secret_santa_test.rb

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
