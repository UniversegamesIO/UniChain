#!/bin/bash

# 🔑 Test SSH Connection Script
# Скрипт для тестирования SSH подключения к GitHub

set -e

echo "🔑 Тестирование SSH подключения к GitHub..."

# Проверка наличия SSH ключа
if [ ! -f ~/.ssh/unichain_deploy_key ]; then
    echo "❌ SSH ключ не найден: ~/.ssh/unichain_deploy_key"
    exit 1
fi

echo "✅ SSH ключ найден (безопасно)"

# Проверка SSH конфигурации
if [ ! -f ~/.ssh/config ]; then
    echo "❌ SSH конфигурация не найдена: ~/.ssh/config"
    exit 1
fi

echo "✅ SSH конфигурация найдена"

# Тестирование подключения к GitHub
echo "🌐 Тестирование подключения к GitHub..."
if ssh -T git@github.com-unichain 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH подключение к GitHub успешно!"
else
    echo "❌ SSH подключение к GitHub не удалось"
    echo ""
    echo "📋 Для настройки деплой ключа в GitHub:"
    echo "1. Скопируйте публичный ключ:"
    echo "   cat ~/.ssh/unichain_deploy_key.pub"
    echo ""
    echo "2. Добавьте ключ в настройки репозитория GitHub:"
    echo "   Settings > Deploy keys > Add deploy key"
    echo ""
    echo "3. Вставьте публичный ключ и сохраните"
    exit 1
fi

echo ""
echo "🎉 SSH подключение настроено правильно!"
echo "Теперь вы можете использовать ./scripts/deploy.sh для деплоя"
