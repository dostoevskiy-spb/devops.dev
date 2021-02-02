#### Установка окружения через Docker ####

Позволяет поднять окружение для разработки, включая API и локальную БД, автоматически установить все composer-зависимости, создать .env-файлы.

***
##### Подготовка инструментов #####

_(Прим.: здесь и далее директория ``/home/user/lucky`` указана как пример некой папки, в которой будут находиться все проекты. Для удобства выполнения рекомендуется придерживаться этого пути.)_
1. ``cd ~/lucky/devops.dev`` 
1. ``./pull-all-repos.sh`` для подтягивания всех реп
1. Установить Docker CE [(инструкция с оф. сайта)](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce)
1. Установить docker-compose [(инструкция с оф. сайта)](https://docs.docker.com/compose/install/#install-compose)
1. [systemd](https://docs.docker.com/install/linux/linux-postinstall/#configure-docker-to-start-on-boot) для запуска при загрузке ОС
1. Permissions 
    
        sudo addgroup --system docker
        sudo adduser $USER docker
        newgrp docker
        reboot

1. Перенести настройки DNS [``hosts``](./hosts) в ``/etc/hosts``
    * (Опционально) Отключить nginx, если он установлен и забил 80-й порт.
    * (Опционально) Отключить apache2, если он установлен и забил 80-й порт.

***

##### Запуск контейнеров через Docker #####

Для Docker'а подготовлен перечень команд, выполняющихся через ``make``. Команды работают при выполнении в корне ``devops.dev``.
Алиасы и что входит в каждую команду можно посмотреть в [``Makefile``](./Makefile).

Для сборки и поднятия всех контейнеров:
```
cd ~/lucky/devops.dev/
make init
```
* (Опционально) Задать через env-переменную другой порт (вместо 80-го) для контейнера: ```NGINX_PORT=8080 make init```

Для отдельной пересборки БД:
```
cd ~/lucky/devops.dev/
make maindb-init
```

Докер, опираясь на [``docker-compose.yml``](./docker-compose.yml), соберёт контейнер из компонентов.
 
 Обратиться к разным частям проекта можно будет по адресам, указанным в ``hosts`` (для админ- и юзерпанели через localhost).
 
 Фронтэнд зависит от Vue и собирается npm, поэтому для него требуется дополнительное разворачивание (см. ниже). 
 
Для просмотра базы clickhouse можно использовать:
 - Штатный GUI в PHPStorm
 - Tabix, доступный по адресу http://localhost:9090/ 

***

##### Разворачивание инфрастуктуры показа #####
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash && export NVM_DIR="${XDG_CONFIG_HOME/:-$HOME/.}nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm use stable
cd ~/lucky/frontend.display.ads.balancer/
npm install
npm run init
```
***

##### Разворачивание фронтэнда для пользователей #####
```
cd ~/lucky/frontend.panel.admin/
cp .env.example .env
npm install
npm run dev
cd ~/lucky/frontend.panel.users/
cp .env.example .env
npm install
npm run dev
```
***

##### Возможные ошибки и их решение #####

Название сервисов/компонентов и что за ними скрывается можно посмотреть в [``docker-compose.yml``](./docker-compose.yml), 
а список выполняемых шагов и их команды -- в [``Makefile``](./Makefile)
 
 ```
 ERROR: No such service: php_api
 Makefile:23: recipe for target 'api-env' failed
 ```
 
 Отсутствует проект или контент для проекта api, в частности, .env.example
 
 ```
 Reading package lists...
 W: Failed to fetch http://deb.debian.org/debian/dists/stretch/InRelease  Temporary failure resolving 'deb.debian.org'
 ```
 
 При обновлении/подгрузке отсутствующих пакетов системы не удаётся подключиться к линуксовой библиотеке. Можно попытаться позднее или с другой сети.
 
 ```
 Makefile:27: recipe for target 'api-composer' failed
 ```
 
 Не удалось установить пакеты, указанные в зависимостях для ``Composer``'а. 

 ***

##### XHProf #####

Чтобы включить профайлинг, нужно использовать GET параметр `?xhprof` на эхе

GUI локально
    открыть http://127.0.0.1:94

GUI на проде (есть ограничение: доступно только с офисного ip)

```
/etc/hosts
192.168.235.11 xhprof-3u.luckyads.tech
```

***

##### Как пересобрать новый docker образ для docker hub #####

1) Ручной способ (пример)
    docker login
    docker build -t luckyteam/php73 images/php73
    docker push luckyteam/php73

2) Залить Dockerfile на bitbucket, запустить build в docker hub.

***

##### Apache Kafka #####

https://kafka.apache.org/08/documentation/#quickstart

Посмотреть список топиков
```bash
docker exec -it devopsdev_display_ads_kafka_1 kafka-topics.sh --zookeeper display_ads_zookeeper:2181 --list
```
    
Producer
```bash
docker exec -it devopsdev_display_ads_kafka_1 kafka-console-producer.sh --broker-list display_ads_kafka:9092 --topic ad_clicks
```
    
Consumer
```bash
docker exec -it devopsdev_display_ads_kafka_1 kafka-console-consumer.sh --bootstrap-server display_ads_kafka:9092 --topic ad_clicks --from-beginning
```

GUI
- Перейти на http://localhost:9393/addCluster
- Ввести "Cluster Name: local"
- Ввести "Cluster Zookeeper Hosts: 192.168.50.90:2181"

***

##### Экспорт csv fixtures из ClickHouse (пример) #####

На сервере ClickHouse

```bash
clickhouse_master --format_csv_delimiter="," --query="SELECT * FROM stats.ad_clicks WHERE toDate(clicked_at) IN ('2019-05-11','2019-05-12') FORMAT CSV" > ~/reports/stats.ad_clicks.csv
clickhouse_master --format_csv_delimiter="," --query="SELECT * FROM stats.ad_shows WHERE toDate(requested_at) IN ('2019-05-11','2019-05-12') FORMAT CSV" > ~/reports/stats.ad_shows.csv
clickhouse_master --format_csv_delimiter="," --query="SELECT * FROM stats.block_shows WHERE toDate(requested_at) IN ('2019-05-11','2019-05-12') FORMAT CSV" > ~/reports/stats.block_shows.csv
```

Локально

```bash
scp la_prod_clickhouse_master:~/reports/stats.ad_clicks.csv .
scp la_prod_clickhouse_master:~/reports/stats.ad_shows.csv .
scp la_prod_clickhouse_master:~/reports/stats.block_shows.csv .
```
