# Mac下terminal的关机/重启/休眠

在mac终端中，需要使用对电脑关机，重启，睡眠的操作。对应的参数是-h，-r，-s。

而定时对电脑设置关机，重启，睡眠则使用如下格式命令 `sudo shutdown -h yymmddhhmm`即可，其中的参数可替换

1. 关机

		sudo shutdown -h 1707111250 #2017年07月11日12点50分关机

2. 重启

		sudo shutdown -r 1707111250 #2017年07月11日12点50分重启
	
3. 睡眠

		sudo shutdown -s 1707111250 #2017年07月11日12点50分睡眠
	
除此之外，还可以使用参数now来代替时间，表示立即关机，重启，睡眠等。如下

	sudo shutdown -h now #更换参数，立即关机，重启，睡眠
	
## 取消定时
	
设置定时，如下
	
	➜  ~ sudo shutdown -h 1707111200
	Password:
	Shutdown at Tue Jul 11 12:00:00 2017.
	shutdown: [pid 653]
                                                                                                    
	*** System shutdown message from pingjunlin@pingjundeMacBook-Pro.local ***   
	System going down in 6 minutes   
	
上文，[pid 653]为当前的进程号，需要关闭该进程，则可以终止自动关机。

	sudo kill 653
