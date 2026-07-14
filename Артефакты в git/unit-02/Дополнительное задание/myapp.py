#!/usr/bin/env python3
import time
import logging

# Пишем в файл, а не в journal
logging.basicConfig(
	level=logging.INFO,
	format='%(asctime)s - %(message)s',
	handlers=[logging.WatchedFileHandler('/var/log/myapp.log')]
)

while True:
	logging.info("Сообщение для тестирования ротации")
	time.sleep(1) # Пишем каждую секунду для быстрого заполнения лога
