#!/bin/sh

# -------- Настройки --------
# Ссылка на raw IPK из GitHub
PACKAGE_URL="https://raw.githubusercontent.com/routerich/packages.routerich/24.10.4/routerich/luci-theme-routerich_1.0.9.10-r20251204_all.ipk"
PACKAGE_FILE="/tmp/$(basename $PACKAGE_URL)"

# -------- Обновление opkg --------
echo "Обновление списка пакетов..."
if ! opkg update; then
    echo "Ошибка: не удалось обновить список пакетов"
    exit 1
fi

# -------- Установка русского пакета LuCI --------
echo "Установка luci-i18n-base-ru..."
if opkg install luci-i18n-base-ru; then
    echo "✔ luci-i18n-base-ru установлен"
else
    echo "Ошибка: не удалось установить luci-i18n-base-ru"
    exit 1
fi

# -------- Скачивание routerich темы --------
echo "Скачивание luci-theme-routerich из репозитория..."
if wget -q -O "$PACKAGE_FILE" "$PACKAGE_URL"; then
    echo "✔ Файл скачан: $PACKAGE_FILE"
else
    echo "Ошибка: не удалось скачать файл по $PACKAGE_URL"
    exit 1
fi

# -------- Установка IPK --------
echo "Установка luci-theme-routerich..."
if opkg install "$PACKAGE_FILE"; then
    echo "✔ luci-theme-routerich успешно установлен"
else
    echo "Ошибка: не удалось установить luci-theme-routerich"
    exit 1
fi

echo "Готово! Все пакеты установлены."
