# deploy-apache-kafka (alpha version)

This project is a simple "mini cluster" of kafka running with docker-compose.

Consists of a zookeeper service and two broker services.

used as base https://github.com/aescobar-icc/base-apache-kafka for running kafka services


the config/*.properties has been created with environment variables and their values will be picked up from each env file as appropriate. (services/broker-(1/2)/.env or services/global.env respectively)

## 1.- Simple Run
```bash
./run.sh
```

## 2.- Topics

First go to helpers folder
```bash
cd deploy-apache-kafka/helpers/
```
### to create
```bash
./topics.sh --create --topic=test02 --replic=2 --part=3
```
### to describe
```bash
./topics.sh --describe --topic=test02
```
### to list all
```bash
./topics.sh --list
```