## Ключевые выводы для дежурства

### Hard vs Symlink
- Hard link = второе имя того же inode (один файл, два пути)
- Symlink = отдельный файл с записанным путём
- Hard нельзя на директории и через границы ФС
- Symlink ломается при удалении оригинала (становится dangling)
- Проверка: `ls -li` → одинаковый inode + link count 2 = это hardlinks

### df vs du
- df: занятое на ФС (через ядро, statvfs)
- du: сумма размеров файлов (через stat)
- Page cache в RAM не виден ни тем ни другим
- Расхождение df > du = почти всегда удалённые открытые файлы
- Найти: `lsof | grep deleted`
- Починить: рестарт держащего процесса systemctl restart app, либо kill -HUP <pid> (если приложение поддерживает reopen логов), или > /proc/<pid>/fd/<N> (агрессивно — обнулить файл через файловый дескриптор).

### Поиск больших жирных файлов
- `du -h --max-depth=1 / 2>/dev/null | sort -h`
- `ncdu /` (если установлен — быстрее и интерактивно)

### Топ процессов
- По памяти: `ps aux --sort=-%mem | head`
- По CPU: `ps aux --sort=-%cpu | head`
- Интерактивно: `htop` (F6 — выбор сортировки)

### lsof — что я могу делать с ним
- Кто держит порт: `lsof -i :443`
- Кто держит файл: `lsof /path/to/file`
- Удалённые открытые: `lsof | grep deleted`
- Что открыл процесс: `lsof -p <pid>`

## эксперимент с hard/symlink
root@dnscache:/tmp/hlinkvsslink# echo "hello" > original.txt
root@dnscache:/tmp/hlinkvsslink# ln original.txt hard.txt
root@dnscache:/tmp/hlinkvsslink# ln -s original.txt sym.txt
root@dnscache:/tmp/hlinkvsslink# cat original.txt hard.txt sym.txt 
hello
hello
hello
root@dnscache:/tmp/hlinkvsslink# 
root@dnscache:/tmp/hlinkvsslink# ls -li
total 8
262168 -rw-r--r-- 2 root root  6 May  9 03:59 hard.txt
262168 -rw-r--r-- 2 root root  6 May  9 03:59 original.txt
262169 lrwxrwxrwx 1 root root 12 May  9 04:00 sym.txt -> original.txt
root@dnscache:/tmp/hlinkvsslink# rm original.txt 
root@dnscache:/tmp/hlinkvsslink# cat hard.txt 
hello
root@dnscache:/tmp/hlinkvsslink# cat sym.txt 
cat: sym.txt: No such file or directory
root@dnscache:/tmp/hlinkvsslink# ls -li 
total 4
262168 -rw-r--r-- 1 root root  6 May  9 03:59 hard.txt
262169 lrwxrwxrwx 1 root root 12 May  9 04:00 sym.txt -> original.txt
root@dnscache:/tmp/hlinkvsslink# 

Вывод: по итогам эксперимента видно, что в терминале строка "sym.txt -> original.txt" выделена красным, что свидетельствует о том, что символическая ссылка ссылается на несуществующий файл, а так же это ясно исходя из команды: "root@dnscache:/tmp/hlinkvsslink# cat sym.txt -> cat: sym.txt: No such file or directory". Но, зато жесткая ссылка работает даже после удаления оригинала, так как, это не просто файл с указанием на оригинал, а это второе имя того же inode, о чем свидетельствует так же, такой же идентификатор inode и количество ссылок (2 ссылки).

## эксперимент с page cache

root@dnscache:/tmp# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        25G  5.4G   18G  23% /
root@dnscache:/tmp# free -h
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       320Mi       1.5Gi       1.1Mi       227Mi       1.6Gi
Swap:             0B          0B          0B
root@dnscache:/tmp# dd if=/dev/urandom of=/tmp/bigfile bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 3.15227 s, 341 MB/s
root@dnscache:/tmp# cat /tmp/bigfile > /dev/null
root@dnscache:/tmp# cat /tmp/bigfile > /dev/null
root@dnscache:/tmp# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        25G  6.4G   17G  28% /
root@dnscache:/tmp# free -h
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       346Mi       503Mi       1.1Mi       1.3Gi       1.6Gi
Swap:             0B          0B          0B
root@dnscache:/tmp# du -sh /tmp/bigfile 
1.1G	/tmp/bigfile
root@dnscache:/tmp# sync && echo 3 > /proc/sys/vm/drop_caches
root@dnscache:/tmp# free -h
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       274Mi       1.7Gi       1.1Mi        67Mi       1.7Gi
Swap:             0B          0B          0B
root@dnscache:/tmp# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        25G  6.4G   17G  28% /
root@dnscache:/tmp# du -sh /tmp/bigfile 
1.1G	/tmp/bigfile
root@dnscache:/tmp# rm /tmp/bigfile 
root@dnscache:/tmp# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        25G  5.4G   18G  23% /
root@dnscache:/tmp# 

Вывод: по итогам эксперимента видно, что кеш в RAM не как не связан с командами du и df, так как, при очистке кэша команды df и du показывали теже данные, что и были. Это объясняется тем, что команды du и df показываеют данные по ФС и разделам, а не RAM.

## эксперимент с deleted files

1 терминал:
root@dnscache:/tmp/deletefiles# touch test.log
root@dnscache:/tmp/deletefiles# tail -f test.log &
[1] 3040
root@dnscache:/tmp/deletefiles# df /
Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/sda2       25623780 5563688  18733144  23% /
root@dnscache:/tmp/deletefiles# du -sh /tmp/deletefiles/
4.0K	/tmp/deletefiles/
root@dnscache:/tmp/deletefiles# lsof | grep deleted
tail      3040                            root    3r      REG                8,2        0     262172 /tmp/deletefiles/test.log (deleted)
root@dnscache:/tmp/deletefiles# 

2 терминал:
root@dnscache:/tmp/deletefiles# rm test.log
root@dnscache:/tmp/deletefiles# 

Вывод: по итогам эксперимента видно, что процесс tail держит память под файл /tmp/deletefiles/test.log, даже при его удалении.