nmcli connection show   #显示当前网络连接
输出：
    NAME UUID                                 TYPE           DEVICE
    eno1 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03 802-3-ethernet eno1

nmcli con mod eno1 ipv4.dns "114.114.114.114"

#将dns配置生效
nmcli con up eno1
