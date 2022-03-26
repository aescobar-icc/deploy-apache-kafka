# deploy-apache-kafka (alpha version)

This project is a simple "mini cluster" of kafka running with docker-compose.

Consists of a zookeeper service and two broker services.

used as base https://github.com/aescobar-icc/base-apache-kafka for running kafka services


the config/*.properties has been created with environment variables and their values will be picked up from each env file as appropriate. (services/broker-(1/2)/.env or services/global.env respectively)

## 1.- Simple Run 

    ./run.sh