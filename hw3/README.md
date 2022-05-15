## Task 1
### Output of nodes
```
mininet> nodes
available nodes are: 
c0 h1 h2 h3 h4 h5 h6 h7 h8 s1 s2 s3 s4 s5 s6 s7
```
### Output of net
```
mininet> net
h1 h1-eth0:s3-eth2
h2 h2-eth0:s3-eth3
h3 h3-eth0:s4-eth2
h4 h4-eth0:s4-eth3
h5 h5-eth0:s6-eth2
h6 h6-eth0:s6-eth3
h7 h7-eth0:s7-eth2
h8 h8-eth0:s7-eth3
s1 lo:  s1-eth1:s2-eth1 s1-eth2:s5-eth1
s2 lo:  s2-eth1:s1-eth1 s2-eth2:s3-eth1 s2-eth3:s4-eth1
s3 lo:  s3-eth1:s2-eth2 s3-eth2:h1-eth0 s3-eth3:h2-eth0
s4 lo:  s4-eth1:s2-eth3 s4-eth2:h3-eth0 s4-eth3:h4-eth0
s5 lo:  s5-eth1:s1-eth2 s5-eth2:s6-eth1 s5-eth3:s7-eth1
s6 lo:  s6-eth1:s5-eth2 s6-eth2:h5-eth0 s6-eth3:h6-eth0
s7 lo:  s7-eth1:s5-eth3 s7-eth2:h7-eth0 s7-eth3:h8-eth0
c0
```
### Output of h7 ifconfig
```
mininet> h7 ifconfig
h7-eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.7  netmask 255.0.0.0  broadcast 10.255.255.255
        inet6 fe80::788f:9cff:fe86:b8b6  prefixlen 64  scopeid 0x20<link>
        ether 7a:8f:9c:86:b8:b6  txqueuelen 1000  (Ethernet)
        RX packets 68  bytes 5252 (5.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 11  bytes 866 (866.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
## Task 2

### Q1
start_switch function is called initially when the topology is created with this remote controller. start_switch function creates Tutorial object for each switch.

Packet is handled in function "_handle_PacketIn" which will invoke function "act_like_hub" ("act_like_switch" is commented by default).
act_like_hub will invoke function resend_packet (with output port as OFPP_ALL, which sends it to all ports except input)
resend_packet will send the message using connection.send
_handle_PacketIn -> act_like_hub -> resend_packet -> connection.send

### Q2
#### h1 ping h2
```
100 packets transmitted, 100 received, 0% packet loss, time 99166ms
rtt min/avg/max/mdev = 1.152/2.596/3.862/0.308 ms
```
Average: 2.596 ms
Min: 1.152 ms
Max: 3.862 ms

#### h1 ping h8
```
00 packets transmitted, 100 received, 0% packet loss, time 99156ms
rtt min/avg/max/mdev = 2.650/7.964/10.768/1.422 ms
```
Average: 7.964 ms
Min: 2.650 ms
Max: 10.768 ms

#### Difference in rtt
Ping from h1 to h8 takes more time than ping from h1 to h2.
This is because h1 to h2 has less number of hops (via s3) while h1 to h8 has more number of hops (s3 -> s2 -> s1 -> s5 -> s7)

### Q3
iperf is used to measure the network bandwidth between 2 hosts.
Mininet documentation says that it returns: "two-element array of [ server, client ] speeds".
So, we can measure both uplink and downlink speeds.
http://mininet.org/api/classmininet_1_1net_1_1Mininet.html#a8e07931f87a08d793bdaefbfa5c279e7

#### iperf h1 h2
```
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['18.6 Mbits/sec', '21.5 Mbits/sec']
```
#### iperf h1 h8
```
*** Iperf: testing TCP bandwidth between h1 and h8 
*** Results: ['2.73 Mbits/sec', '3.10 Mbits/sec']
```
#### Difference in throughput
h1 and h2 has greater throughput when compared to h1 and h8. This is because h1 and h2 has less number of hops between them.

### Q4
Since all the switches are acting like a hub and forwarding packets to all ports except the input, all the switches get the same amount of traffic.
I printed the switch/connection inside the _handle_PacketIn function using:
```
print(event.connection)
```

This is a sample output, when ping was sent from h1 to h2. It shows equal traffic on all switches.
```
[00-00-00-00-00-03 5]
[00-00-00-00-00-02 6]
[00-00-00-00-00-04 2]
[00-00-00-00-00-01 3]
[00-00-00-00-00-05 7]
[00-00-00-00-00-07 1]
[00-00-00-00-00-06 4]
[00-00-00-00-00-07 1]
[00-00-00-00-00-05 7]
[00-00-00-00-00-01 3]
[00-00-00-00-00-06 4]
[00-00-00-00-00-02 6]
[00-00-00-00-00-04 2]
[00-00-00-00-00-03 5]
```

## Task 3

### Q1
The code maintains a simple in-memory map called mac_to_port (MAC address -> port no.), which tells which MAC address can be reached via which port.
Initially this map is empty.
```
self.mac_to_port = {}
```
Whenever any packet arrives at a specific port, the code checks if the source MAC is already saved in mac_to_port map.
If it is not yet saved, then it will save it in the map (Source MAC -> Input Port).
```
if packet.src not in self.mac_to_port:
  self.mac_to_port[packet.src] = packet_in.in_port
```
Now whenever it gets a packet that has a destination MAC address that is already saved in the map, it knows which port to use, instead of blindly sending to all ports.
```
if packet.dst in self.mac_to_port:
  self.resend_packet(packet_in, self.mac_to_port[packet.dst])
```
If the destination MAC address is not known then it defaults to the previous behavior of sending to all ports (except input)
```
else:
  self.resend_packet(packet_in, of.OFPP_ALL)
```

For example, in the logs below, we can see that when the packet is received from 1e:ea:cc:ba:c7:b5 via port 2, it saves it in the dictionary.
1e:ea:cc:ba:c7:b5 -> 2
But when 1e:ea:cc:ba:c7:b5 is the destination of some packet, then it knows which port to send it to, i.e., 2

```
Src:  1e:ea:cc:ba:c7:b5 : 2 Dst: ff:ff:ff:ff:ff:ff
Learning that 1e:ea:cc:ba:c7:b5 is attached at port 2
ff:ff:ff:ff:ff:ff not known, resend to everybody
Src:  2e:4c:ff:4d:38:68 : 3 Dst: 1e:ea:cc:ba:c7:b5
1e:ea:cc:ba:c7:b5 destination known. only send message to it
```

### Q2

#### h1 ping h2
```
100 packets transmitted, 100 received, 0% packet loss, time 99256ms
rtt min/avg/max/mdev = 0.808/1.689/2.463/0.437 ms
```
Average: 1.689 ms
Min: 0.808 ms
Max: 2.463 ms

#### h1 ping h8
```
100 packets transmitted, 100 received, 0% packet loss, time 99147ms
rtt min/avg/max/mdev = 2.170/5.960/8.604/1.947 ms
```
Average: 5.960 ms
Min: 2.170 ms
Max: 8.604 ms

Average rtt for both scenarios decreased when compared to Task 2, because now the switches can learn which port to use for which destination MAC address.
But note that average rtt for h1 to h8 is still relatively greater than that of h1 to h2, due to more number of hops.

### Q3
#### iperf h1 h2
```
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['83.8 Mbits/sec', '86.3 Mbits/sec']
```
#### iperf h1 h8
```
*** Iperf: testing TCP bandwidth between h1 and h8 
*** Results: ['3.16 Mbits/sec', '3.68 Mbits/sec']
```
The network bandwidth performance between h1 and h2 increased drastically when compared to Task 2. This is because the switches can now learn and send to the correct port, instead of flooding the network with duplicate packets. This results in better network utilization.
The bandwidth between h1 and h8 increased only slightly, because it still needs to travel more number of hops.
