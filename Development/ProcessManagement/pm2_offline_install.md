
pm2 离线安装

> node 与 pm2 版本可以先在有网环境下先测试一遍, 防止版本不兼容
#### 1 安装 node
从 [node](https://nodejs.org/) 官网下载相应版本, 本次测试使用 `node-v22.21.0` , 将安装包解压后配置环境变量 `PATH`
#### 2 安装 pm2
1. 从 [pm2](https://github.com/Unitech/pm2/releases) github 网站下载相应版本(==需要解压后执行 `npm install` 安装依赖==), 本次测试使用 `pm2-6.0.13`, 将压缩包解压后配置环境变量 `PATH`
2. 在适当的目录创建 pm2_home , 并配置环境变量 `PM2_HOME`, 默认 PM2_HOME 使用的是 `/home/{user}/.pm2` 目录
```bash
export PM2_HOME=.../pm2_home
```
#### 2 安装 pm2-logrotate
需使用有网络的机器执行 `pm2 install pm2-logrotate` 后打包其 `PM2_HOME/modules` 里的 `pm2-logrotate` 目录以及 `PM2_HOME/module_conf.json` 文件, 然后传到要部署 `pm2` 的机器, 分别解压到 `PM2_HOME` 的对应目录下
```json
{
    "pm2-logrotate": {
        "max_size": "100M",
        "retain": "30",
        "compress": false,
        "dateFormat": "YYYY-MM-DD_HH-mm-ss",
        "workerInterval": "30",
        "rotateInterval": "0 0 * * *",
        "rotateModule": true
    },
    "module-db-v2": {
        "pm2-logrotate": {}
    }
}
```
后续使用下列命令修改配置
```bash
pm2 set pm2-logrotate:max_size 100M
pm2 set pm2-logrotate:retain 10
pm2 set pm2-logrotate:compress true
pm2 set pm2-logrotate:max_size 1M
```
