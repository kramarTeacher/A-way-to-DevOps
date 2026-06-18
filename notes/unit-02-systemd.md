## Ключевые выводы для дежурства

### PID 1 в современном Linux — это systemd. Раньше, примерно до середины 2010-х, на его месте чаще всего работал SysVinit (более старая система инициализации).

### "Файл systemd unit для пользовательских сервисов где?" → `/etc/systemd/system/*.service`

### "После изменения unit-файла что сделать?" → `systemctl daemon-reload`

### "Type=oneshot" → `запустился, отработал, завершился`
### "Type=notify" → `сервис сам сообщает systemd когда готов через sd_notify`
### "Type=simple" → `сервис запускается и работает постоянно (не разово)`
### "Различие After= vs Requires=" → `After задаёт **порядок**, Requires — **зависимость существования**`
### "Restart=on-failure vs always" → `on-failure только при ненулевом exit; always при любом`

### "Логи nginx за час с уровнем error" → `journalctl -u nginx --since "1 hour ago" -p err`
### "Watch логов в реальном времени" → `journalctl -u <unit> -f`

### "Что произойдёт если переименовать лог-файл, в который пишет открытый файловый дескриптор?" → `процесс продолжает писать в переименованный файл; новое имя файла остаётся пустым`
### "Как правильно ротировать логи приложения, которое держит дескриптор?" → `SIGHUP + reopen, или copytruncate, или писать в journald`

### "Restart=always — рестартует ли при нормальном exit 0?" → `да, рестартует`
### "После какого момента сервис может стартовать, если в нём After=postgresql.service?" → `только после старта postgresql, но gut не следит чтобы postgresql был живой`
### "Чем network.target отличается от network-online.target?" → `первый — сеть настроена, второй — есть реальная связь`
### "Куда cron пишет письма об ошибках?" → `/var/mail/$USER`
### "Опасность Persistent=true для частых таймеров?" → `systemd попытается догнать все пропущенные запуски`


## эксперименты

## эксперимент 1

root@dnscache:/home/eakramar# systemctl status myapp.service
● myapp.service - My app that writes to log file
     Loaded: loaded (/etc/systemd/system/myapp.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-06-10 04:56:53 UTC; 2h 18min ago
   Main PID: 4498 (python3)
      Tasks: 1 (limit: 2263)
     Memory: 5.9M (peak: 6.1M)
        CPU: 2.204s
     CGroup: /system.slice/myapp.service
             └─4498 python3 /usr/local/bin/myapp.py

Jun 10 04:56:53 dnscache systemd[1]: Started myapp.service - My app that writes to log file.

Выводы по эксперименту:

systemd-analyze critical-chain показывает цепочку зависимостей при запуске сервиса и время, которое занял каждый этап.

1. Сервис работает стабильно
active (running) — процесс жив
2h 18min — без перезапусков (нет падений)
Restart=always/on-failure не срабатывал (что хорошо — не падал)

2. Ресурсы в норме
Ресурс	   Значение	              Оценка
Память	   5.9 МБ	              Очень мало
CPU	       2.2 с за 2+ часа	      Почти не нагружает систему
Потоков	   1	                  Всё в одном процессе

3. Время старта
Запуск: 2026-06-10 04:56:53 UTC
На момент эксперимента: +2h 18min
Значит сервис стартовал при загрузке системы (до эксперимента)

4. Отсутствие ошибок
В выводе нет:
failed
error
status=
Main process exited
Только одна строка лога — успешный запуск. Это хороший признак.

## эксперимент 2

root@dnscache:/home/eakramar# systemd-analyze critical-chain myapp.service
The time when unit became active or started is printed after the "@" character.
The time the unit took to start is printed after the "+" character.

myapp.service @1d 3h 21min 52.745s
└─network-online.target @3.358s
  └─systemd-networkd-wait-online.service @1.548s +1.808s
    └─systemd-networkd.service @1.055s +487ms
      └─network-pre.target @1.047s
        └─ufw.service @1.021s +24ms
          └─local-fs.target @966ms
            └─test-b.mount @954ms +11ms
              └─systemd-fsck@dev-disk-by\x2duuid-4db74dea\x2db078\x2d48b4\x2db254\x2d85c0f0d04982.service @900ms +48ms
                └─dev-disk-by\x2duuid-4db74dea\x2db078\x2d48b4\x2db254\x2d85c0f0d04982.device @885ms

Выводы по экспереминту: 
1. Сервис был запущен 1 день 3 часа 21 минуту 52 секунды назад (от момента выполнения команды), это время активации, а не время старта

2. Цепочка зависимостей (снизу вверх)
Компонент	                            Время старта	Время выполнения	Что это
dev-disk-by...device	                885ms	        —	                Диск смонтирован
systemd-fsck@...service	                900ms	        +48ms	            Проверка файловой системы
test-b.mount	                        954ms	        +11ms	            Монтирование раздела
local-fs.target	                        966ms	        —	                Все локальные FS смонтированы
ufw.service	                            1.021s	        +24ms	            Запуск фаервола UFW
network-pre.target	                    1.047s	        —	                Подготовка сети (до сети)
systemd-networkd.service	            1.055s	        +487ms	            Запуск сетевого менеджера
systemd-networkd-wait-online.service	1.548s	        +1.808s	            Ожидание готовности сети
network-online.target	                3.358s	        —	                Сеть полностью готова
myapp.service	                        1д 3ч 21м 52с	—	                Мой сервис

3. Самый долгий этап — ожидание сети
systemd-networkd-wait-online.service: +1.808s
Сервис ждал почти 2 секунды, пока сеть поднимется.
+1.808s — это абсолютно нормально
Фактор	Объяснение
DHCP	                Если сеть настраивается через DHCP (а не статический IP), клиенту нужно: отправить запрос → получить предложение → подтвердить. Это занимает 1-2 секунды
Проверка доступности	wait-online ждёт не просто "появился интерфейс", а реальную связность (IP получен, маршруты настроены, иногда даже пинг до шлюза)
Стандартные значения	В большинстве систем эта служба занимает от 1 до 5 секунд

4. myapp.service следует настройкам After= и Wants=
Вывод подтверждает, что мой сервис действительно дождался network-online.target перед запуском.
Если убрать Wants=network-online.target, то ни чего не произойдет, но без Wants Systemd ждёт, но не запускает сам. Если network-online.target запускается другим юнитом — всё работает. Если нет — myapp.service может зависнуть в ожидании или запуститься раньше сети

5. Время запуска myapp.service = 1 день назад
Сервис стабильно работает больше суток — это хороший признак.

6. Общее время цепочки до network-online.target = ~3.36 секунд
3.358s (network-online.target) - 0s = ~3.36s

7. Если сломать файл, будет следующее:
Loaded: loaded (/etc/systemd/system/myapp.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since Thu 2026-06-18 14:30:15 MSK; 5s ago
   Duration: 1ms
    Process: 12345 ExecStart=/usr/local/bin/nonexistent_script.py (code=exited, status=203/EXEC)
   Main PID: 12345 (code=exited, status=203/EXEC)
        CPU: 1ms

Jun 18 14:30:15 dnscache systemd[1]: Started myapp.service - My app that writes to log file.
Jun 18 14:30:15 dnscache systemd[12345]: myapp.service: Failed to execute command: No such file or directory
Jun 18 14:30:15 dnscache systemd[12345]: myapp.service: Failed at step EXEC spawning /usr/local/bin/nonexistent_script.py: No such file or directory
Jun 18 14:30:15 dnscache systemd[1]: myapp.service: Main process exited, code=exited, status=203/EXEC
Jun 18 14:30:15 dnscache systemd[1]: myapp.service: Failed with result 'exit-code'.

## эксперимент 3

root@dnscache:/home/eakramar# systemctl list-dependencies myapp.service
myapp.service
● ├─system.slice
● ├─network-online.target
● │ └─systemd-networkd-wait-online.service
● └─sysinit.target
●   ├─apparmor.service
●   ├─blk-availability.service
●   ├─dev-hugepages.mount
●   ├─dev-mqueue.mount
●   ├─finalrd.service
●   ├─keyboard-setup.service
●   ├─kmod-static-nodes.service
○   ├─ldconfig.service
●   ├─lvm2-lvmpolld.socket
●   ├─lvm2-monitor.service
●   ├─multipathd.service
○   ├─open-iscsi.service
●   ├─plymouth-read-write.service
●   ├─plymouth-start.service
●   ├─proc-sys-fs-binfmt_misc.automount
●   ├─setvtrgb.service
●   ├─sys-fs-fuse-connections.mount
●   ├─sys-kernel-config.mount
●   ├─sys-kernel-debug.mount
●   ├─sys-kernel-tracing.mount
○   ├─systemd-ask-password-console.path
●   ├─systemd-binfmt.service
○   ├─systemd-firstboot.service
○   ├─systemd-hwdb-update.service
○   ├─systemd-journal-catalog-update.service
●   ├─systemd-journal-flush.service
●   ├─systemd-journald.service
○   ├─systemd-machine-id-commit.service
●   ├─systemd-modules-load.service
○   ├─systemd-pcrmachine.service
○   ├─systemd-pcrphase-sysinit.service
○   ├─systemd-pcrphase.service
○   ├─systemd-pstore.service
●   ├─systemd-random-seed.service
○   ├─systemd-repart.service
●   ├─systemd-resolved.service
●   ├─systemd-sysctl.service
○   ├─systemd-sysusers.service
●   ├─systemd-timesyncd.service
●   ├─systemd-tmpfiles-setup-dev-early.service
●   ├─systemd-tmpfiles-setup-dev.service
●   ├─systemd-tmpfiles-setup.service
○   ├─systemd-tpm2-setup-early.service
○   ├─systemd-tpm2-setup.service
●   ├─systemd-udev-trigger.service
●   ├─systemd-udevd.service
○   ├─systemd-update-done.service
●   ├─systemd-update-utmp.service
●   ├─cryptsetup.target
●   ├─integritysetup.target
●   ├─local-fs.target
●   │ ├─-.mount
○   │ ├─systemd-fsck-root.service
●   │ ├─systemd-remount-fs.service
●   │ ├─test-b.mount
●   │ ├─test-c.mount
●   │ └─test-d.mount
●   ├─swap.target
●   └─veritysetup.target

Выводы по эксперименту:

1. systemctl list-dependencies показывает все юниты, от которых зависит мой сервис (и которые зависят от него). Это полное дерево зависимостей, а не только критический путь (как в critical-chain).

2. 
Символ	Значение
●	    юнит активен (загружен и работает)
○	    юнит неактивен (не загружен/отключен)
├─	    элемент в дереве (есть продолжение)
└─	    последний элемент в ветке
─	    горизонтальная черта (продолжение линии)

3. Группы зависимостей
3.1. system.slice — группа управления
Контейнер для системных сервисов
Сервис запущен внутри этой группы (изолирован)

3.2. network-online.target — сеть
Жёсткая зависимость: сервис запустится только после готовности сети
Конкретный юнит — systemd-networkd-wait-online.service (ожидание DHCP/IP)
Это соответствует настройкам: After=network-online.target и Wants=network-online.target

3.3. sysinit.target — базовая инициализация
Самая большая группа — всё, что должно быть инициализировано до основных сервисов
Включает:
local-fs.target — все диски смонтированы (test-b.mount, test-c.mount, test-d.mount)
systemd-journald.service — система логирования
systemd-resolved.service — DNS-резолвер
systemd-timesyncd.service — синхронизация времени
apparmor.service — мандатный контроль доступа
systemd-udevd.service — управление устройствами

4. Сервис правильно ожидает сеть
myapp.service → network-online.target → systemd-networkd-wait-online.service
Мой сервис действительно не запустится раньше, чем система получит IP-адрес.

5. Все файловые системы смонтированы
local-fs.target → test-b.mount, test-c.mount, test-d.mount
Сервис видит все смонтированные разделы.

6. Много неактивных юнитов (○)
○ ldconfig.service
○ open-iscsi.service
○ systemd-firstboot.service
...
Это нормально — некоторые сервисы нужны только при первом запуске или при определённых условиях.