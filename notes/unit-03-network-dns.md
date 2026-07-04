## Ключевые выводы для дежурства

### Что такое состояние `LISTEN`, `ESTABLISHED`, `TIME-WAIT`? `Это TCP-состояния: LISTEN, ESTABLISHED, TIME-WAIT. LISTEN - Сокет открыт и ждёт входящих подключений, но сам ещё ни с кем не соединён. Это состояние сервера, а не клиента — процесс сделал bind() на порт и listen(), и теперь просто "висит" в ожидании, пока кто-то не постучится. ESTABLISHED - Полноценное, двустороннее TCP-соединение после успешного three-way handshake (SYN → SYN-ACK → ACK). В этом состоянии обе стороны могут свободно обмениваться данными в обе стороны. TIME-WAIT - Одно из самых непонятных на первый взгляд состояний. Оно возникает после закрытия соединения — сторона, которая первой инициировала закрытие (отправила FIN), переходит в TIME-WAIT и остаётся в нём некоторое время (обычно 60 секунд, зависит от net.ipv4.tcp_fin_timeout), прежде чем сокет окончательно освобождается.`
### В DNS-трафике видишь имена доменов в открытом виде? `да, DNS без DoH/DoT — plaintext`
### В HTTP видишь содержимое страницы? `да`
### В HTTPS видишь что-то осмысленное? `нет, после handshake — шифр`
### Что такое SYN, SYN-ACK, ACK в выводе tcpdump? `это TCP 3-way handshake`
### DS запись `отвечает за цепочку доверия, в ней указан алгоритм шифорования и сам ключ. Эта запись храниться на корневом сервере которая удостоверяет зону и говорит о том, что ей можно доверять.`
### RRSIG запись `по сути показывает, что DS запись не подделана.`
### NSEC3 запись `отвечает за доказательство отсутствия записи, идет в паре с RRSIG-записью как и в случае с DS-записью.`
### dig +trace `переключает трассировку путей делегирования через корневые имена серверов и по умолчанию, без аргумента +trace эта трассировка через корневые не работает`.
### +cmd `отвечает за отображение первоночальных комментариев`
### За что отвечают флаги заголовка в DNS-ответа - qr aa rd ra `qr - Query Response, aa - Authoritative Answer, rd - Recursion Desired, ra - Recursion Available`
### tcpdump -i any — `слушать все интерфейсы`
### tcpdump -n — `не резолвить имена (быстрее, чище вывод)`
### tcpdump -A — `печатать payload в ASCII`
### tcpdump -s 0 — `захватывать пакет целиком (без обрезки)`
### tcpdump -c 10 — `захватить только 10 пакетов и выйти`
### tcpdump -w file.pcap — `сохранить в файл (потом можно открыть в Wireshark)`

## Эксперимент 1: DNS-резолвинг через dig +trace
[команды, вывод, "что я понял"]

### Вывод команды:
root@dnscache:/home/eakramar# dig +trace eakramar.ru

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> +trace eakramar.ru
;; global options: +cmd
.			4502	IN	NS	k.root-servers.net.
.			4502	IN	NS	g.root-servers.net.
.			4502	IN	NS	l.root-servers.net.
.			4502	IN	NS	b.root-servers.net.
.			4502	IN	NS	j.root-servers.net.
.			4502	IN	NS	a.root-servers.net.
.			4502	IN	NS	h.root-servers.net.
.			4502	IN	NS	m.root-servers.net.
.			4502	IN	NS	c.root-servers.net.
.			4502	IN	NS	f.root-servers.net.
.			4502	IN	NS	d.root-servers.net.
.			4502	IN	NS	e.root-servers.net.
.			4502	IN	NS	i.root-servers.net.
;; Received 239 bytes from 127.0.0.53#53(127.0.0.53) in 143 ms

;; UDP setup with 2001:500:12::d0d#53(2001:500:12::d0d) for eakramar.ru failed: network unreachable.
;; no servers could be reached
;; UDP setup with 2001:500:12::d0d#53(2001:500:12::d0d) for eakramar.ru failed: network unreachable.
;; no servers could be reached
;; UDP setup with 2001:500:12::d0d#53(2001:500:12::d0d) for eakramar.ru failed: network unreachable.
;; UDP setup with 2001:500:a8::e#53(2001:500:a8::e) for eakramar.ru failed: network unreachable.
ru.			172800	IN	NS	a.dns.ripn.net.
ru.			172800	IN	NS	b.dns.ripn.net.
ru.			172800	IN	NS	d.dns.ripn.net.
ru.			172800	IN	NS	e.dns.ripn.net.
ru.			172800	IN	NS	f.dns.ripn.net.
ru.			86400	IN	DS	51575 8 2 34CF735353060D9BD6347FF81ECFAAC24EC8F11971DC800249C64A21 BC062775
ru.			86400	IN	RRSIG	DS 8 1 86400 20260711050000 20260628040000 54393 . DeE3Mpn9bWOht93m22zW4aIUKic6m/Co8Uq/RIuXaJZ9zSUhwjwoBHUA VBAMRhChGEKE44uKahDcAAnKDDSH2VpVBhNmDSm72vpeE2Qs5skk/Fsl 9C3iqNK+ZAcPZMJEz72JNNaSN61bE8kHTEgTiNl8UIcgADgxVjHkKGad PQjffSVabC7BfoxHa1rEQjvt5mFPUEt8nrBUm8ZkAmQ9uU+W9c0KxoXv 2iLPK8m9lCWuJaM/VVJyU9OIwrlwf+MYpCWhNvT/bTtMY12Pkm5A5IOe MCYo22MO0seOAupiQ9uEJlurI1nfk9qLDaHz9KGJHaMjFm14btKNEkGH iHzKDA==
;; Received 687 bytes from 199.7.83.42#53(l.root-servers.net) in 223 ms

;; UDP setup with 2001:678:17:0:193:232:128:6#53(2001:678:17:0:193:232:128:6) for eakramar.ru failed: network unreachable.
;; UDP setup with 2001:678:14:0:193:232:156:17#53(2001:678:14:0:193:232:156:17) for eakramar.ru failed: network unreachable.
eakramar.ru.		345600	IN	NS	lennox.ns.cloudflare.com.
eakramar.ru.		345600	IN	NS	lara.ns.cloudflare.com.
j20c0qkdhua3cumnkst289ff06u2sq91.ru. 3600 IN NSEC3 1 1 0 - J21LULR2UNPA28SERE28OVNJNJ67QP7V NS SOA RRSIG DNSKEY NSEC3PARAM
j20c0qkdhua3cumnkst289ff06u2sq91.ru. 3600 IN RRSIG NSEC3 8 2 3600 20260801001354 20260622081619 27691 ru. b8PdTj8+/DuYpbGuAYLBmg8OwskIISfa5fExCpK2T8qIHecPO0u6zYTQ mYIwahs8zoPcdJTp+4MiaFfEAaNTYaENGj+Hi3i7L3rmHofYzhO+201o REIjoxRywnmf+OlpXIT0EtRIn7gQHRpMVExhWJpEKCNQaPIbQet6BVHi iqo=
jh9ls4qtf53p614htp6qecobcq1cgktl.ru. 3600 IN NSEC3 1 1 0 - JI8GJ9R47S8E8VBP2VLM1PRN6HJ38RBP NS DS RRSIG
jh9ls4qtf53p614htp6qecobcq1cgktl.ru. 3600 IN RRSIG NSEC3 8 2 3600 20260801143503 20260626081626 27691 ru. Dxv7dQDPtpDWgERwPDa09gdPxsHbHu14p5A8WAsi5f9cjTvlzIhUz60R JJlTO/a9SVFHTCB8e8ddxuvvTFjvlRHHgWzRnG5iB58rLBkxFVsxC/Fe pLPsRvj8H8AMPNIYwMCqVIZSR+u2vJ81ZR7JQpfxJxuyvcCwd/jflBPM LhU=
;; Received 580 bytes from 194.85.252.62#53(b.dns.ripn.net) in 126 ms

;; UDP setup with 2606:4700:50::adf5:3a80#53(2606:4700:50::adf5:3a80) for eakramar.ru failed: network unreachable.
;; UDP setup with 2606:4700:58::a29f:2cd6#53(2606:4700:58::a29f:2cd6) for eakramar.ru failed: network unreachable.
eakramar.ru.		300	IN	A	172.67.130.237
eakramar.ru.		300	IN	A	104.21.3.160
;; Received 72 bytes from 108.162.195.214#53(lennox.ns.cloudflare.com) in 86 ms

#### Вывод по команде:
1) Первое, что считаю нужным написать это то, что руководство "man dig" говорит о том, что +trace переключает трассировку путей делегирования через корневые имена серверов и то что по умолчанию, без аргумента +trace эта трассировка через корневые не работает. Так же в руководстве написано, что отображает ответы от каждого сервера, который был испольщован для разрешения поиска.
2) Первый вывод команды, который я вижу: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> +trace eakramar.ru", здесь указана версия dig (9.18.39-0), версия ОС (24.04.5-Ubuntu) и аргументы, которые получила команда dig (+trace eakramar.ru).
3) Дальше выводятся глобальные опции, в моем случае это +cmd. Прочитав руководство я так понял, что эта опция отвечает за отображение первоночальных комментариев: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> +trace eakramar.ru", по умолчанию включено.
4) Дальше, судя по выводу команды, идет прием данных с локального хоста, который вернул строки с корневыми серверами и строку с информацией о принятых данных: ";; Received 239 bytes from 127.0.0.53#53(127.0.0.53) in 143 ms". Я понял так, что в первую очередь DNS-запрос идет на локальный DNS сервер или в соответствии с файлом /etc/resolv.conf
5) На следующем этапе приходит информация от корневого сервера l.root-servers.net: ";; Received 687 bytes from 199.7.83.42#53(l.root-servers.net) in 223 ms", еще в ней указано, что получены ответы по TLD от a.dns.ripn.net., b.dns.ripn.net., d.dns.ripn.net., e.dns.ripn.net., f.dns.ripn.net., с какими то серверами соединиться не удалось и так же в этом ответе я увидел две новые для себя записи: DS и RRSIG. DS запись отвечает за цепочку доверия в ней указан алгоритм шифорования: "8 2" - RSA/SHA-256, и сам ключ. Эта запись храниться на корневом сервере которая удостоверяет зону ru. и говорит о том, что ей можно доверять. RRSIG запись по сути показывает, что DS запись не подделана, а так же в ней можено увидеть: "8 1" - RSA/SHA-256, 86400 - TTL в секундах, 20260711050000 - до какого момента действует, 20260628040000 - с какого момента действует, 54393 - id подписи, . - кем подписано (корневой сервер), дальше сама подпись.
6) Следующий этап - ответ от серевера b.dns.ripn.net, в нем видно: ";; Received 580 bytes from 194.85.252.62#53(b.dns.ripn.net) in 126 ms", а также, видно, что с какими то серверами соединение не установлено, видно, что информация о искомом имени хранится на серверах: lennox.ns.cloudflare.com., lara.ns.cloudflare.com. Так же, для меня появилась еще одна незнакомая запись - NSEC3, она отвечает за доказательство отсутствия записи, идет в паре с RRSIG-записью как и в случае с DS-записью. j20c0qkdhua3cumnkst289ff06u2sq91.ru. - хешированное имя записи (хешированно для того, чтобы нельзя было узнать какие домены есть на сервере, в отличие от NSEC1), 3600 - TTL, 1 - хеш алгоритм SHA-1, 1 - вообще сам не понял, но это флаг opt-out, 0 - сколько раз хешировать (0 раз),  - - соль для хэша (здесь отсутствует),J21LULR2UNPA28SERE28OVNJNJ67QP7V - хеш следующей записи, NS SOA RRSIG DNSKEY NSEC3PARAM - какие типы записей существуют у текущего имени.
7) На последнем этапе получены непосредственно адреса до доменных имен от lennox.ns.cloudflare.com: eakramar.ru. - 172.67.130.237, 104.21.3.160 С сервером lara.ns.cloudflare.com. соединение не удалось установить. Ну и информация о получении: ";; Received 72 bytes from 108.162.195.214#53(lennox.ns.cloudflare.com) in 86 ms".

#### Что я понял:
Я понял, что утилита dig может помагать отлаживать работу DNS-протокола, так же, познакомился со схемой работы опции +trace, которая делает трассировку с корневых серверов и возвращает подробный ответ от каждого из них.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36222
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	A

;; ANSWER SECTION:
eakramar.ru.		377	IN	A	104.21.3.160
eakramar.ru.		377	IN	A	172.67.130.237

;; Query time: 248 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 08:31:00 UTC 2026
;; MSG SIZE  rcvd: 72


#### Вывод по команде:
1) Обычный запрос утилитой dig, который возвращает ip адрес доменного имени и другую отладочную информацию
2) Первый вывод команды, который я вижу: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru", здесь указана версия dig (9.18.39-0), версия ОС (24.04.5-Ubuntu) и аргументы, которые получила команда dig (eakramar.ru).
3) Дальше выводятся глобальные опции, в моем случае это +cmd. Прочитав руководство я так понял, что эта опция отвечает за отображение первоночальных комментариев: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru", по умолчанию включено.
4) Дальше выводится секция: "Got answer", в которой есть следующая информация о заголовках: ;; opcode: QUERY - тип операции (обычный запрос), status: NOERROR - без ошибок, id: 36222 - id по которому соспостовляются запрос и ответ, ;; flags: qr - Query Response, rd - Recursion Desired, ra - Recursion Available, флага aa нет - ответил не авторитативный сервер; QUERY: 1 - один вопрос в запросе, ANSWER: 2 - две ресурсных записи в ответе, AUTHORITY: 0 - секция авторитативных серверов пуста, ADDITIONAL: 1 - одна дополнительная запись.
5) На следующем этапе отображается информация о псевдосекции и секции запроса. ;; OPT PSEUDOSECTION: ; EDNS: version: 0 - версия EDNS (расширение DNS, которое позволяет передавать большие пакеты и флаги вроде DNSSEC), flags: - пусто — DNSSEC-валидация не запрошена (не было +dnssec); udp: 65494 - максимальный размер UDP-пакета
;; QUESTION SECTION: ;eakramar.ru.			IN	A - это сам вопрос, который dig отправил: «дай мне A-запись для eakramar.ru».
6) Следующий этап - секция ответа, в ней видно ip адреса для запрашиваемого поиска. 
7) На последнем этапе получена информация: ;; Query time: 248 msec - указано время выполнения запроса ;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP) - сервер вернувший DNS-ответ ;; WHEN: Sun Jun 28 08:31:00 UTC 2026 - Дата и время запроса ;; MSG SIZE  rcvd: 72 - объем сообщения в байтах.

#### Что я понял:
Я понял, что утилита dig без опций кроме искомого имени выводит больше заголовков чем с опцией +trace, ну и соответственно не выводит информацию откаждого сервера, участвуещего в рекурсии (если она была, возможно ответ был в кэше 127.0.0.53).

### Вывод команды:
root@dnscache:/home/eakramar# dig @lennox.ns.cloudflare.com eakramar.ru

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> @lennox.ns.cloudflare.com eakramar.ru
; (6 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27159
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;eakramar.ru.			IN	A

;; ANSWER SECTION:
eakramar.ru.		300	IN	A	188.114.96.4
eakramar.ru.		300	IN	A	188.114.97.4

;; Query time: 237 msec
;; SERVER: 162.159.44.214#53(lennox.ns.cloudflare.com) (UDP)
;; WHEN: Sun Jun 28 08:40:24 UTC 2026
;; MSG SIZE  rcvd: 72

#### вывод по команде:
1) Запрос через указанный сервер утилитой dig, который возвращает ip адрес доменного имени и другую отладочную информацию
2) Первый вывод команды, который я вижу: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> @lennox.ns.cloudflare.com eakramar.ru", здесь указана версия dig (9.18.39-0), версия ОС (24.04.5-Ubuntu) и аргументы, которые получила команда dig (@lennox.ns.cloudflare.com eakramar.ru).
3) Дальше выводятся глобальные опции, в моем случае это +cmd. Прочитав руководство я так понял, что эта опция отвечает за отображение первоночальных комментариев: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> @lennox.ns.cloudflare.com eakramar.ru", по умолчанию включено.
4) Дальше выводится секция: "Got answer", в которой есть следующая информация о заголовках: ;; opcode: QUERY - тип операции (обычный запрос), status: NOERROR - без ошибок, id: 27159 - id по которому соспостовляются запрос и ответ, ;; flags: qr - Query Response, aa - Authoritative Answer (ответ от авторитативного сервера), rd - Recursion Desire; QUERY: 1 - один вопрос в запросе, ANSWER: 2 - две ресурсных записи в ответе, AUTHORITY: 0 - секция авторитативных серверов пуста, ADDITIONAL: 1 - одна дополнительная запись;; WARNING: recursion requested but not available - dig увидел несоответствие и честно предупредил, то есть клиент ожидал рекурсию, но сервер не дал флаг ra.
5) На следующем этапе отображается информация о псевдосекции и секции запроса. ;; OPT PSEUDOSECTION: ; EDNS: version: 0 - версия EDNS (расширение DNS, которое позволяет передавать большие пакеты и флаги вроде DNSSEC), flags: - пусто — DNSSEC-валидация не запрошена (не было +dnssec); udp: 1232 - максимальный размер UDP-пакета
;; QUESTION SECTION: ;eakramar.ru.			IN	A - это сам вопрос, который dig отправил: «дай мне A-запись для eakramar.ru».
6) Следующий этап - секция ответа, в ней видно ip адреса для запрашиваемого поиска. Другие адреса потому что у Claudeflare есть anycast, то есть они делают балансировку нагрузки в зависимости от местоположения.
7) На последнем этапе получена информация: ;; Query time: 237 msec - указано время выполнения запроса ;; SERVER: 162.159.44.214#53(lennox.ns.cloudflare.com) (UDP) - сервер вернувший DNS-ответ ;; WHEN: Sun Jun 28 08:40:24 UTC 2026 - Дата и время запроса ;; MSG SIZE  rcvd: 72 - объем сообщения в байтах.

#### Что я понял:
Я понял, что утилита dig с поиском через авторитативный сервер ищет информацию также как и предыдущая, поменялись флаги в заголовках и немного другой механизм, то есть то, что сервер отказал в рекурсии, по скольку он является корневым и также, вернул другие адреса, потому что применилась тезнология anycast.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19000
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	A

;; ANSWER SECTION:
eakramar.ru.		377	IN	A	172.67.130.237
eakramar.ru.		377	IN	A	104.21.3.160

;; Query time: 163 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 08:43:36 UTC 2026
;; MSG SIZE  rcvd: 72

#### Вывод по команде:
1) Обычный запрос утилитой dig, который возвращает ip адрес доменного имени и другую отладочную информацию
2) Первый вывод команды, который я вижу: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru", здесь указана версия dig (9.18.39-0), версия ОС (24.04.5-Ubuntu) и аргументы, которые получила команда dig (eakramar.ru).
3) Дальше выводятся глобальные опции, в моем случае это +cmd. Прочитав руководство я так понял, что эта опция отвечает за отображение первоночальных комментариев: "; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru", по умолчанию включено.
4) Дальше выводится секция: "Got answer", в которой есть следующая информация о заголовках: ;; opcode: QUERY - тип операции (обычный запрос), status: NOERROR - без ошибок, id: 19000 - id по которому соспостовляются запрос и ответ, ;; flags: qr - Query Response, rd - Recursion Desired, ra - Recursion Available, флага aa нет - ответил не авторитативный сервер; QUERY: 1 - один вопрос в запросе, ANSWER: 2 - две ресурсных записи в ответе, AUTHORITY: 0 - секция авторитативных серверов пуста, ADDITIONAL: 1 - одна дополнительная запись.
5) На следующем этапе отображается информация о псевдосекции и секции запроса. ;; OPT PSEUDOSECTION: ; EDNS: version: 0 - версия EDNS (расширение DNS, которое позволяет передавать большие пакеты и флаги вроде DNSSEC), flags: - пусто — DNSSEC-валидация не запрошена (не было +dnssec); udp: 65494 - максимальный размер UDP-пакета
;; QUESTION SECTION: ;eakramar.ru.			IN	A - это сам вопрос, который dig отправил: «дай мне A-запись для eakramar.ru».
6) Следующий этап - секция ответа, в ней видно ip адреса для запрашиваемого поиска. 
7) На последнем этапе получена информация: ;; Query time: 163 msec - указано время выполнения запроса ;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP) - сервер вернувший DNS-ответ ;; WHEN: Sun Jun 28 08:43:36 UTC 2026 - Дата и время запроса ;; MSG SIZE  rcvd: 72 - объем сообщения в байтах.

#### Что я понял:
Я понял, что время ответа в этот раз было меньше чем в предыдущий, это объясняется тем, что с прошлого раза локальный сервер закэшировал запись и в этот раз запросу не пришлось связываться с сервером, который далеко.


## Эксперимент 2: Все типы DNS-записей на твоём домене
[команды, вывод, "что я понял"]

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru A

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru A
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60707
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	A

;; ANSWER SECTION:
eakramar.ru.		377	IN	A	104.21.3.160
eakramar.ru.		377	IN	A	172.67.130.237

;; Query time: 227 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:22:40 UTC 2026
;; MSG SIZE  rcvd: 72


#### Вывод по команде:
По сути все тоже самое, что и в первом эксперименте, но в аргумент добавился тип искомой записи - A. Этот тип указывает на то, чтобы найти для доменного имени ip адрес 4 версии.

#### Что я понял:
Я увидел на практике как можно пользоваться аргументом указания типа запроса для поиска.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru AAAA

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru AAAA
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8733
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	AAAA

;; ANSWER SECTION:
eakramar.ru.		377	IN	AAAA	2606:4700:3034::ac43:82ed
eakramar.ru.		377	IN	AAAA	2606:4700:3033::6815:3a0

;; Query time: 195 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:26:01 UTC 2026
;; MSG SIZE  rcvd: 96


#### Вывод по команде:
Из новенького видно, что указан тип записи - AAAA. Этот тип разрешает для доменных имен ip адреса версии 6.

#### Что я понял:
Понял на примере, как разрешать имена в ip адреса версии 6.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru MX

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru MX
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19982
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	MX

;; AUTHORITY SECTION:
eakramar.ru.		1800	IN	SOA	lara.ns.cloudflare.com. dns.cloudflare.com. 2406725644 10000 2400 604800 1800

;; Query time: 882 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:26:46 UTC 2026
;; MSG SIZE  rcvd: 102


#### Вывод по команде:
1) Первое, что увидел это тип записи для почты - MX.
2) Следующее, что бросается в глаза - это то, что в заголовках ответов - 0, но зато в authority - 1. Связано это с тем, что для доменного имени eakramar.ru MX-записей нет и сервер вернул SOA-запись.
3) Время запроса тоже дольше чем обычно, я думаю, что это связано с тем, что поиск MX был в первый раз.
4) Содержимое авторитетной секции: SOA-запись - это главная запись зоны -  описывает саму зону и параметры её обслуживания, lara.ns.cloudflare.com. - главный авторитативный сервер зоны, dns.cloudflare.com. - email администратора (. вместо @), 2406725644 - (Serial) версия зоны, вторичные серверы сверяют с этим числом, 10000 - как часто вторичный сервер проверяет обновления (сек), 2400 - если не смог связаться — повторить через (сек), 604800 если долго нет связи — считать зону устаревшей через (сек),  1800 - сколько кэшировать отрицательный ответ (сек).
5) Последнее число 1800 — это именно то, зачем SOA вернулась в этом запросе. Резолвер прочитает его и будет 30 минут помнить: «MX для eakramar.ru не существует» — и не беспокоить сервер повторными запросами.

#### Что я понял:
Я понял на опыте как делать запрос для MX-записи. Увидел как работает механизм, когда записи нет - возвращеет авторитетную секцию с SOA-записью, в которой указывает NegativeTTL (время, которое указывает сколько нужно не беспокоить с таким запросом сервер, в нашем случае 1800 секунд или пол часа)

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru NS

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru NS
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 63617
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	NS

;; ANSWER SECTION:
eakramar.ru.		4502	IN	NS	lara.ns.cloudflare.com.
eakramar.ru.		4502	IN	NS	lennox.ns.cloudflare.com.

;; Query time: 233 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:27:37 UTC 2026
;; MSG SIZE  rcvd: 97



#### Вывод по команде:
1) Новый тип запроса - NS-сервер, это запись запрашивающая авторитетные сервера для доменной зоны.
2) В секции ответа указаны эти сервера.

#### Что я понял:
Я понял на примере, как запрашивать авторитетные сервера для доменных зон.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru TXT

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru TXT
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 41133
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	TXT

;; AUTHORITY SECTION:
eakramar.ru.		1800	IN	SOA	lara.ns.cloudflare.com. dns.cloudflare.com. 2406725644 10000 2400 604800 1800

;; Query time: 177 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:28:20 UTC 2026
;; MSG SIZE  rcvd: 102


#### Вывод по команде:
1) В этом случае запрашивается TXT-запись. Она нужна для ...
2) Так же, как и с MX-записью вместо секции ответа вернулась авторитативная секция с SOA-записью, которая говорит о том, что TXT-записи на сервере нет.
3) Но если бы TXT-запись была, могло вернуться что то такое: eakramar.ru.  300  IN  TXT  "v=spf1 include:_spf.google.com ~all" или eakramar.ru.  300  IN  TXT  "google-site-verification=abc123...". v=spf1 - SPF, кто имеет право слать почту от домена; v=DKIM1 - DKIM, публичный ключ для подписи писем; v=DMARC1 - DMARC, политика обработки почты; google-site-verificatio - подтверждение владения доменом;
5) У меня сейчас TXT пуст — значит почта через домен не настроена и верификаций нет.

#### Что я понял:
Понял как работает TXT-запрос на примере.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru SOA

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru SOA
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29546
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	SOA

;; ANSWER SECTION:
eakramar.ru.		2252	IN	SOA	lara.ns.cloudflare.com. dns.cloudflare.com. 2406725644 10000 2400 604800 1800

;; Query time: 172 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:29:14 UTC 2026
;; MSG SIZE  rcvd: 102


#### Вывод по команде:
Параметр SOA запрашивает SOA-запись

#### Что я понял:
Ни чего нового

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru CAA

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru CAA
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 45837
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	CAA

;; AUTHORITY SECTION:
eakramar.ru.		1800	IN	SOA	lara.ns.cloudflare.com. dns.cloudflare.com. 2406725644 10000 2400 604800 1800

;; Query time: 174 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:30:07 UTC 2026
;; MSG SIZE  rcvd: 102

#### Вывод по команде:
1) Тот же паттерн — CAA отсутствует, SOA пришла как доказательство этого факта.
2) А вообще, CAA (Certificate Authority Authorization) — запись, которая указывает, каким сертификационным центрам разрешено выпускать SSL/TLS-сертификаты для домена. Это защита от выпуска левого сертификата на твой домен какой-нибудь скомпрометированной или левой CA.
3) Запись могла выглядеть следующим образом: eakramar.ru.   3600  IN  CAA  0 issue "letsencrypt.org" или eakramar.ru.   3600  IN  CAA  0 issuewild "letsencrypt.org" или eakramar.ru.   3600  IN  CAA  0 iodef "mailto:admin@eakramar.ru"
4) Flags 0 = некритичный, 128 = критичный (CA обязан понять тег)
5) Tag issue разрешение на обычные сертификаты
6) Tag issuewild разрешение на wildcard-сертификаты (*.eakramar.ru)
7) Tag iodef куда слать отчёт о нарушении политики
8) Value "letsencrypt.org" имя разрешённой CA

#### Что я понял: 
Если на сервере нет записи возвращает как обычно SOA-запись, если есть то возвращает ответ, в котором можно увидеть сертификаты для домена.

### Вывод команды:
root@dnscache:/home/eakramar# dig eakramar.ru ANY

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru ANY
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62933
;; flags: qr rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	ANY

;; ANSWER SECTION:
eakramar.ru.		70	IN	AAAA	2606:4700:3034::ac43:82ed
eakramar.ru.		70	IN	AAAA	2606:4700:3033::6815:3a0
eakramar.ru.		4291	IN	NS	lara.ns.cloudflare.com.
eakramar.ru.		4291	IN	NS	lennox.ns.cloudflare.com.
eakramar.ru.		2138	IN	SOA	lara.ns.cloudflare.com. dns.cloudflare.com. 2406725644 10000 2400 604800 1800

;; Query time: 8 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (TCP)
;; WHEN: Sun Jun 28 12:31:09 UTC 2026
;; MSG SIZE  rcvd: 193


#### Вывод по команде:
1) Тип запроса ANY, возвращает все типы записей, какие есть у этого имени.
2) Но вернул все кроме A-записи. Это объясняется тем, что современные авторитативные DNS-серверы (Cloudflare в их числе) не отвечают на ANY честно из-за DDoS-амплификации. RFC 8482 — официально разрешает серверам отвечать на ANY не полным набором, а тем, что есть в кэше или произвольным подмножеством.
3) Запрос пошёл через TCP, не UDP. Скорее всего, резолвер сначала попробовал UDP, получил флаг TC (truncated — не уместилось) или сервер сам инициировал переключение, и dig автоматически повторил запрос по TCP.

#### Что я понял:
ANY сегодня — фактически бесполезный тип запроса на практике. Если нужны конкретные данные — лучше явно спрашивать A, AAAA, MX, TXT, NS по отдельности.

### Вывод команды:
root@dnscache:/home/eakramar# dig -x 1.1.1.1

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> -x 1.1.1.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 22686
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;1.1.1.1.in-addr.arpa.		IN	PTR

;; ANSWER SECTION:
1.1.1.1.in-addr.arpa.	1084	IN	PTR	one.one.one.one.

;; Query time: 157 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:31:54 UTC 2026
;; MSG SIZE  rcvd: 78

#### Вывод по команде:
1) Первое, что считаю нужным написать это то, что руководство "man dig" говорит о том, что -x упрощенная опция для обратного поиска, которая сопостовляет адреса с именами.
2) В секции запроса видно, что dig сам форматировал запрос как надо: ;; QUESTION SECTION:
;1.1.1.1.in-addr.arpa.		IN	PTR
3) В секции ответа видим запись с информацией о имени адреса.

#### Что я понял:
Понял на примере, как делать реверсивный запрос

### Вывод команды:

root@dnscache:/home/eakramar# dig -x 8.8.8.8

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> -x 8.8.8.8
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4197
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;8.8.8.8.in-addr.arpa.		IN	PTR

;; ANSWER SECTION:
8.8.8.8.in-addr.arpa.	4502	IN	PTR	dns.google.

;; Query time: 143 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun Jun 28 12:32:53 UTC 2026
;; MSG SIZE  rcvd: 73

#### Вывод по команде:
Все тоже самое, что и в предыдущем эксперименте, только вернулось имя dns.google.

####  Что я понял:
Аналогично предыдущему эксперименту



### **Что записать:**
- Какие записи есть, какие пусты
Есть все записи, кроме MX, TXT, CAA и еще ANY возвращает из имеющегося все, кроме A-записи.

- Особое внимание на SOA — там минимум 7 полей (serial, refresh, retry, expire, minimum, mname, rname). Что означает каждое?
2406725644 - (Serial) версия зоны, вторичные серверы сверяют с этим числом, если на вторичной зоне отличается номер, то он будет делать трансфер зон;
10000 - (Refresh) как часто вторичный сервер проверяет обновления (сек)$
2400 - (Retry) если не смог связаться — повторить через (сек);
604800 (expire) если долго нет связи — считать зону устаревшей через (сек);
1800 - сколько кэшировать отрицательный ответ (сек).
lara.ns.cloudflare.com. - (Master Name) primary authoritative NS зоны;
dns.cloudflare.com. - (Responsible Name) email админа зоны (точка вместо @);
1800 - Negative Caching TTL (minimum).

- TTL для каждой записи — почему у разных записей разный TTL?
Как настроит администратор запись так долго TTL и будет жить. Логика в том, чтобы редкие запросы (NS) жили дольше, частые (A) меньше.
Еще примечательно то, что значение TTL тикает и берется не напрямую с сервера а с моего резолвера.


### **Вопросы:**
- Зачем нужна CAA-запись? (Подсказка: связано с Let's Encrypt, юнит 4)
CAA-запись нужна для подписи домена. Указывает, каким сертификационным центрам разрешено выпускать SSL/TLS-сертификаты для домена.

- Что произойдёт если уменьшить TTL до 60 секунд перед миграцией IP?
Другие резолверы быстрее увидят сервер на который мигрировали адреса.

## Эксперимент 3: tcpdump, захват HTTP и DNS трафика
[команды, вывод, "что я понял"]

### **Сценарий А — DNS запросы:**

#### Терминал 2 — генерируем DNS запрос:
root@dnscache:/home/eakramar# dig eakramar.ru

; <<>> DiG 9.18.39-0ubuntu0.24.04.5-Ubuntu <<>> eakramar.ru
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52605
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;eakramar.ru.			IN	A

;; ANSWER SECTION:
eakramar.ru.		377	IN	A	104.21.3.160
eakramar.ru.		377	IN	A	172.67.130.237

;; Query time: 801 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Tue Jun 30 03:51:42 UTC 2026
;; MSG SIZE  rcvd: 72

root@dnscache:/home/eakramar# ^C
root@dnscache:/home/eakramar# nslookup google.com
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	google.com
Address: 142.251.119.101
Name:	google.com
Address: 142.251.119.113
Name:	google.com
Address: 142.251.119.102
Name:	google.com
Address: 142.251.119.100
Name:	google.com
Address: 142.251.119.139
Name:	google.com
Address: 142.251.119.138
Name:	google.com
Address: 2404:6800:400a:1009::65
Name:	google.com
Address: 2404:6800:400a:1009::66
Name:	google.com
Address: 2404:6800:400a:1009::8a
Name:	google.com
Address: 2404:6800:400a:1009::8b

#### Терминал 1 — захват DNS трафика (порт 53):
root@dnscache:/home/eakramar# tcpdump -i any -n port 53 -A
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
03:51:41.889128 lo    In  IP 127.0.0.1.35219 > 127.0.0.53.53: 52605+ [1au] A? eakramar.ru. (52)
E..P."..@..D.......5...5.<...}. .........eakramar.ru.......).........
....#1U).d
03:51:41.889257 enp0s3 Out IP 172.20.10.4.42955 > 172.20.10.1.53: 50067+ [1au] A? eakramar.ru. (40)
E..D....@.*...
...
....5.0lo.............eakramar.ru.......)........
03:51:42.691220 enp0s3 In  IP 172.20.10.1.53 > 172.20.10.4.42955: 50067 2/0/1 A 104.21.3.160, A 172.67.130.237 (72)
E..d.p..@.h...
...
..5...Pg..............eakramar.ru..............y..h............y...C....)........
03:51:42.691402 lo    In  IP 127.0.0.53.53 > 127.0.0.1.35219: 52605 2/0/1 A 104.21.3.160, A 172.67.130.237 (72)
E..d9.@...B>...5.....5...P...}...........eakramar.ru..............y..h............y...C....)........
03:54:59.351723 lo    In  IP 127.0.0.1.57121 > 127.0.0.53.53: 57884+ A? google.com. (28)
E..8c...@..........5.!.5.$.k.............google.com.....
03:54:59.352303 enp0s3 Out IP 172.20.10.4.43905 > 172.20.10.1.53: 21122+ [1au] A? google.com. (39)
E..C/...@.....
...
....5./lnR............google.com.......)........
03:54:59.519257 enp0s3 In  IP 172.20.10.1.53 > 172.20.10.4.43905: 21122 6/0/1 A 142.251.119.101, A 142.251.119.113, A 142.251.119.102, A 142.251.119.100, A 142.251.119.139, A 142.251.119.138 (135)
E...S6..@.....
...
..5.....=R............google.com..............M....we.........M....wq.........M....wf.........M....wd.........M....w..........M....w...)........
03:54:59.520325 lo    In  IP 127.0.0.53.53 > 127.0.0.1.57121: 57884 6/0/0 A 142.251.119.101, A 142.251.119.113, A 142.251.119.102, A 142.251.119.100, A 142.251.119.139, A 142.251.119.138 (124)
E...&.@...T....5.....5.!.................google.com..............M....we.........M....wq.........M....wf.........M....wd.........M....w..........M....w.
03:54:59.521187 lo    In  IP 127.0.0.1.53833 > 127.0.0.53.53: 40966+ AAAA? google.com. (28)
E..8T...@.'........5.I.5.$.k.............google.com.....
03:54:59.521386 enp0s3 Out IP 172.20.10.4.39681 > 172.20.10.1.53: 30728+ [1au] AAAA? google.com. (39)
E..C.G..@..5..
...
....5./lnx............google.com.......)........
03:54:59.698767 enp0s3 In  IP 172.20.10.1.53 > 172.20.10.4.39681: 30728 4/0/1 AAAA 2404:6800:400a:1009::65, AAAA 2404:6800:400a:1009::66, AAAA 2404:6800:400a:1009::8a, AAAA 2404:6800:400a:1009::8b (151)
E.......@./...
...
..5....M.x............google.com..............6..$.h.@
.	.......e.........6..$.h.@
.	.......f.........6..$.h.@
.	.................6..$.h.@
.	..........)........
03:54:59.698901 lo    In  IP 127.0.0.53.53 > 127.0.0.1.53833: 40966 4/0/0 AAAA 2404:6800:400a:1009::65, AAAA 2404:6800:400a:1009::66, AAAA 2404:6800:400a:1009::8a, AAAA 2404:6800:400a:1009::8b (140)
E...'M@...S....5.....5.I.................google.com..............6..$.h.@
.	.......e.........6..$.h.@
.	.......f.........6..$.h.@
.	.................6..$.h.@
.	........

#### Вывод по команде:
1) Утилита tcpdump позволяет отслеживать Tx Rx трафик на интрефейсах.
2) tcpdump -i any -n port 53 -A
-i any - флаг который говорит утилите слушать трафик на всех интерфейсах сразу.
-n port 53 - флаг, который говорит утилите фильтровать по 53 порту, то есть, будет выводить только DNS-трафик.
-A - флаг, который говорит утилите выводить данные в режиме ASCII
3) При вызове утилиты, она выводт в std_err служебные сообщения:
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes

Описание смысла сообщений:
data link type LINUX_SLL2 - это тип канального уровня (data link layer), который tcpdump использует для интерпретации заголовков пакетов. Поскольку указан -i any (а не конкретный интерфейс), у разных интерфейсов могут быть разные типы линков — Ethernet даёт обычные MAC-заголовки, Wi-Fi свои, loopback свои и т.д. Чтобы единообразно показывать пакеты со всех интерфейсов сразу, Linux подсовывает tcpdump виртуальный "cooked" формат — упрощённый общий заголовок вместо настоящего канального.
SLL2 — это вторая версия этого формата (Linux cooked capture v2), которая пришла на смену старому SLL (v1). В SLL2 добавили информацию о направлении пакета (входящий/исходящий) и индекс интерфейса прямо в заголовок каждого пакета — это полезно именно при -i any, потому что иначе непонятно, через какой именно интерфейс прошёл конкретный пакет.

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode - напоминание, что не передано -v, поэтому tcpdump покажет сокращённую информацию о пакетах (без TTL, ID фрагментации, доп. флагов протокола и т.п.).

listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes - финальная строка перед стартом захвата: подтверждает, что слушаем на всех интерфейсах (any), используется формат LINUX_SLL2, и snapshot length (snaplen) — максимальное число байт, которое tcpdump захватывает с каждого пакета — 262144 байта (256 КБ). Это с большим запасом перекрывает любой реальный DNS-пакет, так что обрезки данных не будет.
4) 03:51:41.889128 lo    In  IP 127.0.0.1.35219 > 127.0.0.53.53: 52605+ [1au] A? eakramar.ru. (52)
E..P."..@..D.......5...5.<...}. .........eakramar.ru.......).........
....#1U).d

03:51:41.889128 lo    In  IP 127.0.0.1.35219 > 127.0.0.53.53: 52605+ [1au] A? eakramar.ru. (52): 03:51:41.889128 - время пакета; lo - интерфейс на котором снят пакет (локальный сетевой интерфейс); In — направление пакета (incoming); IP — версия протокола сетевого уровня, IPv4; 127.0.0.1.35219 > 127.0.0.53.53 — источник и назначение в формате IP.порт > IP.порт; 52605+ — ID транзакции DNS-запроса. Знак + означает, что установлен флаг RD (Recursion Desired) — клиент просит сервер выполнить рекурсивный поиск, если у того нет готового ответа в кэше; [1au] — означает, что в DNS-сообщении есть одна доп. запись в секции Additional (additional record), и это, скорее всего, OPT-запись, то есть включён EDNS0; A? — тип запроса, ресурсная запись типа A (IPv4-адрес), знак ? указывает, что это именно запрос (query), а не ответ; eakramar.ru. — доменное имя, которое резолвится. Точка в конце — это явное обозначение полного (абсолютного) FQDN, как в зоне DNS; (52) — общая длина DNS-сообщения в байтах (без учёта IP/UDP-заголовков), то есть это длина именно payload'а UDP.

E..P."..@..D.......5...5.<...}. .........eakramar.ru.......).........
....#1U).d                                                                   - это полезная нагрузка пакета, коряво потому что в форме ASCII.

5) Все остальные пакеты идут в точно таком же формате, за исключением того что где то может быть In, а где то Out/

#### Что я понял:
Я увидел на примере как происходит DNS-запрос от отдачи пакета до приема.


### Сценарий Б — HTTP трафик:**

#### Терминал 1 — захват HTTP (порт 80)
root@dnscache:/home/eakramar# tcpdump -i any -n port 80 -A -s 0
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
12:40:05.896161 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253917555 ecr 0,nop,wscale 7], length 0
E..<..@.@.0...
.".|-...P............US.........
...s........
12:40:06.936114 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253918595 ecr 0,nop,wscale 7], length 0
E..<..@.@.0...
.".|-...P............US.........
............
12:40:07.960145 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253919619 ecr 0,nop,wscale 7], length 0
E..<..@.@.0...
.".|-...P............US.........
............
12:40:08.984731 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253920643 ecr 0,nop,wscale 7], length 0
E..<..@.@.0...
.".|-...P............US.........
............
12:40:09.328640 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [S.], seq 3924099606, ack 3542066414, win 26847, options [mss 1400,sackOK,TS val 1116372611 ecr 3253920643,nop,wscale 7], length 0
EP.<......}G".|-..
..P............h..<.....x...
B.~.........
12:40:09.328838 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 1, win 502, options [nop,nop,TS val 3253920987 ecr 1116372611], length 0
E..4..@.@.0...
.".|-...P............UK.....
....B.~.
12:40:09.328951 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [P.], seq 1:76, ack 1, win 502, options [nop,nop,TS val 3253920987 ecr 1116372611], length 75: HTTP: GET / HTTP/1.1
E.....@.@.0...
.".|-...P............U......
....B.~.GET / HTTP/1.1
Host: neverssl.com
User-Agent: curl/8.5.0
Accept: */*


12:40:10.264111 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [P.], seq 1:76, ack 1, win 502, options [nop,nop,TS val 3253921923 ecr 1116372611], length 75: HTTP: GET / HTTP/1.1
E.....@.@.0...
.".|-...P............U......
....B.~.GET / HTTP/1.1
Host: neverssl.com
User-Agent: curl/8.5.0
Accept: */*


12:40:10.647719 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [.], ack 76, win 204, options [nop,nop,TS val 1116373945 ecr 3253921923], length 0
EP.4@q....<.".|-..
..P.........9....._.....
B.......
12:40:10.647720 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [.], seq 1:1289, ack 76, win 204, options [nop,nop,TS val 1116373946 ecr 3253921923], length 1288: HTTP: HTTP/1.1 200 OK
EP.<@r....7.".|-..
..P.........9....:......
B.......HTTP/1.1 200 OK
Date: Tue, 30 Jun 2026 12:40:10 GMT
Server: Apache/2.4.66 ()
Upgrade: h2,h2c
Connection: Upgrade
Last-Modified: Wed, 29 Jun 2022 00:23:33 GMT
ETag: "f79-5e28b29d38e93"
Accept-Ranges: bytes
Content-Length: 3961
Vary: Accept-Encoding
Content-Type: text/html; charset=UTF-8

<html>
	<head>
		<title>NeverSSL - Connecting ... </title>
		<style>
		body {
			font-family: Montserrat, helvetica, arial, sans-serif;
			font-size: 16x;
			color: #444444;
			margin: 0;
		}
		h2 {
			font-weight: 700;
			font-size: 1.6em;
			margin-top: 30px;
		}
		p {
			line-height: 1.6em;
		}
		.container {
			max-width: 650px;
			margin: 20px auto 20px auto;
			padding-left: 15px;
			padding-right: 15px
		}
		.header {
			background-color: #42C0FD;
			color: #FFFFFF;
			padding: 10px 0 10px 0;
			font-size: 2.2em;
		}
		.notice {
			background-color: red;
			color: white;
			padding: 10px 0 10px 0;
			font-size: 1.25em;
			animation: flash 4s infinite;
		}
		@keyframes flash {
		0% {
			background-color: red;
		}
		50% {
			background-color: #AA0000;
		}
		0% {
			background-color: red;
		}
		}
		<!-- CSS from Mark Webster https://gist.github.com/markcwebster/9bdf30655cdd5279bad13993ac87c85d -->
		</style>

		<script>
			var adjectives = [ 'cool' , 'calm' , 'relaxed',
12:40:10.647769 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 1289, win 525, options [nop,nop,TS val 3253922306 ecr 1116373946], length 0
E..4..@.@.0...
.".|-...P...9........UK.....
....B...
12:40:10.651995 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [P.], seq 1289:4262, ack 76, win 204, options [nop,nop,TS val 1116373946 ecr 3253921923], length 2973: HTTP
EP..@s....1?".|-..
..P.........9....`......
B....... 'soothing', 'serene', 'slow',
							'beautiful', 'wonderful', 'wonderous', 'fun', 'good',
							'glowing', 'inner', 'grand', 'majestic', 'astounding',
							'fine', 'splendid', 'transcendent', 'sublime', 'whole',
							'unique', 'old', 'young', 'fresh', 'clear', 'shiny',
							'shining', 'lush', 'quiet', 'bright', 'silver' ];

			var nouns =	  [ 'day', 'dawn', 'peace', 'smile', 'love', 'zen', 'laugh',
							'yawn', 'poem', 'song', 'joke', 'verse', 'kiss', 'sunrise',
							'sunset', 'eclipse', 'moon', 'rainbow', 'rain', 'plan',
							'play', 'chart', 'birds', 'stars', 'pathway', 'secret',
							'treasure', 'melody', 'magic', 'spell', 'light', 'morning'];

			var prefix =
					// Choose 3 zen adjectives
					adjectives.sort(function(){return 0.5-Math.random()}).slice(-3).join('')
					+
					// Coupled with a zen noun
					nouns.sort(function(){return 0.5-Math.random()}).slice(-1).join('');
			window.location.href = 'http://' + prefix + '.neverssl.com/online';
		</script>
	</head>
	<body>
	<noscript>
		<div class="notice">
			<div class="container">
				...... JavaScript appears to be disabled. NeverSSL's cache-busting works better if you enable JavaScript for <code>neverssl.com</code>.
			</div>
		</div>
	</noscript>
	<div class="header">
		<div class="container">
		<h1>NeverSSL</h1>
		</div>
	</div>
	<div class="content">
	<div class="container">

	<h1 id="status"></h1>
	<script>document.querySelector("#status").textContent = "Connecting ...";</script>
	<noscript>

		<h2>What?</h2>
		<p>This website is for when you try to open Facebook, Google, Amazon, etc
		on a wifi network, and nothing happens. Type "http://neverssl.com"
		into your browser's url bar, and you'll be able to log on.</p>

		<h2>How?</h2>
		<p>neverssl.com will never use SSL (also known as TLS). No
		encryption, no strong authentication, no <a
		href="https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security">HSTS</a>,
		no HTTP/2.0, just plain old unencrypted HTTP and forever stuck in the dark
		ages of internet security.</p>

		<h2>Why?</h2>
		<p>Normally, that's a bad idea. You should always use SSL and secure
		encryption when possible. In fact, it's such a bad idea that most websites
		are now using https by default.</p>

		<p>And that's great, but it also means that if you're relying on
		poorly-behaved wifi networks, it can be hard to get online.  Secure
		browsers and websites using https make it impossible for those wifi
		networks to send you to a login or payment page. Basically, those networks
		can't tap into your connection just like attackers can't. Modern browsers
		are so good that they can remember when a website supports encryption and
		even if you type in the website name, they'll use https.</p>

		<p>And if the network never redirects you to this page, well as you can
		see, you're not missing much.</p>

        <a href="https://twitter.com/neverssl">Follow @neverssl</a>

	</noscript>

	</div>
	</div>

	</body>
</html>

12:40:10.652018 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 4262, win 572, options [nop,nop,TS val 3253922310 ecr 1116373946], length 0
E..4..@.@.0...
.".|-...P...9.......<UK.....
....B...
12:40:10.652460 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [F.], seq 76, ack 4262, win 572, options [nop,nop,TS val 3253922311 ecr 1116373946], length 0
E..4..@.@.0...
.".|-...P...9.......<UK.....
....B...
12:40:11.009515 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [F.], seq 4262, ack 77, win 204, options [nop,nop,TS val 1116374315 ecr 3253922311], length 0
EP.4@v....<.".|-..
..P.........:....m......
B..+....
12:40:11.009548 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 4263, win 572, options [nop,nop,TS val 3253922668 ecr 1116374315], length 0
E..4..@.@.0...
.".|-...P...:.......<UK.....
...lB..+
^C
16 packets captured
18 packets received by filter
0 packets dropped by kernel


#### Терминал 2 — простой HTTP запрос
curl http://neverssl.com

#### Вывод по команде:
1) tcpdump -i any -n port 80 -A -s 0
-i any - утилита слушает на всех интерфейсах
-n port 80 - слушает на 80 порту, то есть, протокол http
-A - выводит информацию в формате ASCII
-s - .............
2) 12:40:05.896161 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253917555 ecr 0,nop,wscale 7], length 0
enp0s3 Out — пакет уходит с этого физического интерфейса (в отличие от lo, тут направление однозначное).
172.20.10.4.51724 > 34.223.124.45.80 — клиент пытается достучаться до сервера 34.223.124.45 на порту 80 (HTTP).
Flags [S] — установлен флаг SYN, это первый пакет three-way handshake — попытка открыть соединение.
seq 3542066413 — начальный sequence number клиента (ISN — initial sequence number), случайное стартовое значение для нумерации байт в этом направлении.
win 64240 — размер окна приёма (receive window) — сколько байт клиент готов принять без подтверждения, до применения масштабирования (wscale).
options [...] — TCP-опции, согласовываемые при установлении соединения.
mss 1460 — Maximum Segment Size, максимальный размер сегмента данных (без заголовков), которое готов принять клиент.
sackOK — поддержка Selective ACK (выборочного подтверждения, удобно при потере отдельных сегментов).
TS val 3253917555 ecr 0 — TCP timestamps: своё текущее значение таймера (val) и эхо чужого таймера (ecr), используется для RTT-измерений и защиты от переполнения seq (PAWS). ecr 0 означает, что это первый пакет, эхо ещё нечего ставить.
nop — no-operation, просто байт-заполнитель для выравнивания опций.
wscale 7 — window scaling factor, множитель для win, чтобы окно могло быть больше 65535 байт.
length 0 — у SYN-пакета нет полезной нагрузки (данных), только заголовки.
3) Дальше идут ещё три таких же SYN-пакета с интервалом примерно в секунду (12:40:06.936, 12:40:07.960, 12:40:08.984) — это повторные попытки (retransmission), потому что сервер не ответил вовремя. seq остаётся тем же самым (3542066413) — это нормально, retransmit не увеличивает sequence number, это повтор того же самого пакета.

12:40:06.936114 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253918595 ecr 0,nop,wscale 7], length 0

12:40:07.960145 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253919619 ecr 0,nop,wscale 7], length 0

12:40:08.984731 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [S], seq 3542066413, win 64240, options [mss 1460,sackOK,TS val 3253920643 ecr 0,nop,wscale 7], length 0
4) Наконец сервер ответил — это второй шаг handshake.
12:40:09.328640 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [S.], seq 3924099606, ack 3542066414, win 26847, options [mss 1400,sackOK,TS val 1116372611 ecr 3253920643,nop,wscale 7], length 0
Flags [S.] — комбинация флагов SYN+ACK (точка после S в выводе tcpdump означает установленный ACK).
seq 3924099606 — это уже ISN сервера, отдельная независимая нумерация для направления сервер→клиент.
ack 3542066414 — сервер подтверждает получение SYN клиента, номер = seq клиента + 1 (3542066413 + 1).
mss 1400 — у сервера чуть меньший MSS, видимо из-за дополнительных накладных расходов на его стороне сети.
5) Третий шаг handshake — клиент подтверждает SYN+ACK сервера.
12:40:09.328838 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 1, win 502, options [nop,nop,TS val 3253920987 ecr 1116372611], length 0
Flags [.] — пустой флаг означает просто ACK без других флагов.
ack 1 — здесь tcpdump показывает относительный номер подтверждения (он считает от ISN сервера как от нуля, для удобства чтения, а не абсолютное число 3924099607). Это особенность вывода tcpdump — относительные seq/ack номера, если не указан флаг -S.
win 502 — окно стало 502, а не 64240. Это потому что теперь учитывается wscale 7 — это уже не базовое значение, а реальный множитель применяется к показанному числу в дальнейших пакетах (в самом первом SYN масштаб ещё не согласован, поэтому показывалось сырое значение).
6) Handshake завершён — соединение установлено.
7) Передача данных (HTTP-запрос)
12:40:09.328951 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [P.], seq 1:76, ack 1, win 502, options [nop,nop,TS val 3253920987 ecr 1116372611], length 75: HTTP: GET / HTTP/1.1
E.....@.@.0...
.".|-...P............U......
....B.~.GET / HTTP/1.1
Host: neverssl.com
User-Agent: curl/8.5.0
Accept: */*

Flags [P.] — флаги PSH+ACK. PSH (push) говорит принимающей стороне — не буферизировать, а сразу передать данные приложению, не дожидаясь заполнения буфера.
seq 1:76 — диапазон sequence-номеров этого сегмента: от относительного 1 до 76 (не включая), то есть это 75 байт данных (отсюда и length 75).
ack 1 — клиент по-прежнему подтверждает только handshake, новых данных от сервера ещё не получал.
HTTP: GET / HTTP/1.1 — tcpdump распознал протокол приложения по содержимому и показал верхнюю строку HTTP-запроса.
Дальше в дампе виден сырой payload в ASCII: сам HTTP-запрос целиком — GET / HTTP/1.1, заголовки Host: neverssl.com, User-Agent: curl/8.5.0, Accept: */*.
8) Точно такой же пакет повторился через секунду — это retransmit запроса, потому что клиент не получил ACK на первый GET вовремя (классическое поведение TCP при таймауте retransmission timer, RTO).
12:40:10.264111 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [P.], seq 1:76, ack 1, win 502, options [nop,nop,TS val 3253921923 ecr 1116372611], length 75: HTTP: GET / HTTP/1.1
E.....@.@.0...
.".|-...P............U......
....B.~.GET / HTTP/1.1
Host: neverssl.com
User-Agent: curl/8.5.0
Accept: */*
9) Ответ сервера
12:40:10.647719 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [.], ack 76, win 204, options [nop,nop,TS val 1116373945 ecr 3253921923], length 0
EP.4@q....<.".|-..
..P.........9....._.....
B.......
Сервер наконец подтверждает получение GET-запроса — ack 76 означает "я получил байты вплоть до 76-го" (это покрывает оба отправленных GET, так как они были идентичны и занимали один и тот же диапазон).
10) 12:40:10.647720 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [.], seq 1:1289, ack 76, win 204, options [nop,nop,TS val 1116373946 ecr 3253921923], length 1288: HTTP: HTTP/1.1 200 OK
EP.<@r....7.".|-..
..P.........9....:......
B.......HTTP/1.1 200 OK
Date: Tue, 30 Jun 2026 12:40:10 GMT
Server: Apache/2.4.66 ()
Upgrade: h2,h2c
Connection: Upgrade
Last-Modified: Wed, 29 Jun 2022 00:23:33 GMT
ETag: "f79-5e28b29d38e93"
Accept-Ranges: bytes
Content-Length: 3961
Vary: Accept-Encoding
Content-Type: text/html; charset=UTF-8

Сервер шлёт сам ответ — seq 1:1289, то есть 1288 байт данных (length 1288).
tcpdump опознал и показал начало HTTP-ответа: HTTP/1.1 200 OK.
В ASCII-дампе видны заголовки ответа (Server: Apache/2.4.66, Content-Length: 3961, Content-Type: text/html и т.д.) и начало HTML-тела страницы.
11) Клиент подтверждает первую часть тела ответа.
12:40:10.647769 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 1289, win 525, options [nop,nop,TS val 3253922306 ecr 1116373946], length 0
E..4..@.@.0...
.".|-...P...9........UK.....
....B...
12) 12:40:10.651995 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [P.], seq 1289:4262, ack 76, win 204, options [nop,nop,TS val 1116373946 ecr 3253921923], length 2973: HTTP
EP..@s....1?".|-..
..P.........9....`......
B.......
Сервер досылает оставшуюся часть тела — ещё 2973 байта (seq 1289:4262), флаг PSH означает, что это финальный кусок данных этой передачи, который нужно сразу отдать приложению. В сумме 1288 + 2973 = 4261 байт тела плюс заголовки — близко к заявленному Content-Length: 3961 (расхождение из-за заголовков ответа, которые тоже входят в TCP payload, но не в Content-Length, который считает только тело).
Видно остальное содержимое HTML-страницы NeverSSL — JS-скрипт с генерацией случайного поддомена, текст про SSL/TLS и т.д.
13) 12:40:10.652018 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 4262, win 572, options [nop,nop,TS val 3253922310 ecr 1116373946], length 0
12:40:10.652460 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [F.], seq 76, ack 4262, win 572, options [nop,nop,TS val 3253922311 ecr 1116373946], length 0
Первый — подтверждение получения всех данных ответа.
Второй, важный — Flags [F.], то есть FIN+ACK. Клиент инициирует закрытие соединения (он получил весь ответ и больше ничего не отправляет). seq 76 — это его текущий sequence number (там, где он остановился после GET-запроса), FIN как бы "занимает" один байт в нумерации последовательности.
14) 12:40:11.009515 enp0s3 In  IP 34.223.124.45.80 > 172.20.10.4.51724: Flags [F.], seq 4262, ack 77, win 204, options [nop,nop,TS val 1116374315 ecr 3253922311], length 0
Сервер отвечает своим FIN+ACK: подтверждает FIN клиента (ack 77 = 76 + 1, за FIN тоже "платится" единица в нумерации) и одновременно посылает свой собственный FIN, закрывая соединение со своей стороны.
15) 12:40:11.009548 enp0s3 Out IP 172.20.10.4.51724 > 34.223.124.45.80: Flags [.], ack 4263, win 572, options [nop,nop,TS val 3253922668 ecr 1116374315], length 0
Финальный ACK от клиента на FIN сервера (ack 4263 = 4262 + 1). Это завершающий шаг four-way close (на практике тут FIN сервера совмещён с его ACK, поэтому фактически вышло 3 пакета закрытия вместо классических четырёх — FIN/ACK сервер объединил в один пакет).
16) 
16 packets captured
18 packets received by filter
0 packets dropped by kernel

captured — сколько пакетов реально попало в буфер и было показано/сохранено;
received by filter — сколько пакетов прошло через BPF-фильтр ядра (тут 18, чуть больше — возможно, пара пакетов была в процессе обработки на момент Ctrl+C);
dropped by kernel — пакеты, потерянные из-за переполнения буфера захвата (тут 0 — всё захвачено без потерь).


#### Что я понял:
S (SYN, открытие), S. (SYN+ACK), . (просто ACK), P. (PSH+ACK, передача данных с немедленной выдачей приложению), F. (FIN+ACK, закрытие). Это ровно тот набор, который покрывает полный жизненный цикл TCP-соединения — handshake, обмен данными, graceful close


### **Сценарий В — HTTPS (увидишь handshake, но не контент):**

#### Терминал 1
root@dnscache:/home/eakramar# tcpdump -i any -n port 443 -A -s 0 | head -100
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
16:05:44.508548 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154833262 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
.
.n........
16:05:45.560131 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154834314 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
.
..........
16:05:46.584212 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154835338 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
.
..........
16:05:47.608133 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154836362 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
.
..........
16:05:48.632294 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154837386 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
.
..........
16:05:49.656161 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154838410 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
............
16:05:51.704198 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154840458 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
............
16:05:55.736161 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154844490 ecr 0,nop,wscale 7], length 0
E..<5.@.@.H...
...wd...........................
...J........
16:06:01.401915 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [S.], seq 430094843, ack 234390756, win 65535, options [mss 1400,sackOK,TS val 2364714126 ecr 3154833262,nop,wscale 8], length 0
EP.<....o.....wd..
........................x...
.....
.n....
16:06:01.401980 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [.], ack 1, win 502, options [nop,nop,TS val 3154850155 ecr 2364714126], length 0
E..45.@.@.H...
...wd.......................
..1k....
16:06:01.405099 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [P.], seq 1:518, ack 1, win 502, options [nop,nop,TS val 3154850159 ecr 2364714126], length 517
E..95.@.@.F...
...wd.......................
..1o..................Z........%R....
.......\Yn)T. u.V	...#FH..../...."6.....q!..YT.>.......,.0.........+./...$.(.k.#.'.g.
...9.	...3.....=.<.5./.....u........
google.com.........
...............................h2.http/1.1.........1.....*.(...........	.
...........................+........-.....3.&.$... ...A3..O6X....%%.n9.APzb.q...~G............................................................................................................................................................................................
16:06:01.809986 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [.], ack 518, win 1048, options [nop,nop,TS val 2364714542 ecr 3154850159], length 0
EP.4.e..o.....wd..
........................
......1o
16:06:01.810115 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [.], seq 1:1389, ack 518, win 1050, options [nop,nop,TS val 2364714551 ecr 3154850159], length 1388
EP...f..o.{*..wd..
..................l.....
...7..1o....z...v....!%.
.V.5W...E.}l$.....|}..38l. u.V	...#FH..../...."6.....q!..YT......3.$... ;-F..V....XC}j.an..k.f..JdI....U.+.................8..C;z.){w
.......>[/.NoI>&.OP.Y.i..(..F..6J,.....WI...K.E..A.+.......>p...&.~.J.C,.F....(...0WKnA%. x.uwq.....~<...y...*..>..G...E....*...6..t*..o8..S.x).|5.`...T....._.@:N.h..Eh..y.	d..#"<	...:nTi<....f....`$8......4.!XW.5.7.....Z...n......'y...7EK.y..jU....X...O	
Q..N9...wr.Cf+,.*	..-#..NK...J.}..Q...l.......r.2..!	....e..A....o.M{~o2.].<gr...Sa..u.......Q.....MFw.....j..s..@..J.*.saG...E.....z.,`...-hZ.pb"1.u.N.i1(.}.........;....KzI..$.C-....q....1kz.q......U\...y...O......N...C_..L...PB6.[%S\..L...j "6_...9e/.7P..Nw\F...u.p....(..^...D..g.$w....-\.i.......E...n....N..y.. `...EaK.-{......n.....g....}).e].!^....B.N.+".-,.?)....-..B.n.=(.C..wvQ....^sQ.q...i-.....#F....Y.?.?...r?.g.._`2.......A...J0.g>.#.&...2..`b...nA.T3.].e.w..5......E.4......G~.Mq.	.V...D.,m......H.c._m.]rS./xr..`.3e..zK.........Z.p.C....+...:.l{..vvW.Q......e..y.FhB.J..zf?.E/..,.w}g-..q.K%..j.o..%~.x .QFxDy.9..9lq^0...~kE.....-...5&I.tR3A8^..\...g.>d8..].....}...Z..G......(...d.....&...V...Z...$.ie........B.jM..o...A....{.X.......R../....
N..e........rY.UY.pa`-.n.&..9.=..9Y.;v...&....C...........e@..H..cL.3.H^o.......v.)sl.......'.)..Q...[...S.1...N.......z@.kwL.......'.pH.....m.....)...i..`p..+U.+.J.....t|~]..0...Z.........heM..uNj.......i.6....W..c...|.)
16:06:01.810136 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [.], ack 1389, win 525, options [nop,nop,TS val 3154850564 ecr 2364714551], length 0
E..45.@.@.H...
...wd...........h...........
..3....7
16:06:02.117760 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [P.], seq 1389:3871, ack 518, win 1050, options [nop,nop,TS val 2364714921 ecr 3154850564], length 2482
EP	..g..o.v...wd..
........h.........P.....
......3.}...@........=..[..........K@.1...\..>...7.O......0C..R.dd...a....2-.reyr.UH.4...X.@....	...>.n.....E..n.Hu...jE.1/.*.a...H.F,`..l....6x`.Ct....vW..)qPF.1.<....:.#...,?...>..Y......Y.-....}."....R?.p .............peE.y.4....\........p...a4yL;..b...h*.....X...p.r...BR"A^...pB.K'3...>	\]..6ST.@..F........./.X..I..M.....-...o..<.	.....|...OD......>..T|........z.?...?f'.8f...
.._W......
&.vD.9.....E/ .....u`...e....#.'Z.\.!.N.tbh.k@.*.=.Va.J.X.E........yP...L..U$;/+...d.....G..H..h-...C..:Wq..G...C....O.U!.....!!.'S.$.Dj...].._jj.if...Z..%...#.. =M.....u.......b	^.h.......S......;...$w.<\Lt.U....
_.%.h#._..\.....?w..b......Y.l.E.s.z}Y..e.6.w.W=K.ht....YDxo.......M.....a7..|..a%..U.G$N........x...8*..zSa@...B..y..-.@K...u.Oy.....SF.Or......1x.CJ.
2......R.k=..E.X5....V....&<....E......h...3..Vz..J+...9...fgm.E".I..w.D...6#)..._....4. E......r....d._.5n.C].......DL!..B...G..L....}..{	.._.+=..Nm.....Z.CyF....]..y~...0)mA...M....F.<._..b..8P6R.{)....?..G...1!0..K..D,.e.=~.z>.O].(..T...3...x.+....q`.m]cY..\zeD...=..+K...O.(.Df....8[..."..vu.V
...=.fl..D.Og......-;...I_#=.dJ.e..N#>".}.....g4..K..xmkq.*O....@..l-._.7..YB.....P...=..P.S..q...7...k{7ks-9._v.3...U\.U....m.N.Tf<......I&.eG.=.j..|.................=.CI.PNb.....fb.8v.TLq.Y..!.l_6d(..........I..}:..~>.N..!....F..b........L-.W0E.^x......D.J.]	.	K.o`..'....u"..s..Fs:9n	BP.j...8i..#..(.Y. ..v.khJ...!*..M....... .
.X2f.t.......09lV....N.._.
..<..........?..R.J..N`fN*5..u.?j;`E>...e...!..W.^H\......s13.-..s.w...h...u.a..=.J.T....mph.~Kf..$...~.mIk...Q.\:.Y...}...Y..."...-1..Rw.xc.`.....hhL";Cn1L>U.<..	.=1&(..g.N.vj..	.B.r..UL.#L.._.......e..C.d.~.p73..S..Ek	
..
JSK.....Uf.*.uY.o.P.....a..|n....y......f............X..Y.b...,	;St].,$C.@..k=...g..p.H.Cu.v....	9$.|.F..LN1.p.:^.Ug.......o:...$....6...H...w....6=....Hy.....`.F_...D..f.g.7.'\.^....X.w.Wy.........m.nU..]..O..47.hK@.W.fab).....o..MP]ms...
...#.;N...>..[J...0.2..R....Hn..u...;..p.6......H#.r..e.T.;..W.j"i.D...*...|?*......v......\h...8I..oU...L....j...cj8.[......y%Sn4:)../..u.v..or...j...	.....y.,...!.XQ_8..;.(...8...E..Pu'..}...L..t%4.]Qw..~.7....w..J....d.....S`........W.....6W.<....=|.Vvw.t).....m.K..d..YX....e....U0.........L.........Y....v!..43v.7..9.......n...&.*....q<R...(r...i...eUh....*.m...M..>....J.H..Jx..5#_.r=+...p0......*.#.....C........f!H..&.cY..T.&.3..0.m5	\.^d..5.....\AP.;.V..K./.K..V.})..lf.b.W.7N.ae..7.1_......g.PxF.+.w{.>.(......f3iA..x,$'2.$m..GdKR.....
..+........J......b.
....rK.]..BNCln..a...c.....u.`.,..~.I(..p).
16:06:02.117797 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [.], ack 3871, win 564, options [nop,nop,TS val 3154850871 ecr 2364714921], length 0
E..45.@.@.H...
...wd...............4.......
..47....
16:06:02.119698 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [P.], seq 518:598, ack 3871, win 564, options [nop,nop,TS val 3154850873 ecr 2364714921], length 80
E...5.@.@.H_..
...wd...............4.......
..49..............E....u.z.orKn.bx.L._...;.RA.......!!%.r.J...z...{U.P)...t...C.:".{.e..
16:06:02.119815 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [P.], seq 598:684, ack 3871, win 564, options [nop,nop,TS val 3154850873 ecr 2364714921], length 86
E...5.@.@.HX..
...wd.......9.......4.......
..49........Q......D.d_b..|a..@.E.&.4k.LW..y.....].E.js.Wq^..F......j\....O=.Y`w..fn
..:$..UM.


#### Терминал 2
curl https://google.com

#### Вывод по команде:
1) tcpdump -i any -n port 443 -A -s 0 | head -100
-n port 443 - https
-s 0 - ........
| head -100 - .......
2) 16:05:44.508548 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154833262 ecr 0,nop,wscale 7], length 0
Это первый SYN от клиента (172.20.10.4, порт 39856) к серверу 142.251.119.100:443 — это диапазон IP Google (судя по дальнейшему SNI google.com). Параметры те же, что мы уже разбирали: ISN, MSS, SACK, timestamps, window scaling.
3) Дальше идёт серия повторов SYN: 16:05:45.560, 46.584, 47.608, 48.632, 49.656, 51.704, 55.736. Интервалы между ретрансмиссиями — они растут: ~1с, ~1с, ~1с, ~1с, ~1с, ~2с, ~4с. Это классический экспоненциальный backoff алгоритма ретрансмиссии TCP (RTO — retransmission timeout): каждый раз, когда нет ответа, таймаут перед следующей попыткой удваивается. Это куда более выраженный паттерн, чем в предыдущем дампе с NeverSSL (там был фиксированный интервал около секунды на первых нескольких попытках).
16:05:45.560131 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154834314 ecr 0,nop,wscale 7], length 0
16:05:46.584212 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154835338 ecr 0,nop,wscale 7], length 0
16:05:47.608133 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154836362 ecr 0,nop,wscale 7], length 0
16:05:48.632294 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154837386 ecr 0,nop,wscale 7], length 0
16:05:49.656161 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154838410 ecr 0,nop,wscale 7], length 0
16:05:51.704198 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154840458 ecr 0,nop,wscale 7], length 0
16:05:55.736161 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [S], seq 234390755, win 64240, options [mss 1460,sackOK,TS val 3154844490 ecr 0,nop,wscale 7], length 0
Всего было 7 потерянных SYN прежде чем пришёл ответ — это говорит о серьёзных проблемах на пути. 
4) 16:06:01.401915 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [S.], seq 430094843, ack 234390756, win 65535, options [mss 1400,sackOK,TS val 2364714126 ecr 3154833262,nop,wscale 8], length 0
Наконец SYN+ACK пришёл — спустя почти 17 секунд после первого SYN (44.508 → 01.401). ecr 3154833262 — сервер эхом возвращает timestamp из самого первого SYN-пакета клиента, а не из последнего повтора. Это нормально: TCP timestamp echo всегда отражает значение, полученное в том пакете, на который идёт ответ, а здесь, видимо, сервер ответил именно на самый первый дошедший до него SYN.
5) 16:06:01.401980 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [.], ack 1, win 502, options [nop,nop,TS val 3154850155 ecr 2364714126], length 0
ACK клиента — завершение TCP handshake. На этом TCP-уровень установлен, но дальше начинается TLS-уровень поверх него.
6) TLS handshake: ClientHello
16:06:01.405099 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [P.], seq 1:518, ack 1, win 502, options [nop,nop,TS val 3154850159 ecr 2364714126], length 517
E..95.@.@.F...
...wd.......................
..1o..................Z........%R....
.......\Yn)T. u.V	...#FH..../...."6.....q!..YT.>.......,.0.........+./...$.(.k.#.'.g.
...9.	...3.....=.<.5./.....u........
google.com.........
...............................h2.http/1.1.........1.....*.(...........	.
...........................+........-.....3.&.$... ...A3..O6X....%%.n9.APzb.q...~G............................................................................................................................................................................................

Это первый пакет с данными — 517 байт, и это TLS ClientHello. В отличие от HTTP, tcpdump не распознаёт TLS как протокол приложения по умолчанию (поэтому нет строки вида HTTP: GET... — просто бинарный дамп). Зато можно разглядеть кое-что прямо в ASCII-выводе:
В середине дампа видно слово google.com в чистом виде — это поле SNI (Server Name Indication), расширение TLS ClientHello, которое передаёт имя хоста открытым текстом, даже хотя само соединение зашифрованное. Именно через SNI сервер на одном IP понимает, для какого домена выдавать сертификат (важно при множестве сайтов на одном IP/CDN).
Чуть дальше видны строки h2 и http/1.1 — это расширение ALPN (Application-Layer Protocol Negotiation), в котором клиент сообщает, какие протоколы приложения он поддерживает поверх TLS (HTTP/2 и HTTP/1.1 как fallback).
Остальной "мусор" из непечатных символов — это случайные байты (client random), список поддерживаемых cipher suites, список TLS-расширений (key share для TLS 1.3, supported groups, signature algorithms и т.д.) — всё это бинарные структуры, которые в ASCII выглядят нечитаемо, в отличие от HTTP-заголовков.
7) Сервер подтверждает получение ClientHello (ack 518 — все 517 байт + 1 за SYN получены).
16:06:01.809986 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [.], ack 518, win 1048, options [nop,nop,TS val 2364714542 ecr 3154850159], length 0
8) TLS handshake: ServerHello и сертификат
16:06:01.810115 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [.], seq 1:1389, ack 518, win 1050, options [nop,nop,TS val 2364714551 ecr 3154850159], length 1388
EP...f..o.{*..wd..
..................l.....
...7..1o....z...v....!%.
.V.5W...E.}l$.....|}..38l. u.V	...#FH..../...."6.....q!..YT......3.$... ;-F..V....XC}j.an..k.f..JdI....U.+.................8..C;z.){w
.......>[/.NoI>&.OP.Y.i..(..F..6J,.....WI...K.E..A.+.......>p...&.~.J.C,.F....(...0WKnA%. x.uwq.....~<...y...*..>..G...E....*...6..t*..o8..S.x).|5.`...T....._.@:N.h..Eh..y.	d..#"<	...:nTi<....f....`$8......4.!XW.5.7.....Z...n......'y...7EK.y..jU....X...O	
Q..N9...wr.Cf+,.*	..-#..NK...J.}..Q...l.......r.2..!	....e..A....o.M{~o2.].<gr...Sa..u.......Q.....MFw.....j..s..@..J.*.saG...E.....z.,`...-hZ.pb"1.u.N.i1(.}.........;....KzI..$.C-....q....1kz.q......U\...y...O......N...C_..L...PB6.[%S\..L...j "6_...9e/.7P..Nw\F...u.p....(..^...D..g.$w....-\.i.......E...n....N..y.. `...EaK.-{......n.....g....}).e].!^....B.N.+".-,.?)....-..B.n.=(.C..wvQ....^sQ.q...i-.....#F....Y.?.?...r?.g.._`2.......A...J0.g>.#.&...2..`b...nA.T3.].e.w..5......E.4......G~.Mq.	.V...D.,m......H.c._m.]rS./xr..`.3e..zK.........Z.p.C....+...:.l{..vvW.Q......e..y.FhB.J..zf?.E/..,.w}g-..q.K%..j.o..%~.x .QFxDy.9..9lq^0...~kE.....-...5&I.tR3A8^..\...g.>d8..].....}...Z..G......(...d.....&...V...Z...$.ie........B.jM..o...A....{.X.......R../....
N..e........rY.UY.pa`-.n.&..9.=..9Y.;v...&....C...........e@..H..cL.3.H^o.......v.)sl.......'.)..Q...[...S.1...N.......z@.kwL.......'.pH.....m.....)...i..`p..+U.+.J.....t|~]..0...Z.........heM..uNj.......i.6....W..c...|.)
Первый кусок ответа сервера — 1388 байт. Это начало ServerHello (TLS-параметры, выбранные сервером: cipher suite, server random, key share) и, скорее всего, начало сертификата сервера (или зашифрованных расширений, если это TLS 1.3 — там сертификат уже идёт зашифрованным).
9) ACK клиента на этот сегмент.
16:06:01.810136 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [.], ack 1389, win 525, options [nop,nop,TS val 3154850564 ecr 2364714551], length 0
10) 16:06:02.117760 enp0s3 In  IP 142.251.119.100.443 > 172.20.10.4.39856: Flags [P.], seq 1389:3871, ack 518, win 1050, options [nop,nop,TS val 2364714921 ecr 3154850564], length 2482
EP	..g..o.v...wd..
........h.........P.....
......3.}...@........=..[..........K@.1...\..>...7.O......0C..R.dd...a....2-.reyr.UH.4...X.@....	...>.n.....E..n.Hu...jE.1/.*.a...H.F,`..l....6x`.Ct....vW..)qPF.1.<....:.#...,?...>..Y......Y.-....}."....R?.p .............peE.y.4....\........p...a4yL;..b...h*.....X...p.r...BR"A^...pB.K'3...>	\]..6ST.@..F........./.X..I..M.....-...o..<.	.....|...OD......>..T|........z.?...?f'.8f...
.._W......
&.vD.9.....E/ .....u`...e....#.'Z.\.!.N.tbh.k@.*.=.Va.J.X.E........yP...L..U$;/+...d.....G..H..h-...C..:Wq..G...C....O.U!.....!!.'S.$.Dj...].._jj.if...Z..%...#.. =M.....u.......b	^.h.......S......;...$w.<\Lt.U....
_.%.h#._..\.....?w..b......Y.l.E.s.z}Y..e.6.w.W=K.ht....YDxo.......M.....a7..|..a%..U.G$N........x...8*..zSa@...B..y..-.@K...u.Oy.....SF.Or......1x.CJ.
2......R.k=..E.X5....V....&<....E......h...3..Vz..J+...9...fgm.E".I..w.D...6#)..._....4. E......r....d._.5n.C].......DL!..B...G..L....}..{	.._.+=..Nm.....Z.CyF....]..y~...0)mA...M....F.<._..b..8P6R.{)....?..G...1!0..K..D,.e.=~.z>.O].(..T...3...x.+....q`.m]cY..\zeD...=..+K...O.(.Df....8[..."..vu.V
...=.fl..D.Og......-;...I_#=.dJ.e..N#>".}.....g4..K..xmkq.*O....@..l-._.7..YB.....P...=..P.S..q...7...k{7ks-9._v.3...U\.U....m.N.Tf<......I&.eG.=.j..|.................=.CI.PNb.....fb.8v.TLq.Y..!.l_6d(..........I..}:..~>.N..!....F..b........L-.W0E.^x......D.J.]	.	K.o`..'....u"..s..Fs:9n	BP.j...8i..#..(.Y. ..v.khJ...!*..M....... .
.X2f.t.......09lV....N.._.
..<..........?..R.J..N`fN*5..u.?j;`E>...e...!..W.^H\......s13.-..s.w...h...u.a..=.J.T....mph.~Kf..$...~.mIk...Q.\:.Y...}...Y..."...-1..Rw.xc.`.....hhL";Cn1L>U.<..	.=1&(..g.N.vj..	.B.r..UL.#L.._.......e..C.d.~.p73..S..Ek	
..
JSK.....Uf.*.uY.o.P.....a..|n....y......f............X..Y.b...,	;St].,$C.@..k=...g..p.H.Cu.v....	9$.|.F..LN1.p.:^.Ug.......o:...$....6...H...w....6=....Hy.....`.F_...D..f.g.7.'\.^....X.w.Wy.........m.nU..]..O..47.hK@.W.fab).....o..MP]ms...
...#.;N...>..[J...0.2..R....Hn..u...;..p.6......H#.r..e.T.;..W.j"i.D...*...|?*......v......\h...8I..oU...L....j...cj8.[......y%Sn4:)../..u.v..or...j...	.....y.,...!.XQ_8..;.(...8...E..Pu'..}...L..t%4.]Qw..~.7....w..J....d.....S`........W.....6W.<....=|.Vvw.t).....m.K..d..YX....e....U0.........L.........Y....v!..43v.7..9.......n...&.*....q<R...(r...i...eUh....*.m...M..>....J.H..Jx..5#_.r=+...p0......*.#.....C........f!H..&.cY..T.&.3..0.m5	\.^d..5.....\AP.;.V..K./.K..V.})..lf.b.W.7N.ae..7.1_......g.PxF.+.w{.>.(......f3iA..x,$'2.$m..GdKR.....
..+........J......b.
....rK.]..BNCln..a...c.....u.`.,..~.I(..p).
Ещё 2482 байта от сервера — продолжение хендшейка: вероятно, окончание цепочки сертификатов (сертификат сервера + промежуточные сертификаты CA), плюс служебные сообщения вроде CertificateVerify и Finished (если TLS 1.3). Флаг PSH означает, что сервер считает это законченным куском, который надо сразу отдать наверх приложению/TLS-стеку клиента для обработки. Сплошной нечитаемый бинарный поток — целиком зашифровано/закодировано.
11) Клиент подтверждает весь полученный материал хендшейка.
16:06:02.117797 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [.], ack 3871, win 564, options [nop,nop,TS val 3154850871 ecr 2364714921], length 0
12) Завершение хендшейка и начало шифрованного приложения
16:06:02.119698 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [P.], seq 518:598, ack 3871, win 564, options [nop,nop,TS val 3154850873 ecr 2364714921], length 80
16:06:02.119815 enp0s3 Out IP 172.20.10.4.39856 > 142.251.119.100.443: Flags [P.], seq 598:684, ack 3871, win 564, options [nop,nop,TS val 3154850873 ecr 2364714921], length 86
Два небольших пакета от клиента (80 и 86 байт) — это, скорее всего, завершающие сообщения TLS handshake со стороны клиента: ChangeCipherSpec (в TLS 1.2) или Finished (в TLS 1.3), плюс начало уже зашифрованного application data — то есть фактически первый зашифрованный HTTP-запрос (GET / HTTP/2 или похожий), который уже никак не  прочитать в открытом виде через tcpdump, в отличие от HTTP по 80 порту в прошлом примере.
На этом вывод обрывается (head -100 ограничил количество строк).

#### Что я понял:
В HTTP-сессии видно весь GET-запрос и весь HTML-ответ открытым текстом прямо в -A выводе. Здесь же, несмотря на тот же флаг -A, видно содержимое только до момента, пока TLS не зашифровал данные — то есть только два поля остаются видны открытым текстом всегда: SNI (google.com) в ClientHello и согласованные ALPN-протоколы (h2, http/1.1). Всё остальное — даже сертификат сервера и сам HTTP-запрос/ответ внутри — зашифровано и в tcpdump выглядит как случайный бинарный мусор. Это наглядно показывает, что именно скрывает HTTPS, а что всё ещё "утекает" наружу (и почему ECH — Encrypted Client Hello — придумали отдельно, чтобы скрыть и сам SNI тоже).


### **Вопросы:**
- Сколько пакетов летит в `dig eakramar.ru`? (обычно 2: запрос + ответ)
12 в моем случае

- Что такое UDP в DNS-выводе? Почему DNS на UDP, а не TCP?
UDP - транспортный протокол для передачи запросов ответов. Потому что с UDP быстрее, но TCP может тоже использоваться для трансфера зон.

- Когда DNS использует TCP вместо UDP? (Подсказка: ответ >512 байт, или AXFR — зонный трансфер)
для трансфера зон между мастером и зависимым сервером


## Эксперимент 4 📺 — traceroute vs mtr: путь пакета

**Что делаем:** увидеть путь сетевого пакета через интернет.

**Команды:**

### Классический traceroute
root@dnscache:/home/eakramar# traceroute google.com
traceroute to google.com (172.217.213.113), 30 hops max, 60 byte packets
 1  _gateway (172.20.10.1)  4.396 ms  4.372 ms  4.365 ms
 2  * * *
 3  * * *
 4  172.31.0.0 (172.31.0.0)  93.831 ms  93.819 ms 172.31.0.6 (172.31.0.6)  93.814 ms
 5  100.65.27.19 (100.65.27.19)  88.787 ms 100.65.27.17 (100.65.27.17)  88.781 ms 100.65.27.19 (100.65.27.19)  88.630 ms
 6  100.65.28.1 (100.65.28.1)  87.606 ms 100.65.28.2 (100.65.28.2)  101.770 ms  101.699 ms
 7  100.65.27.10 (100.65.27.10)  97.722 ms 100.65.27.22 (100.65.27.22)  101.657 ms  97.684 ms
 8  * * *
 9  172.31.0.8 (172.31.0.8)  97.494 ms 172.31.0.4 (172.31.0.4)  91.602 ms 172.31.0.8 (172.31.0.8)  71.595 ms
10  100.65.30.1 (100.65.30.1)  91.337 ms  91.259 ms  91.252 ms
11  * * *
12  100.65.30.3 (100.65.30.3)  75.425 ms  89.764 ms 100.65.30.23 (100.65.30.23)  89.626 ms
13  100.65.30.33 (100.65.30.33)  89.617 ms 100.65.30.49 (100.65.30.49)  71.680 ms 100.65.30.33 (100.65.30.33)  458.000 ms
14  195.239.56.253 (195.239.56.253)  457.967 ms 195.239.223.37 (195.239.223.37)  457.949 ms  435.550 ms
15  195.239.223.36 (195.239.223.36)  87.874 ms  79.231 ms  79.224 ms
16  pe06.KK12.Moscow.gldn.net (79.104.225.45)  126.077 ms pe03.KK12.Moscow.gldn.net (79.104.235.215)  146.395 ms  146.371 ms
17  81.211.29.103 (81.211.29.103)  146.365 ms 72.14.213.116 (72.14.213.116)  152.294 ms 81.211.29.103 (81.211.29.103)  144.246 ms
18  192.178.241.63 (192.178.241.63)  144.239 ms hr-in-f113.1e100.net (172.217.213.113)  294.129 ms 192.178.241.63 (192.178.241.63)  132.366 ms

#### Вывод по команде:
1) traceroute to google.com (172.217.213.113), 30 hops max, 60 byte packets
google.com (172.217.213.113) — DNS-резолвинг уже произошёл, это IP-адрес, до которого будет строиться маршрут.
30 hops max — максимальное TTL, которое traceroute будет пробовать. Если за 30 хопов пакет не дойдёт — остановится.
60 byte packets — размер зондирующих UDP-пакетов (по умолчанию на Linux).
traceroute: отправляет пакеты с TTL=1, TTL=2, TTL=3 и т.д. Каждый маршрутизатор на пути уменьшает TTL на 1, и когда TTL достигает 0 — отправляет обратно ICMP-сообщение Time Exceeded. Так traceroute "вычисляет" каждый хоп. На каждый TTL отправляется 3 зонда — поэтому в каждой строке три значения RTT.
2) Хоп 1 — шлюз
_gateway (172.20.10.1)  4.396 ms  4.372 ms  4.365 ms
_gateway — DNS-имя, которое /etc/hosts или systemd-resolved назначает шлюзу по умолчанию автоматически.
172.20.10.1 — это default gateway
4.396 ms / 4.372 ms / 4.365 ms — три RTT очень стабильны (~4.4 мс), шлюз рядом.
3) Хопы 2–3 — молчание
 2  * * *
 3  * * *
Три звёздочки означают, что зонды ушли, но ответа не пришло в timeout (по умолчанию 5 секунд). Возможные причины:
маршрутизатор на этом хопе настроен не отвечать на ICMP Time Exceeded (частая политика у операторов — не "светить" внутреннюю инфраструктуру);
приоритет ICMP-ответов низкий, и при нагрузке они дропаются;
это не означает потерю пакетов для реального трафика — пакеты через эти хопы всё равно проходят.
4) Хоп 4 — первый видимый оператор
4  172.31.0.0 (172.31.0.0)  93.831 ms  93.819 ms 172.31.0.6 (172.31.0.6)  93.814 ms
Адреса из диапазона 172.31.0.0/16 — RFC 1918 приватный диапазон, значит это внутренняя инфраструктура оператора (не виден снаружи).
На один хоп — два разных IP (172.31.0.0 и 172.31.0.6). Это ECMP (Equal-Cost Multi-Path) — у оператора несколько параллельных путей с одинаковой стоимостью, и разные зонды traceroute попали на разные физические маршрутизаторы. Это нормально и говорит о наличии балансировки нагрузки.
RTT резко вырос с ~4 мс до ~94 мс.
5) Хопы 5–7 — внутренняя сеть оператора
 5  100.65.27.19 (100.65.27.19)  88.787 ms 100.65.27.17 (100.65.27.17)  88.781 ms 100.65.27.19 (100.65.27.19)  88.630 ms
 6  100.65.28.1 (100.65.28.1)  87.606 ms 100.65.28.2 (100.65.28.2)  101.770 ms  101.699 ms
 7  100.65.27.10 (100.65.27.10)  97.722 ms 100.65.27.22 (100.65.27.22)  101.657 ms  97.684 ms
Все адреса из диапазона 100.64.0.0/10 — это RFC 6598, так называемое Shared Address Space (CGN — Carrier Grade NAT). Это не публичные и не обычные приватные адреса, а специально зарезервированный диапазон именно для провайдеров, которые используют NAT на уровне оператора. Клиенты снаружи их не видят никогда.
Снова ECMP: на каждом хопе видны разные IP — балансировка по нескольким линкам.
RTT колеблется в диапазоне 87–101 мс — относительно стабильно, это нормальная картина глубины внутри провайдерской сети.
6) Хоп 8 — снова молчание
8  * * *
Очередное оборудование с запрещёнными ICMP-ответами. Трафик идёт дальше.
7) Хопы 9–13 — продолжение инфраструктуры оператора
9  172.31.0.8 (172.31.0.8)  97.494 ms 172.31.0.4 (172.31.0.4)  91.602 ms 172.31.0.8 (172.31.0.8)  71.595 ms
10  100.65.30.1 (100.65.30.1)  91.337 ms  91.259 ms  91.252 ms
11  * * *
12  100.65.30.3 (100.65.30.3)  75.425 ms  89.764 ms 100.65.30.23 (100.65.30.23)  89.626 ms
13  100.65.30.33 (100.65.30.33)  89.617 ms 100.65.30.49 (100.65.10.49)  71.680 ms 100.65.30.33 (100.65.30.33)  458.000 ms
Снова микс 172.31.x.x и 100.65.x.x — всё та же внутренняя/CGN-инфраструктура оператора.
Хоп 9: RTT на третьем зонде резко упал до 71 мс (с 97), зонды попали на разные узлы с разной загруженностью — нормально при ECMP.
Хоп 13: последний зонд показал 458 мс против 89–71 мс у первых двух. Это аномальный всплеск на одном из путей — скорее всего, этот конкретный зонд попал на перегруженный линк или сделал дополнительный облёт. Сам по себе один такой выброс не критичен.
8) Хоп 14 — выход из внутренней сети, аномалия задержки
14  195.239.56.253 (195.239.56.253)  457.967 ms 195.239.223.37 (195.239.223.37)  457.949 ms  435.550 ms
195.239.x.x — это уже публичные IP-адреса. Значит, пакет наконец вышел из CGN/приватной инфраструктуры оператора в публичный интернет.
RTT ~457 мс на всех трёх зондах. Это не случайный выброс — все три попали в ~457 мс. 
Два разных IP на одном хопе — опять ECMP.
9) Хоп 15 — резкое улучшение
15  195.239.223.36 (195.239.223.36)  87.874 ms  79.231 ms  79.224 ms
RTT резко упал до 79–87 мс после 457 мс на хопе 14. Это интересный феномен: RTT хопа N+1 может быть меньше, чем RTT хопа N, потому что это не последовательные измерения, а независимые зонды с разными TTL. Разные зонды могут проходить по разным путям при ECMP, иметь разный приоритет обработки на маршрутизаторах, а ICMP-ответы генерируются процессором маршрутизатора (который может быть перегружен). Иными словами: RTT в traceroute — это RTT до данного хопа, а не время прохождения через него.
10) Хоп 16 — точка обмена трафиком, Москва
16  pe06.KK12.Moscow.gldn.net (79.104.225.45)  126.077 ms pe03.KK12.Moscow.gldn.net (79.104.235.215)  146.395 ms  146.371 ms
Здесь появляются DNS-имена — значит, эти узлы имеют PTR-записи (обратный DNS), их владельцы решили раскрывать свою топологию.
gldn.net — это Golden Telecom / VEON, крупный российский магистральный оператор.
KK12.Moscow — судя по формату имени, это точка присутствия (PoP) в Москве, конкретная стойка/площадка.
pe06 / pe03 — скорее всего Provider Edge маршрутизаторы (граничные маршрутизаторы провайдера, через которые трафик выходит во внешний мир или на пиринг).
RTT: ~126–146 мс — немного выросло, Москва географически дальше.
11) Хоп 17 — граница с Google, точка пиринга
17  81.211.29.103 (81.211.29.103)  146.365 ms 72.14.213.116 (72.14.213.116)  152.294 ms 81.211.29.103 (81.211.29.103)  144.246 ms
81.211.29.103 — диапазон принадлежит Golden Telecom/VEON, это ещё одна сторона пирингового линка.
72.14.213.116 — это уже IP-пространство Google. Диапазон 72.14.x.x хорошо известен как Google Transit/Backbone. То есть один из трёх зондов дошёл до уже гугловского узла на один хоп раньше, чем другие — снова ECMP, разные зонды пошли по разным путям.
Фактически хоп 17 — это точка пиринга между Golden Telecom и Google: трафик передаётся с одной автономной системы (AS) на другую. Это типичный IXP (Internet Exchange Point) или прямой пиринговый линк.
12) 18  192.178.241.63 (192.178.241.63)  144.239 ms hr-in-f113.1e100.net (172.217.213.113)  294.129 ms 192.178.241.63 (192.178.241.63)  132.366 ms
192.178.241.63 — адрес Google backbone, внутренняя маршрутизация внутри AS Google.
hr-in-f113.1e100.net (172.217.213.113) — это конечный адрес назначения — тот самый 172.217.213.113, куда и шёл traceroute. 1e100.net — это официальный домен Google для обратного DNS их инфраструктуры (название отсылает к числу 1010010^{100}
10100 — "гугол", откуда и Google).
Один из зондов (294 мс) снова выбился из паттерна — остальные 132–144 мс, значит конкретный путь этого зонда через backbone был длиннее.

#### Что я понял:

Итого 18 хопов до Google, суммарный RTT ~130–150 мс в нормальном режиме — вполне ожидаемо для маршрута через несколько операторов с CGN.


root@dnscache:/home/eakramar# traceroute -I google.com
traceroute to google.com (209.85.233.102), 30 hops max, 60 byte packets
 1  _gateway (172.20.10.1)  7.713 ms  7.673 ms *
 2  * * *
 3  * * *
 4  172.31.0.6 (172.31.0.6)  79.696 ms  79.693 ms  87.429 ms
 5  100.65.27.17 (100.65.27.17)  87.426 ms  90.564 ms  90.561 ms
 6  100.65.28.1 (100.65.28.1)  90.558 ms  86.508 ms  86.458 ms
 7  100.65.27.10 (100.65.27.10)  91.334 ms  91.326 ms  91.321 ms
 8  * * *
 9  172.31.0.4 (172.31.0.4)  89.389 ms  89.386 ms  84.396 ms
10  100.65.30.1 (100.65.30.1)  93.947 ms  91.006 ms  90.972 ms
11  * * *
12  100.65.30.25 (100.65.30.25)  70.535 ms  87.996 ms  87.975 ms
13  100.65.30.49 (100.65.30.49)  90.306 ms  99.085 ms  83.806 ms
14  195.239.223.37 (195.239.223.37)  83.765 ms  89.252 ms  84.597 ms
15  195.239.223.36 (195.239.223.36)  68.021 ms  77.192 ms  69.431 ms
16  pe06.KK12.Moscow.gldn.net (79.104.225.47)  124.933 ms  122.572 ms  118.360 ms
17  81.211.29.103 (81.211.29.103)  123.782 ms  113.522 ms *
18  192.178.241.63 (192.178.241.63)  134.253 ms * *
19  192.178.241.66 (192.178.241.66)  129.556 ms * *
20  192.178.240.241 (192.178.240.241)  162.819 ms * *
21  142.251.237.142 (142.251.237.142)  146.524 ms * *
22  172.253.70.49 (172.253.70.49)  156.006 ms * *
23  * * *
24  * * *
25  * * *
26  * * *
27  * * *
28  * * *
29  * * *
30  * * *
root@dnscache:/home/eakramar# 

#### Вывод по команде:
1) traceroute -I google.com
-I - использовать ICMP Echo Request (ping-пакеты) вместо UDP-пакетов по умолчанию.
Зачем использовать -I: некоторые файрволы блокируют UDP, но пропускают ICMP — тогда -I даёт лучшую видимость маршрута. Обратная ситуация тоже бывает: некоторые сети блокируют именно ICMP, тогда UDP работает лучше. Судя по результату — здесь ICMP сработал хуже (об этом ниже).
2) Заголовок
traceroute to google.com (209.85.233.102), 30 hops max, 60 byte packets
IP другой — 209.85.233.102 против 172.217.213.113 в прошлый раз. Google — огромная сеть, DNS возвращает разные адреса при каждом запросе (Anycast + GeoDNS), поэтому маршрут может идти до другого конечного узла.
3) Хоп 1 — шлюз
1  _gateway (172.20.10.1)  7.713 ms  7.673 ms *
Тот же шлюз 172.20.10.1, но третий зонд вернул * — не ответил. Это уже первое проявление того, что ICMP здесь фильтруется агрессивнее. На хопе 1 это несущественно, но паттерн будет нарастать.
4) Хопы 2–3 — молчание
2  * * *
3  * * *
Аналогично предыдущему traceroute — ICMP Time Exceeded заблокирован.
5) Хопы 4–13 — инфраструктура оператора
 4  172.31.0.6 (172.31.0.6)  79.696 ms  79.693 ms  87.429 ms
 5  100.65.27.17 (100.65.27.17)  87.426 ms  90.564 ms  90.561 ms
 6  100.65.28.1 (100.65.28.1)  90.558 ms  86.508 ms  86.458 ms
 7  100.65.27.10 (100.65.27.10)  91.334 ms  91.326 ms  91.321 ms
 8  * * *
 9  172.31.0.4 (172.31.0.4)  89.389 ms  89.386 ms  84.396 ms
10  100.65.30.1 (100.65.30.1)  93.947 ms  91.006 ms  90.972 ms
11  * * *
12  100.65.30.25 (100.65.30.25)  70.535 ms  87.996 ms  87.975 ms
13  100.65.30.49 (100.65.10.49)  90.306 ms  99.085 ms  83.806 ms
Те же приватные (172.31.x.x) и CGN (100.65.x.x) адреса оператора, что и в прошлом traceroute. Но есть отличие — ECMP почти не виден: в большинстве строк все три зонда попадают на один и тот же IP, тогда как в UDP-варианте разные зонды регулярно попадали на разные маршрутизаторы.
Причина — в том, как хэшируется трафик при ECMP. ICMP-пакеты не имеют портов, поэтому хэш считается только по src IP + dst IP + ICMP type/code. Все три зонда одного TTL имеют одинаковые src и dst IP, поэтому хэш одинаковый → все три идут по одному и тому же пути. UDP-traceroute варьирует порт источника между зондами → разные хэши → разные пути → виден ECMP.
Это важное практическое следствие: traceroute -I показывает один конкретный путь, а обычный UDP traceroute показывает все параллельные пути при ECMP.
6) Хопы 14–16 — выход в публичный интернет, Москва
14  195.239.223.37 (195.239.223.37)  83.765 ms  89.252 ms  84.597 ms
15  195.239.223.36 (195.239.223.36)  68.021 ms  77.192 ms  69.431 ms
16  pe06.KK12.Moscow.gldn.net (79.104.225.47)  124.933 ms  122.572 ms  118.360 ms
Те же узлы, что и раньше — 195.239.x.x (публичный выход оператора) и Golden Telecom в Москве (gldn.net). Интересно, что здесь нет скачка до 457 мс на хопе 14, который был в UDP-варианте — RTT стабилен ~84–89 мс. Это подтверждает, что тот аномальный скачок в прошлый раз был именно из-за конкретного пути через ECMP, а не постоянной проблемой на узле.
7) Хоп 17 — пиринг с Google
17  81.211.29.103 (81.211.29.103)  123.782 ms  113.522 ms *
Граница между Golden Telecom и Google — то же место, что и в прошлом traceroute. Третий зонд уже не вернулся (*) — начинается зона, где ICMP всё хуже проходит.
8) Хопы 18–22 — Google backbone и деградация
18  192.178.241.63 (192.178.241.63)  134.253 ms * *
19  192.178.241.66 (192.178.241.66)  129.556 ms * *
20  192.178.240.241 (192.178.240.241)  162.819 ms * *
21  142.251.237.142 (142.251.237.142)  146.524 ms * *
22  172.253.70.49 (172.253.70.49)  156.006 ms * *
Это уже внутри backbone Google — все адреса из диапазонов Google (192.178.x.x, 142.251.x.x, 172.253.x.x). На каждом хопе виден только один ответ из трёх, остальные *.
Причина: Google внутри своего backbone намеренно ограничивает ICMP-ответы на транзитных узлах — либо rate limiting (не более N ICMP Time Exceeded в секунду), либо явная политика фильтрации. Это стандартная практика для защиты от ICMP-флуда и сокрытия внутренней топологии. Реальный трафик через эти хопы проходит нормально — они просто не отвечают на зонды traceroute.
9) Хопы 23–30 — полное молчание, лимит достигнут
23  * * *
...
30  * * *
Traceroute дошёл до максимального TTL (30) и остановился, так и не получив финального ICMP Echo Reply от 209.85.233.102. Это не означает, что пакеты не доходят до Google — реальный HTTP/HTTPS трафик работает нормально. Просто Google дропает ICMP Echo Request на своих граничных серверах (или где-то раньше по пути), и traceroute не получает финального подтверждения о достижении цели.

#### Что я понял:
Главный вывод: UDP-traceroute в этом случае оказался информативнее, потому что Google (как и многие крупные операторы) активно фильтрует ICMP, тогда как UDP-зонды на высокие порты проходят дальше. -I полезен в ситуациях, где именно UDP заблокирован файрволом — это надо проверять опытным путём под конкретную сеть.

### mtr — то же, но в реальном времени с потерями пакетов
mtr google.com           # интерактивный режим, выйти q

#### Вывод по команде:
1) В реальном времени отображает хопы
2) Выводит статистику по потерям
3) Выводит статистику по количеству отправленных пакетов
4) Выводит статистику по худшему, среднему и лучшему времени
5) Выводит статистику по Wrst и StDev

#### Что я понял:
Данный режим выводит статистику по хопам в реальном времени


mtr -r -c 10 google.com  # один отчёт за 10 циклов

root@dnscache:/home/eakramar# mtr -r -c 10 google.com
Start: 2026-07-02T00:50:25+0000
HOST: dnscache                    Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- _gateway                   0.0%    10   49.1  27.2   2.5 102.0  39.0
  2.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
  3.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
  4.|-- 172.31.0.0                 0.0%    10   75.5 111.9  70.6 219.3  56.8
  5.|-- 100.65.27.5                0.0%    10   86.5 132.1  78.1 364.5  89.9
  6.|-- 100.65.28.1                0.0%    10  112.2 132.6  81.0 334.7  81.4
  7.|-- 100.65.27.20               0.0%    10   84.2 136.9  78.1 307.4  71.6
  8.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
  9.|-- 172.31.0.8                 0.0%    10   80.8 122.2  75.5 251.2  67.5
 10.|-- 100.65.30.17               0.0%    10   82.2 126.9  77.7 217.1  53.3
 11.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 12.|-- 100.65.30.5                0.0%    10   86.9 110.4  83.5 148.1  25.1
 13.|-- 100.65.30.33               0.0%    10  108.7 108.0  89.7 195.8  31.7
 14.|-- 195.239.56.253             0.0%    10   68.0  92.7  68.0 155.1  23.6
 15.|-- 195.239.56.252             0.0%    10   86.6 114.5  80.7 220.0  41.9
 16.|-- pe08.KK12.Moscow.gldn.net  0.0%    10  190.3 151.8 112.6 190.3  26.7
 17.|-- 72.14.205.76               0.0%    10  155.7 140.0 118.3 188.9  20.7
 18.|-- 192.178.241.251            0.0%    10  150.1 145.8 118.5 237.0  34.1
 19.|-- 192.178.241.234            0.0%    10  143.7 145.4 128.1 212.1  24.9
 20.|-- 142.250.238.138           90.0%    10  186.9 186.9 186.9 186.9   0.0
 21.|-- 142.250.235.74             0.0%    10  204.4 170.6 131.5 237.8  39.4
 22.|-- 216.239.42.23              0.0%    10  159.4 158.9 128.6 242.5  34.4
 23.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 24.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 25.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 26.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 27.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 28.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 29.|-- lt-in-f101.1e100.net       0.0%    10  177.3 159.1 139.9 186.8  19.0
root@dnscache:/home/eakramar# 

#### Вывод по команде:
1) Тоже самое только не в реальном времени, а собирает статистику за 10 циклов

####
Если нужно отправить вывод комнады кому то, то этот вариант удобнее копировать

### Полезно для диагностики — проверь несколько целей
mtr -r -c 5 1.1.1.1      # Cloudflare DNS

root@dnscache:/home/eakramar# mtr -r -c 5 1.1.1.1
Start: 2026-07-02T01:00:45+0000
HOST: dnscache                    Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- _gateway                   0.0%     5   10.0  11.4   2.8  37.2  14.7
  2.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  3.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  4.|-- 172.31.0.0                 0.0%     5   81.2  87.2  81.2  91.8   4.3
  5.|-- 100.65.27.5                0.0%     5   88.8  89.1  77.7 104.7  10.8
  6.|-- 100.65.28.1                0.0%     5   76.9  84.9  76.9  91.4   5.9
  7.|-- 100.65.27.10               0.0%     5   85.5  84.1  77.0  88.8   4.8
  8.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  9.|-- 172.31.0.4                 0.0%     5   88.4  79.0  68.8  88.4   7.1
 10.|-- 100.65.30.17               0.0%     5   93.1  92.8  79.5 112.8  12.8
 11.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
 12.|-- 100.65.30.25               0.0%     5   79.9  86.4  79.9  93.1   6.0
 13.|-- 100.65.30.49               0.0%     5  101.3  98.6  80.5 137.1  23.2
 14.|-- 195.239.56.253             0.0%     5  125.1 100.8  75.5 129.7  24.8
 15.|-- 195.239.56.252             0.0%     5   90.5  87.1  76.9  92.2   6.5
 16.|-- pe02.Krasnoyarsk.gldn.net  0.0%     5  112.5 101.4  91.2 113.2  10.7
 17.|-- 195.218.204.255            0.0%     5   98.9 109.7  97.3 126.9  13.6
 18.|-- one.one.one.one            0.0%     5   83.6  92.8  83.6  98.3   5.8

mtr -r -c 5 8.8.8.8      # Google DNS

root@dnscache:/home/eakramar# mtr -r -c 5 8.8.8.8
Start: 2026-07-02T01:01:52+0000
HOST: dnscache                    Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- _gateway                   0.0%     5    2.5   3.9   2.5   6.8   1.7
  2.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  3.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  4.|-- 172.31.0.0                 0.0%     5   78.0  85.3  78.0 102.9  10.1
  5.|-- 100.65.27.7                0.0%     5   76.2  81.0  70.1  88.5   7.6
  6.|-- 100.65.28.2                0.0%     5   74.9  78.4  66.5  89.9   9.7
  7.|-- 100.65.27.20               0.0%     5   75.4  84.6  75.4 102.8  11.0
  8.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  9.|-- 172.31.0.8                 0.0%     5   78.6  97.5  78.0 153.8  31.9
 10.|-- 100.65.30.17               0.0%     5  101.8  95.1  80.2 103.7   9.5
 11.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
 12.|-- 100.65.30.25               0.0%     5   79.0  83.2  78.7  91.0   5.1
 13.|-- 100.65.30.49               0.0%     5   87.5 104.8  82.1 172.5  38.0
 14.|-- 195.239.223.37             0.0%     5   86.4  92.5  70.0 122.4  19.2
 15.|-- 195.239.223.36             0.0%     5   88.3 105.2  79.1 188.6  46.9
 16.|-- pe01.Khabarovsk.gldn.net   0.0%     5  156.9 169.3 134.9 211.5  29.2
 17.|-- 210.173.176.243            0.0%     5  167.0 165.8 159.8 174.2   5.5
 18.|-- 108.170.248.185            0.0%     5  165.9 165.2 160.0 170.4   3.8
 19.|-- 216.239.43.53              0.0%     5  153.6 178.7 153.6 228.5  29.9
 20.|-- dns.google                 0.0%     5  225.7 184.7 158.0 225.7  27.4


mtr -r -c 5 eakramar.ru  # твой домен через CF

root@dnscache:/home/eakramar# mtr -r -c 5 eakramar.ru
Start: 2026-07-02T01:02:35+0000
HOST: dnscache                    Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- _gateway                   0.0%     5   18.1   8.6   2.8  18.1   5.9
  2.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  3.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  4.|-- 172.31.0.0                 0.0%     5   89.7  84.2  77.1  89.7   5.8
  5.|-- 100.65.27.5                0.0%     5   87.1  82.6  78.9  87.1   3.4
  6.|-- 100.65.28.1                0.0%     5   74.4  83.9  74.4  88.4   5.6
  7.|-- 100.65.27.22               0.0%     5   75.4 102.0  75.4 179.6  43.9
  8.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
  9.|-- 172.31.0.8                80.0%     5   84.2  84.2  84.2  84.2   0.0
 10.|-- 100.65.30.17              80.0%     5  100.2 100.2 100.2 100.2   0.0
 11.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0
 12.|-- 100.65.30.5               80.0%     5  132.4 132.4 132.4 132.4   0.0
 13.|-- 100.65.30.33              80.0%     5   89.4  89.4  89.4  89.4   0.0
 14.|-- 195.239.223.37            80.0%     5   87.0  87.0  87.0  87.0   0.0
 15.|-- 195.239.223.36            80.0%     5  102.7 102.7 102.7 102.7   0.0
 16.|-- mx01.Frankfurt.gldn.net   80.0%     5  164.1 164.1 164.1 164.1   0.0
 17.|-- 79.104.28.125             80.0%     5  177.6 177.6 177.6 177.6   0.0
 18.|-- 162.158.84.78             80.0%     5  172.1 172.1 172.1 172.1   0.0
 19.|-- ???                       100.0     5    0.0   0.0   0.0   0.0   0.0


### **Что записать:**
- Сколько хопов до Google? До твоего домена?
До пиринга гугл - 17 хопов
До backbone гугл - 18 хопов
До моего домена 18-19 хопов
- На каких хопах есть потери пакетов (loss%)?
На тех, на которых задана жесткая политика в отношении к тому или иному протоколу, где то UDP фильтруют, где то UDP
- Где находится узкое место по latency?
Там где выше 200ms
- Чем mtr принципиально лучше traceroute для диагностики?
Отражает информацию в реальном времени и позволяет задать нужное количество циклов.

**Вопросы:**
- Почему некоторые хопы показывают `*` (звёздочки)? (Подсказка: ICMP filtering)
где то UDP фильтруют, где то UDP
- Если на 3-м хопе loss 20%, но на 10-м хопе loss 0% — где реально проблема? (Подсказка: некоторые роутеры просто не отвечают на ICMP, но трафик через них идёт)
Если узел вышел из строя то на 3 хопе. А если настроен фильтр то ни где.

## Эксперимент 5 📺 — `ss`: сокеты и соединения

**Что делаем:** изучить рабочий инструмент для диагностики "кто что слушает, кто куда подключён".

**Команды:**

### Все TCP соединения с PID процессов, без DNS-резолвинга
ss -tnp

root@dnscache:/home/eakramar# ss -tnp
State                   Recv-Q                   Send-Q                                     Local Address:Port                                     Peer Address:Port                   Process                   
ESTAB                   0                        60                                           172.20.10.4:22                                        172.20.10.3:52947                   users:(("sshd",pid=8374,fd=4),("sshd",pid=8237,fd=4))

#### Вывод по команде:
1) ss -tnp
-t — только TCP-соединения
-n — не резолвить имена (показывать IP/порты в числовом виде, не дергать DNS)
-p — показывать процесс (PID и имя), который держит соединение
2) State: ESTAB
Соединение установлено и активно — полноценная TCP-сессия (после успешного three-way handshake), не в процессе установки/закрытия.
3) Recv-Q: 0
В приёмном буфере сокета нет непрочитанных данных — приложение (sshd) успевает читать всё, что приходит, без задержек.
4) Send-Q: 60
60 байт в буфере отправки, ещё не подтверждённых peer'ом или ещё не переданных в сеть. Для интерактивной SSH-сессии это нормально — скорее всего, это просто данные "в полёте" в момент снятия снимка (например, вывод команды, который ещё не долетел), а не признак проблемы. Насторожиться стоит, если Send-Q постоянно растёт между несколькими снимками ss — это будет говорить о том, что peer не успевает/не может забирать данные (проблемы на VSAT-линке, потеря пакетов, маленькое окно приёма у клиента).
5) Local Address:Port: 172.20.10.4:22
Локальная сторона соединения — сервер слушает порт 22 (SSH) на адресе 172.20.10.4.
6) Peer Address:Port: 172.20.10.3:52947
Клиент, подключившийся по SSH: IP 172.20.10.3, эфемерный (динамически выбранный) исходящий порт 52947 — это порт, который выбрала клиентская ОС для исходящего TCP-соединения.
7) Process: sshd, pid=8374, fd=4 / pid=8237, fd=4
Тут два PID для одного соединения — это нормальная архитектура OpenSSH:
один sshd — родительский процесс (слушающий/форкнувший),
другой — процесс-обработчик именно этой сессии (после привилегированного разделения / privilege separation, sshd форкается на непривилегированный и привилегированный процесс для одной и той же сессии).

fd=4 в обоих случаях означает, что дескриптор сокета — четвёртый по счёту открытый файловый дескриптор в каждом из этих процессов (0,1,2 — стандартные stdin/stdout/stderr, значит сокет открыт как один из первых после них).

#### Что я понял:
Это единственное активное TCP-соединение на машине dnscache в момент снятия — моя текущая SSH-сессия с клиента 172.20.10.3 на сервер 172.20.10.4. Никаких аномалий в самом соединении не видно; единственное, на что можно обратить внимание при повторных замерах — не растёт ли Send-Q со временем, что было бы сигналом проблем с доставкой на клиентскую сторону.

### Listening сокеты (порты, которые слушают сервисы)
ss -tlnp

eakramar@dnscache:~$ ss -tlnp
State                    Recv-Q                   Send-Q                                     Local Address:Port                                     Peer Address:Port                  Process                   
LISTEN                   0                        128                                            127.0.0.1:6010                                          0.0.0.0:*                                               
LISTEN                   0                        4096                                          127.0.0.54:53                                            0.0.0.0:*                                               
LISTEN                   0                        4096                                             0.0.0.0:22                                            0.0.0.0:*                                               
LISTEN                   0                        4096                                       127.0.0.53%lo:53                                            0.0.0.0:*                                               
LISTEN                   0                        128                                                [::1]:6010                                             [::]:*                                               
LISTEN                   0                        4096                                                [::]:22                                               [::]:*                                               
eakramar@dnscache:~$

#### Вывод по команде:
1) Флаги: -t TCP, -l только слушающие сокеты (LISTEN), -n числовой вывод, -p процесс.
Важный момент: команда запущена не под root (eakramar@dnscache, а не root@dnscache), поэтому колонка Process пустая — без root ss не может определить, какой процесс держит чужие сокеты. Чтобы увидеть имена процессов, нужно sudo ss -tlnp.
2) 127.0.0.1:6010 и [::1]:6010 — LISTEN, Send-Q 128
Порт 6010 = 6000 + 10. Это классический признак X11 forwarding через SSH (ssh -X или ForwardX11 yes в конфиге). Когда клиент подключается с X11-форвардингом, sshd открывает локальный сокет на 60XX, где XX — номер display (тут display :10), и проксирует X11-трафик через SSH-туннель на клиентскую машину. Слушает только на loopback (127.0.0.1 и ::1) — снаружи недоступен, что правильно с точки зрения безопасности.
3) 127.0.0.54:53 — LISTEN, Send-Q 4096
DNS-сервис на нестандартном loopback-адресе. Это systemd-resolved (stub listener) в современных Ubuntu — специальный внутренний резолвер, который слушает на 127.0.0.54 и отвечает за upstream-резолвинг (форвардинг к реальным DNS-серверам из конфигурации).
4) 127.0.0.53%lo:53 — LISTEN, Send-Q 4096
Ещё один DNS-стаб от systemd-resolved, но на 127.0.0.53 — это классический stub resolver, на который обычно смотрит /etc/resolv.conf (nameserver 127.0.0.53). Символ %lo — это zone/scope identifier, явно указывающий интерфейс lo (loopback), к которому привязан сокет; для IPv4 обычно не показывается, но здесь ss его явно проставил.
Наличие двух адресов (127.0.0.53 и 127.0.0.54) — стандартная архитектура systemd-resolved: 53 — то, что видят приложения через resolv.conf, 54 — внутренний слушатель для конкретных настроенных DNS over TLS/обычных запросов к upstream.
5) 0.0.0.0:22 и [::]:22 — LISTEN, Send-Q 4096
SSH слушает на всех интерфейсах (IPv4 и IPv6) — это то самое соединение, которое вы видели в предыдущем ss -tnp (сессия с 172.20.10.3).

#### Что я понял:
X11 forwarding активен — если это не нужно для повседневной работы на dnscache, стоит проверить sshd_config (X11Forwarding) и не таскать его без необходимости — лишняя поверхность атаки, хоть и слушает только на loopback.
SSH открыт на 0.0.0.0 — если этот хост доступен не только из внутренней сети, стоит убедиться, что есть fail2ban/firewall-правила, ограничивающие источники подключения.

### То же для UDP
ss -ulnp

eakramar@dnscache:~$ ss -ulnp
State                   Recv-Q                  Send-Q                                        Local Address:Port                                     Peer Address:Port                  Process                  
UNCONN                  0                       0                                                127.0.0.54:53                                            0.0.0.0:*                                              
UNCONN                  0                       0                                             127.0.0.53%lo:53                                            0.0.0.0:*                                              
UNCONN                  0                       0                                        172.20.10.4%enp0s3:68                                            0.0.0.0:*                                              
eakramar@dnscache:~$

#### Вывод по команде:
1) ss -ulnp
Флаги: -u UDP-сокеты, -l только слушающие/открытые для приёма (LISTEN-эквивалент для UDP), -n числовой вывод, -p процесс (снова пусто, так как без sudo).
Важное отличие UDP от TCP: у UDP нет состояния соединения в классическом смысле (нет handshake, нет ESTAB) — поэтому вместо LISTEN видно UNCONN (unconnected) — это означает "сокет открыт и готов принимать датаграммы", а не что что-то не так.
2) 127.0.0.54:53 — UNCONN
Тот же сокет, что был в ss -tlnp — systemd-resolved, слушает UDP/53 на внутреннем адресе для upstream DNS-запросов. DNS исторически работает и по UDP (обычные запросы/ответы), и по TCP (большие ответы, зоны, TCP fallback при обрезанных UDP-пакетах) — поэтому этот же сервис логично держит порт 53 на обоих протоколах.
3) 127.0.0.53%lo:53 — UNCONN
Второй DNS-сокет от systemd-resolved — тот самый stub-резолвер, на который смотрит /etc/resolv.conf. %lo — явное указание интерфейса loopback (scope), так же как и в TCP-выводе ранее.
4) 172.20.10.4%enp0s3:68 — UNCONN
Это самая интересная строка. Порт 68 — это клиентский порт DHCP (DHCP-сервер слушает 67, клиент — 68). %enp0s3 — это конкретный сетевой интерфейс (судя по имени — стандартное предсказуемое имя интерфейса в Linux, enp0s3 типично для VirtualBox/виртуалок с эмулированным Intel-контроллером).
Это означает: интерфейс enp0s3 (тот самый, где висит IP 172.20.10.4, который видно в SSH-сессиях) получает адрес по DHCP, а не через статическую конфигурацию. DHCP-клиент (обычно systemd-networkd, dhclient или NetworkManager — зависит от того, что настроено в системе) слушает порт 68, чтобы принимать DHCP-ответы (OFFER, ACK) от DHCP-сервера, и при необходимости — обрабатывать renewal (продление lease) или обновления конфигурации от сервера без участия пользователя.

#### Что я понял:
Три UDP-сокета — все ожидаемые и штатные: два от systemd-resolved (DNS на loopback) и один DHCP-клиент на боевом интерфейсе..

### Все listening, и tcp и udp
ss -tulnp

eakramar@dnscache:~$ ss -tulnp
Netid               State                 Recv-Q                Send-Q                                    Local Address:Port                               Peer Address:Port               Process               
udp                 UNCONN                0                     0                                            127.0.0.54:53                                      0.0.0.0:*                                        
udp                 UNCONN                0                     0                                         127.0.0.53%lo:53                                      0.0.0.0:*                                        
udp                 UNCONN                0                     0                                    172.20.10.4%enp0s3:68                                      0.0.0.0:*                                        
tcp                 LISTEN                0                     128                                           127.0.0.1:6010                                    0.0.0.0:*                                        
tcp                 LISTEN                0                     4096                                         127.0.0.54:53                                      0.0.0.0:*                                        
tcp                 LISTEN                0                     4096                                            0.0.0.0:22                                      0.0.0.0:*                                        
tcp                 LISTEN                0                     4096                                      127.0.0.53%lo:53                                      0.0.0.0:*                                        
tcp                 LISTEN                0                     128                                               [::1]:6010                                       [::]:*                                        
tcp                 LISTEN                0                     4096                                               [::]:22                                         [::]:*                                        
eakramar@dnscache:~$ 

#### Вывод по команде:
1) Флаги: -t TCP, -u UDP, -l listening/UNCONN, -n числовой вывод, -p процесс. По сути это объединение двух предыдущих команд (ss -tlnp + ss -ulnp) в одном выводе — плюс появилась колонка Netid, которой не было раньше, потому что теперь нужно отличать протоколы в одной таблице.
2) udp 127.0.0.54:53 systemd-resolved DNS upstream (внутренний)
3) udp 127.0.0.53%lo:53 systemd-resolved DNS stub-резолвер (resolv.conf)
4) udp 172.20.10.4%enp0s3:68 DHCP-клиент Получение/продление адреса по DHCP
5) tcp 127.0.0.1:6010 / [::1]:6010 sshd (X11 forwarding) Форвардинг X11 SSH-сессии
6) tcp 127.0.0.54:53 systemd-resolved DNS upstream (TCP fallback)
7) tcp 127.0.0.53%lo:53 systemd-resolved DNS stub-резолвер (TCP fallback)
8) tcp 0.0.0.0:22 / [::]:22 sshd SSH-доступ (все интерфейсы, IPv4+IPv6)

#### Что я понял:
Профиль портов у dnscache выглядит ожидаемо и без сюрпризов для хоста с ролью локального DNS-кэша: DNS-сервис (systemd-resolved) на loopback по обоим протоколам, DHCP-клиент на боевом интерфейсе, SSH снаружи и временный X11-форвардинг сессии.

### Соединения в состоянии ESTABLISHED
ss -tn state established

eakramar@dnscache:~$ ss -tn state established
Recv-Q                      Send-Q                                           Local Address:Port                                             Peer Address:Port                       Process                      
0                           0                                                  172.20.10.4:22                                                172.20.10.3:52289                                                   
eakramar@dnscache:~$

#### Вывод по команде:
1) Флаги: -t TCP, -n числовой вывод, state established — фильтр, показывающий только соединения в состоянии ESTAB (в отличие от голого ss -tn, который показал бы вообще все TCP-сокеты, включая LISTEN, TIME_WAIT и т.д.). Флаг -p не указан, поэтому колонки Process нет — даже под root её тут просто не запросили.
2) Recv-Q: 0, Send-Q: 0
Оба буфера пусты — идеальное состояние для интерактивной SSH-сессии в момент простоя: всё, что было отправлено, уже подтверждено, всё, что получено, уже прочитано приложением. В отличие от самого первого разбора, где Send-Q был 60 (данные "в полёте"), здесь снимок сделан в момент, когда сессия ничего активно не передавала.
3) Local Address:Port: 172.20.10.4:22
Сервер (dnscache) на SSH-порту — та же сторона, что и во всех предыдущих разборах.
4) Peer Address:Port: 172.20.10.3:52289
Клиент с тем же IP 172.20.10.3, но новый эфемерный порт — 52289, в отличие от 52947 в самом первом выводе этой беседы. Это означает, что это другая, новая TCP-сессия, а не та же самая, что была раньше: при каждом новом SSH-подключении клиентская ОС выбирает новый случайный исходящий порт из диапазона эфемерных портов (обычно 32768–60999 в Linux).

#### Что я понял:
Это удобный способ отфильтровать "шум" и увидеть только реально активные, установленные соединения — полезно, когда нужно быстро проверить, кто сейчас подключён, не листая полный список.

### Сколько соединений к конкретному порту
ss -tn '( dport = :443 or sport = :443 )' | wc -l

eakramar@dnscache:~$ ss -tn '( dport = :443 or sport = :443 )' | wc -l
1
eakramar@dnscache:~$ ss -tn '( dport = :22 or sport = :22 )' | wc -l
2
eakramar@dnscache:~$

#### Вывод по команде:
1) Обе команды используют один и тот же паттерн: ss -tn '( dport = :PORT or sport = :PORT )' — фильтр по порту в любом направлении (либо порт назначения, либо порт источника совпадает с указанным), с числовым выводом (-n), без флага -l, значит показываются все TCP-сокеты с этим портом в любом состоянии (не только LISTEN), но по умолчанию ss без явного state покажет в основном ESTAB и связанные с ними записи.
| wc -l — просто подсчитывает количество строк в выводе, включая строку заголовка (State Recv-Q Send-Q...), которую ss всегда печатает первой.
2) Порт 443 (HTTPS): wc -l = 1
Это важный момент: единица здесь — это ровно строка заголовка и ничего больше. Значит ни одного соединения на 443 порту нет вообще — ни входящего, ни исходящего, ни в LISTEN, ни в ESTAB.
Это значит:
на хосте dnscache в данный момент не работает никакой HTTPS-сервис (нет веб-сервера, слушающего 443)
и не открыто ни одного исходящего HTTPS-соединения с этой машины в момент снятия снимка (ни к какому внешнему сайту/API/DoH-серверу)
3) Порт 22 (SSH): wc -l = 2
Здесь строка заголовка + ровно одна строка данных = ровно одно активное TCP-соединение на 22-м порту.
Это соотносится с предыдущим выводом ss -tn state established, где была одна ESTAB-запись (172.20.10.3:52289).

#### Что я понял:
Команда для подсчета количества соединений

### Сравни со старым netstat (если установлен)
netstat -tlnp 2>/dev/null

eakramar@dnscache:~$ netstat -tlnp 2>/dev/null
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:6010          0.0.0.0:*               LISTEN      -                   
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      -                   
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -                   
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -                   
tcp6       0      0 ::1:6010                :::*                    LISTEN      -                   
tcp6       0      0 :::22                   :::*                    LISTEN      -                   
eakramar@dnscache:~

#### Вывод по команде:
1) Флаги у netstat означают почти то же самое: -t TCP, -l listening, -n числовой вывод, -p процесс — но реализация и вывод отличаются от ss.
2) Набор открытых портов полностью идентичен — это ожидаемо, обе утилиты читают одни и те же данные из ядра (/proc/net/tcp, /proc/net/tcp6), просто разными способами их получают и по-разному форматируют.
3) netstat разделяет IPv4 и IPv6 явно через Proto колонку (tcp / tcp6), а адреса IPv6 показывает в сокращённой записи (::1:6010, :::22 — где ::: означает "любой адрес" для IPv6, аналог 0.0.0.0 в IPv4).
4) Отсутствует %lo / %enp0s3 — scope identifier
В выводе netstat нет того же самого 127.0.0.53%lo:53, что был в ss — просто 127.0.0.53:53, без указания интерфейса. ss в принципе даёт чуть более детальную информацию по scope-идентификаторам, netstat этого не показывает вообще.
5) Отсутствуют UDP DNS/DHCP-сокеты — потому что команда с флагом -t (только TCP), как и в ss -tlnp изначально. Если добавить -u, увидели бы то же самое, что в ss -ulnp.
6) Порядок колонок другой
netstat: Proto Recv-Q Send-Q Local Address Foreign Address State PID/Program
ss: State Recv-Q Send-Q Local Address:Port Peer Address:Port Process
Разное расположение State (в конце у netstat, в начале у ss) — просто вопрос привычки при чтении.

#### Что я понял:
 netstat в моем рабочем процессе можно не использовать вообще — ss полностью покрывает его функциональность и даёт больше возможностей для той диагностики, которой я занимаюсь. Знать netstat полезно только потому, что он ещё встречается в старых системах/докерах, где iproute2 не установлен.

### **Что записать:**
- Какие порты слушает твоя система?
6010, 53, 22, 68
- Что такое состояние `LISTEN`, `ESTABLISHED`, `TIME-WAIT`?
Это TCP-состояния: LISTEN, ESTABLISHED, TIME-WAIT
LISTEN - Сокет открыт и ждёт входящих подключений, но сам ещё ни с кем не соединён. Это состояние сервера, а не клиента — процесс сделал bind() на порт и listen(), и теперь просто "висит" в ожидании, пока кто-то не постучится.
ESTABLISHED - Полноценное, двустороннее TCP-соединение после успешного three-way handshake (SYN → SYN-ACK → ACK). В этом состоянии обе стороны могут свободно обмениваться данными в обе стороны.
TIME-WAIT - Одно из самых непонятных на первый взгляд состояний. Оно возникает после закрытия соединения — сторона, которая первой инициировала закрытие (отправила FIN), переходит в TIME-WAIT и остаётся в нём некоторое время (обычно 60 секунд, зависит от net.ipv4.tcp_fin_timeout), прежде чем сокет окончательно освобождается.
- Какой процесс слушает порт 22?
ssh
- Что показывает `Local Address` и `Peer Address`?
Local Address - означает адрес хоста
Peer Address - означает адрес с которым соединен хост

**Вопросы:**
- Что значит `0.0.0.0:22` vs `127.0.0.1:22` в Local Address? (важный для безопасности момент)
0.0.0.0:22 - означает, что прослушиваются все ssh соединения
127.0.0.1:22 - означает, что прослушивается ssh только с локального хоста
- Если видишь много `TIME-WAIT` — это плохо? (Подсказка: обычно нормально, это TCP в порядке завершает соединение)
Это не плохо, означает, что одна сторона ждет от другой стороны завершающий пакет с флагом FIN.