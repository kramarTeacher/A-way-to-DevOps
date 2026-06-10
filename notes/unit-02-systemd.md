## Ключевые выводы для дежурства

### PID 1 в современном Linux — это systemd. Раньше, примерно до середины 2010-х, на его месте чаще всего работал SysVinit (более старая система инициализации).

### "Файл systemd unit для пользовательских сервисов где?" → `/etc/systemd/system/*.service`

### "После изменения unit-файла что сделать?" → `systemctl daemon-reload`

### "Type=oneshot" → запустился, отработал, завершился
### "Type=notify" → сервис сам сообщает systemd когда готов через sd_notify
### "Type=simple" → сервис запускается и работает постоянно (не разово)
### "Различие After= vs Requires=" → After задаёт **порядок**, Requires — **зависимость существования**
### "Restart=on-failure vs always" → on-failure только при ненулевом exit; always при любом

### "Логи nginx за час с уровнем error" → `journalctl -u nginx --since "1 hour ago" -p err`
### "Watch логов в реальном времени" → `journalctl -u <unit> -f`


## эксперименты

### Эксперименты не проводил