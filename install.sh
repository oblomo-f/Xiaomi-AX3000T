#!/bin/sh
# =========================================

CONFIG="/etc/opkg/distfeeds.conf"
KEYDIR="/etc/opkg/keys"
KEYFILE="$KEYDIR/2e724001fb65916f"

THEME_PACKAGE="luci-theme-routerich"
FILEMANAGER_PACKAGE="luci-app-filemanager"
FILEMANAGER_LANG="luci-i18n-filemanager-ru"

# -----------------------------
# Репозитории
# -----------------------------
REPOS=$(cat <<EOF
src/gz routerich_core https://github.com/routerich/packages.routerich/raw/24.10.4/core
src/gz openwrt_base https://downloads.openwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/base
src/gz openwrt_kmods https://downloads.openwrt.org/releases/24.10.4/targets/mediatek/filogic/kmods/6.6.110-1-6a9e125268c43e0bae8cecb014c8ab03
src/gz openwrt_luci https://downloads.openwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://downloads.openwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://downloads.openwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://downloads.openwrt.org/releases/24.10.4/packages/aarch64_cortex-a53/telephony
src/gz routerich https://github.com/routerich/packages.routerich/raw/24.10.4/routerich
EOF
)

# -----------------------------
# Обновление distfeeds.conf
# -----------------------------
if [ ! -f "$CONFIG" ]; then
    echo "Файл $CONFIG не найден!"
    exit 1
fi

cp "$CONFIG" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
echo "Создана резервная копия: ${CONFIG}.bak.*"

echo "$REPOS" > "$CONFIG"
echo "Новые репозитории добавлены в $CONFIG"

# -----------------------------
# Добавление Public Key
# -----------------------------
KEY_CONTENT="untrusted comment: Public usign key for 24.10 release builds
RWQuckAB+2WRb9rwzhWarTedFmsvy8y5kxAS3A0KXe3yUou9V/Nfbqty"

mkdir -p "$KEYDIR"

if [ -f "$KEYFILE" ]; then
    echo "Ключ уже существует: $KEYFILE"
else
    echo "$KEY_CONTENT" > "$KEYFILE"
    echo "Public Key добавлен в $KEYFILE"
fi

# -----------------------------
# Проверка opkg
# -----------------------------
if ! command -v opkg >/dev/null 2>&1; then
    echo "opkg не найден. Скрипт работает только на OpenWrt."
    exit 1
fi

echo "Обновляем списки пакетов..."
opkg update

echo "=== Устанавливаем базовый русский перевод LuCI ==="
opkg install luci-i18n-base-ru

if ! opkg list-installed | grep -q '^luci-i18n-base-ru'; then
    echo "❌ Ошибка: базовый перевод LuCI не установлен"
    exit 1
fi

echo "✔ Базовый перевод установлен"

echo "=== Поиск установленных LuCI-пакетов ==="
opkg list-installed | awk '{print $1}' | grep '^luci-' | while read -r pkg; do
    ru_pkg="${pkg}-ru"

    if opkg list | grep -q "^$ru_pkg "; then
        if opkg list-installed | grep -q "^$ru_pkg "; then
            echo "✔ $ru_pkg уже установлен"
        else
            echo "→ Устанавливаем $ru_pkg"
            opkg install "$ru_pkg" || echo "⚠ Не удалось установить $ru_pkg"
        fi
    else
        echo "— Русификация для $pkg не найдена"
    fi
done

echo "=== Устанавливаем язык LuCI: русский ==="
uci set luci.main.lang='ru'
uci commit luci

echo "=== Перезапуск веб-интерфейса ==="
/etc/init.d/uhttpd restart

echo "🎉 Русификация LuCI завершена"

# -----------------------------
# Установка и применение темы luci-theme-routerich
# -----------------------------
if opkg list | grep -q "^$THEME_PACKAGE "; then
    if opkg list-installed | grep -q "^$THEME_PACKAGE "; then
        echo "Тема $THEME_PACKAGE уже установлена."
    else
        echo "Устанавливаем тему $THEME_PACKAGE..."
        opkg install $THEME_PACKAGE
        echo "Тема $THEME_PACKAGE установлена."
    fi

#    # Гарантированное применение темы
#    uci set luci.main.mediaurlbase="Routerich"
#    uci set luci.main.rnd_theme="Routerich"
#    uci commit luci
#    rm -rf /tmp/luci-*
#    /etc/init.d/uhttpd restart

#    echo "Тема $THEME_PACKAGE успешно применена."
#else
#    echo "Тема $THEME_PACKAGE недоступна в текущих репозиториях. Установка пропущена."
fi

# -----------------------------
# Установка File Manager и русификация
# -----------------------------
for PKG in "$FILEMANAGER_PACKAGE" "$FILEMANAGER_LANG"; do
    if opkg list | grep -q "^$PKG "; then
        if opkg list-installed | grep -q "^$PKG "; then
            echo "Пакет $PKG уже установлен."
        else
            echo "Устанавливаем пакет $PKG..."
            opkg install $PKG
        fi
    else
        echo "Пакет $PKG недоступен в текущих репозиториях. Пропуск."
    fi
done

# -----------------------------
# Установка Терминала
# -----------------------------
for PKG in "ttyd" "luci-i18n-ttyd-ru" "luci-app-ttyd"; do
    if opkg list | grep -q "^$PKG "; then
        if opkg list-installed | grep -q "^$PKG "; then
            echo "Пакет $PKG уже установлен."
        else
            echo "Устанавливаем пакет $PKG..."
            opkg install $PKG
        fi
    else
        echo "Пакет $PKG недоступен в текущих репозиториях. Пропуск."
    fi
done


# -----------------------------
# Перезапуск uHTTPd
# -----------------------------
echo "Перезапуск LuCI..."
/etc/init.d/uhttpd restart

echo "Готово!."
