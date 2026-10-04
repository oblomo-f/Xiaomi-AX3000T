#!/bin/sh

DNS_CONFIG="cfg01411c"

add_server()
{
    local value="$1"

    if ! uci -q get "dhcp.$DNS_CONFIG.server" 2>/dev/null | \
        tr ' ' '\n' | grep -F -x -q "$value"
    then
        uci add_list "dhcp.$DNS_CONFIG.server=$value"
    fi
}

add_domain()
{
    local name="$1"
    local ip="$2"

    if ! uci show dhcp 2>/dev/null | grep -F -q "name='$name'"
    then
        uci add dhcp domain
        uci set "dhcp.@domain[-1].name=$name"
        uci set "dhcp.@domain[-1].ip=$ip"
    fi
}

echo "Configure DNS..."

# dnsmasq-full
if opkg list-installed | grep -q '^dnsmasq-full '; then
    echo "dnsmasq-full already installed..."
else
    echo "Installing dnsmasq-full..."

    cd /tmp || exit 1

    opkg update
    opkg download dnsmasq-full

    if [ $? -ne 0 ]; then
        echo "Error downloading dnsmasq-full."
        exit 1
    fi

    opkg remove dnsmasq
    opkg install /tmp/dnsmasq-full*.ipk

    if [ $? -ne 0 ]; then
        echo "Error installing dnsmasq-full."
        exit 1
    fi

    if [ -f /etc/config/dhcp-opkg ]; then
        cp /etc/config/dhcp /etc/config/dhcp-old
        mv /etc/config/dhcp-opkg /etc/config/dhcp
    fi
fi

# dnsmasq confdir
uci set dhcp.@dnsmasq[0].confdir='/tmp/dnsmasq.d'

# DNS options
uci set dhcp.$DNS_CONFIG.strictorder='1'
uci set dhcp.$DNS_CONFIG.filter_aaaa='1'

# DNS servers
add_server '127.0.0.1#5053'
add_server '127.0.0.1#5054'
add_server '127.0.0.1#5055'
add_server '127.0.0.1#5056'

# Domain routing
add_server '/*.chatgpt.com/127.0.0.1#5056'
add_server '/*.oaistatic.com/127.0.0.1#5056'
add_server '/*.oaiusercontent.com/127.0.0.1#5056'
add_server '/*.openai.com/127.0.0.1#5056'
add_server '/*.microsoft.com/127.0.0.1#5056'
add_server '/*.windowsupdate.com/127.0.0.1#5056'
add_server '/*.bing.com/127.0.0.1#5056'
add_server '/*.supercell.com/127.0.0.1#5056'
add_server '/*.seeurlpcl.com/127.0.0.1#5056'
add_server '/*.supercellid.com/127.0.0.1#5056'
add_server '/*.supercellgames.com/127.0.0.1#5056'
add_server '/*.clashroyale.com/127.0.0.1#5056'
add_server '/*.brawlstars.com/127.0.0.1#5056'
add_server '/*.clash.com/127.0.0.1#5056'
add_server '/*.clashofclans.com/127.0.0.1#5056'
add_server '/*.x.ai/127.0.0.1#5056'
add_server '/*.grok.com/127.0.0.1#5056'
add_server '/*.github.com/127.0.0.1#5056'
add_server '/*.forzamotorsport.net/127.0.0.1#5056'
add_server '/*.forzaracingchampionship.com/127.0.0.1#5056'
add_server '/*.forzarc.com/127.0.0.1#5056'
add_server '/*.gamepass.com/127.0.0.1#5056'
add_server '/*.orithegame.com/127.0.0.1#5056'
add_server '/*.renovacionxboxlive.com/127.0.0.1#5056'
add_server '/*.tellmewhygame.com/127.0.0.1#5056'
add_server '/*.xbox.co/127.0.0.1#5056'
add_server '/*.xbox.com/127.0.0.1#5056'
add_server '/*.xbox.eu/127.0.0.1#5056'
add_server '/*.xbox.org/127.0.0.1#5056'
add_server '/*.xbox360.co/127.0.0.1#5056'
add_server '/*.xbox360.com/127.0.0.1#5056'
add_server '/*.xbox360.eu/127.0.0.1#5056'
add_server '/*.xbox360.org/127.0.0.1#5056'
add_server '/*.xboxab.com/127.0.0.1#5056'
add_server '/*.xboxgamepass.com/127.0.0.1#5056'
add_server '/*.xboxgamestudios.com/127.0.0.1#5056'
add_server '/*.xboxlive.cn/127.0.0.1#5056'
add_server '/*.xboxlive.com/127.0.0.1#5056'
add_server '/*.xboxone.co/127.0.0.1#5056'
add_server '/*.xboxone.com/127.0.0.1#5056'
add_server '/*.xboxone.eu/127.0.0.1#5056'
add_server '/*.xboxplayanywhere.com/127.0.0.1#5056'
add_server '/*.xboxservices.com/127.0.0.1#5056'
add_server '/*.xboxstudios.com/127.0.0.1#5056'
add_server '/*.xbx.lv/127.0.0.1#5056'
add_server '/*.sentry.io/127.0.0.1#5056'
add_server '/*.usercentrics.eu/127.0.0.1#5056'
add_server '/*.recaptcha.net/127.0.0.1#5056'
add_server '/*.gstatic.com/127.0.0.1#5056'
add_server '/*.brawlstarsgame.com/127.0.0.1#5056'

# Static ChatGPT/OpenAI DNS
add_domain 'chatgpt.com' '83.220.169.155'
add_domain 'openai.com' '83.220.169.155'
add_domain 'webrtc.chatgpt.com' '83.220.169.155'
add_domain 'ios.chat.openai.com' '83.220.169.155'
add_domain 'searchgpt.com' '83.220.169.155'

uci commit dhcp

echo "Restart dnsmasq..."
service dnsmasq restart

echo "Restart odhcpd..."
service odhcpd restart

echo "DNS configuration completed."
