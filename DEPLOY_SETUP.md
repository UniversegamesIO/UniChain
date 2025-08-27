# 🔑 Безопасная настройка деплой ключа

## ⚠️ ВАЖНО: Безопасность

**НИКОГДА не публикуйте приватные SSH ключи!**

## 🚀 Быстрая настройка

### 1. Создайте SSH ключ (выполните эту команду):

```bash
ssh-keygen -t ed25519 -C "unichain-deploy@github.com" -f ~/.ssh/unichain_deploy_key -N ""
```

### 2. Настройте SSH конфигурацию:

```bash
echo -e "\n# Unichain Deploy Key\nHost github.com-unichain\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/unichain_deploy_key\n  IdentitiesOnly yes" >> ~/.ssh/config
```

### 3. Получите публичный ключ:

```bash
cat ~/.ssh/unichain_deploy_key.pub
```

**Скопируйте результат этой команды**

### 4. Добавьте ключ в GitHub:

1. Перейдите в ваш GitHub репозиторий
2. Settings → Deploy keys → Add deploy key
3. Title: `Unichain Deploy Key`
4. Key: Вставьте скопированный ключ
5. ✅ Allow write access
6. Add key

### 5. Протестируйте:

```bash
./scripts/test-ssh.sh
```

### 6. Используйте деплой:

```bash
./scripts/deploy.sh
```

## 📚 Подробная документация

См. `docs/deploy-key-setup.md` для подробной информации.

---

**Безопасность превыше всего!** 🔒
