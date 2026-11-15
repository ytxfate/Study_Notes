# 端口可用性探测

1. traceroute  

```
traceroute -n -T -p 27017 127.0.0.1
    -n 直接使用 IP 地址而非主机名称（禁用 DNS 反查）。
    -T 通过 TCP 探测。
    -p 探测目标端口号。
```

2. telnet  

```
telnet 127.0.0.1 27017
```
