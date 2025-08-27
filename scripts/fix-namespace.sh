#!/bin/bash

# 🔧 Fix Namespace Script
# Замена ton:: на unichain:: во всех файлах

set -e

echo "🔧 Начало замены namespace ton:: на unichain::..."

# Создание резервной копии
echo "💾 Создание резервной копии..."
if [ ! -d "uni-source-backup-namespace" ]; then
    cp -r uni-source uni-source-backup-namespace
    echo "✅ Резервная копия создана в uni-source-backup-namespace/"
fi

# Функция для замены namespace
replace_namespace() {
    echo "🔄 Замена namespace ton:: на unichain::..."
    
    # Заменяем ton:: на unichain:: во всех .cpp и .h файлах
    find uni-source -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) | while read file; do
        if grep -q "ton::" "$file"; then
            echo "🔄 Обработка namespace в $file"
            
            # Создаем резервную копию
            cp "$file" "$file.namespace.backup"
            
            # Заменяем ton:: на unichain::
            sed -i.tmp 's/ton::/unichain::/g' "$file"
            
            # Удаляем временные файлы
            rm -f "$file.tmp"
        fi
    done
}

# Функция для замены include путей
replace_includes() {
    echo "📁 Обновление include путей..."
    
    # Заменяем include ton/ на unichain/
    find uni-source -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) | while read file; do
        if grep -q '#include "ton/' "$file"; then
            echo "🔄 Обновление include в $file"
            
            # Создаем резервную копию
            cp "$file" "$file.include.backup"
            
            # Заменяем include пути
            sed -i.tmp 's|#include "ton/|#include "unichain/|g' "$file"
            sed -i.tmp 's|#include <ton/|#include <unichain/|g' "$file"
            
            # Удаляем временные файлы
            rm -f "$file.tmp"
        fi
    done
}

# Функция для переименования директорий
rename_directories() {
    echo "📁 Переименование директорий..."
    
    # Переименовываем директорию ton в unichain
    if [ -d "uni-source/ton" ]; then
        echo "🔄 Переименование uni-source/ton в uni-source/unichain"
        mv uni-source/ton uni-source/unichain
    fi
}

# Функция для проверки изменений
verify_namespace_changes() {
    echo "🔍 Проверка изменений namespace..."
    
    local errors=0
    
    # Проверяем, что ton:: заменен на unichain::
    local ton_count=$(find uni-source -name "*.cpp" -exec grep -l "ton::" {} \; | wc -l)
    local unichain_count=$(find uni-source -name "*.cpp" -exec grep -l "unichain::" {} \; | wc -l)
    
    echo "📊 Статистика namespace:"
    echo "   ton:: осталось: $ton_count файлов"
    echo "   unichain:: найдено: $unichain_count файлов"
    
    if [ $ton_count -eq 0 ]; then
        echo "✅ Все ton:: заменены на unichain::"
    else
        echo "❌ Остались ton:: в $ton_count файлах"
        ((errors++))
    fi
    
    if [ $unichain_count -gt 0 ]; then
        echo "✅ unichain:: namespace найден в $unichain_count файлах"
    else
        echo "❌ unichain:: namespace не найден"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "🎉 Все изменения namespace успешно применены!"
    else
        echo "⚠️  Найдено $errors ошибок. Проверьте файлы вручную."
    fi
}

# Функция для отката изменений
rollback_namespace_changes() {
    echo "🔄 Откат изменений namespace..."
    
    if [ -d "uni-source-backup-namespace" ]; then
        rm -rf uni-source
        cp -r uni-source-backup-namespace uni-source
        echo "✅ Изменения namespace откачены"
    else
        echo "❌ Резервная копия не найдена"
    fi
}

# Основная функция
main() {
    echo "🔧 Начало замены namespace..."
    
    # Проверка наличия исходного кода
    if [ ! -d "uni-source" ]; then
        echo "❌ Исходный код не найден"
        exit 1
    fi
    
    # Выполнение замены namespace
    replace_namespace
    replace_includes
    rename_directories
    
    # Проверка изменений
    verify_namespace_changes
    
    echo ""
    echo "🎉 Замена namespace завершена!"
    echo ""
    echo "📋 Что было сделано:"
    echo "✅ Заменены ton:: на unichain::"
    echo "✅ Обновлены include пути"
    echo "✅ Переименованы директории"
    echo "✅ Сохранена вся функциональность"
    echo ""
    echo "🔗 Следующие шаги:"
    echo "1. Проверьте изменения: git diff"
    echo "2. Соберите проект: ./scripts/build-unichain.sh"
    echo "3. Протестируйте функциональность"
    echo ""
    echo "⚠️  Резервная копия сохранена в uni-source-backup-namespace/"
    echo "🔄 Для отката: ./scripts/fix-namespace.sh rollback"
}

# Обработка аргументов
case "${1:-}" in
    "rollback")
        rollback_namespace_changes
        ;;
    *)
        main
        ;;
esac
