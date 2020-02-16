# git 使用

#### 首次创建仓库时操作步骤
1. 初始化

```
git init
```

2. 添加一个新的远程仓库并指定一个简单的名字（一般名字指定为 origin）


```
git remote add origin https://github.com/xxx/xxx.git
```
3. 拉取远程仓库 master 分支

```
git pull origin master
```
4. 将本地的 master 分支推送到origin主机，同时指定origin为默认主机，之后就可以不加任何参数使用 git push、git pull 提交拉取数据了
```
git push -u origin master
```

#### 常用 git 命令

```
git checkout dev    # 切换到 dev 分支
git branch -a       # 查看所有分支（最好 git pull 拉取最后一次提交后使用）
```

![git 操作](https://raw.githubusercontent.com/ytxfate/Study_Notes/master/git_operate.jpg)

```
若修改已提交到远程仓库，git reset 之后使用 git push -f 提交修改
```
