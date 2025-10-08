# Variables
CC = gcc
CFLAGS = -Wall -Wextra -std=c99
TARGET = custom_keybind
SOURCE = custom_keybind.c
INSTALL_DIR = /usr/local/bin
SERVICE_DIR = /etc/systemd/system
SERVICE_FILE = custom-keybind.service

# Default target
all: $(TARGET)

# Build the program
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
	@echo "✅ Program compiled successfully!"

# Clean build files
clean:
	rm -f $(TARGET)
	@echo "🧹 Cleaned build files"

# Install program system-wide
install: $(TARGET)
	@echo "📦 Installing $(TARGET)..."
	sudo cp $(TARGET) $(INSTALL_DIR)/
	sudo cp control_service.sh $(INSTALL_DIR)/custom_keybind_control
	sudo chmod +x $(INSTALL_DIR)/custom_keybind_control
	@echo "✅ Installed to $(INSTALL_DIR)"
	@echo "📋 You can now use: custom_keybind_control {start|stop|status|restart|debug}"

# Uninstall program
uninstall:
	@echo "🗑️  Uninstalling $(TARGET)..."
	sudo rm -f $(INSTALL_DIR)/$(TARGET)
	sudo rm -f $(INSTALL_DIR)/custom_keybind_control
	sudo rm -f $(SERVICE_DIR)/$(SERVICE_FILE)
	sudo systemctl daemon-reload 2>/dev/null || true
	@echo "✅ Uninstalled successfully"

# Create systemd service (optional)
install-service: install
	@echo "🔧 Creating systemd service..."
	@echo "[Unit]" | sudo tee $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "Description=Custom Keybind Service for Microphone Mute" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "After=graphical-session.target" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "[Service]" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "Type=forking" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "ExecStart=$(INSTALL_DIR)/$(TARGET)" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "ExecStop=$(INSTALL_DIR)/custom_keybind_control stop" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "PIDFile=/tmp/custom_keybind.pid" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "Restart=on-failure" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "User=pactivisme" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "[Install]" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	@echo "WantedBy=default.target" | sudo tee -a $(SERVICE_DIR)/$(SERVICE_FILE) > /dev/null
	sudo systemctl daemon-reload
	@echo "✅ Service created. Enable with: sudo systemctl enable custom-keybind.service"

# Test the program (run in debug mode)
test: $(TARGET)
	@echo "🧪 Testing program in debug mode..."
	@echo "Press Ctrl+C to stop"
	./$(TARGET)

# Show help
help:
	@echo "🛠️  Available targets:"
	@echo "  make          - Compile the program"
	@echo "  make clean    - Remove build files"
	@echo "  make install  - Install program system-wide"
	@echo "  make uninstall- Remove program from system"
	@echo "  make install-service - Install as systemd service"
	@echo "  make test     - Run program in debug mode"
	@echo "  make help     - Show this help"
	@echo ""
	@echo "💡 Usage after installation:"
	@echo "  custom_keybind_control start   - Start service"
	@echo "  custom_keybind_control stop    - Stop service"
	@echo "  custom_keybind_control status  - Check status"
	@echo "  custom_keybind_control debug   - Run with debug output"

# Find mouse button codes (utility)
find-buttons:
	@echo "🔍 Looking for available input devices..."
	@echo "Run this command to identify your mouse events:"
	@echo "  sudo evtest"
	@echo ""
	@echo "Or to see button codes specifically:"
	@echo "  xev -event button | grep button"

.PHONY: all clean install uninstall install-service test help find-buttons
