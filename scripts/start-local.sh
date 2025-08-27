#!/bin/bash

# 🚀 UNI Blockchain Local Network Startup Script
# Запуск локальной сети UNI Blockchain

set -e

echo "🚀 Запуск локальной сети UNI Blockchain..."

# Проверка наличия собранных компонентов
if [ ! -f "bin/uni-validator" ]; then
    echo "❌ Валидатор не найден. Запустите ./scripts/build-uni.sh"
    exit 1
fi

# Проверка конфигурации
if [ ! -f "config/uni-local.conf" ]; then
    echo "❌ Конфигурация не найдена. Запустите ./scripts/build-uni.sh"
    exit 1
fi

# Создание рабочих директорий
echo "📁 Создание рабочих директорий..."
sudo mkdir -p /var/uni-work/db
sudo mkdir -p /var/uni-work/logs
sudo mkdir -p /var/uni-work/keys
sudo chown -R $USER:$USER /var/uni-work

# Генерация ключей валидатора
echo "🔑 Генерация ключей валидатора..."
if [ ! -f "/var/uni-work/keys/validator.key" ]; then
    echo "Создание ключей валидатора..."
    bin/uni-console -k /var/uni-work/keys/validator.key -p /var/uni-work/keys/validator.pub -a
    echo "✅ Ключи валидатора созданы"
else
    echo "✅ Ключи валидатора уже существуют"
fi

# Создание genesis блока
echo "🏗️ Создание genesis блока..."
if [ ! -f "/var/uni-work/db/genesis.bin" ]; then
    echo "Создание genesis блока..."
    bin/uni-console -k /var/uni-work/keys/validator.key -p /var/uni-work/keys/validator.pub -g /var/uni-work/db/genesis.bin
    echo "✅ Genesis блок создан"
else
    echo "✅ Genesis блок уже существует"
fi

# Запуск валидатора
echo "🔄 Запуск валидатора..."
if pgrep -f "uni-validator" > /dev/null; then
    echo "⚠️ Валидатор уже запущен"
    echo "Для остановки: ./scripts/stop-local.sh"
else
    echo "Запуск валидатора в фоновом режиме..."
    nohup bin/uni-validator \
        -k /var/uni-work/keys/validator.key \
        -p /var/uni-work/keys/validator.pub \
        -c config/uni-local.conf \
        -d /var/uni-work/db \
        -l /var/uni-work/logs/validator.log \
        > /var/uni-work/logs/validator.out 2>&1 &
    
    VALIDATOR_PID=$!
    echo $VALIDATOR_PID > /var/uni-work/validator.pid
    echo "✅ Валидатор запущен (PID: $VALIDATOR_PID)"
fi

# Ожидание запуска
echo "⏳ Ожидание запуска валидатора..."
sleep 5

# Проверка статуса
echo "🔍 Проверка статуса валидатора..."
if pgrep -f "uni-validator" > /dev/null; then
    echo "✅ Валидатор работает"
else
    echo "❌ Валидатор не запустился"
    echo "Проверьте логи: tail -f /var/uni-work/logs/validator.log"
    exit 1
fi

# Запуск легкого клиента
echo "🔄 Запуск легкого клиента..."
if pgrep -f "uni-lite-client" > /dev/null; then
    echo "⚠️ Легкий клиент уже запущен"
else
    echo "Запуск легкого клиента в фоновом режиме..."
    nohup bin/uni-lite-client \
        -c config/uni-local.conf \
        -p 8080 \
        > /var/uni-work/logs/lite-client.log 2>&1 &
    
    LITE_CLIENT_PID=$!
    echo $LITE_CLIENT_PID > /var/uni-work/lite-client.pid
    echo "✅ Легкий клиент запущен (PID: $LITE_CLIENT_PID)"
fi

# Создание скрипта статуса
cat > scripts/status.sh << 'EOF'
#!/bin/bash

echo "📊 Статус UNI Blockchain Local Network"
echo "======================================"

# Проверка валидатора
if pgrep -f "uni-validator" > /dev/null; then
    VALIDATOR_PID=$(pgrep -f "uni-validator")
    echo "✅ Валидатор работает (PID: $VALIDATOR_PID)"
else
    echo "❌ Валидатор не запущен"
fi

# Проверка легкого клиента
if pgrep -f "uni-lite-client" > /dev/null; then
    LITE_CLIENT_PID=$(pgrep -f "uni-lite-client")
    echo "✅ Легкий клиент работает (PID: $LITE_CLIENT_PID)"
else
    echo "❌ Легкий клиент не запущен"
fi

# Проверка портов
if netstat -an | grep ":8080" | grep "LISTEN" > /dev/null; then
    echo "✅ RPC порт 8080 активен"
else
    echo "❌ RPC порт 8080 не активен"
fi

if netstat -an | grep ":8081" | grep "LISTEN" > /dev/null; then
    echo "✅ HTTP порт 8081 активен"
else
    echo "❌ HTTP порт 8081 не активен"
fi

# Информация о сети
echo ""
echo "📁 Файлы:"
echo "  • Конфигурация: config/uni-local.conf"
echo "  • База данных: /var/uni-work/db/"
echo "  • Логи: /var/uni-work/logs/"
echo "  • Ключи: /var/uni-work/keys/"
echo ""
echo "🔗 Команды:"
echo "  • Статус: ./scripts/status.sh"
echo "  • Остановка: ./scripts/stop-local.sh"
echo "  • Логи валидатора: tail -f /var/uni-work/logs/validator.log"
echo "  • Логи клиента: tail -f /var/uni-work/logs/lite-client.log"
EOF

chmod +x scripts/status.sh

# Создание скрипта остановки
cat > scripts/stop-local.sh << 'EOF'
#!/bin/bash

echo "🛑 Остановка UNI Blockchain Local Network..."

# Остановка валидатора
if [ -f "/var/uni-work/validator.pid" ]; then
    VALIDATOR_PID=$(cat /var/uni-work/validator.pid)
    if kill -0 $VALIDATOR_PID 2>/dev/null; then
        echo "Остановка валидатора (PID: $VALIDATOR_PID)..."
        kill $VALIDATOR_PID
        rm -f /var/uni-work/validator.pid
        echo "✅ Валидатор остановлен"
    else
        echo "Валидатор уже остановлен"
    fi
else
    echo "PID файл валидатора не найден"
fi

# Остановка легкого клиента
if [ -f "/var/uni-work/lite-client.pid" ]; then
    LITE_CLIENT_PID=$(cat /var/uni-work/lite-client.pid)
    if kill -0 $LITE_CLIENT_PID 2>/dev/null; then
        echo "Остановка легкого клиента (PID: $LITE_CLIENT_PID)..."
        kill $LITE_CLIENT_PID
        rm -f /var/uni-work/lite-client.pid
        echo "✅ Легкий клиент остановлен"
    else
        echo "Легкий клиент уже остановлен"
    fi
else
    echo "PID файл легкого клиента не найден"
fi

# Принудительная остановка процессов
pkill -f "uni-validator" 2>/dev/null || true
pkill -f "uni-lite-client" 2>/dev/null || true

echo "🎉 UNI Blockchain Local Network остановлена"
EOF

chmod +x scripts/stop-local.sh

echo ""
echo "🎉 Локальная сеть UNI Blockchain запущена!"
echo ""
echo "📊 Статус сети:"
./scripts/status.sh
echo ""
echo "🔗 Полезные команды:"
echo "  • Проверить статус: ./scripts/status.sh"
echo "  • Остановить сеть: ./scripts/stop-local.sh"
echo "  • Логи валидатора: tail -f /var/uni-work/logs/validator.log"
echo "  • Логи клиента: tail -f /var/uni-work/logs/lite-client.log"
echo ""
echo "🌐 Доступные endpoints:"
echo "  • RPC: http://localhost:8080"
echo "  • HTTP API: http://localhost:8081"
echo ""
echo "💡 Для тестирования используйте:"
echo "  • bin/uni-console - для управления сетью"
echo "  • bin/uni-func - для компиляции смарт-контрактов"
echo "  • bin/uni-fift - для выполнения скриптов"
