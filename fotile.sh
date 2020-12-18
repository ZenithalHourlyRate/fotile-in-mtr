#!/usr/bin/env bash

# enable echo of cmd
set -x

# full of labor work now
P=2a0c:b641:69c:fecb
ip netns add fotile1
ip netns add fotile2
ip netns add fotile3
ip netns add fotile4
ip netns add fotile5
ip netns add fotile6
ip netns exec fotile1 sysctl net.ipv6.conf.all.forwarding=1
ip netns exec fotile2 sysctl net.ipv6.conf.all.forwarding=1
ip netns exec fotile3 sysctl net.ipv6.conf.all.forwarding=1
ip netns exec fotile4 sysctl net.ipv6.conf.all.forwarding=1
ip netns exec fotile5 sysctl net.ipv6.conf.all.forwarding=1
ip netns exec fotile6 sysctl net.ipv6.conf.all.forwarding=1
ip l add veth-fotile12 netns fotile1 type veth peer veth-fotile21 netns fotile2
ip l add veth-fotile23 netns fotile2 type veth peer veth-fotile32 netns fotile3
ip l add veth-fotile34 netns fotile3 type veth peer veth-fotile43 netns fotile4
ip l add veth-fotile45 netns fotile4 type veth peer veth-fotile54 netns fotile5
ip l add veth-fotile56 netns fotile5 type veth peer veth-fotile65 netns fotile6

ip -n fotile1 l set veth-fotile12 up
ip -n fotile2 l set veth-fotile21 up
ip -n fotile2 l set veth-fotile23 up
ip -n fotile3 l set veth-fotile32 up
ip -n fotile3 l set veth-fotile34 up
ip -n fotile4 l set veth-fotile43 up
ip -n fotile4 l set veth-fotile45 up
ip -n fotile5 l set veth-fotile54 up
ip -n fotile5 l set veth-fotile56 up
ip -n fotile6 l set veth-fotile65 up

ip -n fotile1 a a $P::1/128 peer $P::2/128 dev veth-fotile12
ip -n fotile2 a a $P::2/128 peer $P::1/128 dev veth-fotile21
ip -n fotile2 a a $P::2/128 peer $P::3/128 dev veth-fotile23
ip -n fotile3 a a $P::3/128 peer $P::2/128 dev veth-fotile32
ip -n fotile3 a a $P::3/128 peer $P::4/128 dev veth-fotile34
ip -n fotile4 a a $P::4/128 peer $P::3/128 dev veth-fotile43
ip -n fotile4 a a $P::4/128 peer $P::5/128 dev veth-fotile45
ip -n fotile5 a a $P::5/128 peer $P::4/128 dev veth-fotile54
ip -n fotile5 a a $P::5/128 peer $P::6/128 dev veth-fotile56
ip -n fotile6 a a $P::6/128 peer $P::5/128 dev veth-fotile65

# sleep to wait for setup
sleep 5

ip -n fotile1 r a $P::3 via $P::2 dev veth-fotile12
ip -n fotile1 r a $P::4 via $P::2 dev veth-fotile12
ip -n fotile1 r a $P::5 via $P::2 dev veth-fotile12
ip -n fotile1 r a $P::6 via $P::2 dev veth-fotile12

ip -n fotile2 r a $P::4 via $P::3 dev veth-fotile23
ip -n fotile2 r a $P::5 via $P::3 dev veth-fotile23
ip -n fotile2 r a $P::6 via $P::3 dev veth-fotile23
ip -n fotile2 r a default via $P::1 dev veth-fotile21

ip -n fotile3 r a $P::1 via $P::2 dev veth-fotile32
ip -n fotile3 r a $P::5 via $P::4 dev veth-fotile34
ip -n fotile3 r a $P::6 via $P::4 dev veth-fotile34
ip -n fotile3 r a default via $P::2 dev veth-fotile32

ip -n fotile4 r a $P::1 via $P::3 dev veth-fotile43
ip -n fotile4 r a $P::2 via $P::3 dev veth-fotile43
ip -n fotile4 r a $P::6 via $P::5 dev veth-fotile45
ip -n fotile4 r a default via $P::3 dev veth-fotile43

ip -n fotile5 r a $P::1 via $P::4 dev veth-fotile54
ip -n fotile5 r a $P::2 via $P::4 dev veth-fotile54
ip -n fotile5 r a $P::3 via $P::4 dev veth-fotile54
ip -n fotile5 r a default via $P::4 dev veth-fotile54

ip -n fotile6 r a $P::1 via $P::5 dev veth-fotile65
ip -n fotile6 r a $P::2 via $P::5 dev veth-fotile65
ip -n fotile6 r a $P::3 via $P::5 dev veth-fotile65
ip -n fotile6 r a $P::4 via $P::5 dev veth-fotile65
ip -n fotile6 r a default via $P::5 dev veth-fotile65

# connect to the world!
# how the world connects to netns gravity, is not the concern of the script
ip l add veth-fotile netns gravity type veth peer veth-gravity netns fotile1
ip -n gravity l set veth-fotile up
ip -n fotile1 l set veth-gravity up
ip -n fotile1 a a $P::1/128 peer $P::/128 dev veth-gravity
ip -n gravity a a $P::/128 peer $P::1/128 dev veth-fotile

sleep 5

ip -n gravity r a $P::/64 via $P::1 dev veth-fotile
ip -n fotile1 r a default via $P:: dev veth-gravity

# Then you should setup PTR in your DNS
