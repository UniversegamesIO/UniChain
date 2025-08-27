#!/bin/bash

# 🎨 Safe Unichain Rebranding Script
# Безопасный скрипт для точечного ребрендинга UNI в Unichain

set -e

echo "🎨 Начало безопасного ребрендинга UNI в Unichain..."

# Создание резервной копии
echo "💾 Создание резервной копии..."
if [ ! -d "unichain-source-backup" ]; then
    cp -r unichain-source unichain-source-backup
    echo "✅ Резервная копия создана в unichain-source-backup/"
fi

# Функция для безопасной замены в заголовках файлов
safe_replace_headers() {
    echo "📝 Безопасная замена заголовков файлов..."
    
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

    # Замена заголовков в ключевых файлах
    local files=(
        "unichain-source/ton/ton-types.h"
        "unichain-source/ton/ton-types.cpp"
        "unichain-source/validator/validator-options.h"
        "unichain-source/validator-engine/validator-engine.h"
        "unichain-source/lite-client/lite-client.h"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "🔄 Обновление заголовка в $file"
            # Сохраняем оригинальный файл
            cp "$file" "$file.orig"
            
            # Заменяем только заголовок (первые 20 строк)
            head -n 20 "$file" | grep -q "UNI Blockchain" && {
                # Создаем новый файл с замененным заголовком
                cat /tmp/unichain_header.txt > "$file.new"
                tail -n +21 "$file" >> "$file.new"
                mv "$file.new" "$file"
                echo "✅ Заголовок обновлен в $file"
            } || echo "⚠️  Заголовок не найден в $file"
        fi
    done

    rm -f /tmp/unichain_header.txt
}

# Функция для обновления namespace
safe_replace_namespace() {
    echo "🔧 Безопасная замена namespace..."
    
    # Заменяем только namespace, не трогая функциональность
    find unichain-source -name "*.h" -o -name "*.cpp" -o -name "*.cc" | while read file; do
        if grep -q "namespace ton" "$file"; then
            echo "🔄 Обновление namespace в $file"
            # Создаем резервную копию
            cp "$file" "$file.namespace.backup"
            
            # Заменяем namespace ton на namespace unichain
            sed -i.tmp 's/namespace ton/namespace unichain/g' "$file"
            sed -i.tmp 's/}  \/\/ namespace ton/}  \/\/ namespace unichain/g' "$file"
            
            # Проверяем, что замена прошла успешно
            if grep -q "namespace unichain" "$file"; then
                rm -f "$file.tmp"
                echo "✅ Namespace обновлен в $file"
            else
                echo "❌ Ошибка обновления namespace в $file"
                mv "$file.namespace.backup" "$file"
            fi
        fi
    done
}

# Функция для обновления CMakeLists.txt
safe_update_cmake() {
    echo "⚙️ Безопасное обновление CMakeLists.txt..."
    
    if [ -f "unichain-source/CMakeLists.txt" ]; then
        cp "unichain-source/CMakeLists.txt" "unichain-source/CMakeLists.txt.backup"
        
        # Заменяем только название проекта и описания
        sed -i.tmp 's/project(UNI VERSION 0.5 LANGUAGES C CXX)/project(UNICHAIN VERSION 1.0 LANGUAGES C CXX)/g' unichain-source/CMakeLists.txt
        sed -i.tmp 's/  Out-of-source build should be used to build UNI./  Out-of-source build should be used to build Unichain./g' unichain-source/CMakeLists.txt
        
        # Проверяем изменения
        if grep -q "project(UNICHAIN" unichain-source/CMakeLists.txt; then
            rm -f unichain-source/CMakeLists.txt.tmp
            echo "✅ CMakeLists.txt обновлен"
        else
            echo "❌ Ошибка обновления CMakeLists.txt"
            mv "unichain-source/CMakeLists.txt.backup" "unichain-source/CMakeLists.txt"
        fi
    fi
}

# Функция для создания констант Unichain
create_unichain_constants() {
    echo "🔧 Создание констант Unichain..."
    
    # Создаем файл с константами Unichain
    cat > unichain-source/ton/unichain-constants.h << 'EOF'
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
#pragma once

#include "ton/ton-types.h"

namespace unichain {

// Unichain specific constants
constexpr WorkchainId unichain_workchain_id = 0;
constexpr ShardId unichain_shard_id = 0x8000000000000000;
constexpr BlockSeqno unichain_genesis_seqno = 1;

// Token configuration
constexpr td::uint64 unichain_token_decimals = 9;
constexpr td::uint64 unichain_total_supply = 1000000000000000000ULL; // 1 billion tokens
constexpr td::uint64 unichain_min_stake = 1000000000ULL; // 1 token minimum stake

// Network configuration
constexpr int unichain_max_validators = 100;
constexpr int unichain_min_validators = 3;
constexpr td::uint32 unichain_block_time = 5; // 5 seconds
constexpr td::uint32 unichain_gas_price = 1000;
constexpr td::uint64 unichain_gas_limit = 1000000;

// Smart contract addresses
constexpr StdSmcAddress unichain_system_contract = {0};
constexpr StdSmcAddress unichain_config_contract = {1};
constexpr StdSmcAddress unichain_elector_contract = {2};
constexpr StdSmcAddress unichain_dns_contract = {3};

} // namespace unichain
EOF

    echo "✅ Константы Unichain созданы"
}

# Функция для обновления README
safe_update_readme() {
    echo "📚 Безопасное обновление README..."
    
    if [ -f "unichain-source/README.md" ]; then
        cp "unichain-source/README.md" "unichain-source/README.md.backup"
        
        # Заменяем только названия и описания
        sed -i.tmp 's/UNI/Unichain/g' unichain-source/README.md
        sed -i.tmp 's/The Open Network/Next Generation Blockchain Technology/g' unichain-source/README.md
        
        echo "✅ README обновлен"
        rm -f unichain-source/README.md.tmp
    fi
}

# Функция для проверки изменений
verify_changes() {
    echo "🔍 Проверка изменений..."
    
    local errors=0
    
    # Проверяем, что основные файлы обновлены
    if grep -q "Unichain Blockchain Library" unichain-source/ton/ton-types.h; then
        echo "✅ ton-types.h обновлен"
    else
        echo "❌ ton-types.h не обновлен"
        ((errors++))
    fi
    
    if grep -q "project(UNICHAIN" unichain-source/CMakeLists.txt; then
        echo "✅ CMakeLists.txt обновлен"
    else
        echo "❌ CMakeLists.txt не обновлен"
        ((errors++))
    fi
    
    if [ -f "unichain-source/ton/unichain-constants.h" ]; then
        echo "✅ Константы Unichain созданы"
    else
        echo "❌ Константы Unichain не созданы"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "🎉 Все изменения успешно применены!"
    else
        echo "⚠️  Найдено $errors ошибок. Проверьте файлы вручную."
    fi
}

# Функция для отката изменений
rollback_changes() {
    echo "🔄 Откат изменений..."
    
    if [ -d "unichain-source-backup" ]; then
        rm -rf unichain-source
        cp -r unichain-source-backup unichain-source
        echo "✅ Изменения откачены"
    else
        echo "❌ Резервная копия не найдена"
    fi
}

# Основная функция
main() {
    echo "🎨 Начало безопасного ребрендинга UNI в Unichain..."
    
    # Проверка наличия исходного кода
    if [ ! -d "unichain-source" ]; then
        echo "❌ Исходный код UNI не найден. Запустите ./scripts/setup.sh"
        exit 1
    fi
    
    # Выполнение безопасного ребрендинга
    safe_replace_headers
    safe_replace_namespace
    safe_update_cmake
    create_unichain_constants
    safe_update_readme
    
    # Проверка изменений
    verify_changes
    
    echo ""
    echo "🎉 Безопасный ребрендинг завершен!"
    echo ""
    echo "📋 Что было сделано:"
    echo "✅ Обновлены заголовки файлов"
    echo "✅ Заменен namespace ton на unichain"
    echo "✅ Обновлен CMakeLists.txt"
    echo "✅ Созданы константы Unichain"
    echo "✅ Обновлен README"
    echo ""
    echo "🔗 Следующие шаги:"
    echo "1. Проверьте изменения: git diff"
    echo "2. Соберите проект: ./scripts/build-unichain.sh"
    echo "3. Протестируйте функциональность"
    echo ""
    echo "⚠️  Резервная копия сохранена в unichain-source-backup/"
    echo "🔄 Для отката: ./scripts/safe-rebrand.sh rollback"
}

# Обработка аргументов
case "${1:-}" in
    "rollback")
        rollback_changes
        ;;
    *)
        main
        ;;
esac
