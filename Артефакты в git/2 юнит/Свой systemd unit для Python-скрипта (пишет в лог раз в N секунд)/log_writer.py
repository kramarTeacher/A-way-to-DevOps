#!/usr/bin/env python3
import time
import logging
from datetime import datetime

# Настройка логгирования в syslog (через systemd)
logging.basicConfig(
	level=logging.INFO,
	format='%(asctime)s - %(message)s',
	handlers=[logging.StreamHandler()]
)

N = 5 # секунд

while True:
	logging.info(f"Лог-сообщение в {datetime.now().isoformat()}")
	time.sleep(N)
