
>[!note] 说明：
>本次安装使用 `VMware-Workstation-Full-16.2.5`
>安装环境为 `Debain 12`

### 安装包
官网下载 `VMware Workstation` `linux`版安装包

### 安装
1. 文件添加执行权限
	`chmod +x VMware-Workstation-Full-16.2.5-20904516.x86_64.bundle`
2. 执行脚本
	`sudo ./VMware-Workstation-Full-16.2.5-20904516.x86_64.bundle`

### 其他安装
1. 安装 `linux-headers`
	`sudo apt install linux-headers-$(uname -r)`
2. 安装 `host modules`
	1. `git clone https://github.com/mkubecek/vmware-host-modules`
	2. 根据 `VMware` 版本切换对应分支 `git switch workstation-16.2.5`  
	3. 编译安装 `make && sudo make install`

> 可执行 `sudo /etc/init.d/vmware start` 检查各模块是否正常


>[!warning] 说明：
>创建 `win7` 虚拟机后需要先安装
>`windows6.1-kb4474419-v3-x64_b5614c6cea5cb4e198717789633dca16308ef79c.msu` 
>才能安装 `VMware Tools`
>其次需要将虚拟机设置中的软盘设置修改为自动检测才能安装`VMware Tools`,安装完成记得将配置还原
![[_Files/VMware_win7_floppy_setting.png]]
