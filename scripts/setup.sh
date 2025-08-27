#!/bin/bash

# 🚀 Unichain Setup Script
# Скрипт для настройки окружения разработки

set -e

echo "🚀 Настройка окружения Unichain..."

# Проверка зависимостей
check_dependencies() {
    echo "📋 Проверка зависимостей..."
    
    # Проверка Git
    if ! command -v git &> /dev/null; then
        echo "❌ Git не установлен. Установите Git и попробуйте снова."
        exit 1
    fi
    
    # Проверка CMake
    if ! command -v cmake &> /dev/null; then
        echo "❌ CMake не установлен. Установите CMake и попробуйте снова."
        exit 1
    fi
    
    # Проверка Clang
    if ! command -v clang &> /dev/null; then
        echo "❌ Clang не установлен. Установите Clang и попробуйте снова."
        exit 1
    fi
    
    # Проверка Make
    if ! command -v make &> /dev/null; then
        echo "❌ Make не установлен. Установите Make и попробуйте снова."
        exit 1
    fi
    
    echo "✅ Все зависимости установлены"
}

# Установка зависимостей для macOS
install_macos_deps() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🍎 Установка зависимостей для macOS..."
        
        if ! command -v brew &> /dev/null; then
            echo "📦 Установка Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        echo "📦 Установка необходимых пакетов..."
        brew install cmake clang make openssl zlib
        
        echo "✅ Зависимости для macOS установлены"
    fi
}

# Установка зависимостей для Linux
install_linux_deps() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "🐧 Установка зависимостей для Linux..."
        
        # Определение дистрибутива
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y build-essential cmake clang libssl-dev zlib1g-dev
        elif command -v yum &> /dev/null; then
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y cmake clang openssl-devel zlib-devel
        elif command -v dnf &> /dev/null; then
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y cmake clang openssl-devel zlib-devel
        else
            echo "❌ Неподдерживаемый дистрибутив Linux"
            exit 1
        fi
        
        echo "✅ Зависимости для Linux установлены"
    fi
}

# Клонирование UNI репозитория
clone_uni() {
    if [ ! -d "uni-source" ]; then
        echo "📥 Клонирование UNI репозитория..."
        git clone https://github.com/uni-blockchain/uni.git uni-source
        echo "✅ UNI репозиторий клонирован"
    else
        echo "✅ UNI репозиторий уже существует"
    fi
}

# Настройка подмодулей
setup_submodules() {
    echo "📦 Настройка подмодулей..."
    cd uni-source
    git submodule update --init --recursive
    cd ..
    echo "✅ Подмодули настроены"
}

# Создание конфигурационных файлов
create_configs() {
    echo "⚙️ Создание конфигурационных файлов..."
    
    # Создание конфигурации для Unichain
    cat > config/unichain.conf << EOF
# Unichain Configuration
[network]
name = "Unichain"
version = "1.0.0"
workchain_id = 0
shard_id = 0x8000000000000000

[validator]
min_validators = 3
max_validators = 100
stake_min = 1000000000

[token]
name = "Unichain Coin"
symbol = "UNI"
decimals = 9
total_supply = 1000000000000000000

[gas]
gas_price = 1000
gas_limit = 1000000
EOF
    
    echo "✅ Конфигурационные файлы созданы"
}

# Создание Docker конфигурации
create_docker_config() {
    echo "🐳 Создание Docker конфигурации..."
    
    cat > docker/Dockerfile << EOF
FROM ubuntu:20.04

# Установка зависимостей
RUN apt-get update && apt-get install -y \\
    build-essential \\
    cmake \\
    clang \\
    libssl-dev \\
    zlib1g-dev \\
    git \\
    && rm -rf /var/lib/apt/lists/*

# Копирование исходного кода
COPY uni-source /app/uni-source
WORKDIR /app/uni-source

# Сборка UNI
RUN mkdir build && cd build \\
    && cmake -DCMAKE_BUILD_TYPE=Release .. \\
    && make -j$(nproc)

# Создание директории для данных
RUN mkdir -p /app/data

EXPOSE 8080 8081 8082

CMD ["/app/uni-source/build/validator-engine/validator-engine"]
EOF
    
    cat > docker/docker-compose.yml << EOF
version: '3.8'

services:
  validator:
    build: .
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    volumes:
      - ./data:/app/data
    environment:
      - UNI_CONFIG=/app/config/unichain.conf
    restart: unless-stopped

  fullnode:
    build: .
    ports:
      - "8083:8080"
      - "8084:8081"
      - "8085:8082"
    volumes:
      - ./data:/app/data
    environment:
      - UNI_CONFIG=/app/config/fullnode.conf
    restart: unless-stopped
EOF
    
    echo "✅ Docker конфигурация создана"
}

# Создание скриптов автоматизации
create_scripts() {
    echo "📜 Создание скриптов автоматизации..."
    
    cat > scripts/build.sh << 'EOF'
#!/bin/bash
# Скрипт сборки Unichain

set -e

echo "🔨 Сборка Unichain..."

cd uni-source
mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

echo "✅ Сборка завершена"
EOF
    
    cat > scripts/start-local.sh << 'EOF'
#!/bin/bash
# Скрипт запуска локальной сети

set -e

echo "🚀 Запуск локальной сети Unichain..."

# Проверка наличия собранных бинарников
if [ ! -f "uni-source/build/validator-engine/validator-engine" ]; then
    echo "❌ Бинарники не найдены. Запустите ./scripts/build.sh"
    exit 1
fi

# Создание директории для данных
mkdir -p data

# Запуск валидатора
echo "🔧 Запуск валидатора..."
./uni-source/build/validator-engine/validator-engine \
    --config config/unichain.conf \
    --db data/validator \
    --port 8080 &

echo "✅ Локальная сеть запущена"
echo "📊 Мониторинг: http://localhost:8080"
EOF
    
    chmod +x scripts/build.sh scripts/start-local.sh
    
    echo "✅ Скрипты автоматизации созданы"
}

# Основная функция
main() {
    echo "🚀 Настройка окружения Unichain..."
    
    check_dependencies
    install_macos_deps
    install_linux_deps
    clone_uni
    setup_submodules
    create_configs
    create_docker_config
    create_scripts
    
    echo ""
    echo "🎉 Настройка завершена!"
    echo ""
    echo "📋 Следующие шаги:"
    echo "1. Запустите: ./scripts/build.sh"
    echo "2. Запустите: ./scripts/start-local.sh"
    echo "3. Изучите документацию в папке docs/"
    echo ""
    echo "🔗 Полезные ссылки:"
    echo "- Архитектура: docs/architecture.md"
    echo "- Деплой: docs/deployment.md"
}

# Запуск скрипта
main "$@"
