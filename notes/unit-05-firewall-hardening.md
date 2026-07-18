# Ключевые выводы для дежурства

## 1. Netfilter — основы

### [Netfilter] Что такое netfilter - `Фреймворк в ядре Linux с набором hooks для обработки сетевых пакетов, предоставляет только инфраструктуру, а не логику фильтрации`
### [Netfilter] Пять основных hooks - `prerouting, input, forward, output, postrouting`
### [Netfilter] Где живут хуки в сетевом стеке - `prerouting (после приёма пакета), input (для локально адресованных), forward (транзитные), output (локально сгенерированные), postrouting (перед отправкой)`
### [Netfilter] Что цепляется к хукам - `Разные подсистемы: ip_tables (старая), nf_tables (новая), conntrack, NAT, bridge filter, IPVS`
### [Netfilter] Где посмотреть packet flow диаграмму - `Wikipedia: File:Netfilter-packet-flow.svg`

## 2. nftables — базовые концепции

### [nftables] Что такое nftables - `Современная подсистема ядра Linux для правил файрвола, пришла на смену ip_tables с 2014 года (ядро 3.13)`
### [nftables] Утилита для управления - `nft`
### [nftables] Что такое table (таблица) - `Верхнеуровневый контейнер для правил, определяется семейством (family) и именем`
### [nftables] Семейства (families) - `ip (только IPv4), ip6 (только IPv6), inet (v4+v6), bridge, arp, netdev`
### [nftables] Что даёт семейство inet - `Работает одновременно для IPv4 и IPv6, не нужно дублировать правила`
### [nftables] Стандартные имена таблиц - `filter, nat, mangle, raw (это конвенция, не жёсткое требование)`
### [nftables] Роль таблицы filter - `Фильтрация: пропустить (accept) или дропнуть (drop) пакет`
### [nftables] Роль таблицы nat - `Трансляция адресов и портов (SNAT, DNAT, MASQUERADE, REDIRECT)`
### [nftables] Роль таблицы mangle - `Модификация полей пакета: TTL, DSCP, marks`
### [nftables] Роль таблицы raw - `Работа до conntrack (notrack, ct helper, ct zone)`
### [nftables] Приоритеты стандартных хуков - `raw: -300, mangle: -150, nat prerouting: -100, filter: 0, nat postrouting: +100`
### [nftables] Почему raw имеет priority -300 - `Работает раньше всех остальных, до создания записи в conntrack`
### [nftables] iif — что это - `input interface, через какой интерфейс пакет пришёл (аналог -i в iptables)`
### [nftables] oif — что это - `output interface, через какой интерфейс пакет уйдёт (аналог -o в iptables)`
### [nftables] Просмотр всех правил - `sudo nft list ruleset`
### [nftables] Полная очистка всех правил - `sudo nft flush ruleset`
### [nftables] Применить конфиг - `sudo nft -f /etc/nftables.conf`
### [nftables] Проверить синтаксис без применения - `sudo nft -c -f /etc/nftables.conf`
### [nftables] Стандартный конфиг для автозагрузки - `/etc/nftables.conf, применяется через systemd-юнит nftables.service`

## 3. iptables vs nftables — миграция

### [iptables→nftables] `-i eth0` в nftables - `iif "eth0"`
### [iptables→nftables] `-o eth0` в nftables - `oif "eth0"`
### [iptables→nftables] `-s 10.0.0.1` в nftables - `ip saddr 10.0.0.1`
### [iptables→nftables] `-d 10.0.0.1` в nftables - `ip daddr 10.0.0.1`
### [iptables→nftables] `-p tcp --dport 22` в nftables - `tcp dport 22`
### [iptables→nftables] `-m state --state ESTABLISHED` в nftables - `ct state established`
### [iptables→nftables] `-j ACCEPT` в nftables - `accept`
### [iptables→nftables] `-j MASQUERADE` в nftables - `masquerade`
### [iptables→nftables] `-j DNAT --to-destination IP:PORT` в nftables - `dnat to IP:PORT`
### [iptables→nftables] `iptables-save` в nftables - `nft list ruleset`
### [iptables→nftables] `iptables -F` в nftables - `nft flush ruleset` (сильнее — сносит и цепочки, и таблицы)
### [iptables-nft] Что это - `Утилита iptables, работающая под капотом через nf_tables (compatibility layer). Проверить: iptables --version покажет (nf_tables)`

## 4. NAT

### [NAT] SNAT — что делает - `Source NAT: меняет source IP пакета (для исходящего NAT)`
### [NAT] DNAT — что делает - `Destination NAT: меняет destination IP пакета (для проброса портов внутрь)`
### [NAT] MASQUERADE — отличие от SNAT - `Как SNAT, но автоматически берёт IP выходного интерфейса (не нужно жёстко прописывать IP)`
### [NAT] REDIRECT — что это - `Специальный DNAT на локальный хост (перенаправить порт на другой порт этого же хоста)`
### [NAT] Правило MASQUERADE в nftables - `ip saddr 10.0.3.0/24 oif "eth0" masquerade`
### [NAT] Правило DNAT в nftables - `iif "eth0" udp dport 53 dnat to 10.0.3.53:53`
### [NAT] Почему DNAT в prerouting - `Меняет destination ДО маршрутизации, чтобы routing выбрал правильный путь`
### [NAT] Почему SNAT в postrouting - `Меняет source ПОСЛЕ маршрутизации, когда destination уже известен`

## 5. Connection Tracking (conntrack)

### [conntrack] Что такое conntrack - `Подсистема ядра Linux, которая помнит все проходящие соединения в специальной таблице в памяти`
### [conntrack] Зачем нужен - `Stateful firewall: разрешать ответы на исходящие без открытия широких дыр; NAT; распознавание связанных соединений`
### [conntrack] Основные состояния - `NEW, ESTABLISHED, RELATED, INVALID, UNTRACKED`
### [conntrack] Что означает NEW - `Первый пакет в соединении, ещё не видели такой пары src/dst`
### [conntrack] Что означает ESTABLISHED - `Соединение уже установлено, пакеты идут в обе стороны`
### [conntrack] Что означает RELATED - `Соединение связано с другим уже установленным (ICMP-ошибки, FTP data-connection, SIP RTP streams)`
### [conntrack] Что означает INVALID - `Пакет не подходит ни под одну запись и не выглядит как валидный NEW (ACK без SYN, битые флаги)`
### [conntrack] Ключевое правило stateful firewall - `ct state established,related accept`
### [conntrack] Почему без него curl не работает - `Ответы приходят на случайный эфемерный порт клиента, который заранее не пропишешь; conntrack распознаёт их как продолжение исходящего`
### [conntrack] Почему SSH работает без conntrack - `Входящее соединение на фиксированный порт 22 - каждый пакет матчит правило tcp dport 22`
### [conntrack] Пример RELATED - ICMP - `ICMP-ошибка (destination unreachable) в ответ на TCP-пакет`
### [conntrack] Пример RELATED - FTP - `Data-connection FTP, открываемое сервером к клиенту, распознаётся модулем nf_conntrack_ftp`
### [conntrack] Команда просмотра активных соединений - `sudo conntrack -L`
### [conntrack] Команда просмотра событий в реальном времени - `sudo conntrack -E`
### [conntrack] Счётчик текущих соединений - `sudo conntrack -C`
### [conntrack] Максимальное число отслеживаемых соединений - `sysctl net.netfilter.nf_conntrack_max`
### [conntrack] Что происходит при переполнении - `Новые соединения дропаются, в логах: "nf_conntrack: table full, dropping packet"`
### [conntrack] Связь с NAT - `NAT работает через conntrack: ядро запоминает трансляцию в записи и автоматически применяет её для всех пакетов соединения`
### [conntrack] notrack — что делает - `Отключает создание записи в conntrack для конкретного трафика (для оптимизации нагрузки)`
### [conntrack] Таймаут ESTABLISHED TCP - `432000 секунд (5 дней) по умолчанию`
### [conntrack] Таймаут UDP - `30 секунд для NEW, 120 секунд для установленных`

## 6. UFW и обёртки

### [UFW] Что такое UFW - `Uncomplicated Firewall — простая обёртка над nftables для быстрой настройки файрвола`
### [UFW] Базовая настройка - `ufw default deny incoming; ufw default allow outgoing; ufw allow OpenSSH; ufw enable`
### [UFW] Три политики по умолчанию - `incoming, outgoing, routed (соответствуют цепочкам input, output, forward)`
### [UFW] Что означает disabled (routed) - `UFW не управляет forward-цепочкой, она остаётся с настройками других подсистем`
### [UFW] Проблема с Docker - `Docker вставляет свои правила ДО правил UFW и не уважает их — создаёт ложное чувство защиты`
### [UFW] Как отключить UFW и очистить - `sudo ufw disable && sudo systemctl disable ufw && sudo apt purge ufw`
### [UFW] Почему после apt purge правила остаются в nft list - `apt purge удаляет только файлы на диске, правила остаются загруженными в память ядра`
### [UFW] Как выгрузить ВСЕ правила nftables - `sudo nft flush ruleset (радикально: удаляет и правила Docker/K8s)`
### [firewalld] Что такое - `Альтернативная обёртка над nftables с концепцией "зон" и "сервисов", стандарт на RHEL/CentOS`

## 7. Netfilter Packet Flow

### [Packet Flow] Порядок обработки транзитного пакета - `входящий интерфейс → prerouting → routing decision → forward → postrouting → исходящий интерфейс`
### [Packet Flow] Порядок для локально адресованного пакета - `входящий → prerouting → routing decision → input → локальный процесс`
### [Packet Flow] Порядок для локально сгенерированного - `локальный процесс → output → routing decision → postrouting → исходящий`
### [Packet Flow] Общий порядок таблиц на одном hook - `raw → mangle → nat → filter (по возрастанию приоритета)`
### [Packet Flow] Схема для MikroTik RouterOS - `https://help.mikrotik.com/docs/spaces/ROS/pages/328227/Packet+Flow+in+RouterOS`
### [Packet Flow] Особенность IPIP-туннеля - `Пакет проходит через firewall ДВАЖДЫ: как внешний IPIP и как декапсулированный внутренний`

## 8. Sets, Maps и продвинутый nftables

### [nftables] Что такое set - `Именованное множество для эффективной работы с большими списками IP/портов (O(1) lookup, хеш-таблица)`
### [nftables] Синтаксис set - `set blocked_ips { type ipv4_addr; elements = { 192.0.2.1, 192.0.2.2 } }`
### [nftables] Динамический set с таймаутом - `flags dynamic, timeout; timeout 1m — можно использовать для rate limiting`
### [nftables] Применение set в правиле - `ip saddr @blocked_ips drop`

## 9. Hardening — базовые 10 пунктов

### [Hardening] Философия - `Defense in depth: несколько слоёв защиты, каждый следующий держит, если предыдущий пробит`
### [Hardening] Пункт 1 - `Non-root user + sudo: создать пользователя, добавить в группу sudo, отключить root SSH`
### [Hardening] Пункт 2 - `SSH ключи вместо паролей (PasswordAuthentication no, PubkeyAuthentication yes)`
### [Hardening] Пункт 3 - `Файрвол (UFW или nftables) — закрыть всё, кроме нужного`
### [Hardening] Пункт 4 - `Автоматические обновления безопасности (unattended-upgrades)`
### [Hardening] Пункт 5 - `Fail2ban — защита от брутфорса`
### [Hardening] Пункт 6 - `Отключение лишних сервисов (avahi, cups, bluetooth, ModemManager)`
### [Hardening] Пункт 7 - `Логи и аудит (auditd)`
### [Hardening] Пункт 8 - `etckeeper — /etc в git для отслеживания изменений`
### [Hardening] Пункт 9 - `AIDE или debsums — проверка целостности файлов`
### [Hardening] Пункт 10 - `Бэкапы (правило 3-2-1: 3 копии, 2 носителя, 1 offsite)`
### [Hardening] Дополнительно - sysctl - `Kernel hardening: SYN cookies, отключение redirects, ASLR, kptr_restrict`
### [Hardening] Дополнительно - AppArmor - `Mandatory Access Control (MAC) поверх дискреционного (DAC) — ограничивает, что может делать программа`
### [Hardening] Дополнительно - 2FA - `Двухфакторная аутентификация для SSH через libpam-google-authenticator`
### [Hardening] Дополнительно - централизованные логи - `Отправка на удалённый syslog-сервер, чтобы атакующий не мог замести следы локально`

## 10. SSH Hardening

### [SSH] Отключить парольный логин - `PasswordAuthentication no в /etc/ssh/sshd_config`
### [SSH] Отключить root-логин - `PermitRootLogin no`
### [SSH] Разница no vs prohibit-password - `no — вообще запрещает root; prohibit-password — разрешает root ТОЛЬКО по ключу (не паролю)`
### [SSH] Проверить синтаксис конфига перед reload - `sudo sshd -t`
### [SSH] Перезагрузить SSH без разрыва соединений - `sudo systemctl reload sshd (не restart!)`
### [SSH] Современный тип ключа - `ed25519: короткий, быстрый, безопасный. Генерация: ssh-keygen -t ed25519`
### [SSH] Скопировать публичный ключ на сервер - `ssh-copy-id user@server-ip`
### [SSH] Ограничить попытки авторизации - `MaxAuthTries 3`
### [SSH] Таймаут неактивных сессий - `ClientAliveInterval 300; ClientAliveCountMax 2`
### [SSH] Правило безопасного изменения sshd_config - `Держи ОДНО рабочее SSH-соединение открытым; проверь новую сессию из другого окна ДО закрытия текущего`
### [SSH] Имя сервиса на Ubuntu - `ssh (не sshd — это алиас через симлинк)`
### [SSH] Имя сервиса на RHEL/CentOS - `sshd`

## 11. Automatic Updates (unattended-upgrades)

### [unattended-upgrades] Что делает - `Автоматически применяет обновления безопасности из pocket -security без участия человека`
### [unattended-upgrades] Три Ubuntu pocket'а - `-security (обновления безопасности), -updates (обычные), -backports (из будущих релизов)`
### [unattended-upgrades] Update-Package-Lists "1" - `Раз в день обновляет метаданные пакетов (эквивалент apt update)`
### [unattended-upgrades] Download-Upgradeable-Packages "1" - `Раз в день скачивает обновления в кеш (без установки)`
### [unattended-upgrades] Unattended-Upgrade "1" - `Раз в день применяет автоматические обновления (ключевой параметр!)`
### [unattended-upgrades] AutocleanInterval "7" - `Раз в неделю удаляет устаревшие .deb из кеша`
### [unattended-upgrades] Что происходит при обновлении ядра - `Новое ядро ставится в /boot/, работает старое до перезагрузки; создаётся /var/run/reboot-required`
### [unattended-upgrades] Проверить (dry-run) - `sudo unattended-upgrade -d --dry-run`
### [unattended-upgrades] Файл политик обновлений - `/etc/apt/apt.conf.d/50unattended-upgrades (Allowed-Origins, Blacklist)`
### [unattended-upgrades] Файл расписания - `/etc/apt/apt.conf.d/20auto-upgrades (APT::Periodic параметры)`
### [Kernel] Livepatch от Canonical - `Применяет критические патчи ядра БЕЗ перезагрузки (бесплатно для 3 машин на Ubuntu Pro)`
### [Kernel] Как узнать, требуется ли reboot - `Файл /var/run/reboot-required + список пакетов в /var/run/reboot-required.pkgs`

## 12. Fail2ban

### [Fail2ban] Что делает - `Читает логи, детектит неудачные попытки авторизации, банит IP через iptables/nftables/ufw`
### [Fail2ban] Правильный конфиг - `/etc/fail2ban/jail.local (НЕ трогать jail.conf — обновляется с пакетом)`
### [Fail2ban] banaction для UFW - `banaction = ufw`
### [Fail2ban] banaction для nftables - `banaction = nftables-multiport`
### [Fail2ban] Проверить статус - `sudo fail2ban-client status sshd`
### [Fail2ban] Ключевые параметры - `bantime (сколько банить), findtime (окно наблюдения), maxretry (порог попыток)`
### [Fail2ban] Разбанить IP - `sudo fail2ban-client set sshd unbanip 1.2.3.4`

## 13. Audit / etckeeper

### [auditd] Что делает - `Аудит системных вызовов и файловых изменений в ядре Linux`
### [auditd] Правило слежения за файлом - `-w /etc/passwd -p wa -k passwd_changes (watch, write+attribute, tag)`
### [auditd] Просмотр событий по тегу - `sudo ausearch -k passwd_changes`
### [auditd] Правила пишутся в - `/etc/audit/rules.d/*.rules`
### [auditd] Перезагрузить правила - `sudo augenrules --load`
### [etckeeper] Что делает - `Автоматически коммитит изменения /etc в локальный git-репо (при apt-операциях + раз в день)`
### [etckeeper] Хранит ли метаданные (владелец, права) - `Да, через специальный файл .etckeeper с командами chmod/chown`
### [etckeeper] Это бэкап? - `Нет, по умолчанию только локальный git. Для бэкапа настроить PUSH_REMOTE`
### [etckeeper] Как сделать бэкапом - `Добавить remote (Gitea/GitLab) и PUSH_REMOTE="origin" в /etc/etckeeper/etckeeper.conf`
### [etckeeper] Правильно работать с репозиторием - `sudo etckeeper commit "..." (не голый git, чтобы метаданные сохранялись)`

## 14. Другие hardening инструменты

### [Lynis] Что это - `Автоматический аудит безопасности системы, даёт hardening index и список слабых мест`
### [Lynis] Запустить аудит - `sudo lynis audit system`
### [AIDE] Что делает - `Проверяет целостность файлов: сравнивает с baseline-БД, детектит подмену системных бинарников (rootkits)`
### [AIDE] Инициализация baseline - `sudo aideinit && sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db`
### [AIDE] Проверка - `sudo aide --check`
### [debsums] Что делает - `Сравнивает установленные файлы с чексуммами из пакетов, показывает изменённые`
### [debsums] Проверить изменённые - `sudo debsums -s`
### [needrestart] Что делает - `Детектит сервисы, использующие устаревшие библиотеки после обновления, предлагает перезапустить`

## 15. Sysctl hardening

### [sysctl] Защита от SYN-флуда - `net.ipv4.tcp_syncookies = 1`
### [sysctl] Игнорировать ICMP redirects - `net.ipv4.conf.all.accept_redirects = 0`
### [sysctl] Не отправлять ICMP redirects - `net.ipv4.conf.all.send_redirects = 0`
### [sysctl] Не отвечать на broadcast pings - `net.ipv4.icmp_echo_ignore_broadcasts = 1`
### [sysctl] Kernel ASLR - `kernel.randomize_va_space = 2`
### [sysctl] Скрыть kernel pointers - `kernel.kptr_restrict = 2`
### [sysctl] Применить настройки - `sudo sysctl --system`
### [sysctl] Файл кастомных настроек - `/etc/sysctl.d/99-hardening.conf`

## 16. Bash-скриптование (для написания hardening-скриптов)

### [Bash] Безопасный режим скрипта - `set -euo pipefail`
### [Bash] set -e — что делает - `Прервать при любой ошибке (ненулевой код возврата)`
### [Bash] set -u — что делает - `Прервать при использовании необъявленной переменной`
### [Bash] pipefail — что делает - `Пайп считается упавшим, если ЛЮБАЯ команда в нём упала (по умолчанию — только последняя)`
### [Bash] Проверка root в скрипте - `if [[ $EUID -ne 0 ]]; then exit 1; fi`
### [Bash] Что такое RUID/EUID/SUID - `RUID — кто реально запустил; EUID — под каким UID действует сейчас (ядро проверяет); SUID — сохранённая копия для возврата`
### [Bash] Логирование stdout+stderr на экран и в файл - `exec > >(tee -a "$LOG_FILE") 2>&1`
### [Bash] Что делает tee - `Раздваивает поток: пишет одновременно в stdout и в файл (T-образный тройник)`
### [Bash] tee -a — что значит - `Append: дописать в конец файла (без -a — перезаписать)`
### [Bash] Идемпотентность скрипта - `Можно запускать много раз, результат одинаковый, повторы не ломают ничего`
### [Bash] Массив — синтаксис - `arr=("a" "b" "c")`
### [Bash] Итерация по массиву - `for x in "${arr[@]}"; do ... done`
### [Bash] Зачем "${arr[@]}" в кавычках - `Защита от word splitting — каждый элемент остаётся отдельным даже с пробелами`
### [Bash] Обращение к элементу массива - `${arr[0]} (обязательно фигурные скобки!)`
### [Bash] Длина массива - `${#arr[@]}`
### [Bash] Когда обязательны ${var} - `Когда имя примыкает к буквам/цифрам/подчёркиваниям (${var}suffix), при манипуляциях (${var^^}), для массивов`
### [Bash] Логика if - `if смотрит на код возврата команды: 0 = успех = then, не-0 = ошибка = else (0 = "нет проблем")`
### [Bash] Оператор && - `Правая команда выполняется, ТОЛЬКО если левая вернула 0 (успех)`
### [Bash] Оператор || - `Правая команда выполняется, ТОЛЬКО если левая вернула не-0 (ошибка)`
### [Bash] Защита от set -e для опциональной команды - `команда || true (или команда || log_warn "...")`
### [Bash] Проверка существования файла - `[[ -f /path/to/file ]]`
### [Bash] Проверка существования директории - `[[ -d /path ]]`
### [Bash] Проверка наличия команды - `command -v утилита &>/dev/null`
### [Bash] Проверка существования пользователя - `id username &>/dev/null`
### [Bash] Локальная переменная в функции - `local key="$1"`
### [Bash] Heredoc для многострочных данных - `cat > file <<EOF ... EOF`
### [Bash] 2>&1 — что делает - `Направить stderr туда же, куда stdout`
### [Bash] > /dev/null 2>&1 — что делает - `Подавить весь вывод (и stdout, и stderr) — команда работает молча`
### [Bash] Command substitution - `$(команда) — вставить вывод команды в текст`

## 17. Регулярные выражения

### [Regex] Разница BRE и ERE - `Basic и Extended regex. В BRE спецсимволы ?+|() требуют экранирования \\, в ERE — наоборот`
### [Regex] grep -E — что делает - `Использовать extended regex (не нужно экранировать ?+|)`
### [Regex] . — что означает - `Любой один символ (кроме перевода строки)`
### [Regex] \\. — что означает - `Буквальная точка (экранированная)`
### [Regex] * — что означает - `Предыдущий элемент 0 или больше раз`
### [Regex] + — что означает - `Предыдущий элемент 1 или больше раз (в BRE: \\+)`
### [Regex] ? — что означает - `Предыдущий элемент 0 или 1 раз (в BRE: \\?)`
### [Regex] ^ — что означает - `Начало строки`
### [Regex] $ — что означает - `Конец строки`
### [Regex] \\s — что означает - `Пробельный символ (пробел, таб)`
### [Regex] \\| в BRE - `Оператор ИЛИ (в ERE — просто |)`
### [Regex] Идиома для sed - `sed s|...|...| — разделитель может быть любой символ, | удобно когда в тексте есть слеши`
### [Regex] Полезный сайт для проверки - `regex101.com`

## 18. Полезные Unix-концепции

### [Unix] Правило кодов возврата - `0 = успех ("нет проблем"), любое другое число = ошибка (много вариантов)`
### [Unix] Код возврата grep - `0 если найдено, 1 если не найдено, 2 при ошибке`
### [Unix] Код возврата systemctl is-active - `0 если active/activating, 3 если inactive/failed, 4 если unknown`
### [Unix] Проверить код возврата последней команды - `echo $?`
### [systemd] Три состояния сервиса - `active/inactive/failed vs enabled/disabled (два независимых понятия!)`
### [systemd] Отключить и остановить сервис - `sudo systemctl disable --now service`
### [systemd] Включить и запустить сервис - `sudo systemctl enable --now service`

## 19. Практические команды

### [Проверка] Кто слушает порты наружу - `sudo ss -tlnp | grep -v '127\\.0\\.0\\.1\\|::1'`
### [Проверка] Все слушающие TCP-порты - `sudo ss -tlnp`
### [Проверка] Активные соединения - `sudo ss -tanp`
### [Проверка] Все активные UDP-сокеты - `sudo ss -ulnp`
### [Проверка] Сетевые интерфейсы - `ip -br link`
### [Проверка] Таблица маршрутизации - `ip route`
### [Проверка] Есть ли форвардинг - `sudo sysctl net.ipv4.ip_forward`
### [Проверка] Активные ядра в /boot - `ls /boot/vmlinuz-*`
### [Проверка] Текущее работающее ядро - `uname -r`
### [Проверка] Загрузка через SSH? - `env | grep SSH_CONNECTION`


# Эксперимент 1 📺 — Что такое netfilter и куда попадают пакеты

**Что делаем:** увидеть цепочки правил и понять как пакет проходит через firewall.

**Команды:**

### Что сейчас в netfilter (можно на свежей системе — увидеть базу)
sudo iptables -L -v -n --line-numbers
sudo iptables -t nat -L -v -n

#### Вывод:
root@DNS:/home/eakramar# iptables -L -v -n --line-numbers
Chain INPUT (policy ACCEPT 257 packets, 386K bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:53 ctstate NEW,ESTABLISHED
2       64  4348 ACCEPT     17   --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:53
3      183 15670 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:2288

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:53 ctstate NEW,ESTABLISHED
2        0     0 ACCEPT     17   --  *      *       0.0.0.0/0            10.0.3.187           udp dpt:53

Chain OUTPUT (policy ACCEPT 433 packets, 38559 bytes)
num   pkts bytes target     prot opt in     out     source               destination 


root@DNS:/home/eakramar# iptables -t nat -L -v -n
Chain PREROUTING (policy ACCEPT 16 packets, 2512 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DNAT       17   --  enp0s3 *       0.0.0.0/0            0.0.0.0/0            udp dpt:53 to:10.0.3.187:53
    0     0 DNAT       6    --  enp0s3 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:53 to:10.0.3.187:53

Chain INPUT (policy ACCEPT 14 packets, 1360 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 56 packets, 4130 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 56 packets, 4130 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 MASQUERADE  0    --  *      enp0s3  10.0.3.0/24          0.0.0.0/0

1) Все политики - ACCEPT, ни чего лишнего файервол не отбрасывает.
2) Фильтр, входящая цепочка, 1 правило. Принимать пакеты со всех адресов на все адреса на порту 53 (DNS) по протоколу TCP с состоянием - NEW, ESTABLISHED. NEW это состояние conntrack, при котором устанавливается соединение (TCP handshake) когда приходит первый пакет SYN, последующие пакеты (SYN-ACK, ACK) устанавливают соединение с состоянием ESTABLISHED.
3) Фильтр, входящая цепочка, 2 правило. Принимать пакеты по протоколу UDP со всех адресов на все адреса на 53 порту.
4) Фильтр, входящая цепочка, 3 правило. Принимать пакеты по протоколу TCP со всех адресов на все адреса на 2288 порту (нестандартный порт для ssh).
5) Фильтр, транзитная цепочка, 1 правило. Пересылать пакеты по протоколу TCP со всех адресов на все адреса на 53 порту с состоянием - NEW, ESTABLISHED.
6) Фильтр, транзитная цепочка, 2 правило. Пересылать пакеты по протоколу UDP со всех адресов на 10.0.3.187 на 53 порту.
7) NAT, PREROUTING, 1 правило. Проброс порта по протоколу UDP с интерфейса enp0s3 со всех адресов на 10.0.3.187 на 53 порту.
8) NAT, PREROUTING, 2 правило. Проброс порта по протоколу TCP с интерфейса enp0s3 со всех адресов на 10.0.3.187 на 53 порту.
9) NAT, POSTROUTING, 1 правило. Маскировка адреса под адрес выходного интерфейса enp0s3 для пакетов с адресом источником - 10.0.3.0/24.

### Или для nftables (современнее)
sudo nft list ruleset

#### Вывод:
root@DNS:/home/eakramar# nft list ruleset
Warning: table ip filter is managed by iptables-nft, do not touch!
table ip filter {
	chain INPUT {
		type filter hook input priority filter; policy accept;
		tcp dport 53 ct state new,established counter packets 0 bytes 0 accept
		udp dport 53 counter packets 68 bytes 4628 accept
		tcp dport 2288 counter packets 296 bytes 22402 accept
	}

	chain FORWARD {
		type filter hook forward priority filter; policy accept;
		tcp dport 53 ct state new,established counter packets 0 bytes 0 accept
		ip daddr 10.0.3.187 udp dport 53 counter packets 0 bytes 0 accept
	}

	chain OUTPUT {
		type filter hook output priority filter; policy accept;
	}
}
Warning: table ip nat is managed by iptables-nft, do not touch!
table ip nat {
	chain PREROUTING {
		type nat hook prerouting priority dstnat; policy accept;
		iifname "enp0s3" udp dport 53 counter packets 0 bytes 0 dnat to 10.0.3.187:53
		iifname "enp0s3" tcp dport 53 counter packets 0 bytes 0 dnat to 10.0.3.187:53
	}

	chain INPUT {
		type nat hook input priority srcnat; policy accept;
	}

	chain OUTPUT {
		type nat hook output priority dstnat; policy accept;
	}

	chain POSTROUTING {
		type nat hook postrouting priority srcnat; policy accept;
		ip saddr 10.0.3.0/24 oifname "enp0s3" counter packets 0 bytes 0 masquerade
	}
}
table inet lxc {
	chain input {
		type filter hook input priority filter; policy accept;
		iifname "lxcbr0" udp dport { 53, 67 } accept
		iifname "lxcbr0" tcp dport { 53, 67 } accept
	}

	chain forward {
		type filter hook forward priority filter; policy accept;
		iifname "lxcbr0" accept
		oifname "lxcbr0" accept
	}
}
table ip lxc {
	chain postrouting {
		type nat hook postrouting priority srcnat; policy accept;
		ip saddr 10.0.3.0/24 ip daddr != 10.0.3.0/24 counter packets 0 bytes 0 masquerade
	}
}
root@DNS:/home/eakramar# 

Тоже самое, но в nft, стоит отметить, что даже cli iptables, пользуется nf_tables в ядре, а не ip_tables. О чем свидетельствует следующая команда:
root@DNS:/home/eakramar# iptables --version
iptables v1.8.10 (nf_tables)
Также, в отличии от iptables, видно таблицы и правила для lxc-контейнеров, пояснять не нужно там и так все понятно.


### Показать текущие соединения через conntrack
sudo apt install conntrack -y
sudo conntrack -L | head -20

#### Вывод:

root@DNS:/home/eakramar# conntrack -L | head -20
conntrack v1.4.8 (conntrack-tools): 6 flow entries have been shown.
udp      17 11 src=127.0.0.1 dst=127.0.0.53 sport=35380 dport=53 src=127.0.0.53 dst=127.0.0.1 sport=53 dport=35380 mark=0 use=1
udp      17 11 src=192.168.100.32 dst=89.31.108.2 sport=39117 dport=53 src=89.31.108.2 dst=192.168.100.32 sport=53 dport=39117 mark=0 use=1
udp      17 2 src=192.168.100.26 dst=192.168.100.255 sport=138 dport=138 [UNREPLIED] src=192.168.100.255 dst=192.168.100.26 sport=138 dport=138 mark=0 use=1
tcp      6 431999 ESTABLISHED src=192.168.100.26 dst=192.168.100.32 sport=63983 dport=2288 src=192.168.100.32 dst=192.168.100.26 sport=2288 dport=63983 [ASSURED] mark=0 use=1
tcp      6 101 TIME_WAIT src=192.168.100.32 dst=213.180.204.183 sport=35566 dport=80 src=213.180.204.183 dst=192.168.100.32 sport=80 dport=35566 [ASSURED] mark=0 use=1
udp      17 11 src=127.0.0.1 dst=127.0.0.53 sport=58901 dport=53 src=127.0.0.53 dst=127.0.0.1 sport=53 dport=58901 mark=0 use=1

Интересная утилита, первый раз ее опробовал, анализ построчно:
1) Формат вывода:
<протокол> <номер_протокола> <таймаут> <состояние> \
    src=<оригинал_src> dst=<оригинал_dst> sport=... dport=... \
    src=<обратный_src> dst=<обратный_dst> sport=... dport=... \
    [флаги] mark=... use=...
Первая пара src/dst/sport/dport — как выглядит прямой пакет.
Вторая пара — как будет выглядеть ответ (если бы NAT был, здесь бы отличалось).
Флаг [ASSURED] — обе стороны обменялись пакетами, соединение подтверждено.
Флаг [UNREPLIED] — ответа ещё не было, только исходящий.
mark — метка для policy routing/QoS.
use — счётчик текущего использования записи.
2) Строка 1: локальный DNS-запрос. Расшифровка: протокол UDP (17 — его номер в IP); таймаут: 11 секунд до истечения; состояния нет (UDP же — нет state machine как у TCP); локальный процесс (127.0.0.1) обратился к 127.0.0.53:53; ответ пришёл симметрично. Это обращение к systemd-resolved. На современной Ubuntu он слушает DNS на специальном локальном адресе 127.0.0.53:53 — это встроенный DNS-заглушка/кэш. Любая программа на хосте, которая делает DNS-запрос через стандартный резолвер, обращается сюда, а systemd-resolved уже пересылает наружу к настоящим апстрим-DNS-серверам.
3) Строка 2: настоящий DNS-запрос наружу. Расшифровка: мой хост (192.168.100.32) обратился к 89.31.108.2:53; обмен состоялся, ответ пришёл симметрично. Это уже исходящий DNS. Скорее всего это тот же самый systemd-resolved (или отдельный резолвер) переслал запрос из строки 1 наружу к настоящему DNS-серверу.
4) Строка 3: NetBIOS broadcast — [UNREPLIED]. Расшифровка: хост 192.168.100.26 шлёт UDP на 192.168.100.255:138 (это broadcast-адрес сети 192.168.100.0/24); порт 138 — NetBIOS Datagram Service; [UNREPLIED] — ответа не было; Таймаут 2 секунды — сейчас исчезнет. Что происходит: это NetBIOS-объявление от Windows/Samba-машины. Хосты в сети периодически рассылают broadcast'ы с информацией «я тут, меня зовут так-то, я в группе такой-то». Это как «привет всем!» в локалке. Флаг [UNREPLIED] тут естественен: на broadcast'ы никто прямых ответов не шлёт — они по определению «в никуда конкретно». Conntrack всё равно создаёт запись, потому что технически это UDP-поток с исходящим адресом, просто никогда не получит ответа. Через несколько секунд запись протухнет и удалится. Присутствие таких записей — признак, что в твоей сети есть Windows-машина (или Samba-сервер). Совершенно нормально для смешанной сети. Кстати, эти broadcast'ы иногда «шумят» в conntrack — если у кого то тысячи машин и все NetBIOS'ят, может забивать таблицу. Можно исключить через notrack-правило, но обычно не критично.
5) Строка 4: SSH-сессия — [ASSURED] ESTABLISHED. Расшифровка: TCP-соединение; Таймаут: 431999 секунд ≈ 5 дней (это стандартный tcp_timeout_established); состояние: ESTABLISHED — рабочая TCP-сессия; клиент 192.168.100.26 подключился к моему хосту 192.168.100.32 на порт 2288; [ASSURED] — обмен в обе стороны состоялся. Что происходит: это входящее SSH-соединение к моему хосту. Тот же клиент 192.168.100.26 (что и NetBIOS'ит в строке 3) — моя рабочая станция, с которой я и залогинен сейчас. Достойно внимания: таймаут 5 дней — это ядерный дефолт для tcp_timeout_established. То есть даже если я закрою окно SSH-клиента без корректного разлогинивания и соединение окажется «полумёртвым», conntrack будет держать запись 5 суток. На нагруженном сервере это может забивать таблицу «мёртвыми» ESTABLISHED, поэтому админы часто уменьшают: sudo sysctl net.netfilter.nf_conntrack_tcp_timeout_established=7200  # 2 часа. Или в /etc/sysctl.conf: net.netfilter.nf_conntrack_tcp_timeout_established = 7200. Для домашней виртуалки — не критично, но знать полезно.
6) Строка 5: HTTP-запрос куда-то — TIME_WAIT. Расшифровка: TCP-соединение; таймаут: 101 секунда; состояние: TIME_WAIT; мой хост обращался к 213.180.204.183:80 (HTTP, не HTTPS); [ASSURED] — обмен состоялся. Что происходит: это уже завершённое HTTP-соединение, которое сейчас в состоянии TIME_WAIT. TIME_WAIT — это финальная фаза TCP-хэндшейка закрытия. Инициатор закрытия (тот, кто отправил FIN первым) обязан пробыть в TIME_WAIT некоторое время после закрытия. Зачем это нужно: убедиться, что финальный ACK дошёл до другой стороны — если пропал, придёт повторный FIN, на который надо ответить. Не позволить старым пакетам из этого соединения смешаться с новым соединением с теми же портами. Порты через некоторое время могут переиспользоваться, и заблудившийся пакет мог бы попасть не туда. Стандартное время TIME_WAIT в Linux — 120 секунд (2 * MSL). Моя запись сейчас с таймаутом 101 — то есть закрытие произошло 19 секунд назад. Кто такой 213.180.204.183:
root@DNS:/home/eakramar# whois 213.180.204.183 | head -20
% This is the RIPE Database query service.
% The objects are in RPSL format.
%
% The RIPE Database is subject to Terms and Conditions.
% See https://docs.db.ripe.net/terms-conditions.html

% Note: this output has been filtered.
%       To receive output for a database update, use the "-B" flag.

% Information related to '213.180.204.0 - 213.180.204.255'

% Abuse contact for '213.180.204.0 - 213.180.204.255' is 'abuse@yandex.ru'

inetnum:        213.180.204.0 - 213.180.204.255
netname:        YANDEX-213-180-204-0
status:         ASSIGNED PA
country:        RU
descr:          Yandex enterprise network
mnt-by:         YANDEX-MNT
admin-c:        YNDX1-RIPE
Это, скорее всего, Yandex. Обращение по HTTP (порт 80). Возможно, это браузер, apt update, любой сервис, который дёрнул что-то у Яндекса — их сервисы (метрика, DNS-checker и т.д.) активно ходят по HTTP. Практический момент: TIME_WAIT-соединений на активном сервере может быть очень много (сотни, тысячи). Они не потребляют «ресурсов» в смысле процессорного времени, но занимают слоты в conntrack-таблице и сокет-таблице. Иногда это становится проблемой: sudo ss -tan | awk '{print $1}' | sort | uniq -c # покажет распределение состояний. Если много TIME_WAIT — иногда включают net.ipv4.tcp_tw_reuse=1 (переиспользовать TIME_WAIT для новых соединений). Но это уже тюнинг под конкретную нагрузку.
7) Строка 6: ещё один локальный DNS-запрос. Расшифровка: ещё один локальный DNS-запрос к 127.0.0.53; другой source-port (58901 вместо 35380 в строке 1). Что происходит: аналогично строке 1 — ещё один DNS-запрос через systemd-resolved. Разные source-порты означают разные независимые запросы. Возможно, к тому моменту первый запрос ещё не протух — и вот второй уже начался.

Еще команды: Распределение по состояниям — сколько чего - sudo conntrack -L 2>/dev/null | awk '/^tcp/ {print $4}' | sort | uniq -c;
Топ IP-адресов, к которым много соединений - sudo conntrack -L 2>/dev/null | grep -oP 'dst=\S+' | sort | uniq -c | sort -rn | head;
Соединения к конкретному хосту - sudo conntrack -L -d 213.180.204.183;
Всё, что было в состоянии NEW (только что открытые) - sudo conntrack -E -e NEW --any-nat;   # в реальном времени
Общий счётчик - sudo conntrack -C;  # то же самое - sysctl net.netfilter.nf_conntrack_count.

Особенно полезно conntrack -E — в реальном времени видно, как соединения открываются, меняют состояния, закрываются. Иногда там всплывают неожиданные вещи — фоновые сервисы, которые ты забыл настроить, обновления пакетов, «шумные» приложения.
   
### Статистика conntrack: сколько соединений сейчас, максимум
sudo conntrack -C
cat /proc/sys/net/netfilter/nf_conntrack_max

#### Вывод:
root@DNS:/home/eakramar# conntrack -C
2
root@DNS:/home/eakramar# cat /proc/sys/net/netfilter/nf_conntrack_max
65536

Сейчас 2 соединения, максимум - 65536

### **Что записать в `notes/unit-05-firewall-hardening.md`:**
- Какие цепочки видишь? 
INPUT, FORWARD, OUTPUT в filter
- Что делает каждая цепочка? 
INPUT — трафик к серверу, FORWARD — транзит, OUTPUT — от сервера наружу
- Что такое таблица (table)? Табл filter, nat, mangle, raw — зачем каждая
filter — «здесь я решаю, пропустить или дропнуть»
nat — «здесь я делаю трансляцию адресов»
mangle — «здесь я модифицирую поля пакета (TTL, DSCP, marks)»
raw — «здесь я работаю с пакетом до conntrack»
В nftables этих ограничений нет. Технически можно писать любые правила в любой таблице. Но люди продолжают разделять — потому что это удобно для чтения и структуры.
- Проходит ли пакет через все цепочки?
Нет — путь зависит от типа

### **Вопросы для самопроверки:**
- Пакет пришёл на порт 443 nginx - через какую цепочку проходит?
Если nginx находится на хосте на котором файервол, то INPUT
- Пакет от nginx уходит к клиенту - через какую цепочку?
Если nginx находится на хосте на котором файервол, то OUTPUT
- Пакет транзитом через сервер (роутинг) - через какую цепочку?
FORWARD

# Эксперимент 2 🧠 — ufw с нуля: правильный порядок команд

**⚠️ ВАЖНО перед началом:** если делаешь на удалённом сервере — **держи открытой вторую SSH-сессию**. Если ошибёшься с портом — потеряешь доступ, придётся идти в web-консоль провайдера.

**Что делаем:** настраиваем ufw пошагово, наблюдаем что происходит на каждом шаге.

**Команды:**

### Начинаем с чистого листа
sudo ufw status  # inactive?

#### Вывод:
root@server-h9qt:~# ufw status
Status: inactive

### Смотрим дефолтные политики (важно понять до включения!)
sudo ufw status verbose

#### Вывод:
root@server-h9qt:~# ufw status verbose
Status: inactive

### ЛЮБОЙ ДРУГОЙ КОМАНДЕ ДОЛЖНО ПРЕДШЕСТВОВАТЬ ЭТО:
sudo ufw allow 22/tcp
#### ↑ или свой SSH-порт если ты его менял
#### Без этого следующая команда потеряет доступ!
#### Вывод:
root@server-h9qt:~# ufw allow 22/tcp
Rules updated
Rules updated (v6)

### Разрешаем стандартные веб-порты
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

#### Вывод:
root@server-h9qt:~# ufw allow 80/tcp comment 'HTTP'
Rules updated
Rules updated (v6)
root@server-h9qt:~# ufw allow 443/tcp comment 'HTTPS'
Rules updated
Rules updated (v6)

### Смотрим что накопили ДО применения
sudo ufw show added

#### Вывод:
root@server-h9qt:~# ufw show added
Added user rules (see 'ufw status' for running firewall):
ufw allow 22/tcp
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

### Только теперь можно включать
sudo ufw enable
### ufw предупредит: "Command may disrupt existing ssh connections" — Yes
#### Вывод:
root@server-h9qt:~# ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup

### Проверяем что получилось
sudo ufw status verbose
sudo ufw status numbered  # с номерами правил — для delete

#### Вывод:
root@server-h9qt:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                  
80/tcp                     ALLOW IN    Anywhere                   # HTTP
443/tcp                    ALLOW IN    Anywhere                   # HTTPS
22/tcp (v6)                ALLOW IN    Anywhere (v6)             
80/tcp (v6)                ALLOW IN    Anywhere (v6)              # HTTP
443/tcp (v6)               ALLOW IN    Anywhere (v6)              # HTTPS

root@server-h9qt:~# sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere                  
[ 2] 80/tcp                     ALLOW IN    Anywhere                   # HTTP
[ 3] 443/tcp                    ALLOW IN    Anywhere                   # HTTPS
[ 4] 22/tcp (v6)                ALLOW IN    Anywhere (v6)             
[ 5] 80/tcp (v6)                ALLOW IN    Anywhere (v6)              # HTTP
[ 6] 443/tcp (v6)               ALLOW IN    Anywhere (v6)              # HTTPS

### Что делает ufw под капотом? Смотрим сгенерированные iptables/nftables правила
sudo iptables -L -v -n | head -30
### Или для новых Ubuntu (backend=nftables):
sudo nft list ruleset | head -50

#### Вывод:
root@server-h9qt:~# iptables -L -v -n | head -30
Chain INPUT (policy DROP 65 packets, 3674 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  466 36138 ufw-before-logging-input  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
  466 36138 ufw-before-input  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
  355 22250 ufw-after-input  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
   65  3674 ufw-after-logging-input  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
   65  3674 ufw-reject-input  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
   65  3674 ufw-track-input  0    --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ufw-before-logging-forward  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-before-forward  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-after-forward  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-after-logging-forward  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-reject-forward  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 ufw-track-forward  0    --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  100 16054 ufw-before-logging-output  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
  100 16054 ufw-before-output  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    76 ufw-after-output  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    76 ufw-after-logging-output  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    76 ufw-reject-output  0    --  *      *       0.0.0.0/0            0.0.0.0/0           
    1    76 ufw-track-output  0    --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain ufw-after-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination         

root@server-h9qt:~# nft list ruleset | head -50
 Warning: table ip filter is managed by iptables-nft, do not touch!
table ip filter {
        chain ufw-before-logging-input {
        }

        chain ufw-before-logging-output {
        }

        chain ufw-before-logging-forward {
        }

        chain ufw-before-input {
                iifname "lo" counter packets 6 bytes 887 accept
                ct state related,established counter packets 557 bytes 500330 accept
                ct state invalid counter packets 0 bytes 0 jump ufw-logging-deny
                ct state invalid counter packets 0 bytes 0 drop
                ip protocol icmp icmp type destination-unreachable counter packets 0 bytes 0 accept
                ip protocol icmp icmp type time-exceeded counter packets 0 bytes 0 accept
                ip protocol icmp icmp type parameter-problem counter packets 0 bytes 0 accept
                ip protocol icmp icmp type echo-request counter packets 3 bytes 204 accept
                udp sport 67 udp dport 68 counter packets 0 bytes 0 accept
                counter packets 617 bytes 38637 jump ufw-not-local
                ip daddr 224.0.0.251 udp dport 5353 counter packets 0 bytes 0 accept
                ip daddr 239.255.255.250 udp dport 1900 counter packets 0 bytes 0 accept
                counter packets 617 bytes 38637 jump ufw-user-input
        }

        chain ufw-before-output {
                oifname "lo" counter packets 6 bytes 887 accept
                ct state related,established counter packets 450 bytes 41240 accept
                counter packets 5 bytes 417 jump ufw-user-output
        }

        chain ufw-before-forward {
                ct state related,established counter packets 0 bytes 0 accept
                ip protocol icmp icmp type destination-unreachable counter packets 0 bytes 0 accept
                ip protocol icmp icmp type time-exceeded counter packets 0 bytes 0 accept
                ip protocol icmp icmp type parameter-problem counter packets 0 bytes 0 accept
                ip protocol icmp icmp type echo-request counter packets 0 bytes 0 accept
                counter packets 0 bytes 0 jump ufw-user-forward
        }

        chain ufw-after-input {
                udp dport 137 counter packets 0 bytes 0 jump ufw-skip-to-policy-input
                udp dport 138 counter packets 0 bytes 0 jump ufw-skip-to-policy-input
                tcp dport 139 counter packets 0 bytes 0 jump ufw-skip-to-policy-input
                tcp dport 445 counter packets 0 bytes 0 jump ufw-skip-to-policy-input
                udp dport 67 counter packets 0 bytes 0 jump ufw-skip-to-policy-input
                udp dport 68 counter packets 0 bytes 0 jump ufw-skip-to-policy-input
                fib daddr type broadcast counter packets 514 bytes 33126 jump ufw-skip-to-policy-input
        }

### **Что записать:**
- Дефолтные политики ufw: incoming DENY, outgoing ALLOW, forward DENY. Почему такая логика?
Стандартная настройка всех админов, блочить то, что не разрешено
- Что случится если я забуду allow 22 перед enable? 
потеря SSH-доступа
- Разница `ufw allow 22` vs `ufw allow 22/tcp` 
первая — и TCP и UDP; вторая — только TCP
- Что делает флаг `comment`
 сохраняет читаемое описание в выводе status

### **Вопросы:**
- Как удалить конкретное правило? 
`sudo ufw status numbered` → `sudo ufw delete N`
- Как заблокировать конкретный IP? 
`sudo ufw deny from 1.2.3.4`
- Как разрешить SSH только с одного IP? 
`sudo ufw allow from 1.2.3.4 to any port 22`
- Что делает `sudo ufw reset`? 
сбрасывает всё в дефолт — использовать с осторожностью

# Эксперимент 3 🧠 — fail2ban для SSH

**Что делаем:** ставим fail2ban, настраиваем защиту от bruteforce, проверяем что работает.

**Команды:**
### Установка
sudo apt install fail2ban -y

#### Вывод:
Установил

### Проверяем что установился и запущен
sudo systemctl status fail2ban
sudo fail2ban-client status

#### Вывод:
root@server-h9qt:~# systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-07-16 03:33:20 UTC; 59s ago
       Docs: man:fail2ban(1)
   Main PID: 79224 (fail2ban-server)
      Tasks: 5 (limit: 4625)
     Memory: 19.1M (peak: 19.6M)
        CPU: 325ms
     CGroup: /system.slice/fail2ban.service
             └─79224 /usr/bin/python3 /usr/bin/fail2ban-server -xf start

Jul 16 03:33:20 server-h9qt systemd[1]: Started fail2ban.service - Fail2Ban Service.
Jul 16 03:33:20 server-h9qt fail2ban-server[79224]: 2026-07-16 03:33:20,149 fail2ban.configreader   [79224]: WARNING 'allowipv6' not defined in>
Jul 16 03:33:20 server-h9qt fail2ban-server[79224]: Server ready

root@server-h9qt:~# fail2ban-client status
Status
|- Number of jail:      1
`- Jail list:   sshd

### По умолчанию fail2ban защищает только SSH (jail sshd)
sudo fail2ban-client status sshd

#### Вывод:
root@server-h9qt:~# fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 2
|  |- Total failed:     5
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:

**Настройка через jail.local (ВАЖНО: не править jail.conf!):**
### Копируем дефолт в jail.local — свою кастомизацию
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
#### Или чище — сразу создать пустой jail.local только со своими секциями

#### Вывод:
root@server-h9qt:~# cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
root@server-h9qt:~# 

### Открой `/etc/fail2ban/jail.local` и найди/добавь секцию `[sshd]`:
[DEFAULT]
#### Как долго держать бан (в секундах). -1 = навсегда
bantime  = 1h
#### За какое окно считать попытки
findtime = 10m
#### Сколько неудачных попыток до бана
maxretry = 5
#### Не банить свой домашний IP (если знаешь свой публичный)
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port    = 22
#### Если менял SSH-порт — указать здесь
#### port    = 22022

#### Вывод:
Удалил все содержимое и вписал новое, как в задании.

### Применяем:
sudo systemctl reload fail2ban
sudo fail2ban-client status sshd

#### Вывод:
root@server-h9qt:~# systemctl reload fail2ban
root@server-h9qt:~# fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 4
|  |- Total failed:     8
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:

**Тест что работает (симулируем bruteforce):**
### С другой машины — специально ошибись паролем 5 раз
ssh nonexistent-user@твой-сервер
#### (введи неверный пароль)
#### Повторить 5 раз

#### На сервере смотрим:
sudo fail2ban-client status sshd
#### Increase in "Currently banned" — работает

#### Вывод:
root@server-h9qt:~# fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 3
|  |- Total failed:     14
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   217.177.44.136

Да, 5 попыток и бан - работает.

### Смотрим детально
sudo iptables -L f2b-sshd -n
#### Увидишь IP атакующего

**Разбан себя если что:**
sudo fail2ban-client set sshd unbanip 1.2.3.4

#### Вывод:

root@server-h9qt:~# fail2ban-client set sshd unbanip 217.177.44.136
1
root@server-h9qt:~# fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 3
|  |- Total failed:     16
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     1
   `- Banned IP list:
root@server-h9qt:~# 

**Что записать:**
- Разница между jail.conf и jail.local 
jail.conf перезаписывается при обновлении пакета, jail.local — нет
- Что такое DEFAULT секция
применяется ко всем jails если не переопределено
- Как fail2ban технически банит? 
добавляет iptables/nftables правила через action

**Вопросы:**
- Что произойдёт если я ошибусь паролем 5 раз со своего домашнего IP? 
ban на 1 час, если не в ignoreip
- Как посмотреть все забаненные IP через все jails? 
`sudo fail2ban-client banned`
- Fail2ban читает какие логи для SSH? 
`/var/log/auth.log` — журнал sudo/ssh/pam

# Эксперимент 4 🧠 — Hardening: обязательный чек-лист сервера

**Что делаем:** проходим по чек-листу, проверяем каждый пункт на своей виртуалке. Каждый пункт — тест.

### **1. SSH — только ключи, no password**
#### В /etc/ssh/sshd_config:
#### PasswordAuthentication no
#### KbdInteractiveAuthentication no
#### PermitRootLogin no  (или prohibit-password если нужен root по ключу)
#### PubkeyAuthentication yes
sudo sshd -t  # проверка синтаксиса
sudo systemctl reload sshd

Проверка: `ssh -o PubkeyAuthentication=no user@server` → должен отказать.

#### Вывод:
root@server-h9qt:~# nano /etc/ssh/sshd_config
root@server-h9qt:~# sshd -t
root@server-h9qt:~# systemctl reload sshd
root@vdska:~# ssh -o PubkeyAuthentication=no root@94.183.155.135
root@94.183.155.135: Permission denied (publickey).

### **2. Non-root user with sudo**
Проверка: `id evgeniy` — есть в группе sudo? `sudo -l` — что разрешено?

#### Вывод:
eakramar@server-h9qt:~$ id eakramar
uid=1000(eakramar) gid=1000(eakramar) groups=1000(eakramar),27(sudo),100(users)
eakramar@server-h9qt:~$ sudo -l
[sudo] password for eakramar: 
Matching Defaults entries for eakramar on server-h9qt:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User eakramar may run the following commands on server-h9qt:
    (ALL : ALL) ALL
eakramar@server-h9qt:~$ whoami
eakramar

### **3. Automatic security updates (unattended-upgrades)**
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades

#### Проверка конфига
cat /etc/apt/apt.conf.d/50unattended-upgrades | grep -A1 "Allowed-Origins"
cat /etc/apt/apt.conf.d/20auto-upgrades

#### Форс-запуск для теста
sudo unattended-upgrade -d --dry-run 2>&1 | tail -20

#### Вывод:
root@server-h9qt:/home/eakramar# cat /etc/apt/apt.conf.d/50unattended-upgrades | grep -A1 "Allowed-Origins"
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
root@server-h9qt:/home/eakramar# cat /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "0";
root@server-h9qt:/home/eakramar# unattended-upgrade -d --dry-run 2>&1 | tail -20
Applying pinning: PkgFilePin(id=9, priority=-32768)
Applying pin -32768 to package_file: <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/ru-msk1.clouds.archive.ubuntu.com_ubuntu_dists_noble-backports_universe_binary-amd64_Packages'  a=noble-backports,c=universe,v=24.04,o=Ubuntu,l=Ubuntu arch='amd64' site='ru-msk1.clouds.archive.ubuntu.com' IndexType='Debian Package Index' Size=143929 ID:9>
Applying pinning: PkgFilePin(id=8, priority=-32768)
Applying pin -32768 to package_file: <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/ru-msk1.clouds.archive.ubuntu.com_ubuntu_dists_noble-backports_main_binary-amd64_Packages'  a=noble-backports,c=main,v=24.04,o=Ubuntu,l=Ubuntu arch='amd64' site='ru-msk1.clouds.archive.ubuntu.com' IndexType='Debian Package Index' Size=254753 ID:8>
Applying pinning: PkgFilePin(id=7, priority=-32768)
Applying pin -32768 to package_file: <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/ru-msk1.clouds.archive.ubuntu.com_ubuntu_dists_noble-updates_multiverse_binary-amd64_Packages'  a=noble-updates,c=multiverse,v=24.04,o=Ubuntu,l=Ubuntu arch='amd64' site='ru-msk1.clouds.archive.ubuntu.com' IndexType='Debian Package Index' Size=306681 ID:7>
Applying pinning: PkgFilePin(id=6, priority=-32768)
Applying pin -32768 to package_file: <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/ru-msk1.clouds.archive.ubuntu.com_ubuntu_dists_noble-updates_restricted_binary-amd64_Packages'  a=noble-updates,c=restricted,v=24.04,o=Ubuntu,l=Ubuntu arch='amd64' site='ru-msk1.clouds.archive.ubuntu.com' IndexType='Debian Package Index' Size=7506273 ID:6>
Applying pinning: PkgFilePin(id=5, priority=-32768)
Applying pin -32768 to package_file: <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/ru-msk1.clouds.archive.ubuntu.com_ubuntu_dists_noble-updates_universe_binary-amd64_Packages'  a=noble-updates,c=universe,v=24.04,o=Ubuntu,l=Ubuntu arch='amd64' site='ru-msk1.clouds.archive.ubuntu.com' IndexType='Debian Package Index' Size=10400042 ID:5>
Applying pinning: PkgFilePin(id=4, priority=-32768)
Applying pin -32768 to package_file: <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/ru-msk1.clouds.archive.ubuntu.com_ubuntu_dists_noble-updates_main_binary-amd64_Packages'  a=noble-updates,c=main,v=24.04,o=Ubuntu,l=Ubuntu arch='amd64' site='ru-msk1.clouds.archive.ubuntu.com' IndexType='Debian Package Index' Size=5879024 ID:4>
Using (^linux-.*-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^kfreebsd-.*-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^gnumach-.*-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^.*-modules-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^.*-kernel-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^linux-.*-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^kfreebsd-.*-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^gnumach-.*-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^.*-modules-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$|^.*-kernel-[1-9][0-9]*\.[0-9]+\.[0-9]+-[0-9]+(-.+)?$) regexp to find kernel packages
Using (^linux-.*-6\.8\.0\-35\-generic$|^linux-.*-6\.8\.0\-35$|^kfreebsd-.*-6\.8\.0\-35\-generic$|^kfreebsd-.*-6\.8\.0\-35$|^gnumach-.*-6\.8\.0\-35\-generic$|^gnumach-.*-6\.8\.0\-35$|^.*-modules-6\.8\.0\-35\-generic$|^.*-modules-6\.8\.0\-35$|^.*-kernel-6\.8\.0\-35\-generic$|^.*-kernel-6\.8\.0\-35$|^linux-.*-6\.8\.0\-35\-generic$|^linux-.*-6\.8\.0\-35$|^kfreebsd-.*-6\.8\.0\-35\-generic$|^kfreebsd-.*-6\.8\.0\-35$|^gnumach-.*-6\.8\.0\-35\-generic$|^gnumach-.*-6\.8\.0\-35$|^.*-modules-6\.8\.0\-35\-generic$|^.*-modules-6\.8\.0\-35$|^.*-kernel-6\.8\.0\-35\-generic$|^.*-kernel-6\.8\.0\-35$) regexp to find running kernel packages
pkgs that look like they should be upgraded: 
Fetched 0 B in 0s (0 B/s)                                                       
fetch.run() result: 0
Packages blacklist due to conffile prompts: []
No packages found that can be upgraded unattended and no pending auto-removals
The list of kept packages can't be calculated in dry-run mode.
root@server-h9qt:/home/eakramar# 

### **4. UFW настроен (эксперимент 2)**
Проверка: `sudo ufw status verbose` — active, минимум портов.

#### Вывод:

### **5. Fail2ban настроен (эксперимент 3)**
Проверка: `sudo fail2ban-client status sshd` — enabled.

#### Вывод:
root@server-h9qt:/home/eakramar# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                  
80/tcp                     ALLOW IN    Anywhere                   # HTTP
443/tcp                    ALLOW IN    Anywhere                   # HTTPS
22/tcp (v6)                ALLOW IN    Anywhere (v6)             
80/tcp (v6)                ALLOW IN    Anywhere (v6)              # HTTP
443/tcp (v6)               ALLOW IN    Anywhere (v6)              # HTTPS


### **6. Отключены неиспользуемые сервисы**
#### Что вообще слушает наружу?
sudo ss -tlnp | grep -v '127\.0\.0\.1\|::1'
#### Если видишь что-то незнакомое — разбираться
#### Классические кандидаты на отключение: rpcbind, avahi-daemon, cups
sudo systemctl disable --now avahi-daemon 2>/dev/null || true

#### Вывод:
State  Recv-Q Send-Q Local Address:Port Peer Address:PortProcess                                                                            
LISTEN 0      4096   127.0.0.53%lo:53        0.0.0.0:*    users:(("systemd-resolve",pid=9792,fd=15))                                        
LISTEN 0      511          0.0.0.0:443       0.0.0.0:*    users:(("nginx",pid=52327,fd=7),("nginx",pid=52326,fd=7),("nginx",pid=52325,fd=7))
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=52327,fd=8),("nginx",pid=52326,fd=8),("nginx",pid=52325,fd=8))
LISTEN 0      4096         0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=79247,fd=3),("systemd",pid=1,fd=92))                           
LISTEN 0      4096      127.0.0.54:53        0.0.0.0:*    users:(("systemd-resolve",pid=9792,fd=17))                                        
LISTEN 0      4096            [::]:22           [::]:*    users:(("sshd",pid=79247,fd=4),("systemd",pid=1,fd=99)) 


### **7. SSH-порт возможно поменян (защита от ботов, не от целевой атаки)**
#### Опционально — я лично считаю необязательным
#### Если делать — не забыть открыть ufw на новом порту
sudo ufw allow 22022/tcp
#### И только потом менять в sshd_config

#### Вывод:
считаю необязательным

### **8. /etc в git (простой аудит изменений)**
sudo apt install etckeeper -y
#### Автоматически хранит /etc в git, коммит при apt install/upgrade

#### Вывод:
Проверить у себя после установки:
sudo ls -la /etc/.git
sudo git -C /etc log --oneline | head -20
Покажется история коммитов — вида «committing changes in /etc after apt run», «daily autocommit» и т.д.

### **9. Проверка целостности пакетов (опционально)**
sudo apt install debsums -y
sudo debsums -s  # покажет изменённые файлы пакетов

#### Вывод:

[master 434362c] committing changes in /etc made by "apt install debsums -y"
 Author: eakramar <eakramar@server-h9qt.novalocal>
 5 files changed, 95 insertions(+)
 create mode 100755 cron.daily/debsums
 create mode 100755 cron.monthly/debsums
 create mode 100755 cron.weekly/debsums
 create mode 100644 default/debsums
root@server-h9qt:/home/eakramar# debsums -s



### **10. Разумные ограничения по ресурсам (fork bomb protection)**
#### /etc/security/limits.conf
#### * hard nproc 4096
#### * hard nofile 65535

### **Что записать в артефакт:** `initial-server-hardening.sh` — bash-скрипт (даже если не идемпотентный пока), который применяет пункты 1-8. В юните 6 сделаешь его идемпотентным.
#### Вывод:
Готово.

### **Вопросы:**
- Зачем менять SSH-порт если fail2ban всё равно защищает?
Для того, чтобы меньше сканировали боты, но при целевой атаке не поможет.
- Что произойдёт если unattended-upgrades накатит критическое обновление ядра?
В работе будет предыдущая версия ядра, до перезагрузки сервера.
- В чём отличие `PermitRootLogin no` от `PermitRootLogin prohibit-password`?
PermitRootLogin no - полностью отключает авторизацию под root
PermitRootLogin prohibit-password - если нужен root по ключу

# Эксперимент 5 📺 — nftables руками (для понимания что под ufw)

**Что делаем:** пишем пару правил напрямую на nftables — чтобы понимать что ufw делает под капотом.

**Команды:**
### ВНИМАНИЕ: если у тебя работает ufw — сначала разберись как временно отключить
#### Или делай это на отдельной виртуалке!

### Посмотреть текущий ruleset (если ufw включён — увидишь его правила)
sudo nft list ruleset

#### Вывод:
root@hardening:/home/eakramar# nft list ruleset
root@hardening:/home/eakramar# 

### Создать свою таблицу и цепочку с нуля (пример)
sudo nft add table inet myfilter
sudo nft add chain inet myfilter input { type filter hook input priority 0 \; policy drop \; }

#### Вывод:
root@hardening:/home/eakramar# nft add table inet myfilter
root@hardening:/home/eakramar# nft list ruleset
table inet myfilter {
}
root@hardening:/home/eakramar# sudo nft add chain inet myfilter input { type filter hook input priority 0 \; policy accept \; }
root@hardening:/home/eakramar# nft list ruleset
table inet myfilter {
	chain input {
		type filter hook input priority filter; policy accept;
	}
}


### Разрешить loopback
sudo nft add rule inet myfilter input iif lo accept

#### Вывод:
root@hardening:/home/eakramar# sudo nft add rule inet myfilter input iif lo accept
root@hardening:/home/eakramar# nft list ruleset
table inet myfilter {
	chain input {
		type filter hook input priority filter; policy accept;
		iif "lo" accept
	}
}


### Разрешить established соединения (иначе даже curl отвалится)
sudo nft add rule inet myfilter input ct state established,related accept

#### Вывод:
root@hardening:/home/eakramar# sudo nft add rule inet myfilter input ct state established,related accept
root@hardening:/home/eakramar# nft list ruleset
table inet myfilter {
	chain input {
		type filter hook input priority filter; policy accept;
		iif "lo" accept
		ct state established,related accept
	}
}

### Разрешить SSH
sudo nft add rule inet myfilter input tcp dport 22 accept

#### Вывод:
root@hardening:/home/eakramar# sudo nft add rule inet myfilter input tcp dport 22 accept
root@hardening:/home/eakramar# nft list ruleset
table inet myfilter {
	chain input {
		type filter hook input priority filter; policy accept;
		iif "lo" accept
		ct state established,related accept
		tcp dport 22 accept
	}
}
root@hardening:/home/eakramar# clear
root@hardening:/home/eakramar# sudo nft add chain inet myfilter input { type filter hook input priority 0 \; policy drop \; }
root@hardening:/home/eakramar# nft list ruleset
table inet myfilter {
	chain input {
		type filter hook input priority filter; policy drop;
		iif "lo" accept
		ct state established,related accept
		tcp dport 22 accept
	}
}

### Смотрим что получилось
sudo nft list table inet myfilter

#### Вывод:
root@hardening:/home/eakramar# nft list table inet myfilter
table inet myfilter {
	chain input {
		type filter hook input priority filter; policy drop;
		iif "lo" accept
		ct state established,related accept
		tcp dport 22 accept
	}
}


### Убрать всё (не забудь если экспериментировал!)
sudo nft delete table inet myfilter

#### Вывод:
root@hardening:/home/eakramar# nft delete table inet myfilter
root@hardening:/home/eakramar# nft list ruleset
root@hardening:/home/eakramar# 

### **Что записать:**
- Что такое `table inet`
dual-stack, IPv4+IPv6 в одной таблице
- Что такое `hook input priority 0`
куда в netfilter-цепочке вклиниться
- Что такое `ct state established,related`
пропускать пакеты уже установленных соединений — это ключ понимания как stateful firewall работает

### **Вопросы:**
- Почему без правила про established connections curl не работает даже если SSH разрешён?
SSH — входящее соединение к фиксированному порту 22. Правило dport 22 accept матчит каждый пакет этой сессии. Curl — исходящее соединение с сервера на удалённый сервер (например, google:443). Ответы (SYN-ACK, данные) приходят обратно на сервер, но с destination port = эфемерный случайный порт, который выбрал curl. Нельзя написать правило под этот случайный порт — он неизвестен заранее и разный для каждого соединения. Правило ct state established,related accept решает эту проблему: оно пропускает любой входящий пакет, который является ответом на уже открытое тобой соединение. Conntrack знает, что ты открыл соединение с google:443, и распознаёт входящие пакеты как его продолжение.
- Что произойдёт с активной SSH-сессией если я поставлю policy drop без соответствующего правила?
обрыв соединения, ssh перестанет работать
- В чём принципиальная разница nftables и iptables?
единый инструмент nft, атомарные апдейты, поддержка dual-stack, сокращённый синтаксис