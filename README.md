# Logitech Mouse Microphone Mute

Un programme C simple pour contrôler le mute/unmute du microphone via un bouton de souris Logitech MX Master 3.

## ⚡ Installation Rapide

```bash
# Compiler
make

# Tester en mode debug pour identifier les bons codes de boutons
make test

# Installer system-wide
sudo make install

# Démarrer le service
custom_keybind_control start
```

## 🔧 Configuration

### Identifier le bon bouton de souris

Le programme est actuellement configuré pour le code de bouton `276` (BTN_EXTRA). Pour identifier le bon code pour votre souris :

1. **Méthode 1 - Mode debug :**
   ```bash
   make test
   # Appuyez sur tous les boutons de votre souris pour voir les codes
   ```

2. **Méthode 2 - evtest :**
   ```bash
   sudo evtest
   # Sélectionnez votre souris et testez les boutons
   ```

3. **Méthode 3 - xev :**
   ```bash
   xev -event button | grep button
   # Cliquez sur les boutons dans la fenêtre qui s'ouvre
   ```

### Codes de boutons courants pour MX Master 3

D'après nos recherches :
- `195` (0xc3) - Bouton pouce (Gesture button)
- `276` - BTN_EXTRA (bouton supplémentaire)
- `8` - Bouton intérieur du pouce
- `9` - Bouton du bout du pouce

### Modifier le code de bouton

Éditez `custom_keybind.c` et changez la ligne :
```c
#define MOUSE_BTN_CODE 276  // Remplacez 276 par votre code
```

Puis recompilez :
```bash
make clean && make
```

## 🚀 Utilisation

### Commandes de contrôle

```bash
# Démarrer le service en arrière-plan
custom_keybind_control start

# Arrêter le service
custom_keybind_control stop

# Vérifier le statut
custom_keybind_control status

# Redémarrer
custom_keybind_control restart

# Mode debug (voir les événements en temps réel)
custom_keybind_control debug
```

### Installation comme service systemd (optionnel)

```bash
# Installer comme service système
sudo make install-service

# Activer le démarrage automatique
sudo systemctl enable custom-keybind.service

# Démarrer le service
sudo systemctl start custom-keybind.service

# Vérifier le statut
sudo systemctl status custom-keybind.service
```

## 🛠️ Développement

### Structure du projet

- `custom_keybind.c` - Programme principal
- `control_service.sh` - Script de contrôle du service
- `Makefile` - Fichier de build et installation
- `README.md` - Documentation

### Targets du Makefile

```bash
make              # Compiler le programme
make clean        # Nettoyer les fichiers de build
make install      # Installer system-wide
make uninstall    # Désinstaller
make test         # Tester en mode debug
make help         # Afficher l'aide
make find-buttons # Aide pour identifier les boutons
```

### Personnalisation

Pour personnaliser le programme, modifiez ces constantes dans `custom_keybind.c` :

```c
// Chemin vers votre périphérique d'entrée
#define DEV_EVENT_PATH "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse"

// Code du bouton à écouter
#define MOUSE_BTN_CODE 276  

// Commande à exécuter (remplacez 'pactivisme' par votre username)
#define COMMAND "sudo -u pactivisme XDG_RUNTIME_DIR=/run/user/$(id -u pactivisme) pactl set-source-mute @DEFAULT_SOURCE@ toggle"
```

## ❗ Dépannage

### Le bouton Tab continue de couper le micro

Si le problème persiste, vérifiez qu'aucune autre instance ne tourne :
```bash
# Tuer tous les processus liés
pkill -f custom_keybind
pkill -f logitech

# Vérifier les processus
ps aux | grep custom_keybind
```

### Permissions

Le programme nécessite l'accès aux périphériques d'entrée. Ajoutez votre utilisateur au groupe `input` :
```bash
sudo usermod -a -G input $USER
# Puis redémarrez votre session
```

### Identifier votre périphérique d'entrée

```bash
# Lister tous les périphériques d'entrée
ls -la /dev/input/by-id/ | grep -i logitech

# Ou utiliser evtest pour identifier
sudo evtest
```

## 🔍 Alternatives

Si ce programme ne fonctionne pas pour vous, essayez :

1. **logiops** - Configuration avancée pour souris Logitech
   ```bash
   # Arch/Manjaro
   yay -S logiops
   ```

2. **Solaar** - Interface graphique pour périphériques Logitech
   ```bash
   sudo pacman -S solaar
   ```

3. **xbindkeys** - Pour les raccourcis clavier simples
   ```bash
   sudo pacman -S xbindkeys
   ```

## 📄 Licence

Ce projet est sous licence libre. Basé sur le travail de [mickdevil/logitech-mouse-microphone-mute](https://github.com/mickdevil/logitech-mouse-microphone-mute).

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer des améliorations
- Ajouter de nouvelles fonctionnalités
- Améliorer la documentation
