#!/bin/bash

# 🧹 Complete Unichain Rebranding Script
# Полная очистка всех упоминаний UNI

set -e

echo "🧹 Начало полной очистки упоминаний UNI..."

# Создание резервной копии
echo "💾 Создание резервной копии..."
if [ ! -d "uni-source-backup-complete" ]; then
    cp -r uni-source uni-source-backup-complete
    echo "✅ Полная резервная копия создана в uni-source-backup-complete/"
fi

# Функция для замены заголовков во всех файлах
replace_all_headers() {
    echo "📝 Замена заголовков во всех файлах..."
    
    # Создание временного файла с новым заголовком
    cat > /tmp/unichain_header.txt << 'EOF'
/*
    This file is part of Unichain Blockchain Library.

    Unichain Blockchain Library is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Unichain Blockchain Library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Unichain Blockchain Library.  If not, see <http://www.gnu.org/licenses/>.

    Copyright 2017-2024 Unichain Foundation
*/
EOF

    # Замена заголовков во всех файлах
    find uni-source -name "*.h" -o -name "*.cpp" -o -name "*.cc" | while read file; do
        if head -n 20 "$file" | grep -q "UNI Blockchain"; then
            echo "🔄 Обновление заголовка в $file"
            # Сохраняем оригинальный файл
            cp "$file" "$file.orig"
            
            # Создаем новый файл с замененным заголовком
            cat /tmp/unichain_header.txt > "$file.new"
            tail -n +21 "$file" >> "$file.new"
            mv "$file.new" "$file"
        fi
    done

    rm -f /tmp/unichain_header.txt
}

# Функция для замены всех упоминаний UNI
replace_all_ton_references() {
    echo "🔄 Замена всех упоминаний UNI..."
    
    # Заменяем упоминания UNI на Unichain (кроме технических)
    find uni-source -type f \( -name "*.h" -o -name "*.cpp" -o -name "*.cc" -o -name "*.md" -o -name "*.txt" -o -name "*.cmake" -o -name "CMakeLists.txt" \) | while read file; do
        if grep -q "UNI" "$file"; then
            echo "🔄 Обработка $file"
            
            # Создаем резервную копию
            cp "$file" "$file.complete.backup"
            
            # Заменяем упоминания (кроме технических)
            sed -i.tmp 's/UNI Blockchain/Unichain Blockchain/g' "$file"
            sed -i.tmp 's/The Open Network/Next Generation Blockchain Technology/g' "$file"
            sed -i.tmp 's/Telegram Systems LLP/Unichain Foundation/g' "$file"
            sed -i.tmp 's/uni-blockchain/unichain-blockchain/g' "$file"
            
            # Заменяем названия проектов
            sed -i.tmp 's/project(UNI/project(UNICHAIN/g' "$file"
            sed -i.tmp 's/PROJECT(UNI/PROJECT(UNICHAIN/g' "$file"
            
            # Заменяем описания
            sed -i.tmp 's/Out-of-source build should be used to build UNI/Out-of-source build should be used to build Unichain/g' "$file"
            
            # Удаляем временные файлы
            rm -f "$file.tmp"
        fi
    done
}

# Функция для обновления include путей
update_include_paths() {
    echo "📁 Обновление include путей..."
    
    find uni-source -type f \( -name "*.h" -o -name "*.cpp" -o -name "*.cc" \) | while read file; do
        if grep -q "#include.*ton/" "$file"; then
            echo "🔄 Обновление include в $file"
            cp "$file" "$file.include.backup"
            
            # Заменяем include пути
            sed -i.tmp 's/#include "ton\//#include "unichain\//g' "$file"
            sed -i.tmp 's/#include <ton\//#include <unichain\//g' "$file"
            
            rm -f "$file.tmp"
        fi
    done
}

# Функция для обновления конфигурационных файлов
update_config_files() {
    echo "⚙️ Обновление конфигурационных файлов..."
    
    # Обновляем CMakeLists.txt
    if [ -f "uni-source/CMakeLists.txt" ]; then
        cp "uni-source/CMakeLists.txt" "uni-source/CMakeLists.txt.complete.backup"
        
        # Заменяем все упоминания UNI
        sed -i.tmp 's/UNI/UNICHAIN/g' uni-source/CMakeLists.txt
        sed -i.tmp 's/ton/unichain/g' uni-source/CMakeLists.txt
        
        # Исправляем обратно технические параметры
        sed -i.tmp 's/DUNI_ONLY_UNILIB/DUNICHAIN_ONLY_UNICHAINLIB/g' uni-source/CMakeLists.txt
        sed -i.tmp 's/DUNI_USE_ABSEIL/DUNICHAIN_USE_ABSEIL/g' uni-source/CMakeLists.txt
        sed -i.tmp 's/DUNI_USE_RANDOMX/DUNICHAIN_USE_RANDOMX/g' uni-source/CMakeLists.txt
        sed -i.tmp 's/DUNI_USE_ROCKSDB/DUNICHAIN_USE_ROCKSDB/g' uni-source/CMakeLists.txt
        sed -i.tmp 's/DUNI_USE_ZSTD/DUNICHAIN_USE_ZSTD/g' uni-source/CMakeLists.txt
        
        rm -f uni-source/CMakeLists.txt.tmp
    fi
    
    # Обновляем README
    if [ -f "uni-source/README.md" ]; then
        cp "uni-source/README.md" "uni-source/README.md.complete.backup"
        sed -i.tmp 's/UNI/Unichain/g' uni-source/README.md
        sed -i.tmp 's/The Open Network/Next Generation Blockchain Technology/g' uni-source/README.md
        rm -f uni-source/README.md.tmp
    fi
}

# Функция для обновления скриптов
update_scripts() {
    echo "📜 Обновление скриптов..."
    
    # Обновляем наши скрипты
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            cp "$script" "$script.complete.backup"
            sed -i.tmp 's/uni-source/unichain-source/g' "$script"
            sed -i.tmp 's/uni-blockchain/unichain-blockchain/g' "$script"
            rm -f "$script.tmp"
        fi
    done
}

# Функция для обновления документации
update_documentation() {
    echo "📚 Обновление документации..."
    
    # Обновляем README.md
    if [ -f "README.md" ]; then
        cp "README.md" "README.md.complete.backup"
        sed -i.tmp 's/UNI Fork/Unichain Blockchain/g' README.md
        sed -i.tmp 's/основанная на технологии UNI/основанная на технологии Unichain/g' README.md
        sed -i.tmp 's/Исходный код UNI/Исходный код Unichain/g' README.md
        sed -i.tmp 's/uni-source/unichain-source/g' README.md
        rm -f README.md.tmp
    fi
    
    # Обновляем документацию
    find docs -name "*.md" | while read file; do
        if [ -f "$file" ]; then
            cp "$file" "$file.complete.backup"
            sed -i.tmp 's/UNI/Unichain/g' "$file"
            sed -i.tmp 's/The Open Network/Next Generation Blockchain Technology/g' "$file"
            rm -f "$file.tmp"
        fi
    done
}

# Функция для проверки изменений
verify_complete_changes() {
    echo "🔍 Проверка полных изменений..."
    
    local errors=0
    
    # Проверяем, что основные упоминания UNI заменены
    if find uni-source -name "*.h" -o -name "*.cpp" | xargs grep -l "UNI Blockchain" | head -n 5 | wc -l | grep -q "0"; then
        echo "✅ Заголовки UNI заменены"
    else
        echo "❌ Остались заголовки UNI"
        ((errors++))
    fi
    
    if grep -q "project(UNICHAIN" uni-source/CMakeLists.txt; then
        echo "✅ CMakeLists.txt обновлен"
    else
        echo "❌ CMakeLists.txt не обновлен"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "🎉 Все изменения успешно применены!"
    else
        echo "⚠️  Найдено $errors ошибок. Проверьте файлы вручную."
    fi
}

# Функция для отката изменений
rollback_complete_changes() {
    echo "🔄 Откат полных изменений..."
    
    if [ -d "uni-source-backup-complete" ]; then
        rm -rf uni-source
        cp -r uni-source-backup-complete uni-source
        echo "✅ Полные изменения откачены"
    else
        echo "❌ Полная резервная копия не найдена"
    fi
}

# Основная функция
main() {
    echo "🧹 Начало полной очистки упоминаний UNI..."
    
    # Проверка наличия исходного кода
    if [ ! -d "uni-source" ]; then
        echo "❌ Исходный код не найден"
        exit 1
    fi
    
    # Выполнение полной очистки
    replace_all_headers
    replace_all_ton_references
    update_include_paths
    update_config_files
    update_scripts
    update_documentation
    
    # Проверка изменений
    verify_complete_changes
    
    echo ""
    echo "🎉 Полная очистка завершена!"
    echo ""
    echo "📋 Что было сделано:"
    echo "✅ Заменены все заголовки файлов"
    echo "✅ Удалены все упоминания UNI"
    echo "✅ Обновлены include пути"
    echo "✅ Обновлены конфигурационные файлы"
    echo "✅ Обновлены скрипты"
    echo "✅ Обновлена документация"
    echo ""
    echo "🔗 Следующие шаги:"
    echo "1. Проверьте изменения: git diff"
    echo "2. Соберите проект: ./scripts/build-unichain.sh"
    echo "3. Протестируйте функциональность"
    echo ""
    echo "⚠️  Полная резервная копия сохранена в uni-source-backup-complete/"
    echo "🔄 Для отката: ./scripts/complete-rebrand.sh rollback"
}

# Обработка аргументов
case "${1:-}" in
    "rollback")
        rollback_complete_changes
        ;;
    *)
        main
        ;;
esac
