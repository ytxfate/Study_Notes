# Tmux 常用技巧

1. 创建新会话

   ```shell
   tmux new -s {session_name}
   ```

2. 将当前会话放入后台

   快捷键	 `Ctrl` + `b`  `d`

3. 列出当前所有会话(tmux 终端外)

   ```
   tmux ls
   ```

4. 进入已有会话

   ```shell
   tmux attach -t {session_name}
   ```

5. 列出所有当前会话(tmux 终端内)

   快捷键	 `Ctrl`+`b` `s`

6.  垂直分割窗格

   快捷键	`Ctrl`+`b` `%`

7. 水平分割窗格

   快捷键	`Ctrl`+`b` `"`

8. 创建窗口(一个窗口可以有多个窗格)

   快捷键	`Ctrl`+`b` `c`

9. 在窗格间移动光标

   快捷键	`Ctrl` + `b`	{方向键}

10. 窗口切换

    上一个窗口	`Ctrl` + `b` `p`

    下一个窗口 `Ctrl`+`b` `n`

    前后两个窗口间互相切换	`Ctrl`+`b` `l`

