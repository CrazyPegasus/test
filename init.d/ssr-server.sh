#!/bin/sh /etc/rc.common
#
# Copyright (C) 2014 Justin Liu <rssnsj@gmail.com>
# https://github.com/rssnsj/network-feeds
#

START=99

SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

SSR_CONF=/tmp/shadowsocksr-server.json
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

cp /etc/shadowsocksr-server.json /tmp/
start()
{
	local ssr_enabled=`uci get ssr-config.@server_config[0].enable 2>/dev/null`
	local ssr_server_addr=`uci get ssr-config.@server_config[0].server 2>/dev/null`
        local ssr_server_ipv6=`uci get ssr-config.@server_config[0].server_ipv6 2>/dev/null`
	local ssr_server_port=`uci get ssr-config.@server_config[0].server_port 2>/dev/null`
	local ssr_password=`uci get ssr-config.@server_config[0].password 2>/dev/null`
	local ssr_encrypt_method=`uci get ssr-config.@server_config[0].encrypt_method 2>/dev/null`
        local ssr_timeout=`uci get ssr-config.@server_config[0].timeout 2>/dev/null`
	local ssr_protocol=`uci get ssr-config.@server_config[0].protocol 2>/dev/null`
        local ssr_protocol_param=`uci get ssr-config.@server_config[0].protocol_param 2>/dev/null`
	local ssr_obfs=`uci get ssr-config.@server_config[0].obfs 2>/dev/null`
	local ssr_obfs_param=`uci get ssr-config.@server_config[0].obfs_param 2>/dev/null`
        local ssr_redirect=`uci get ssr-config.@server_config[0].redirect 2>/dev/null`
	local ssr_dns_ipv6=`uci get ssr-config.@server_config[0].dns_ipv6 2>/dev/null`
        local ssr_fast_open=`uci get ssr-config.@server_config[0].fast_open 2>/dev/null`
        #local ssr_local_address=`uci get ssr-config.@server_config[0].local_address 2>/dev/null`
        #local ssr_local_port=`uci get ssr-config.@server_config[0].local_port 2>/dev/null`
	# -----------------------------------------------------------------
	if [ "$ssr_enabled" = 0 ]; then
		echo "WARNING: Shadowsocksr is disabled."
		return 1
	fi  

        if [ "$ssr_fast_open" = "1" ] ;then
         fastopen="true";
        else
         fastopen="false";
        fi
        
        if [ "$ssr_dns_ipv6" = "1" ] ;then
         dnsv6="true";
        else
         dnsv6="false";
        fi
	
	cat > $SSR_CONF <<EOF
{
    "server": "$ssr_server_addr",
    "server_ipv6": "$ssr_server_ipv6",
    "server_port": $ssr_server_port,
    "password": "$ssr_password",
    "method": "$ssr_encrypt_method",
    "timeout": $ssr_timeout,
    "protocol": "$ssr_protocol",
    "protocol_param": "$ssr_protocol_param",
    "obfs": "$ssr_obfs",
    "obfs_param": "$ssr_obfs_param",
    "redirect": "$ssr_redirect",
    "dns_ipv6": $dnsv6 ,
    "fast_open": $fastopen 
}
EOF


	service_start /usr/bin/ssr-server -c $SSR_CONF -u 
}

stop() {
  rm -rf /tmp/shadowsocksr-server.json	
  service_stop /usr/bin/ssr-server
}
