#!/bin/bash

echo "🔍 Identification des périphériques d'entrée disponibles..."
echo ""
echo "=== Tous les périphériques d'entrée ==="
ls -la /dev/input/by-id/ 2>/dev/null || echo "Dossier /dev/input/by-id/ non trouvé"
echo ""

echo "=== Périphériques d'événements ==="
ls -la /dev/input/event* 2>/dev/null
echo ""

echo "=== Informations détaillées des périphériques ==="
if command -v evtest &> /dev/null; then
    echo "📋 Pour identifier manuellement, lancez : sudo evtest"
else
    echo "⚠️  evtest n'est pas installé. Installez-le avec : sudo pacman -S evtest"
fi

echo ""
echo "=== Analyse automatique avec /proc/bus/input/devices ==="
if [ -f /proc/bus/input/devices ]; then
    echo "🖱️  SOURIS trouvées :"
    grep -A 5 -B 5 -i "mouse\|logitech\|pointing" /proc/bus/input/devices
    echo ""
    echo "⌨️  CLAVIERS trouvés :"
    grep -A 5 -B 5 -i "keyboard\|kbd" /proc/bus/input/devices
fi

echo ""
echo "=== Détection automatique de votre souris Logitech ==="

# Chercher spécifiquement les périphériques Logitech
LOGITECH_DEVICES=$(ls /dev/input/by-id/ 2>/dev/null | grep -i logitech | grep -i mouse)

if [ -n "$LOGITECH_DEVICES" ]; then
    echo "✅ Périphériques Logitech trouvés :"
    for device in $LOGITECH_DEVICES; do
        echo "   /dev/input/by-id/$device"
    done
    echo ""
    echo "🎯 Pour tester un périphérique spécifique, utilisez :"
    for device in $LOGITECH_DEVICES; do
        echo "   sudo evtest /dev/input/by-id/$device"
    done
else
    echo "❌ Aucun périphérique Logitech trouvé dans /dev/input/by-id/"
    echo ""
    echo "🔍 Vérifiez manuellement avec :"
    echo "   ls /dev/input/"
    echo "   sudo evtest"
fi

echo ""
echo "=== Instructions pour identifier votre bouton de souris ==="
echo "1. Lancez : sudo evtest"
echo "2. Sélectionnez votre souris Logitech dans la liste"
echo "3. Appuyez sur tous les boutons de votre MX Master 3"
echo "4. Notez les codes qui apparaissent (format: type X, code Y, value Z)"
echo "5. Utilisez le code Y dans votre programme"
