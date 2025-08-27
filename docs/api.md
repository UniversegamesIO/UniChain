# 🔌 API документация Unichain

## Обзор

Unichain предоставляет REST API для взаимодействия с блокчейном. API поддерживает все основные операции: получение информации о блоках, транзакциях, аккаунтах, отправка транзакций и работа со смарт-контрактами.

## 🔗 Базовые URL

### Тестовая сеть:
```
https://testnet-api.unichain.org
```

### Продакшн сеть:
```
https://api.unichain.org
```

### Локальная сеть:
```
http://localhost:8080
```

## 🔐 Аутентификация

### API ключи

Для доступа к API требуется API ключ:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://api.unichain.org/v1/status
```

### Получение API ключа

```bash
# Регистрация
curl -X POST https://api.unichain.org/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "secure_password"
  }'

# Вход
curl -X POST https://api.unichain.org/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "secure_password"
  }'
```

## 📊 Статус сети

### Получение статуса сети

```http
GET /v1/status
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "network": "Unichain",
    "version": "1.0.0",
    "block_height": 12345,
    "total_transactions": 67890,
    "validators_count": 15,
    "total_stake": "1000000000000000000",
    "block_time": 5,
    "uptime": 86400,
    "last_block_time": "2024-01-15T10:30:00Z"
  }
}
```

### Получение метрик

```http
GET /v1/metrics
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "transactions_per_second": 100,
    "blocks_per_minute": 12,
    "active_validators": 15,
    "total_accounts": 50000,
    "network_load": 0.75,
    "memory_usage": "8.5GB",
    "storage_usage": "150GB"
  }
}
```

## 🧱 Блоки

### Получение блока по высоте

```http
GET /v1/blocks/{height}
```

**Параметры:**
- `height` (number) - Высота блока

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "height": 12345,
    "hash": "0x1234567890abcdef...",
    "timestamp": "2024-01-15T10:30:00Z",
    "transactions_count": 150,
    "validator": "EQA...",
    "shard": "0x8000000000000000",
    "workchain": 0,
    "gas_used": 1000000,
    "gas_limit": 1000000,
    "gas_price": 1000,
    "total_fees": "1000000",
    "prev_block": "0xabcdef1234567890...",
    "next_block": "0xfedcba0987654321..."
  }
}
```

### Получение последних блоков

```http
GET /v1/blocks/latest?limit=10
```

**Параметры:**
- `limit` (number, optional) - Количество блоков (по умолчанию 10)

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "blocks": [
      {
        "height": 12345,
        "hash": "0x1234567890abcdef...",
        "timestamp": "2024-01-15T10:30:00Z",
        "transactions_count": 150,
        "validator": "EQA..."
      }
    ],
    "total": 10,
    "has_more": true
  }
}
```

## 💰 Транзакции

### Получение транзакции по хешу

```http
GET /v1/transactions/{hash}
```

**Параметры:**
- `hash` (string) - Хеш транзакции

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "hash": "0x1234567890abcdef...",
    "block_height": 12345,
    "timestamp": "2024-01-15T10:30:00Z",
    "from": "EQA...",
    "to": "EQB...",
    "amount": "1000000000",
    "fee": "1000000",
    "gas_used": 1000,
    "gas_price": 1000,
    "status": "success",
    "message": "Transfer",
    "data": "base64_encoded_data",
    "signature": "0xabcdef1234567890..."
  }
}
```

### Отправка транзакции

```http
POST /v1/transactions/send
```

**Тело запроса:**
```json
{
  "from": "EQA...",
  "to": "EQB...",
  "amount": "1000000000",
  "message": "Transfer",
  "data": "base64_encoded_data",
  "signature": "0xabcdef1234567890..."
}
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "hash": "0x1234567890abcdef...",
    "status": "pending",
    "estimated_confirmation_time": 5
  }
}
```

### Получение транзакций аккаунта

```http
GET /v1/accounts/{address}/transactions?limit=20&offset=0
```

**Параметры:**
- `address` (string) - Адрес аккаунта
- `limit` (number, optional) - Количество транзакций
- `offset` (number, optional) - Смещение

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "transactions": [
      {
        "hash": "0x1234567890abcdef...",
        "block_height": 12345,
        "timestamp": "2024-01-15T10:30:00Z",
        "from": "EQA...",
        "to": "EQB...",
        "amount": "1000000000",
        "status": "success"
      }
    ],
    "total": 150,
    "has_more": true
  }
}
```

## 👤 Аккаунты

### Получение информации об аккаунте

```http
GET /v1/accounts/{address}
```

**Параметры:**
- `address` (string) - Адрес аккаунта

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "address": "EQA...",
    "balance": "1000000000000",
    "code_hash": "0x1234567890abcdef...",
    "data_hash": "0xabcdef1234567890...",
    "last_transaction_lt": 123456789,
    "last_transaction_hash": "0x1234567890abcdef...",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T10:30:00Z",
    "is_contract": false,
    "is_active": true
  }
}
```

### Получение баланса

```http
GET /v1/accounts/{address}/balance
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "address": "EQA...",
    "balance": "1000000000000",
    "currency": "UNI",
    "decimals": 9
  }
}
```

## 📜 Смарт-контракты

### Получение информации о контракте

```http
GET /v1/contracts/{address}
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "address": "EQA...",
    "name": "System Contract",
    "type": "system",
    "code_hash": "0x1234567890abcdef...",
    "data_hash": "0xabcdef1234567890...",
    "balance": "1000000000000",
    "created_at": "2024-01-01T00:00:00Z",
    "methods": [
      {
        "name": "transfer",
        "signature": "transfer(address,uint256)",
        "inputs": [
          {"name": "to", "type": "address"},
          {"name": "amount", "type": "uint256"}
        ],
        "outputs": [{"type": "bool"}]
      }
    ],
    "events": [
      {
        "name": "Transfer",
        "signature": "Transfer(address,address,uint256)",
        "inputs": [
          {"name": "from", "type": "address", "indexed": true},
          {"name": "to", "type": "address", "indexed": true},
          {"name": "amount", "type": "uint256", "indexed": false}
        ]
      }
    ]
  }
}
```

### Вызов метода контракта

```http
POST /v1/contracts/{address}/call
```

**Тело запроса:**
```json
{
  "method": "transfer",
  "params": {
    "to": "EQB...",
    "amount": "1000000000"
  },
  "from": "EQA...",
  "gas_limit": 1000000,
  "gas_price": 1000
}
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "transaction_hash": "0x1234567890abcdef...",
    "gas_used": 50000,
    "result": true,
    "logs": [
      {
        "event": "Transfer",
        "data": {
          "from": "EQA...",
          "to": "EQB...",
          "amount": "1000000000"
        }
      }
    ]
  }
}
```

## 🔍 Поиск

### Поиск по хешу

```http
GET /v1/search/{hash}
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "type": "transaction",
    "hash": "0x1234567890abcdef...",
    "block_height": 12345,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Поиск аккаунтов

```http
GET /v1/search/accounts?q=validator&limit=10
```

**Параметры:**
- `q` (string) - Поисковый запрос
- `limit` (number, optional) - Количество результатов

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "accounts": [
      {
        "address": "EQA...",
        "balance": "1000000000000",
        "is_validator": true,
        "stake": "1000000000000"
      }
    ],
    "total": 5
  }
}
```

## 📊 Валидаторы

### Получение списка валидаторов

```http
GET /v1/validators
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "validators": [
      {
        "address": "EQA...",
        "stake": "1000000000000",
        "commission": 0.05,
        "uptime": 0.99,
        "blocks_produced": 1234,
        "last_block_time": "2024-01-15T10:30:00Z",
        "is_active": true
      }
    ],
    "total_stake": "1000000000000000000",
    "min_stake": "1000000000",
    "max_validators": 100
  }
}
```

### Получение статистики валидатора

```http
GET /v1/validators/{address}/stats
```

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "address": "EQA...",
    "total_blocks": 1234,
    "total_rewards": "50000000000",
    "uptime_24h": 0.99,
    "uptime_7d": 0.98,
    "uptime_30d": 0.97,
    "average_block_time": 5.1,
    "commission_earned": "2500000000"
  }
}
```

## 🔔 WebSocket API

### Подключение

```javascript
const ws = new WebSocket('wss://api.unichain.org/v1/ws');

ws.onopen = function() {
  console.log('Connected to Unichain WebSocket API');
  
  // Подписка на новые блоки
  ws.send(JSON.stringify({
    "method": "subscribe",
    "params": {
      "channel": "blocks"
    }
  }));
};

ws.onmessage = function(event) {
  const data = JSON.parse(event.data);
  console.log('New block:', data);
};
```

### Доступные каналы

- `blocks` - Новые блоки
- `transactions` - Новые транзакции
- `accounts/{address}` - Изменения аккаунта
- `contracts/{address}` - События контракта

## 📈 Графики и аналитика

### Получение статистики сети

```http
GET /v1/analytics/network?period=24h
```

**Параметры:**
- `period` (string) - Период (1h, 24h, 7d, 30d)

**Ответ:**
```json
{
  "status": "success",
  "data": {
    "period": "24h",
    "transactions": [
      {
        "timestamp": "2024-01-15T00:00:00Z",
        "count": 1000,
        "volume": "1000000000000"
      }
    ],
    "blocks": [
      {
        "timestamp": "2024-01-15T00:00:00Z",
        "count": 17280,
        "average_time": 5.0
      }
    ],
    "fees": [
      {
        "timestamp": "2024-01-15T00:00:00Z",
        "total": "1000000000",
        "average": "1000000"
      }
    ]
  }
}
```

## 🚨 Ошибки

### Коды ошибок

| Код | Описание |
|-----|----------|
| 400 | Неверный запрос |
| 401 | Не авторизован |
| 403 | Доступ запрещен |
| 404 | Не найдено |
| 429 | Слишком много запросов |
| 500 | Внутренняя ошибка сервера |

### Пример ошибки

```json
{
  "status": "error",
  "error": {
    "code": 400,
    "message": "Invalid address format",
    "details": "Address must be a valid Unichain address"
  }
}
```

## 📚 SDK

### JavaScript/TypeScript

```bash
npm install @unichain/sdk
```

```javascript
import { UnichainClient } from '@unichain/sdk';

const client = new UnichainClient({
  apiKey: 'YOUR_API_KEY',
  network: 'mainnet' // или 'testnet'
});

// Получение статуса сети
const status = await client.getStatus();
console.log('Block height:', status.block_height);

// Отправка транзакции
const tx = await client.sendTransaction({
  from: 'EQA...',
  to: 'EQB...',
  amount: '1000000000'
});
console.log('Transaction hash:', tx.hash);
```

### Python

```bash
pip install unichain-sdk
```

```python
from unichain import UnichainClient

client = UnichainClient(
    api_key='YOUR_API_KEY',
    network='mainnet'
)

# Получение статуса сети
status = client.get_status()
print(f"Block height: {status.block_height}")

# Отправка транзакции
tx = client.send_transaction(
    from_address='EQA...',
    to_address='EQB...',
    amount='1000000000'
)
print(f"Transaction hash: {tx.hash}")
```

## 🔧 Rate Limiting

### Лимиты запросов

- **Базовый план**: 100 запросов/минуту
- **Премиум план**: 1000 запросов/минуту
- **Enterprise план**: 10000 запросов/минуту

### Заголовки

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642234567
```

## 📞 Поддержка

### Контакты

- **Email**: api-support@unichain.org
- **Telegram**: @unichain_api_support
- **Discord**: Unichain API Community

### Полезные ссылки

- [SDK документация](./sdk.md)
- [Примеры использования](./examples.md)
- [Часто задаваемые вопросы](./faq.md)
