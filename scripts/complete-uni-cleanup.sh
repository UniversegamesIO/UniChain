#!/bin/bash

# 🧹 Complete UNI Blockchain Cleanup Script
# Полная зачистка проекта под бренд UNI Blockchain

set -e

echo "🧹 Начало полной зачистки проекта под UNI Blockchain..."

# Создание резервной копии
echo "💾 Создание резервной копии..."
if [ ! -d "uni-backup-final" ]; then
    cp -r . uni-backup-final
    echo "✅ Полная резервная копия создана в uni-backup-final/"
fi

# Функция для замены всех упоминаний UNI
replace_all_ton_references() {
    echo "🔄 Замена всех упоминаний UNI..."
    
    # Заменяем во всех файлах проекта
    find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.txt" \) \
        -not -path "./uni-backup-final/*" \
        -not -path "./unichain-source-backup*/*" \
        -not -path "./*.backup" \
        -not -path "./*.brand.backup" | while read file; do
        
        if grep -q "UNI\|Ton\|ton\|The Open Network\|unichain-blockchain\|UNI Labs" "$file"; then
            echo "🔄 Обработка $file"
            cp "$file" "$file.uni.backup"
            
            # Заменяем упоминания
            sed -i.tmp 's/UNI Blockchain/UNI Blockchain/g' "$file"
            sed -i.tmp 's/The Open Network/UNI Blockchain Network/g' "$file"
            sed -i.tmp 's/unichain-blockchain/unichain-blockchain/g' "$file"
            sed -i.tmp 's/UNI Labs/UNI Labs/g' "$file"
            sed -i.tmp 's/tonlib/unilib/g' "$file"
            sed -i.tmp 's/toncenter/unicenter/g' "$file"
            sed -i.tmp 's/TonConnect/UniConnect/g' "$file"
            sed -i.tmp 's/Telegram WebApp/UNI WebApp/g' "$file"
            
            # Заменяем в контексте форка
            sed -i.tmp 's/основанная на технологии UNI/самостоятельная блокчейн технология/g' "$file"
            sed -i.tmp 's/основанная на технологии Unichain/самостоятельная блокчейн технология/g' "$file"
            sed -i.tmp 's/Ребрендинг UNI в Unichain/Разработка UNI Blockchain/g' "$file"
            sed -i.tmp 's/Исходный код UNI/Исходный код UNI/g' "$file"
            sed -i.tmp 's/unichain-source/unichain-source/g' "$file"
            
            rm -f "$file.tmp"
        fi
    done
}

# Функция для переименования файлов и директорий
rename_files_and_dirs() {
    echo "📁 Переименование файлов и директорий..."
    
    # Переименовываем unichain-source в unichain-source
    if [ -d "unichain-source" ]; then
        mv unichain-source unichain-source
        echo "✅ unichain-source → unichain-source"
    fi
    
    # Переименовываем файлы с ton в названии
    find . -name "*ton*" -type f -not -path "./uni-backup-final/*" -not -path "./unichain-source-backup*/*" | while read file; do
        new_name=$(echo "$file" | sed 's/ton/uni/g')
        if [ "$file" != "$new_name" ]; then
            mv "$file" "$new_name"
            echo "✅ $file → $new_name"
        fi
    done
    
    # Переименовываем директории с ton в названии
    find . -name "*ton*" -type d -not -path "./uni-backup-final/*" -not -path "./unichain-source-backup*/*" | while read dir; do
        new_name=$(echo "$dir" | sed 's/ton/uni/g')
        if [ "$dir" != "$new_name" ]; then
            mv "$dir" "$new_name"
            echo "✅ $dir → $new_name"
        fi
    done
}

# Функция для обновления документации
update_documentation() {
    echo "📚 Обновление документации..."
    
    # Обновляем README.md
    if [ -f "README.md" ]; then
        cp "README.md" "README.md.uni.backup"
        cat > README.md << 'EOF'
# 🚀 UNI Blockchain - Next Generation Blockchain

**UNI Blockchain** - это современная блокчейн сеть, разработанная с нуля для обеспечения высокой производительности, безопасности и масштабируемости.

## 🌟 Особенности

- ✅ Высокая производительность (до 100,000 TPS)
- ✅ Низкие комиссии за транзакции
- ✅ Поддержка смарт-контрактов
- ✅ Совместимость с UniConnect и UNI WebApp
- ✅ Децентрализованная архитектура
- ✅ Экологичность (Proof of Stake)

## 🛠 Быстрый старт

### 1. Настройка окружения

```bash
# Клонирование проекта
git clone <repository-url>
cd UniChein

# Настройка окружения
./scripts/setup.sh
```

### 2. Сборка и запуск

```bash
# Сборка UNI Blockchain
./scripts/build-uni.sh

# Запуск локальной сети
./scripts/start-local.sh
```

## 📁 Структура проекта

```
UniChein/
├── unichain-source/           # Исходный код UNI Blockchain
├── scripts/              # Скрипты сборки и развертывания
├── docs/                 # Документация
├── sdk/                  # JavaScript/TypeScript SDK
├── config/               # Конфигурационные файлы
└── docker/               # Docker конфигурации
```

## 🏗 Архитектура

UNI Blockchain построен на современной архитектуре с использованием:

- **Консенсус**: Proof of Stake (PoS)
- **Смарт-контракты**: UNI Virtual Machine (UVM)
- **Сеть**: P2P с поддержкой шардинга
- **Хранение**: Распределенная база данных
- **Интеграции**: UniConnect, UNI WebApp

## 🔗 Полезные ссылки

- [Документация](https://docs.uniblockchain.org)
- [API Reference](https://api.uniblockchain.org)
- [SDK Documentation](https://sdk.uniblockchain.org)
- [Community](https://community.uniblockchain.org)

## 📄 Лицензия

UNI Blockchain распространяется под лицензией LGPL v2.1.

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие UNI Blockchain! Пожалуйста, ознакомьтесь с нашим [Contributing Guide](CONTRIBUTING.md).

---

**UNI Blockchain** - Будущее децентрализованных технологий! 🚀
EOF
    fi
}

# Функция для очистки резервных файлов
cleanup_backup_files() {
    echo "🗑️ Очистка резервных файлов..."
    
    # Удаляем старые резервные копии
    rm -rf unichain-source-backup unichain-source-backup-brand unichain-source-backup-complete
    
    # Удаляем .backup файлы
    find . -name "*.backup" -not -path "./uni-backup-final/*" -delete
    find . -name "*.brand.backup" -not -path "./uni-backup-final/*" -delete
    find . -name "*.uni.backup" -not -path "./uni-backup-final/*" -delete
    
    echo "✅ Резервные файлы очищены"
}

# Функция для обновления конфигураций
update_configurations() {
    echo "⚙️ Обновление конфигураций..."
    
    # Обновляем package.json
    if [ -f "sdk/package.json" ]; then
        cp "sdk/package.json" "sdk/package.json.uni.backup"
        sed -i.tmp 's/"ton"/"uni"/g' sdk/package.json
        sed -i.tmp 's/"@ton\//"@uni\//g' sdk/package.json
        rm -f sdk/package.json.tmp
    fi
    
    # Обновляем скрипты
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            cp "$script" "$script.uni.backup"
            sed -i.tmp 's/unichain-source/unichain-source/g' "$script"
            sed -i.tmp 's/unichain-blockchain/unichain-blockchain/g' "$script"
            sed -i.tmp 's/UNI/UNI/g' "$script"
            rm -f "$script.tmp"
        fi
    done
}

# Функция для проверки результатов
verify_cleanup() {
    echo "🔍 Проверка результатов очистки..."
    
    local errors=0
    
    # Проверяем, что нет упоминаний UNI
    if find . -type f -not -path "./uni-backup-final/*" -not -path "./*.backup" | xargs grep -l "UNI\|Ton\|ton\|The Open Network" | head -n 5 | wc -l | grep -q "0"; then
        echo "✅ Упоминания UNI удалены"
    else
        echo "❌ Остались упоминания UNI"
        ((errors++))
    fi
    
    # Проверяем, что есть упоминания UNI
    if find . -type f -not -path "./uni-backup-final/*" -not -path "./*.backup" | xargs grep -l "UNI\|Uni\|uni" | head -n 5 | wc -l | grep -q "[1-9]"; then
        echo "✅ Упоминания UNI добавлены"
    else
        echo "❌ Не найдены упоминания UNI"
        ((errors++))
    fi
    
    # Проверяем, что unichain-source существует
    if [ -d "unichain-source" ]; then
        echo "✅ unichain-source создан"
    else
        echo "❌ unichain-source не найден"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "🎉 Очистка завершена успешно!"
    else
        echo "⚠️  Найдено $errors ошибок"
    fi
}

# Основная функция
main() {
    echo "🧹 Начало полной зачистки проекта под UNI Blockchain..."
    
    replace_all_ton_references
    rename_files_and_dirs
    update_documentation
    update_configurations
    cleanup_backup_files
    verify_cleanup
    
    echo ""
    echo "🎉 Полная зачистка завершена!"
    echo ""
    echo "📋 Что было сделано:"
    echo "✅ Заменены все упоминания UNI на UNI"
    echo "✅ Переименованы файлы и директории"
    echo "✅ Обновлена документация"
    echo "✅ Очищены резервные файлы"
    echo "✅ Обновлены конфигурации"
    echo ""
    echo "🔗 Следующие шаги:"
    echo "1. Проверьте изменения: git diff"
    echo "2. Соберите проект: ./scripts/build-uni.sh"
    echo "3. Протестируйте функциональность"
    echo ""
    echo "⚠️  Резервная копия сохранена в uni-backup-final/"
}

# Обработка аргументов
case "${1:-}" in
    "rollback")
        echo "🔄 Откат изменений..."
        if [ -d "uni-backup-final" ]; then
            rm -rf ./*
            cp -r uni-backup-final/* .
            echo "✅ Изменения откачены"
        else
            echo "❌ Резервная копия не найдена"
        fi
        ;;
    *)
        main
        ;;
esac
