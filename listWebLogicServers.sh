#!/bin/bash
# ---------------------------------------------------------------------------
# listWebLogicServers.sh - List running WebLogic Servers and Node Managers
# Peter Lorenzen
# Version 0.9
# ---------------------------------------------------------------------------

DOMAIN_DIRECTORY="domains"

echo "################################################################################"
echo "# WebLogic Servers"
echo "# <owner>  <domain>  <server>  <pid>  <ports>"
echo "################################################################################"
ps -ef | grep "[D]weblogic.Name="|while read tmp
do
  owner=`echo $tmp | awk '{ print $1 }'`
  webLogicServer=`echo $tmp | grep -oP "(?<=Dweblogic.Name=)[^ ]+"`
  pid=`echo $tmp | awk '{ print $2 }'`
  port=`echo $tmp | netstat -tlpn 2>/dev/null | grep $pid | awk '{ print $4 }' | tr '\n' ',' | tr ' ' ',' | grep -o ":....," | sort -u | tr -d '\n' | tr -d ':' | sed 's/,$//'`
  if [ -z "$port" ]; then
    port="null"
  fi
  domain=`echo $tmp | grep -oP "(?<=BootIdentityFile=)[^ ]+"`
  domain=`echo $domain | grep -oP "(?<=$DOMAIN_DIRECTORY/)[^ ]+" | cut -d/ -f1`
  if [ -n "$1" ]; then
    echo "$owner $domain $webLogicServer $pid $port kill -9 $pid"
  else  
    echo "$owner $domain $webLogicServer $pid $port"
  fi
done|sort|column -t

echo
echo "################################################################################"
echo "# Node Managers"
echo "# <owner>  <mw_home>  <pid>  <port>"
echo "################################################################################"
ps -ef | grep "[w]eblogic.NodeManager"|while read tmp
do
  owner=`echo $tmp | awk '{ print $1 }'`
  pid=`echo $tmp | awk '{ print $2 }'`
  port=`echo $tmp | netstat -tlpn 2>/dev/null | grep $pid | awk '{ print $4 }' | tr '\n' ',' | tr ' ' ',' | grep -o ":....," | sort -u | tr -d '\n' | tr -d ':' | sed 's/,$//'`
  if [ -z "$port" ]; then
    port="null"
  fi
  mw_home=`echo $tmp | grep -oP "(?<=bea.home=)[^ ]+"`
  if [ -n "$1" ]; then
    echo "$owner $mw_home $pid $port kill -9 $pid"
  else  
    echo "$owner $mw_home $pid $port"
  fi
done|sort|column -t
