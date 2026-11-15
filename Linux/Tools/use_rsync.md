# use rsync

1. 源目录`source`下的所有内容被完整地复制到了目标目录`destination`下面 (<font color="red">注意与2的区别</font>)

   ```bash
   rsync -av source/ destination
   ```

2. 源目录`source`被完整地复制到了目标目录`destination`下面 (`destination`目录包含`source`目录)(<font color="red">注意与1的区别</font>)

   ```bash
   rsync -av source destination
   ```

3. `--exclude` (排除)参数与`--include` (包含)参数

   ```bash
   rsync -av --exclude 'file1.txt' --exclude 'dir1/*' source/ destination
   rsync -av --exclude={'file1.txt','dir1/*'} source/ destination
   rsync -av --include="*.txt" --exclude='*' source/ destination
   ```

4. 远程同步

   ```bash
   rsync -av username@remote_host:source/ destination
   ```

