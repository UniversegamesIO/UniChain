#!/bin/bash

# 🚀 Unichain Deploy Script
# Скрипт для деплоя обновлений в GitHub репозиторий

set -e

echo "🚀 Начало деплоя Unichain..."

# Проверка наличия SSH ключа
if [ ! -f ~/.ssh/unichain_deploy_key ]; then
    echo "❌ SSH ключ для деплоя не найден"
    echo "Создайте ключ: ssh-keygen -t ed25519 -C 'unichain-deploy@github.com' -f ~/.ssh/unichain_deploy_key -N \"\""
    echo "См. документацию: docs/deploy-key-setup.md"
    exit 1
fi

# Проверка Git репозитория
if [ ! -d ".git" ]; then
    echo "❌ Git репозиторий не инициализирован"
    echo "Инициализируйте: git init && git add . && git commit -m 'Initial commit'"
    exit 1
fi

# Проверка статуса Git
echo "📋 Проверка статуса Git..."
git status

# Запрос подтверждения
read -p "Продолжить деплой? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Деплой отменен"
    exit 1
fi

# Добавление всех изменений
echo "📦 Добавление изменений..."
git add .

# Проверка, есть ли изменения для коммита
if git diff --cached --quiet; then
    echo "ℹ️ Нет изменений для коммита"
else
    # Создание коммита
    echo "💾 Создание коммита..."
    git commit -m "Update Unichain: $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Настройка remote для деплоя (если не настроен)
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "🔗 Настройка remote..."
    read -p "Введите URL GitHub репозитория: " repo_url
    git remote add origin "$repo_url"
fi

# Получение текущего remote URL
remote_url=$(git remote get-url origin)

# Замена на SSH URL для деплоя
if [[ $remote_url == https://* ]]; then
    # Конвертация HTTPS в SSH
    repo_name=$(echo "$remote_url" | sed 's|https://github.com/||')
    deploy_url="git@github.com-unichain:$repo_name"
    echo "🔄 Конвертация URL в SSH: $deploy_url"
    git remote set-url origin "$deploy_url"
fi

# Пуш изменений
echo "📤 Отправка изменений..."
git push origin main

echo "✅ Деплой завершен успешно!"

# Восстановление оригинального URL (если был HTTPS)
if [[ $remote_url == https://* ]]; then
    echo "🔄 Восстановление оригинального URL..."
    git remote set-url origin "$remote_url"
fi

echo ""
echo "🎉 Обновления успешно загружены в GitHub!"
echo "📋 Следующие шаги:"
echo "  1. Проверьте изменения в GitHub репозитории"
echo "  2. Создайте Pull Request если необходимо"
echo "  3. Запустите CI/CD pipeline"
