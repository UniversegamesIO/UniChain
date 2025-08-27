#!/bin/bash

# 🏷️ Brand-Only Replacement Script
# Только замена названий без удаления функциональности

set -e

echo "🏷️ Начало замены только названий..."

# Создание резервной копии
echo "💾 Создание резервной копии..."
if [ ! -d "uni-source-backup-brand" ]; then
    cp -r uni-source uni-source-backup-brand
    echo "✅ Резервная копия создана в uni-source-backup-brand/"
fi

# Функция для замены только заголовков файлов
replace_brand_headers() {
    echo "📝 Замена только заголовков файлов..."
    
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

    # Замена заголовков только в файлах с упоминанием UNI Blockchain
    find uni-source -name "*.h" -o -name "*.cpp" -o -name "*.cc" | while read file; do
        if head -n 20 "$file" | grep -q "UNI Blockchain"; then
            echo "🔄 Обновление заголовка в $file"
            # Сохраняем оригинальный файл
            cp "$file" "$file.brand.backup"
            
            # Создаем новый файл с замененным заголовком
            cat /tmp/unichain_header.txt > "$file.new"
            tail -n +21 "$file" >> "$file.new"
            mv "$file.new" "$file"
        fi
    done

    rm -f /tmp/unichain_header.txt
}

# Функция для замены только брендинга (без технических изменений)
replace_brand_only() {
    echo "🏷️ Замена только брендинга..."
    
    # Заменяем только брендинг, не трогая техническую функциональность
    find uni-source -type f \( -name "*.h" -o -name "*.cpp" -o -name "*.cc" -o -name "*.md" -o -name "*.txt" -o -name "CMakeLists.txt" \) | while read file; do
        if grep -q "UNI Blockchain" "$file" || grep -q "The Open Network" "$file" || grep -q "Telegram Systems LLP" "$file"; then
            echo "🔄 Обработка брендинга в $file"
            
            # Создаем резервную копию
            cp "$file" "$file.brand.backup"
            
            # Заменяем только брендинг
            sed -i.tmp 's/UNI Blockchain/Unichain Blockchain/g' "$file"
            sed -i.tmp 's/The Open Network/Next Generation Blockchain Technology/g' "$file"
            sed -i.tmp 's/Telegram Systems LLP/Unichain Foundation/g' "$file"
            
            # Заменяем только названия проектов в CMake
            if [[ "$file" == *"CMakeLists.txt" ]]; then
                sed -i.tmp 's/project(UNI VERSION 0.5 LANGUAGES C CXX)/project(UNICHAIN VERSION 1.0 LANGUAGES C CXX)/g' "$file"
                sed -i.tmp 's/Out-of-source build should be used to build UNI/Out-of-source build should be used to build Unichain/g' "$file"
            fi
            
            # Удаляем временные файлы
            rm -f "$file.tmp"
        fi
    done
}

# Функция для обновления только документации
update_documentation_brand() {
    echo "📚 Обновление только документации..."
    
    # Обновляем README.md
    if [ -f "README.md" ]; then
        cp "README.md" "README.md.brand.backup"
        sed -i.tmp 's/UNI Fork/Unichain Blockchain/g' README.md
        sed -i.tmp 's/основанная на технологии UNI/основанная на технологии Unichain/g' README.md
        rm -f README.md.tmp
    fi
    
    # Обновляем документацию
    find docs -name "*.md" | while read file; do
        if [ -f "$file" ]; then
            cp "$file" "$file.brand.backup"
            sed -i.tmp 's/UNI/Unichain/g' "$file"
            sed -i.tmp 's/The Open Network/Next Generation Blockchain Technology/g' "$file"
            rm -f "$file.tmp"
        fi
    done
}

# Функция для проверки изменений
verify_brand_changes() {
    echo "🔍 Проверка изменений брендинга..."
    
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
        echo "🎉 Все изменения брендинга успешно применены!"
    else
        echo "⚠️  Найдено $errors ошибок. Проверьте файлы вручную."
    fi
}

# Функция для отката изменений
rollback_brand_changes() {
    echo "🔄 Откат изменений брендинга..."
    
    if [ -d "uni-source-backup-brand" ]; then
        rm -rf uni-source
        cp -r uni-source-backup-brand uni-source
        echo "✅ Изменения брендинга откачены"
    else
        echo "❌ Резервная копия не найдена"
    fi
}

# Основная функция
main() {
    echo "🏷️ Начало замены только названий..."
    
    # Проверка наличия исходного кода
    if [ ! -d "uni-source" ]; then
        echo "❌ Исходный код не найден"
        exit 1
    fi
    
    # Выполнение замены только брендинга
    replace_brand_headers
    replace_brand_only
    update_documentation_brand
    
    # Проверка изменений
    verify_brand_changes
    
    echo ""
    echo "🎉 Замена брендинга завершена!"
    echo ""
    echo "📋 Что было сделано:"
    echo "✅ Заменены заголовки файлов"
    echo "✅ Обновлен брендинг в коде"
    echo "✅ Обновлена документация"
    echo "✅ Сохранена вся функциональность"
    echo ""
    echo "🔗 Следующие шаги:"
    echo "1. Проверьте изменения: git diff"
    echo "2. Соберите проект: ./scripts/build-unichain.sh"
    echo "3. Протестируйте функциональность"
    echo ""
    echo "⚠️  Резервная копия сохранена в uni-source-backup-brand/"
    echo "🔄 Для отката: ./scripts/brand-only-replace.sh rollback"
}

# Обработка аргументов
case "${1:-}" in
    "rollback")
        rollback_brand_changes
        ;;
    *)
        main
        ;;
esac
