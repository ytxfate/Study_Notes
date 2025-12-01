
配置文件 `config.toml`, 可执行 `hx` 后 输入 `:config-open` 打开
```toml
theme = "everforest_light"

[editor]
line-number = "relative"
cursorline = true
mouse = false

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.statusline]
left = ["mode", "spinner"]
center = ["file-name"]
right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"]
# separator = "│"
mode.normal = "NORMAL"
mode.insert = "INSERT"
mode.select = "SELECT"

# [editor.whitespace]
# render = "all"
# or control each character
[editor.whitespace.render]
space = "all"
tab = "all"
newline = "none"

[editor.whitespace.characters]
space = "·"
nbsp = "⍽"
tab = "→"
newline = "⏎"
tabpad = "·" # Tabs will look like "→···" (depending on tab width)

[editor.indent-guides]
render = true
character = "╎" # Some characters that work well: "▏", "┆", "┊", "⸽"
skip-levels = 1
```

常用操作(部分操作与 `vim` 类似, 此处仅记录部分常用或差异的操作, 详情文档见[helix](https://docs.helix-editor.cn/))
```
w       移动到下一个 word 开头
W       移动到下一个 WORD 开头
b       移动到上一个 word 开头
B       移动到上一个 WORD 开头
e       移动到下一个 word 结尾
E       移动到下一个 WORD 结尾

Ctrl-u  往上翻半页
Ctrl-d  往下翻半页

Home    移动到当前行开头
gh      到当前行开头(Goto 模式)
End     移动到当前行结尾
gl      到当前行结尾(Goto 模式)

gg      输入 gng 跳转到第 n 行2；不输入数字跳转到第 1 行(Goto 模式)
ge      到最后一行(Goto 模式)

v       进入 select (extend) mode

Alt-up, Alt-o       将所选内容拓展到上一级父语法节点 (TS)
Alt-down, Alt-i     将所选内容收缩语法节点 (TS)
Alt-left, Alt-p     选择语法树中的上一个同级节点 (TS)
Alt-right, Alt-n    选择语法树中的下一个同级节点 (TS)

Alt-s       在多行选区中对每个非空行结尾放置一个光标

<space>f    打开文件选取器(Space 模式)
```

全选文本并选择行首第一个字符, 然后将整行文本替换成第一个字符(大序号下的小序号表示并列或操作)
```
1 执行 % 全选文本 (也可以执行 v 然后上下选择需要的行)
2.1 执行 Alt + s 在每个非空行结尾放置一个光标
2.2 如果想选择部分符合条件的单词然后加上光标(类似vscode Ctrl + d 命令快速选择文档中的下一个与当前选中单词相同的实例), 可在 1 的选择下执行 s 输入匹配的单词然后回车
3 执行 gh 到行开头
4.1 将光标移到第二个字符上执行 vgl , 会选中第二个字符至行尾, 然后执行 d 删除选中的字符
4.2 执行 v 进入选择模式, 选中第一个字符, 执行 y 复制, 然后执行 gh 到行首, 执行 vgl, 最后执行 R 替换
5 执行 ,(逗号) 将多光标收缩到主光标
```
