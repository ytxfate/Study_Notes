# 多用户使用 git

##### 1.新建SSH key  
```
cd ~/.ssh   (C:\Users\Administrator\.ssh)  
ssh-keygen -t rsa -C "youremail@example.com"  # 新建工作的SSH key
设置名称为id_rsa_github     # 名字随意
```

##### 2.添加新密钥到SSH agent
```
ssh-add ~/.ssh/id_rsa_github
```
如果出现Could not open a connection to your authentication agent  
3种解决方法：
```
（a) 先输入ssh-agent bash，然后再输入ssh-add ~/.ssh/id_rsa_github
（b）先输入eval $(ssh-agent)，然后输入ssh-add ~/.ssh/id_rsa_github
（c）使用Git GUI生成密钥，密钥会自动被加进ssh-agent中
```

##### 3.修改config文件  
若~/.ssh/目录下不存在config文件，则新建一个，内容如下：
```
#github  --- github
Host github.com
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_github_rsa
    User github
```
Host host简称，使用命令ssh host可连接远程服务器 (如：ssh github)  
HostName 主机名用ip或域名，建议使用域名 (如:github.com)  
PreferredAuthentications 配置登录时用什么权限认证--可设为publickey,password publickey,keyboard-interactive等  
IdentityFile 证书文件路径 （如~/.ssh/id_rsa_*)  
User 登录用户名 (如：test/test@qq.com)  
Port 服务器open-ssh端口 (默认：22,默认时一般不写此行) 

##### 4.添加新密钥到Git远程仓库  
把~/.ssh/id_rsa_github.pub的内容添加到Github的SSH keys中

##### 5.测试
```
ssh -T git@github.com
```
若出现Bad owner or permissions on /home/ytx/.ssh/config，修改config文件权限
```
chmod 600 config
```
