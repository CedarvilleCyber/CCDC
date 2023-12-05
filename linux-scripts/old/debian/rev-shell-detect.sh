#!/bin/bash

apt-get install silversearcher-ag
yum install the_silver_searcher

# This can't find them all, but it can find some...

ag -Us --hidden -A 3 -B 3 "nc -e|/dev/tcp/|/dev/udp/|mkfifo| -e /bin/sh| -e /bin/bash| -e /bin/zsh| -e /bin/dash|-e bash| -e sh| -e zsh| -e dash|nc -c |ncat -e |netcat -e |rcat -r | -r sh| -r bash| -r zsh| -r /bin/sh| -r /bin/bash| -r /bin/zsh| -r /bin/dash|AF_INET, SOCK_STREAM,|AF_INET,SOCK_STREAM,|PF_INET, SOCK_STREAM,|PF_INET,SOCK_STREAM,|new TcpClient|reverse shell|reverseshell|bind shell|STDIN->fdopen($c,r);|STDIN->fdopen($c, r);|fsockopen\(|fsockopen \(|pty.spawn\(|pty.spawn \(|TCPSocket.new\(|TCPSocket.new \(|UDPSocket.new\(|UDPSocket.new \(|socat |LEGO|cp.spawn\(|cp.spawn \(|bash -i|new java.net.Socket|redirectErrorStream|zmodload zsh/net/|socket.tcp|socket.udp|exec.Command|Socket.connect\(|Socket.connect \(|/inet/tcp/0/|SO_REUSEADDR|msfvenom|%2fbin%2fbash|%2fbin%2fsh|%2fbin%2fzsh|%2fbin%2fdash|bmMgLW|5jIC1l|uYyAtZW|iYXNo|YmFza|Jhc2h" / 2>/dev/null > ./dataFiles/ag-results.data 

cat ./dataFiles/ag-results.data | ag -Us "([0-9]{1,3}[\.]){3}[0-9]{1,3}"

exit 0
