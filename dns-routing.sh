
    
  
#!/bin/sh
# DNS routing installer for OpenWrt / RouteRich
# Adds local DNS servers and routes selected domains to 127.0.0.1#5056.

set -eu

SECTION="$(uci show dhcp 2>/dev/null | sed -n 's/^dhcp\.\([^.=]*\)=dnsmasq$/\1/p' | head -n 1)"
if [ -z "$SECTION" ]; then
    echo "ERROR: dnsmasq section not found in UCI dhcp config." >&2
    exit 1
fi

echo "Using dnsmasq section: dhcp.$SECTION"

uci set "dhcp.$SECTION.strictorder=1"
uci set "dhcp.$SECTION.filter_aaaa=1"

add_server() {
    value="$1"
    current="$(uci -q get "dhcp.$SECTION.server" 2>/dev/null || true)"
    if printf "%s\n" "$current" | grep -F -x -q -- "$value"; then
        echo "Already present: $value"
    else
        uci add_list "dhcp.$SECTION.server=$value"
        echo "Added: $value"
    fi
}

echo "Adding DNS servers..."
add_server '127.0.0.1#5053'
add_server '127.0.0.1#5054'
add_server '127.0.0.1#5055'
add_server '127.0.0.1#5056'

echo "Adding domain routing rules..."
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

uci commit dhcp

echo "Restarting dnsmasq..."
/etc/init.d/dnsmasq restart

echo "Done."
echo "DNS configuration:"
uci show "dhcp.$SECTION" | grep -E "strictorder|filter_aaaa|server" || true

