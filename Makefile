# Variables
CC = gcc
CFLAGS = -Wall -Wextra -std=c99
TARGET = custom_keybind
SOURCE = custom_keybind.c
INSTALL_DIR = /usr/local/bin
USER_SERVICE_DIR = $(HOME)/.config/systemd/user
USER_SERVICE_FILE = custom-keybind.service

# Default target
all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
	@echo "✅ Program compiled successfully!"

clean:
	rm -f $(TARGET)
	@echo "🧹 Cleaned build files"

install: $(TARGET)
	@echo "📦 Installing $(TARGET)..."
	sudo cp $(TARGET) $(INSTALL_DIR)/
	sudo cp control_service.sh $(INSTALL_DIR)/custom_keybind_control
	sudo chmod +x $(INSTALL_DIR)/custom_keybind_control
	@echo "✅ Installed to $(INSTALL_DIR)"

install-service: install
	@echo "🔧 Creating user systemd service..."
	mkdir -p $(USER_SERVICE_DIR)
	echo "[Unit]" > $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "Description=Microphone Mute Toggle Service" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "[Service]" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "ExecStart=$(INSTALL_DIR)/$(TARGET)" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "Restart=on-failure" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "KillMode=process" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "[Install]" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	echo "WantedBy=default.target" >> $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	systemctl --user daemon-reload
	systemctl --user enable custom-keybind.service
	systemctl --user start custom-keybind.service
	@echo "✅ Service créé, activé et démarré automatiquement !"

uninstall:
	@echo "🗑️  Uninstalling $(TARGET)..."
	sudo rm -f $(INSTALL_DIR)/$(TARGET)
	sudo rm -f $(INSTALL_DIR)/custom_keybind_control
	rm -f $(USER_SERVICE_DIR)/$(USER_SERVICE_FILE)
	systemctl --user disable --now custom-keybind.service || true
	systemctl --user daemon-reload
	@echo "✅ Uninstalled completely"

test: $(TARGET)
	@echo "🧪 Testing program in debug mode..."
	@echo "Press Ctrl+C to stop"
	./$(TARGET)

help:
	@echo "🛠️  Available targets:"
	@echo "  make              - Compile the program"
	@echo "  make clean        - Remove build files"
	@echo "  make install      - Install program system-wide"
	@echo "  make uninstall    - Remove program and user service"
	@echo "  make install-service - Install and enable systemd user service"
	@echo "  make test         - Run program in debug mode"
	@echo "  make help         - Show this help"
	@echo ""
	@echo "💡 Usage after installation:"
	@echo "  custom_keybind_control start   - Start service"
	@echo "  custom_keybind_control stop    - Stop service"
	@echo "  custom_keybind_control status  - Check status"
	@echo "  custom_keybind_control debug   - Run with debug output"
	@echo ""
	@echo "💡 Enable/disable background service:"
	@echo "  systemctl --user enable custom-keybind.service"
	@echo "  systemctl --user start custom-keybind.service"
	@echo "  systemctl --user stop custom-keybind.service"
	@echo "  systemctl --user status custom-keybind.service"

.PHONY: all clean install uninstall install-service test help

