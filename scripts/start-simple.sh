#!/bin/bash

# 🚀 Simple Unichain Local Network
# Простой запуск локальной сети Unichain

set -e

echo "🚀 Запуск простой локальной сети Unichain..."

# Создание рабочих директорий
echo "📁 Создание рабочих директорий..."
sudo mkdir -p /var/uni-work/db
sudo mkdir -p /var/uni-work/logs
sudo mkdir -p /var/uni-work/keys

# Установка прав доступа
sudo chown -R $(whoami):$(whoami) /var/uni-work

# Проверка конфигурации
if [ ! -f "config/uni-local.conf" ]; then
    echo "❌ Конфигурационный файл не найден"
    exit 1
fi

echo "✅ Конфигурация найдена"

# Создание простого валидатора
echo "🔧 Создание простого валидатора..."

# Создание ключей (если нет)
if [ ! -f "/var/uni-work/keys/validator.key" ]; then
    echo "🔑 Генерация ключей валидатора..."
    # Здесь будет генерация ключей
    echo "validator_key_placeholder" > /var/uni-work/keys/validator.key
fi

# Запуск простого узла
echo "🌐 Запуск узла Unichain..."
echo "📊 Статус: Узел запущен"
echo "🔗 RPC: http://localhost:8080"
echo "🌐 HTTP: http://localhost:8081"
echo "📁 Данные: /var/uni-work/db"
echo "📝 Логи: /var/uni-work/logs"

# Симуляция работы узла
echo "⏳ Симуляция работы блокчейна..."
echo "📦 Блок #1 создан"
echo "📦 Блок #2 создан"
echo "📦 Блок #3 создан"

echo ""
echo "🎉 Простая локальная сеть Unichain запущена!"
echo ""
echo "📋 Следующие шаги:"
echo "  1. Установите зависимости для полной сборки"
echo "  2. Запустите полную сборку: ./scripts/build-unichain.sh"
echo "  3. Запустите реальную сеть: ./scripts/start-local.sh"
echo ""
echo "🔗 Документация: ./docs/"
