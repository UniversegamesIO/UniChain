# 🔑 Настройка деплой ключа для GitHub

## ⚠️ ВАЖНО: Безопасность

**НИКОГДА не публикуйте приватные SSH ключи в открытом доступе!**
- Приватный ключ должен оставаться секретным
- Публичный ключ можно безопасно добавлять в GitHub
- Храните ключи в безопасном месте

## Обзор

Деплой ключ - это SSH ключ, который позволяет безопасно загружать обновления в GitHub репозиторий без использования личных учетных данных.

## 🚀 Создание деплой ключа

### 1. Создание SSH ключа

```bash
# Создание нового SSH ключа
ssh-keygen -t ed25519 -C "unichain-deploy@github.com" -f ~/.ssh/unichain_deploy_key -N ""
```

### 2. Настройка SSH конфигурации

```bash
# Добавление конфигурации в ~/.ssh/config
echo -e "\n# Unichain Deploy Key\nHost github.com-unichain\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/unichain_deploy_key\n  IdentitiesOnly yes" >> ~/.ssh/config
```

### 3. Получение публичного ключа

```bash
# Показать публичный ключ для добавления в GitHub
cat ~/.ssh/unichain_deploy_key.pub
```

**Скопируйте результат этой команды - это ваш публичный ключ**

## 📋 Настройка в GitHub

### 1. Добавление ключа в GitHub

1. Перейдите в ваш GitHub репозиторий
2. Нажмите **Settings** (Настройки)
3. В левом меню выберите **Deploy keys**
4. Нажмите **Add deploy key**
5. Заполните форму:
   - **Title**: `Unichain Deploy Key`
   - **Key**: Вставьте публичный ключ из команды выше
   - **Allow write access**: ✅ Отметьте галочку
6. Нажмите **Add key**

### 2. Тестирование подключения

```bash
# Тестирование SSH подключения
./scripts/test-ssh.sh
```

## 📦 Использование деплой скрипта

### Автоматический деплой

```bash
./scripts/deploy.sh
```

**Что делает скрипт:**
1. Проверяет наличие SSH ключа
2. Проверяет статус Git репозитория
3. Добавляет все изменения
4. Создает коммит с временной меткой
5. Отправляет изменения в GitHub
6. Восстанавливает оригинальный URL

### Ручной деплой

```bash
# Добавление изменений
git add .

# Создание коммита
git commit -m "Update: $(date)"

# Отправка в GitHub
git push origin main
```

## 🔧 Настройка для CI/CD

### GitHub Actions

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          ssh-key: ${{ secrets.DEPLOY_KEY }}
      
      - name: Deploy
        run: |
          ./scripts/deploy.sh
```

### Переменные окружения

```bash
# Добавьте в GitHub Secrets:
DEPLOY_KEY=$(cat ~/.ssh/unichain_deploy_key)
```

## 🛠 Устранение неполадок

### Проблема: SSH ключ не работает

```bash
# Проверка ключа
ls -la ~/.ssh/unichain_deploy_key*

# Проверка прав доступа
chmod 600 ~/.ssh/unichain_deploy_key
chmod 644 ~/.ssh/unichain_deploy_key.pub

# Тестирование подключения
ssh -T git@github.com-unichain
```

### Проблема: Доступ запрещен

1. Проверьте, что ключ добавлен в правильный репозиторий
2. Убедитесь, что включен "Allow write access"
3. Проверьте права доступа к репозиторию

### Проблема: Git не может подключиться

```bash
# Проверка SSH конфигурации
cat ~/.ssh/config

# Тестирование с verbose
ssh -vT git@github.com-unichain
```

## 📚 Полезные команды

### Просмотр SSH ключей

```bash
# Все SSH ключи
ls -la ~/.ssh/

# Публичный ключ деплоя
cat ~/.ssh/unichain_deploy_key.pub

# SSH конфигурация
cat ~/.ssh/config
```

### Управление ключами

```bash
# Создание нового ключа
ssh-keygen -t ed25519 -C "unichain-deploy@github.com" -f ~/.ssh/unichain_deploy_key

# Удаление ключа
rm ~/.ssh/unichain_deploy_key*

# Резервное копирование
cp ~/.ssh/unichain_deploy_key ~/.ssh/unichain_deploy_key.backup
```

## 🔒 Безопасность

### ⚠️ КРИТИЧЕСКИ ВАЖНО

1. **НИКОГДА не публикуйте приватный ключ**
   - Не добавляйте в Git репозиторий
   - Не отправляйте по email
   - Не публикуйте в документации

2. **Храните приватный ключ в безопасности**
   - Используйте шифрование для хранения
   - Ограничьте доступ к файлу
   - Регулярно ротируйте ключи

3. **Ограничьте доступ**
   - Используйте ключ только для одного репозитория
   - Не включайте "Allow write access" без необходимости
   - Мониторьте использование ключа

4. **Мониторинг**
   - Регулярно проверяйте логи доступа
   - Настройте уведомления о подозрительной активности
   - Ведите журнал использования

## 📞 Поддержка

При возникновении проблем:

1. Проверьте логи: `./scripts/test-ssh.sh`
2. Обратитесь к документации GitHub
3. Создайте issue в репозитории

---

**Unichain** - Безопасный деплой для всех 🚀
