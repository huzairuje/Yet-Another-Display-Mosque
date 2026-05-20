.PHONY: help install clean dev dev-frontend dev-backend build build-frontend build-backend runner lint format check test

# Default target
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Configuration
FRONTEND_PORT := 5173
BACKEND_PORT := 3000
BACKEND_HOST := 0.0.0.0
GO_BINARY := server
BUILD_DIR := build
RUNNER_DIR := runner

help: ## Show this help message
	@echo "$(CYAN)Al-Ye'AnDiMo - Makefile Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "  make install        # Install dependencies"
	@echo "  make dev-frontend   # Run frontend dev server"
	@echo "  make dev-backend    # Run backend server (in another terminal)"
	@echo "  make build          # Build both frontend and backend"
	@echo "  make runner         # Create production runner packages"

install: ## Install frontend dependencies
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	pnpm install
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

clean: ## Clean build artifacts
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR)
	rm -rf $(RUNNER_DIR)
	rm -rf .svelte-kit
	rm -f $(GO_BINARY)
	rm -f server.exe
	@echo "$(GREEN)✓ Clean complete$(NC)"

dev-frontend: ## Run frontend development server (Vite)
	@echo "$(GREEN)Starting frontend dev server on port $(FRONTEND_PORT)...$(NC)"
	@echo "$(CYAN)Open http://localhost:$(FRONTEND_PORT)$(NC)"
	pnpm dev

dev-backend: build-backend ## Build and run backend server
	@echo "$(GREEN)Starting backend server on $(BACKEND_HOST):$(BACKEND_PORT)...$(NC)"
	@echo "$(CYAN)API available at http://localhost:$(BACKEND_PORT)/api$(NC)"
	PORT=$(BACKEND_PORT) HOST=$(BACKEND_HOST) ./$(GO_BINARY)

dev: ## Run both frontend and backend (requires two terminals)
	@echo "$(YELLOW)Note: This target requires running in two separate terminals$(NC)"
	@echo ""
	@echo "$(CYAN)Terminal 1:$(NC) make dev-frontend"
	@echo "$(CYAN)Terminal 2:$(NC) make dev-backend"
	@echo ""
	@echo "$(YELLOW)Or use tmux/screen to run both:$(NC)"
	@echo "  tmux new-session -d -s yadm-frontend 'make dev-frontend'"
	@echo "  tmux new-session -d -s yadm-backend 'make dev-backend'"

build-frontend: ## Build SvelteKit static site
	@echo "$(GREEN)Building frontend...$(NC)"
	pnpm build
	@echo "$(GREEN)✓ Frontend build complete → $(BUILD_DIR)/$(NC)"

build-backend: ## Build Go backend binary
	@echo "$(GREEN)Building backend...$(NC)"
	go build -o $(GO_BINARY) cmd/server/main.go
	@echo "$(GREEN)✓ Backend build complete → ./$(GO_BINARY)$(NC)"

build: build-frontend build-backend ## Build both frontend and backend
	@echo "$(GREEN)✓ Full build complete$(NC)"

build-linux: ## Build backend for Linux
	@echo "$(GREEN)Building backend for Linux...$(NC)"
	GOOS=linux GOARCH=amd64 go build -o $(GO_BINARY)-linux cmd/server/main.go
	@echo "$(GREEN)✓ Linux build complete$(NC)"

build-windows: ## Build backend for Windows
	@echo "$(GREEN)Building backend for Windows...$(NC)"
	GOOS=windows GOARCH=amd64 go build -o $(GO_BINARY).exe cmd/server/main.go
	@echo "$(GREEN)✓ Windows build complete$(NC)"

runner: ## Build production runner packages (Linux + Windows)
	@echo "$(GREEN)Building production runner packages...$(NC)"
	bash build.sh
	@echo "$(GREEN)✓ Runner packages created in $(RUNNER_DIR)/$(NC)"

lint: ## Run linters (Prettier + ESLint)
	@echo "$(GREEN)Running linters...$(NC)"
	pnpm lint

format: ## Format code with Prettier
	@echo "$(GREEN)Formatting code...$(NC)"
	pnpm format
	@echo "$(GREEN)✓ Code formatted$(NC)"

check: ## Run TypeScript type checking
	@echo "$(GREEN)Running type checks...$(NC)"
	pnpm check

check-watch: ## Run TypeScript type checking in watch mode
	@echo "$(GREEN)Running type checks in watch mode...$(NC)"
	pnpm check:watch

preview: build-frontend ## Preview production build locally
	@echo "$(GREEN)Starting preview server...$(NC)"
	pnpm preview

run: build ## Build and run production server
	@echo "$(GREEN)Starting production server...$(NC)"
	PORT=$(BACKEND_PORT) HOST=$(BACKEND_HOST) ./$(GO_BINARY)

# Go-specific targets
go-mod-tidy: ## Tidy Go module dependencies
	@echo "$(GREEN)Tidying Go modules...$(NC)"
	go mod tidy
	@echo "$(GREEN)✓ Go modules tidied$(NC)"

go-mod-download: ## Download Go module dependencies
	@echo "$(GREEN)Downloading Go modules...$(NC)"
	go mod download
	@echo "$(GREEN)✓ Go modules downloaded$(NC)"

# Utility targets
logs: ## Show backend logs (if running)
	@echo "$(YELLOW)Showing backend logs...$(NC)"
	@tail -f logs/*.log 2>/dev/null || echo "$(RED)No log files found$(NC)"

status: ## Show project status
	@echo "$(CYAN)Project Status:$(NC)"
	@echo ""
	@echo "$(GREEN)Frontend:$(NC)"
	@test -d node_modules && echo "  ✓ Dependencies installed" || echo "  ✗ Dependencies not installed (run: make install)"
	@test -d $(BUILD_DIR) && echo "  ✓ Build exists" || echo "  ✗ No build found"
	@echo ""
	@echo "$(GREEN)Backend:$(NC)"
	@test -f $(GO_BINARY) && echo "  ✓ Binary exists (./$(GO_BINARY))" || echo "  ✗ Binary not built (run: make build-backend)"
	@echo ""
	@echo "$(GREEN)Runner Packages:$(NC)"
	@test -d $(RUNNER_DIR)/linux && echo "  ✓ Linux runner exists" || echo "  ✗ Linux runner not built"
	@test -d $(RUNNER_DIR)/windows && echo "  ✓ Windows runner exists" || echo "  ✗ Windows runner not built"

# Development helpers
watch-frontend: ## Watch frontend files and rebuild on change
	@echo "$(GREEN)Watching frontend files...$(NC)"
	pnpm dev

watch-backend: ## Watch backend files and rebuild on change (requires entr)
	@echo "$(GREEN)Watching backend files...$(NC)"
	@command -v entr >/dev/null 2>&1 || { echo "$(RED)Error: entr not installed. Install with: sudo pacman -S entr$(NC)"; exit 1; }
	find cmd -name '*.go' | entr -r make dev-backend

# Quick development setup
setup: install build ## Complete setup (install + build)
	@echo "$(GREEN)✓ Setup complete! Ready to develop.$(NC)"
	@echo ""
	@echo "$(CYAN)Next steps:$(NC)"
	@echo "  1. Terminal 1: make dev-frontend"
	@echo "  2. Terminal 2: make dev-backend"
	@echo "  3. Open http://localhost:$(FRONTEND_PORT)"

# Production deployment helpers
deploy-check: lint check build ## Pre-deployment checks
	@echo "$(GREEN)✓ All pre-deployment checks passed$(NC)"

# Clean specific artifacts
clean-frontend: ## Clean only frontend artifacts
	@echo "$(YELLOW)Cleaning frontend artifacts...$(NC)"
	rm -rf $(BUILD_DIR) .svelte-kit
	@echo "$(GREEN)✓ Frontend cleaned$(NC)"

clean-backend: ## Clean only backend artifacts
	@echo "$(YELLOW)Cleaning backend artifacts...$(NC)"
	rm -f $(GO_BINARY) $(GO_BINARY)-linux $(GO_BINARY).exe
	@echo "$(GREEN)✓ Backend cleaned$(NC)"

clean-runner: ## Clean only runner packages
	@echo "$(YELLOW)Cleaning runner packages...$(NC)"
	rm -rf $(RUNNER_DIR)
	@echo "$(GREEN)✓ Runner packages cleaned$(NC)"
