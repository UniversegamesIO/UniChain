#!/bin/bash

# 🏗️ UNI Blockchain Build Script
# Сборка UNI Blockchain из исходного кода

set -e

echo "🏗️ Начало сборки UNI Blockchain..."

# Проверка наличия исходного кода
if [ ! -d "uni-source" ]; then
    echo "❌ Исходный код UNI не найден. Запустите ./scripts/setup.sh"
    exit 1
fi

# Проверка зависимостей
echo "🔍 Проверка зависимостей..."

# Проверяем CMake
if ! command -v cmake &> /dev/null; then
    echo "❌ CMake не найден. Установите CMake 3.16+"
    exit 1
fi

# Проверяем компилятор
if ! command -v clang++ &> /dev/null && ! command -v g++ &> /dev/null; then
    echo "❌ Компилятор C++ не найден. Установите clang++ или g++"
    exit 1
fi

# Проверяем Git
if ! command -v git &> /dev/null; then
    echo "❌ Git не найден. Установите Git"
    exit 1
fi

echo "✅ Зависимости проверены"

# Создание директории сборки
echo "📁 Создание директории сборки..."
cd uni-source

if [ -d "build" ]; then
    echo "🗑️ Удаление старой сборки..."
    rm -rf build
fi

mkdir build
cd build

# Конфигурация сборки
echo "⚙️ Конфигурация сборки..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DTON_ONLY_TONLIB=OFF \
    -DTON_USE_ABSEIL=OFF \
    -DTON_USE_RANDOMX=OFF \
    -DTON_USE_ROCKSDB=OFF \
    -DTON_USE_ZSTD=OFF \
    -DTON_ARCH=native

# Сборка
echo "🔨 Сборка UNI Blockchain..."
make -j$(nproc)

# Проверка результатов сборки
echo "🔍 Проверка результатов сборки..."

# Проверяем основные компоненты
components=(
    "validator-engine/validator-engine"
    "validator-engine-console/validator-engine-console"
    "lite-client/lite-client"
    "func/func"
    "fift/fift"
)

for component in "${components[@]}"; do
    if [ -f "$component" ]; then
        echo "✅ $component собран"
    else
        echo "❌ $component не найден"
    fi
done

# Создание символических ссылок
echo "🔗 Создание символических ссылок..."
cd ../..

if [ ! -d "bin" ]; then
    mkdir bin
fi

ln -sf uni-source/build/validator-engine/validator-engine bin/uni-validator
ln -sf uni-source/build/validator-engine-console/validator-engine-console bin/uni-console
ln -sf uni-source/build/lite-client/lite-client bin/uni-lite-client
ln -sf uni-source/build/func/func bin/uni-func
ln -sf uni-source/build/fift/fift bin/uni-fift

echo "✅ Символические ссылки созданы"

# Создание конфигурации
echo "⚙️ Создание конфигурации..."
if [ ! -d "config" ]; then
    mkdir config
fi

cat > config/uni-local.conf << 'EOF'
# UNI Blockchain Local Configuration

# Network configuration
network_id = 1
workchain_id = 0
shard_id = 0x8000000000000000

# Validator configuration
validator_count = 1
min_validators = 1
max_validators = 100

# Block configuration
block_time = 5
block_size_limit = 1048576
gas_price = 1000
gas_limit = 1000000

# Token configuration
token_decimals = 9
total_supply = 1000000000000000000
min_stake = 1000000000

# Database configuration
db_path = "/var/uni-work/db"
log_level = "INFO"

# RPC configuration
rpc_port = 8080
http_port = 8081
EOF

echo "✅ Конфигурация создана"

# Создание директорий для работы
echo "📁 Создание рабочих директорий..."
mkdir -p /var/uni-work/db
mkdir -p /var/uni-work/logs
mkdir -p /var/uni-work/keys

echo "✅ Рабочие директории созданы"

echo ""
echo "🎉 Сборка UNI Blockchain завершена!"
echo ""
echo "📋 Собранные компоненты:"
echo "  • uni-validator - Валидатор"
echo "  • uni-console - Консоль управления"
echo "  • uni-lite-client - Легкий клиент"
echo "  • uni-func - Компилятор смарт-контрактов"
echo "  • uni-fift - Интерпретатор Fift"
echo ""
echo "🔗 Следующие шаги:"
echo "  1. Запуск локальной сети: ./scripts/start-local.sh"
echo "  2. Проверка статуса: ./scripts/status.sh"
echo "  3. Остановка сети: ./scripts/stop-local.sh"
echo ""
echo "📁 Файлы:"
echo "  • Конфигурация: config/uni-local.conf"
echo "  • Бинарные файлы: bin/"
echo "  • Рабочие директории: /var/uni-work/"
