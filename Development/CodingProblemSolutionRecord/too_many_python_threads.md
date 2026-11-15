
>[!Warning] 场景不同时本示例可能有差异

# Python 线程数过多排查
#### 问题描述
> `python3 -u main.py` 为 `fastapi` 接口后台服务
```bash
> ps -aux | grep "python3 -u main.py"
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
xxx      12468  9.3  0.1  42780 21856 pts/2    S+   08:43   0:04 python3 -u main.py

> ps -eLf | grep 12468 | wc -l
285
```

#### 排查步骤
> 使用 `gdb` 工具进行调试
1. 查询具体那个`PID`启动了大量线程
```bash
> ps -eLf | grep 12468 | tail -n 10
UID        PID  PPID   LWP  C NLWP STIME TTY          TIME CMD
xxx      12470 12468 13490  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13492  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13493  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13496  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13497  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13500  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13501  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13504  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
xxx      12470 12468 13505  0  285 08:43 pts/2    00:00:00 python3 -c from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=6, pipe_handle=8) --multiprocessing-fork
```
根据`NLWP`列也可以看出该`PID`启动了285个线程
2. `gdb`准备
注: `gdb`版本是>=7，gdb从版本7开始支持对`Python`的`debug`
由于`gdb`看到的是`C`栈, 需使用`python`扩展来查看`python`代码栈;
从`https://github.com/python/cpython/blob/v3.7.9/Tools/gdb/libpython.py`下载`libpython.py`文件, 其中`v3.7.9`为`Python`的版本
安装`gdb`及`python-gdbm`
```
sudo apt-get install gdb python-gdbm
```
3. `gdb`调试
执行以下命令进如`gdb`调试, 注意需要使用`root`权限才行
```bash
sudo gdb -p 12470
```
依次执行以下命令,加载`libpython.py`, `path_to_libpython_dir`为`libpython.py`所在的目录
```bash
(gdb) python
>import sys
>sys.path.insert(0, "path_to_libpython_dir")
>import libpython
>end
(gdb) 
```
执行`info threads`也可以看到该进程包含大量线程
```bash
(gdb) info threads
  Id   Target Id         Frame 
* 1    Thread 0x7f4865ee5740 (LWP 12470) "python3" 0x00007f48657f5947 in epoll_wait (epfd=8, 
    events=events@entry=0x7ffd0fe06670, maxevents=maxevents@entry=1024, timeout=timeout@entry=100)
    at ../sysdeps/unix/sysv/linux/epoll_wait.c:30
  2    Thread 0x7f4861dc7700 (LWP 12481) "python3" 0x00007f48657ead1f in __GI___select (nfds=0, 
    readfds=0x0, writefds=0x0, exceptfds=0x0, timeout=0x7f4861dc6620)
    at ../sysdeps/unix/sysv/linux/select.c:41
  3    Thread 0x7f48615c6700 (LWP 12482) "python3" 0x00007f48657ead1f in __GI___select (nfds=0, 
    readfds=0x0, writefds=0x0, exceptfds=0x0, timeout=0x7f48615c5620)
    at ../sysdeps/unix/sysv/linux/select.c:41
  4    Thread 0x7f486097c700 (LWP 12485) "python3" 0x00007f48657ead1f in __GI___select (nfds=0, 
    readfds=0x0, writefds=0x0, exceptfds=0x0, timeout=0x7f486097b620)
    at ../sysdeps/unix/sysv/linux/select.c:41
  5    Thread 0x7f4853fff700 (LWP 12486) "python3" 0x00007f48657ead1f in __GI___select (nfds=0, 
    readfds=0x0, writefds=0x0, exceptfds=0x0, timeout=0x7f4853ffe620)
    at ../sysdeps/unix/sysv/linux/select.c:41
  6    Thread 0x7f48537fe700 (LWP 12489) "python3" 0x00007f48657ead1f in __GI___select (nfds=0, 
    readfds=0x0, writefds=0x0, exceptfds=0x0, timeout=0x7f48537fd620)
    at ../sysdeps/unix/sysv/linux/select.c:41
  7    Thread 0x7f4852ffd700 (LWP 12490) "python3" 0x00007f48657ead1f in __GI___select (nfds=0, 
    readfds=0x0, writefds=0x0, exceptfds=0x0, timeout=0x7f4852ffc620)
    at ../sysdeps/unix/sysv/linux/select.c:41
```
星号开头的列为当前选中的线程
执行`thread Id`选中线程, 使用`py-up`和`py-down`可上下移动栈的位置, 多查看几个线程
```bash
(gdb) thread 2
[Switching to thread 2 (Thread 0x7f4861dc7700 (LWP 12481))]
#0  0x00007f48657ead1f in __GI___select (nfds=0, readfds=0x0, writefds=0x0, exceptfds=0x0, 
    timeout=0x7f4861dc6620) at ../sysdeps/unix/sysv/linux/select.c:41
41      ../sysdeps/unix/sysv/linux/select.c: 没有那个文件或目录.
(gdb) py-up
#6 Frame 0x7f4863e04450, for file .../lib/python3.7/site-packages/pymongo/periodic_executor.py, line 140, in _run (self=<PeriodicExecutor(_event=False, _interval=10, _min_interval=<float at remote 0x7f4862c92b30>, _target=<function at remote 0x7f4861e30b00>, _stopped=False, _thread=<weakproxy at remote 0x7f4861ec2890>, _name='pymongo_server_monitor_thread', _skip_sleep=False, _thread_will_exit=False, _lock=<_thread.lock at remote 0x7f4861eb5b70>) at remote 0x7f4861e3f2d0>, deadline=<float at remote 0x7f481004b8b0>)
    time.sleep(self._min_interval)
(gdb) py-up
#12 (frame information optimized out)
(gdb) thread 3
[Switching to thread 3 (Thread 0x7f48615c6700 (LWP 12482))]
#0  0x00007f48657ead1f in __GI___select (nfds=0, readfds=0x0, writefds=0x0, exceptfds=0x0, 
    timeout=0x7f48615c5620) at ../sysdeps/unix/sysv/linux/select.c:41
41      ../sysdeps/unix/sysv/linux/select.c: 没有那个文件或目录.
(gdb) py-up
#6 Frame 0x7f4863e04c50, for file .../lib/python3.7/site-packages/pymongo/periodic_executor.py, line 140, in _run (self=<PeriodicExecutor(_event=False, _interval=1, _min_interval=<float at remote 0x7f4862b6df50>, _target=<function at remote 0x7f4861e30b90>, _stopped=False, _thread=<weakproxy at remote 0x7f4861ec2710>, _name='pymongo_kill_cursors_thread', _skip_sleep=False, _thread_will_exit=False, _lock=<_thread.lock at remote 0x7f4861eb5990>) at remote 0x7f4861e38510>, deadline=<float at remote 0x7f483060c110>)
    time.sleep(self._min_interval)
(gdb) py-up
#12 (frame information optimized out)
(gdb) thread 4
[Switching to thread 4 (Thread 0x7f486097c700 (LWP 12485))]
#0  0x00007f48657ead1f in __GI___select (nfds=0, readfds=0x0, writefds=0x0, exceptfds=0x0, 
    timeout=0x7f486097b620) at ../sysdeps/unix/sysv/linux/select.c:41
41      in ../sysdeps/unix/sysv/linux/select.c
(gdb) py-up
#6 Frame 0x7f4860a18a50, for file .../lib/python3.7/site-packages/pymongo/periodic_executor.py, line 140, in _run (self=<PeriodicExecutor(_event=False, _interval=10, _min_interval=<float at remote 0x7f4862c92b30>, _target=<function at remote 0x7f48609890e0>, _stopped=False, _thread=<weakproxy at remote 0x7f4860a3c7d0>, _name='pymongo_server_monitor_thread', _skip_sleep=False, _thread_will_exit=False, _lock=<_thread.lock at remote 0x7f4860a35db0>) at remote 0x7f48609f6ad0>, deadline=<float at remote 0x7f4860a26dd0>)
    time.sleep(self._min_interval)
(gdb) py-up
#12 (frame information optimized out)
(gdb) thread 5
[Switching to thread 5 (Thread 0x7f4853fff700 (LWP 12486))]
#0  0x00007f48657ead1f in __GI___select (nfds=0, readfds=0x0, writefds=0x0, exceptfds=0x0, 
    timeout=0x7f4853ffe620) at ../sysdeps/unix/sysv/linux/select.c:41
41      in ../sysdeps/unix/sysv/linux/select.c
(gdb) py-up
#6 Frame 0x7f486098f050, for file .../lib/python3.7/site-packages/pymongo/periodic_executor.py, line 140, in _run (self=<PeriodicExecutor(_event=False, _interval=1, _min_interval=<float at remote 0x7f4862b6df50>, _target=<function at remote 0x7f4860989050>, _stopped=False, _thread=<weakproxy at remote 0x7f48609becb0>, _name='pymongo_kill_cursors_thread', _skip_sleep=False, _thread_will_exit=False, _lock=<_thread.lock at remote 0x7f4860a35bd0>) at remote 0x7f48609c2f90>, deadline=<float at remote 0x7f47f0589a10>)
    time.sleep(self._min_interval)
(gdb) py-up
#12 (frame information optimized out)
```
根据`py-up`的输出可以看到线程基本都停在了`.../lib/python3.7/site-packages/pymongo/periodic_executor.py, line 140`这里,查看该文件如下:
```
 24 class PeriodicExecutor(object):
 25     def __init__(self, interval, min_interval, target, name=None):
 26         """"Run a target function periodically on a background thread.
 27 
 28         If the target's return value is false, the executor stops.
 29 
 30         :Parameters:
 31           - `interval`: Seconds between calls to `target`.
 32           - `min_interval`: Minimum seconds between calls if `wake` is
 33             called very often.
 34           - `target`: A function.
 35           - `name`: A name to give the underlying thread.
 36         """
...
135             if self._skip_sleep:
136                 self._skip_sleep = False
137             else:
138                 deadline = _time() + self._interval
139                 while not self._stopped and _time() < deadline:
140                     time.sleep(self._min_interval)
141                     if self._event:
142                         break  # Early wake.
143 
144             self._event = False
```
发现线程全部停在`time.sleep(self._min_interval)`这里, 根据`__init__()`方法里的文档, 可以看出是`pymongo`启动了一个后台线程定时监控`target`状态, 按`Ctrl`键点击`PeriodicExecutor`, 可以看到有几个调用的地方, 依次排查是哪里使用了
![[too_many_python_threads_PeriodicExecutor.png]]
点进右边第一个`mongo_client.py`, 可以看到是在`pymongo`连接的时候启动了这个监控, 然后查看项目代码发现`mongodb`连接代码有问题,每次获取`Database`时都连接了一次`mongodb`
![[too_many_python_threads_conn_mongodb.png]]
根据问题, 调整`conn_mongodb`逻辑, 仅在初始化是连接一次数据库, 参考实例如下:
![[too_many_python_threads_get_conn_and_db.png]]
修改后, 重新启动项目, 检查进程的线程数
```bash
> ps -aux | grep "python3 -u main.py"
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
xxx      12468  9.5  0.1  42780 21920 pts/2    S+   08:43   7:19 python3 -u main.py
> ps -eLf | grep 12468 | wc -l
7
```
可以看到线程数大量减少, 推断`conn_mongodb`导致的本次异常
