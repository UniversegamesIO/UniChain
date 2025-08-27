# 🚀 Руководство по развертыванию Unichain

## Обзор

Это руководство описывает процесс развертывания Unichain сети от локальной разработки до продакшн окружения.

## 📋 Требования

### Системные требования

#### Минимальные требования для валидатора:
- **CPU**: 4 ядра
- **RAM**: 8 GB
- **Storage**: 100 GB SSD
- **Network**: 100 Mbps
- **OS**: Ubuntu 20.04+ / CentOS 8+ / macOS 12+

#### Рекомендуемые требования для валидатора:
- **CPU**: 8+ ядер
- **RAM**: 16+ GB
- **Storage**: 500 GB+ NVMe SSD
- **Network**: 1 Gbps+
- **OS**: Ubuntu 22.04 LTS

### Программные зависимости

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y build-essential cmake clang libssl-dev zlib1g-dev git

# CentOS/RHEL
sudo yum groupinstall -y "Development Tools"
sudo yum install -y cmake clang openssl-devel zlib-devel git

# macOS
brew install cmake clang make openssl zlib git
```

## 🏗 Архитектура развертывания

### Компоненты сети

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Validator     │    │   Full Node     │    │   Lite Server   │
│     Node        │    │                 │    │                 │
│                 │    │                 │    │                 │
│ - Block         │    │ - Block         │    │ - Light         │
│   Validation    │    │   Storage       │    │   Queries       │
│ - Consensus     │    │ - Transaction   │    │ - API           │
│ - Staking       │    │   Processing    │    │   Access        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   ADNL Network  │
                    │                 │
                    │ - P2P Protocol  │
                    │ - Message       │
                    │   Routing       │
                    └─────────────────┘
```

### Топология сети

#### Тестовая сеть:
- 3-5 валидаторов
- 2-3 full node
- 1-2 lite server

#### Продакшн сеть:
- 10+ валидаторов
- 5+ full node
- 3+ lite server
- Load balancers
- Monitoring

## 🔧 Локальное развертывание

### 1. Подготовка окружения

```bash
# Клонирование проекта
git clone <repository-url>
cd UniChein

# Настройка окружения
./scripts/setup.sh

# Ребрендинг
./scripts/rebrand.sh
```

### 2. Сборка

```bash
# Сборка Unichain
./scripts/build-unichain.sh
```

### 3. Генерация ключей

```bash
# Создание директории для ключей
mkdir -p keys

# Генерация ключей валидатора
./uni-source/build/validator-engine-console/validator-engine-console \
    -k keys/validator-key.json \
    -p keys/validator-pub.json \
    -a keys/validator-addr.json
```

### 4. Запуск локальной сети

```bash
# Запуск валидатора
./scripts/start-local.sh

# Проверка статуса
./scripts/status.sh
```

## 🌐 Тестовая сеть

### 1. Подготовка серверов

#### Настройка валидатора:

```bash
# Установка зависимостей
sudo apt-get update
sudo apt-get install -y build-essential cmake clang libssl-dev zlib1g-dev git

# Настройка firewall
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 8082/tcp
```

#### Конфигурация валидатора:

```ini
# config/uni-local.conf
[validator]
workchain_id = 0
shard_id = 0x8000000000000000
min_validators = 3
max_validators = 10
stake_min = 1000000000

[network]
name = "Unichain Testnet"
version = "1.0.0"
block_time = 5
gas_price = 1000
gas_limit = 1000000

[storage]
db_path = "/var/uni-work/db"
log_level = "INFO"

[adnl]
port = 8080
external_port = 8080
external_ip = "YOUR_SERVER_IP"
```

### 2. Деплой с Docker

```bash
# Сборка проекта
./scripts/build-unichain.sh

# Запуск валидатора
./scripts/start-local.sh
```

### 3. Мониторинг

```bash
# Проверка логов
tail -f /var/uni-work/logs/validator.log

# Проверка статуса
./scripts/status.sh

# Проверка метрик
cat /var/uni-work/logs/metrics.log
```

## 🏭 Продакшн развертывание

### 1. Инфраструктура

#### Рекомендуемая архитектура:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load          │    │   Monitoring    │    │   Backup        │
│   Balancer      │    │   Stack         │    │   Storage       │
│                 │    │                 │    │                 │
│ - Nginx         │    │ - Prometheus    │    │ - S3 Compatible │
│ - HAProxy       │    │ - Grafana       │    │ - Local Storage │
│ - Cloudflare    │    │ - AlertManager  │    │ - Snapshots     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Kubernetes    │
                    │   Cluster       │
                    │                 │
                    │ - Validators    │
                    │ - Full Nodes    │
                    │ - Lite Servers  │
                    └─────────────────┘
```

### 2. Kubernetes развертывание

#### Namespace:

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: unichain
```

#### ConfigMap:

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: unichain-config
  namespace: unichain
data:
  uni-local.conf: |
    [validator]
    workchain_id = 0
    shard_id = 0x8000000000000000
    min_validators = 10
    max_validators = 100
    stake_min = 1000000000
    
    [network]
    name = "Unichain Mainnet"
    version = "1.0.0"
    block_time = 5
    gas_price = 1000
    gas_limit = 1000000
    
    [storage]
    db_path = "/var/uni-work/db"
    log_level = "INFO"
    
    [adnl]
    port = 8080
    external_port = 8080
```

#### Deployment:

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: unichain-validator
  namespace: unichain
spec:
  replicas: 3
  selector:
    matchLabels:
      app: unichain-validator
  template:
    metadata:
      labels:
        app: unichain-validator
    spec:
      containers:
      - name: validator
        image: unichain/validator:latest
        ports:
        - containerPort: 8080
        - containerPort: 8081
        - containerPort: 8082
        volumeMounts:
        - name: config
          mountPath: /app/config
        - name: data
          mountPath: /app/data
        resources:
          requests:
            memory: "8Gi"
            cpu: "4"
          limits:
            memory: "16Gi"
            cpu: "8"
      volumes:
      - name: config
        configMap:
          name: unichain-config
      - name: data
        persistentVolumeClaim:
          claimName: unichain-data
```

#### Service:

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: unichain-validator-service
  namespace: unichain
spec:
  selector:
    app: unichain-validator
  ports:
  - name: adnl
    port: 8080
    targetPort: 8080
  - name: control
    port: 8081
    targetPort: 8081
  - name: metrics
    port: 8082
    targetPort: 8082
  type: LoadBalancer
```

### 3. Мониторинг и логирование

#### Prometheus конфигурация:

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'unichain-validators'
    static_configs:
      - targets: ['unichain-validator-service:8082']
    metrics_path: '/metrics'
```

#### Grafana дашборд:

```json
{
  "dashboard": {
    "title": "Unichain Network",
    "panels": [
      {
        "title": "Block Height",
        "type": "stat",
        "targets": [
          {
            "expr": "unichain_block_height"
          }
        ]
      },
      {
        "title": "Transactions per Second",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(unichain_transactions_total[5m])"
          }
        ]
      }
    ]
  }
}
```

## 🔐 Безопасность

### 1. Управление ключами

```bash
# Генерация ключей в безопасной среде
./uni-source/build/validator-engine-console/validator-engine-console \
    -k /secure/validator-key.json \
    -p /secure/validator-pub.json \
    -a /secure/validator-addr.json

# Шифрование ключей
gpg --encrypt --recipient admin@unichain.org validator-key.json
```

### 2. Сетевая безопасность

```bash
# Настройка firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 8082/tcp
sudo ufw enable
```

### 3. Мониторинг безопасности

```bash
# Установка fail2ban
sudo apt-get install fail2ban

# Конфигурация
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📊 Мониторинг и метрики

### Ключевые метрики:

- **Block Height** - Высота блокчейна
- **TPS** - Транзакций в секунду
- **Validator Count** - Количество валидаторов
- **Stake Distribution** - Распределение стейков
- **Network Latency** - Задержка сети
- **Storage Usage** - Использование хранилища

### Алерты:

```yaml
# monitoring/alerts.yml
groups:
  - name: unichain
    rules:
      - alert: ValidatorDown
        expr: up{job="unichain-validators"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Validator {{ $labels.instance }} is down"
      
      - alert: BlockHeightStuck
        expr: unichain_block_height - unichain_block_height offset 5m == 0
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Block height is not increasing"
```

## 🔄 Обновления и миграции

### 1. План обновления

```bash
# 1. Создание резервной копии
cp -r /var/uni-work /var/uni-work.backup

# 2. Остановка сервисов
./scripts/stop-local.sh

# 3. Обновление кода
git pull origin main

# 4. Пересборка проекта
./scripts/build-unichain.sh

# 5. Запуск сервисов
./scripts/start-local.sh

# 6. Проверка статуса
./scripts/status.sh
```

### 2. Откат изменений

```bash
# Откат к предыдущей версии
cp -r /var/uni-work.backup /var/uni-work

# Проверка статуса
./scripts/status.sh
```

## 🆘 Troubleshooting

### Частые проблемы:

#### 1. Валидатор не синхронизируется

```bash
# Проверка логов
tail -f /var/uni-work/logs/validator.log

# Проверка сетевого подключения
netstat -an | grep 8080

# Проверка конфигурации
cat config/uni-local.conf
```

#### 2. Высокое использование CPU

```bash
# Проверка процессов
ps aux | grep validator-engine

# Проверка метрик
cat /var/uni-work/logs/metrics.log | grep cpu
```

#### 3. Нехватка места на диске

```bash
# Проверка использования диска
df -h /var/uni-work

# Очистка старых данных
rm -rf /var/uni-work/db/old_blocks
```

## 📞 Поддержка

### Контакты:

- **Email**: UniverseGames2024@gmail.com
- **Telegram**: @UniverseGamesSupport
- **Telegram Chat**: @UniverseGamesChat


### Полезные ссылки:

- [Архитектура](./architecture.md)
- [API документация](./api.md)
- [Смарт-контракты](./smart-contracts.md)
- [FAQ](./faq.md)
