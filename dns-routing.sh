#!/bin/sh

# DNS routing / GeoBlock bypass
# Xiaomi AX3000T / RouteRich / OpenWrt

DNS_CONFIG="cfg01411c"

addServer()
{
    local value="$1"

    if ! uci -q get "dhcp.$DNS_CONFIG.server" 2>/dev/null | tr ' ' '\n' | grep -F -x -q "$value"
    then
        uci add_list "dhcp.$DNS_CONFIG.server=$value"
    fi
}

checkAndAddDomainPermanentName()
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

configureDns()
{
    echo "Configure DNS..."

    uci set "dhcp.$DNS_CONFIG.strictorder=1"
    uci set "dhcp.$DNS_CONFIG.filter_aaaa=1"

    addServer '127.0.0.1#5053'
    addServer '127.0.0.1#5054'
    addServer '127.0.0.1#5055'
    addServer '127.0.0.1#5056'
    addServer '/*.chatgpt.com/127.0.0.1#5056'
    addServer '/*.oaistatic.com/127.0.0.1#5056'
    addServer '/*.oaiusercontent.com/127.0.0.1#5056'
    addServer '/*.openai.com/127.0.0.1#5056'
    addServer '/*.microsoft.com/127.0.0.1#5056'
    addServer '/*.windowsupdate.com/127.0.0.1#5056'
    addServer '/*.bing.com/127.0.0.1#5056'
    addServer '/*.supercell.com/127.0.0.1#5056'
    addServer '/*.seeurlpcl.com/127.0.0.1#5056'
    addServer '/*.supercellid.com/127.0.0.1#5056'
    addServer '/*.supercellgames.com/127.0.0.1#5056'
    addServer '/*.clashroyale.com/127.0.0.1#5056'
    addServer '/*.brawlstars.com/127.0.0.1#5056'
    addServer '/*.clash.com/127.0.0.1#5056'
    addServer '/*.clashofclans.com/127.0.0.1#5056'
    addServer '/*.x.ai/127.0.0.1#5056'
    addServer '/*.grok.com/127.0.0.1#5056'
    addServer '/*.github.com/127.0.0.1#5056'
    addServer '/*.forzamotorsport.net/127.0.0.1#5056'
    addServer '/*.forzaracingchampionship.com/127.0.0.1#5056'
    addServer '/*.forzarc.com/127.0.0.1#5056'
    addServer '/*.gamepass.com/127.0.0.1#5056'
    addServer '/*.orithegame.com/127.0.0.1#5056'
    addServer '/*.renovacionxboxlive.com/127.0.0.1#5056'
    addServer '/*.tellmewhygame.com/127.0.0.1#5056'
    addServer '/*.xbox.co/127.0.0.1#5056'
    addServer '/*.xbox.com/127.0.0.1#5056'
    addServer '/*.xbox.eu/127.0.0.1#5056'
    addServer '/*.xbox.org/127.0.0.1#5056'
    addServer '/*.xbox360.co/127.0.0.1#5056'
    addServer '/*.xbox360.com/127.0.0.1#5056'
    addServer '/*.xbox360.eu/127.0.0.1#5056'
    addServer '/*.xbox360.org/127.0.0.1#5056'
    addServer '/*.xboxab.com/127.0.0.1#5056'
    addServer '/*.xboxgamepass.com/127.0.0.1#5056'
    addServer '/*.xboxgamestudios.com/127.0.0.1#5056'
    addServer '/*.xboxlive.cn/127.0.0.1#5056'
    addServer '/*.xboxlive.com/127.0.0.1#5056'
    addServer '/*.xboxone.co/127.0.0.1#5056'
    addServer '/*.xboxone.com/127.0.0.1#5056'
    addServer '/*.xboxone.eu/127.0.0.1#5056'
    addServer '/*.xboxplayanywhere.com/127.0.0.1#5056'
    addServer '/*.xboxservices.com/127.0.0.1#5056'
    addServer '/*.xboxstudios.com/127.0.0.1#5056'
    addServer '/*.xbx.lv/127.0.0.1#5056'
    addServer '/*.sentry.io/127.0.0.1#5056'
    addServer '/*.usercentrics.eu/127.0.0.1#5056'
    addServer '/*.recaptcha.net/127.0.0.1#5056'
    addServer '/*.gstatic.com/127.0.0.1#5056'
    addServer '/*.brawlstarsgame.com/127.0.0.1#5056'
    echo "Configure ChatGPT..."

    checkAndAddDomainPermanentName "chatgpt.com" "83.220.169.155"
    checkAndAddDomainPermanentName "openai.com" "83.220.169.155"
    checkAndAddDomainPermanentName "webrtc.chatgpt.com" "83.220.169.155"
    checkAndAddDomainPermanentName "ios.chat.openai.com" "83.220.169.155"
    checkAndAddDomainPermanentName "searchgpt.com" "83.220.169.155"

    uci commit dhcp

    service dnsmasq restart
    service odhcpd restart

    echo "DNS routing configured."
}

removeDomain()
{
    local name="$1"
    local section

    for section in $(uci show dhcp 2>/dev/null | sed -n 's/^dhcp\.\([^=]*\)=domain$/\1/p')
    do
        if [ "$(uci -q get "dhcp.$section.name" 2>/dev/null)" = "$name" ]
        then
            uci -q delete "dhcp.$section"
        fi
    done
}

removeDns()
{
    echo "Remove DNS routing..."

    uci -q delete "dhcp.$DNS_CONFIG.strictorder"
    uci -q delete "dhcp.$DNS_CONFIG.filter_aaaa"

    uci -q del_list "dhcp.$DNS_CONFIG.server=127.0.0.1#5053"
    uci -q del_list "dhcp.$DNS_CONFIG.server=127.0.0.1#5054"
    uci -q del_list "dhcp.$DNS_CONFIG.server=127.0.0.1#5055"
    uci -q del_list "dhcp.$DNS_CONFIG.server=127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.chatgpt.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.oaistatic.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.oaiusercontent.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.openai.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.microsoft.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.windowsupdate.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.bing.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.supercell.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.seeurlpcl.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.supercellid.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.supercellgames.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.clashroyale.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.brawlstars.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.clash.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.clashofclans.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.x.ai/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.grok.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.github.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.forzamotorsport.net/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.forzaracingchampionship.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.forzarc.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.gamepass.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.orithegame.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.renovacionxboxlive.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.tellmewhygame.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox.co/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox.eu/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox.org/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox360.co/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox360.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox360.eu/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbox360.org/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxab.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxgamepass.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxgamestudios.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxlive.cn/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxlive.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxone.co/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxone.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxone.eu/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxplayanywhere.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxservices.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xboxstudios.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.xbx.lv/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.sentry.io/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.usercentrics.eu/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.recaptcha.net/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.gstatic.com/127.0.0.1#5056"
    uci -q del_list "dhcp.$DNS_CONFIG.server=/*.brawlstarsgame.com/127.0.0.1#5056"
    removeDomain "chatgpt.com"
    removeDomain "openai.com"
    removeDomain "webrtc.chatgpt.com"
    removeDomain "ios.chat.openai.com"
    removeDomain "searchgpt.com"

    uci commit dhcp

    service dnsmasq restart
    service odhcpd restart

    echo "DNS routing removed."
}

case "${1:-install}" in
    install)
        configureDns
        ;;
    remove)
        removeDns
        ;;
    *)
        echo "Usage: $0 [install|remove]"
        exit 1
        ;;
esac
