# Pet-проекты для портфолио DevOps

К моменту первого собеседования (~месяц 12) у тебя должно быть **4-5 серьёзных проектов на GitHub**, каждый с README, архитектурной диаграммой и live-демо где это возможно.

**Главный принцип:** проект засчитывается, только если он:
1. Лежит в публичном GitHub репо с осмысленным README
2. Содержит реальный работающий результат, не "учебный пример из туториала"
3. Имеет диаграмму архитектуры (draw.io / excalidraw / mermaid)
4. Документирует как минимум одну проблему, с которой ты столкнулся, и как её решил

**Связь с юнитами:** артефакты, которые ты делаешь по ходу юнитов (server-init.sh из юнита 6, конфиг nginx из юнита 4, скрипт бэкапа PostgreSQL из юнита 10), не теряются — они становятся строительными блоками **Проекта 1**. К юниту 9 у тебя уже почти всё готово, нужно только собрать в один отдельный репозиторий с README. То же самое для последующих проектов и этапов.

---

## Проект 1: Production-ready VPS setup (месяц 3)

**Что делает:** один скрипт превращает чистый Ubuntu VPS в защищённый веб-сервер с задеплоенным сайтом.

**Технологии:** Bash, nginx, Let's Encrypt, ufw, fail2ban, GitHub Actions

**Должен включать:**
- [ ] `server-init.sh` — идемпотентный скрипт настройки
- [ ] Простой статический сайт (твоя визитка/portfolio)
- [ ] HTTPS через Let's Encrypt с автообновлением
- [ ] GitHub Actions workflow для авто-деплоя при push
- [ ] README с архитектурной диаграммой и инструкцией
- [ ] Раздел "Lessons learned" с реальными граблями

**Критерий готовности:** Я (или незнакомый человек) могу склонировать репо, прочитать README, и за 30 минут получить такой же работающий сайт на своём VPS.

**Bonus level:** SSL Labs grade A+, Lighthouse score 95+, security headers через securityheaders.com — A+

---

## Проект 2: Containerized multi-service app (месяц 6-7)

**Что делает:** реальное приложение из 3-4 сервисов, упакованное в Docker, разворачивается одной командой.

**Технологии:** Docker, docker-compose, Python (FastAPI или Flask), PostgreSQL, Redis, nginx

**Идея приложения** (выбери одну, или придумай свою):
- URL shortener (как bit.ly) с аналитикой кликов
- Pastebin-клон с истечением срока
- Простой блог-движок с API и админкой
- Telegram bot + web dashboard для статистики

**Должен включать:**
- [ ] Backend API (Python)
- [ ] PostgreSQL для данных
- [ ] Redis для кэша/сессий
- [ ] Nginx как reverse proxy
- [ ] Multi-stage Dockerfile (минимум для production)
- [ ] docker-compose.yml для локальной разработки
- [ ] docker-compose.prod.yml для прода (с переменными окружения, без bind mounts)
- [ ] Healthchecks для всех сервисов
- [ ] Логи через docker logging driver
- [ ] README с диаграммой контейнеров и сети

**Критерий готовности:** `docker compose up` поднимает всё локально, на VPS работает по HTTPS под твоим доменом.

---

## Проект 3: Kubernetes deployment с Helm (месяц 7-8)

**Что делает:** то же приложение из проекта 2, но в Kubernetes-кластере.

**Технологии:** Kubernetes, Helm, Ingress, cert-manager

**Должен включать:**
- [ ] Helm chart с values для dev/staging/prod
- [ ] Deployments, Services, Ingress, ConfigMaps, Secrets
- [ ] StatefulSet для PostgreSQL (или managed DB через CSI)
- [ ] Horizontal Pod Autoscaler настроен
- [ ] Resource limits и requests на всех контейнерах
- [ ] Liveness и readiness probes
- [ ] cert-manager для автоматических TLS-сертификатов
- [ ] README с k8s-диаграммой (namespaces, ресурсы, потоки трафика)

**Где запускать:** managed cluster — Hetzner k8s (~€10/мес), DigitalOcean (~$12/мес), или локально kind/k3d для разработки + один день на managed для проверки.

**Критерий готовности:** Полностью работающее приложение в кластере, доступное по HTTPS, с автомасштабированием при нагрузке (продемонстрировано через нагрузочный тест с k6 или ab).

---

## Проект 4: Infrastructure as Code (месяц 10-11)

**Что делает:** вся инфраструктура для проекта 3 описана кодом и поднимается с нуля одной командой.

**Технологии:** Terraform, Ansible, GitLab CI/CD

**Должен включать:**
- [ ] Terraform-модуль для провижининга: VPC, серверы, k8s-кластер, БД, DNS-записи (через Cloudflare provider)
- [ ] Terraform state в S3-совместимом хранилище (Hetzner Object Storage / AWS S3) с блокировками
- [ ] Ansible playbook для базовой настройки серверов (там, где не managed)
- [ ] GitLab CI/CD pipeline: lint → plan → manual approval → apply
- [ ] Environments: dev, staging, prod с раздельным state
- [ ] README с архитектурной диаграммой и runbook'ом

**Критерий готовности:** Удалить всё → запустить pipeline → через 20 минут полностью рабочая инфраструктура с приложением. Сделать это публично и показать в README с записью.

**Это ключевой проект для собеседований.** На него потрать максимум времени.

---

## Проект 5: Observability stack (месяц 13-14)

**Что делает:** полный стек мониторинга и логирования для приложения из проектов 3-4.

**Технологии:** Prometheus, Grafana, Loki, Alertmanager

**Должен включать:**
- [ ] Prometheus собирает метрики с приложения (custom metrics через prometheus_client)
- [ ] Node Exporter, kube-state-metrics, cAdvisor для инфры
- [ ] Loki + Promtail для логов
- [ ] Grafana с 3-4 dashboards:
  - Application metrics (RPS, latency, errors — RED method)
  - Infrastructure (CPU, RAM, disk, network — USE method)
  - Business metrics (что-то осмысленное для твоего приложения)
  - Logs explorer
- [ ] Alertmanager с правилами (high error rate, pod crashloop, disk full) → Telegram/Slack/email
- [ ] SLO/SLI определены и измеряются
- [ ] README с описанием каждого dashboard и каждого alert

**Критерий готовности:** Сломай что-нибудь специально (kill pod, заполни диск) — alert приходит в течение 2 минут, в Grafana видно, что произошло.

---

## Опциональные проекты (если останется время или для углубления)

### Проект 6: GitOps с ArgoCD
- Деплой через ArgoCD, всё описано в Git
- Multi-environment с promotion через PR
- Sync hooks для миграций БД

### Проект 7: Chaos Engineering
- Запусти Chaos Mesh / Litmus в свой кластер
- Документируй, что сломалось и как починил
- Это очень ценно для senior-позиций

### Проект 8: Cost optimization case study
- Возьми свою инфраструктуру, проанализируй стоимость
- Оптимизируй (spot instances, autoscaling, right-sizing)
- Напиши blog post с цифрами до/после

---

## Как оформлять README каждого проекта

Минимальная структура, которую ждут на собеседовании:

```markdown
# Project Name

One-line description of what it does.

![Architecture Diagram](./docs/architecture.png)

## Why this project
What problem does it solve? Why did you build it?

## Stack
- Tech 1 — why this and not alternatives
- Tech 2 — ...

## Quick Start
```bash
# Should work on a clean machine
git clone ...
cd ...
make up
```

## Architecture
Detailed explanation with diagrams.

## Lessons Learned
- Real problems you faced
- How you solved them
- What you'd do differently

## Roadmap
What's next.
```

**Главное правило README:** напиши его так, как будто читать будет твой будущий тим-лид. Потому что он и будет.
