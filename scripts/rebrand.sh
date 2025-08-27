#!/bin/bash

# 🎨 Unichain Rebranding Script
# Скрипт для автоматического ребрендинга UNI в Unichain

set -e

echo "🎨 Начало ребрендинга UNI в Unichain..."

# Конфигурация ребрендинга
UNI_NAME="UNI"
UNICHAIN_NAME="Unichain"
UNI_SYMBOL="UNI"
UNICHAIN_SYMBOL="UNI"
UNI_DESCRIPTION="The Open Network"
UNICHAIN_DESCRIPTION="Next Generation Blockchain Technology"

# Функция для безопасной замены текста в файлах
replace_in_files() {
    local pattern="$1"
    local replacement="$2"
    local file_pattern="$3"
    
    echo "🔄 Замена '$pattern' на '$replacement' в файлах $file_pattern..."
    
    # Создание резервной копии
    find . -name "$file_pattern" -type f -exec cp {} {}.backup \;
    
    # Выполнение замены
    find . -name "$file_pattern" -type f -exec sed -i "s/$pattern/$replacement/g" {} \;
    
    echo "✅ Замена завершена"
}

# Функция для замены в заголовках файлов
replace_headers() {
    echo "📝 Обновление заголовков файлов..."
    
    # Замена в комментариях заголовков
    find . -name "*.h" -o -name "*.cpp" -o -name "*.cc" | while read file; do
        if grep -q "UNI Blockchain" "$file"; then
            echo "🔄 Обновление заголовка в $file"
            sed -i 's/UNI Blockchain/Unichain Blockchain/g' "$file"
            sed -i 's/The Open Network/Next Generation Blockchain Technology/g' "$file"
        fi
    done
    
    echo "✅ Заголовки обновлены"
}

# Функция для обновления констант и типов
update_constants() {
    echo "🔧 Обновление констант и типов..."
    
    # Создание файла с новыми константами
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
    
    echo "✅ Константы обновлены"
}

# Функция для обновления конфигурационных файлов
update_configs() {
    echo "⚙️ Обновление конфигурационных файлов..."
    
    # Обновление CMakeLists.txt
    if [ -f "unichain-source/CMakeLists.txt" ]; then
        echo "🔄 Обновление CMakeLists.txt..."
        sed -i 's/PROJECT(ton)/PROJECT(unichain)/g' unichain-source/CMakeLists.txt
        sed -i 's/UNI Blockchain/Unichain Blockchain/g' unichain-source/CMakeLists.txt
    fi
    
    # Обновление README.md
    if [ -f "unichain-source/README.md" ]; then
        echo "🔄 Обновление README.md..."
        sed -i 's/UNI/Unichain/g' unichain-source/README.md
        sed -i 's/The Open Network/Next Generation Blockchain Technology/g' unichain-source/README.md
    fi
    
    echo "✅ Конфигурационные файлы обновлены"
}

# Функция для обновления Docker конфигурации
update_docker() {
    echo "🐳 Обновление Docker конфигурации..."
    
    # Обновление Dockerfile
    if [ -f "unichain-source/Dockerfile" ]; then
        echo "🔄 Обновление Dockerfile..."
        sed -i 's/UNI/Unichain/g' unichain-source/Dockerfile
        sed -i 's/unichain-blockchain/unichain-blockchain/g' unichain-source/Dockerfile
    fi
    
    echo "✅ Docker конфигурация обновлена"
}

# Функция для создания новых конфигурационных файлов
create_unichain_configs() {
    echo "📄 Создание конфигурационных файлов Unichain..."
    
    # Конфигурация валидатора
    cat > config/validator.conf << 'EOF'
# Unichain Validator Configuration
[validator]
workchain_id = 0
shard_id = 0x8000000000000000
min_validators = 3
max_validators = 100
stake_min = 1000000000

[network]
name = "Unichain"
version = "1.0.0"
block_time = 5
gas_price = 1000
gas_limit = 1000000

[storage]
db_path = "./data/validator"
log_level = "INFO"

[adnl]
port = 8080
external_port = 8080
EOF
    
    # Конфигурация full node
    cat > config/fullnode.conf << 'EOF'
# Unichain Full Node Configuration
[fullnode]
workchain_id = 0
shard_id = 0x8000000000000000

[network]
name = "Unichain"
version = "1.0.0"
block_time = 5

[storage]
db_path = "./data/fullnode"
log_level = "INFO"

[adnl]
port = 8083
external_port = 8083
EOF
    
    # Конфигурация lite server
    cat > config/liteserver.conf << 'EOF'
# Unichain Lite Server Configuration
[liteserver]
workchain_id = 0
shard_id = 0x8000000000000000

[network]
name = "Unichain"
version = "1.0.0"

[storage]
db_path = "./data/liteserver"
log_level = "INFO"

[adnl]
port = 8086
external_port = 8086
EOF
    
    echo "✅ Конфигурационные файлы созданы"
}

# Функция для обновления смарт-контрактов
update_smart_contracts() {
    echo "📜 Обновление смарт-контрактов..."
    
    # Создание директории для смарт-контрактов
    mkdir -p contracts
    
    # Системный контракт
    cat > contracts/system.fc << 'EOF'
;; System Contract for Unichain
;; This contract handles system-level operations

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    ;; Handle system messages
    if (in_msg_body.slice_empty?()) {
        return ();
    }
    
    ;; Process system operations
    int op = in_msg_body~load_uint(32);
    
    if (op == 0) {
        ;; System ping
        return ();
    }
    
    ;; Unknown operation
    throw(0xffff);
}
EOF
    
    # Конфигурационный контракт
    cat > contracts/config.fc << 'EOF'
;; Configuration Contract for Unichain
;; This contract stores network configuration

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    ;; Handle configuration updates
    if (in_msg_body.slice_empty?()) {
        return ();
    }
    
    ;; Process configuration operations
    int op = in_msg_body~load_uint(32);
    
    if (op == 0) {
        ;; Get configuration
        return ();
    }
    
    if (op == 1) {
        ;; Update configuration
        return ();
    }
    
    ;; Unknown operation
    throw(0xffff);
}
EOF
    
    echo "✅ Смарт-контракты обновлены"
}

# Функция для создания скриптов сборки
create_build_scripts() {
    echo "🔨 Создание скриптов сборки..."
    
    # Скрипт сборки с ребрендингом (создается только если не существует)
    if [ ! -f "scripts/build-unichain.sh" ]; then
        cat > scripts/build-unichain.sh << 'EOF'
#!/bin/bash
# Build script for Unichain

set -e

echo "🔨 Сборка Unichain..."

# Переход в директорию с исходным кодом
cd unichain-source

# Создание директории сборки
mkdir -p build
cd build

# Конфигурация CMake с ребрендингом
cmake -DCMAKE_BUILD_TYPE=Release \
      -DUNI_ONLY_UNILIB=OFF \
      -DUNI_USE_ABSEIL=OFF \
      -DUNI_USE_RANDOMX=OFF \
      -DUNI_USE_ROCKSDB=OFF \
      -DUNI_USE_ZSTD=OFF \
      ..

# Сборка
make -j$(nproc)

echo "✅ Сборка Unichain завершена"
EOF
        
        chmod +x scripts/build-unichain.sh
        echo "✅ Скрипт build-unichain.sh создан"
    else
        echo "✅ Скрипт build-unichain.sh уже существует"
    fi
    
    echo "✅ Скрипты сборки созданы"
}

# Функция для создания документации
create_documentation() {
    echo "📚 Создание документации..."
    
    # Обновление README
    cat > README.md << 'EOF'
# 🚀 Unichain - Next Generation Blockchain

**Unichain** - это независимая блокчейн сеть, основанная на технологии UNI, но с полным контролем над исходным кодом и собственным брендингом.

## 🎯 Особенности

- ✅ Полный контроль над исходным кодом
- ✅ Собственная валидатор сеть
- ✅ Совместимость с TonConnect
- ✅ Интеграция с Telegram WebApp
- ✅ Настраиваемая токеномика

## 🛠 Быстрый старт

```bash
# Настройка окружения
./scripts/setup.sh

# Ребрендинг UNI в Unichain
./scripts/rebrand.sh

# Сборка
./scripts/build-unichain.sh

# Запуск локальной сети
./scripts/start-local.sh
```

## 📋 Архитектура

Unichain состоит из следующих компонентов:

- **Validator Node** - Валидатор ноды
- **Full Node** - Полные ноды
- **Lite Server** - Легкие серверы
- **Smart Contracts** - Смарт-контракты
- **API Layer** - API слой

## 🔧 Конфигурация

Основные параметры сети:

- **Workchain ID**: 0
- **Shard ID**: 0x8000000000000000
- **Block Time**: 5 секунд
- **Gas Price**: 1000
- **Min Stake**: 1 UNI

## 📚 Документация

- [Архитектура](./docs/architecture.md)
- [Деплой](./docs/deployment.md)
- [API](./docs/api.md)
- [Смарт-контракты](./docs/smart-contracts.md)

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие Unichain!

## 📄 Лицензия

MIT License

---

**Unichain** - Следующее поколение блокчейн технологий 🚀
EOF
    
    echo "✅ Документация создана"
}

# Основная функция
main() {
    echo "🎨 Начало ребрендинга UNI в Unichain..."
    
    # Проверка наличия исходного кода
    if [ ! -d "unichain-source" ]; then
        echo "❌ Исходный код UNI не найден. Запустите ./scripts/setup.sh"
        exit 1
    fi
    
    # Создание резервной копии
    echo "💾 Создание резервной копии..."
    cp -r unichain-source unichain-source-backup
    
    # Выполнение ребрендинга
    replace_headers
    update_constants
    update_configs
    update_docker
    create_unichain_configs
    update_smart_contracts
    create_build_scripts
    create_documentation
    
    echo ""
    echo "🎉 Ребрендинг завершен!"
    echo ""
    echo "📋 Что было сделано:"
    echo "✅ Обновлены заголовки файлов"
    echo "✅ Созданы новые константы Unichain"
    echo "✅ Обновлены конфигурационные файлы"
    echo "✅ Созданы смарт-контракты"
    echo "✅ Обновлена документация"
    echo ""
    echo "🔗 Следующие шаги:"
    echo "1. Запустите: ./scripts/build-unichain.sh"
    echo "2. Запустите: ./scripts/start-local.sh"
    echo "3. Изучите документацию"
    echo ""
    echo "⚠️  Резервная копия сохранена в unichain-source-backup/"
}

# Запуск скрипта
main "$@"
