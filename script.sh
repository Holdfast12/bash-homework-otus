#!/bin/bash
#создаю файл, наличием которого буду блокировать запуск нескольких копий скрипта
touch /var/tmp/script.lock
# если ранее файл отчета не создавался, создаю новый. в первой строчке храню момент последнего запуска скрипта для использования при следующих запусках
test -f /vagrant/result || echo "0000000000" > /vagrant/result
let t=$(head -n1 /vagrant/result)
echo $(date "+%s") > /vagrant/result

#Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
echo -en "\n\nIP адреса\n" >> /vagrant/result
cat /vagrant/access.log | grep -E -o '[0-9]{,2}/[A-Z][a-z][a-z]/[0-9][0-9][0-9][0-9]:[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | sed 's_/_ _g' | sed 's/:/ /' | while read -r line; do date -d "$line" "+%s"; done | while read -r line; do [[ $line -gt $t ]] && echo $line; done | while read -r line; do date --date @$line +"%d/%b/%Y:%H:%M:%S"; done | while read -r line; do grep $line /vagrant/access.log; done | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq -c | sort -n -r | head >> /vagrant/result

#Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
echo -en "\n\nзапрашиваемые URL\n" >> /vagrant/result
cat /vagrant/access.log | grep -E -o '[0-9]{,2}/[A-Z][a-z][a-z]/[0-9][0-9][0-9][0-9]:[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | sed 's_/_ _g' | sed 's/:/ /' | while read -r line; do date -d "$line" "+%s"; done | while read -r line; do [[ $line -gt $t ]] && echo $line; done | while read -r line; do date --date @$line +"%d/%b/%Y:%H:%M:%S"; done | while read -r line; do grep $line /vagrant/access.log; done | grep -E -o '(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]' | sort | uniq -c | sort -n -r | head >> /vagrant/result

#Ошибки веб-сервера/приложения c момента последнего запуска
echo -en "\n\nОшибки веб-сервера/приложения\n" >> /vagrant/result
cat /vagrant/access.log | grep -E -o '[0-9]{,2}/[A-Z][a-z][a-z]/[0-9][0-9][0-9][0-9]:[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | sed 's_/_ _g' | sed 's/:/ /' | while read -r line; do date -d "$line" "+%s"; done | while read -r line; do [[ $line -gt $t ]] && echo $line; done | while read -r line; do date --date @$line +"%d/%b/%Y:%H:%M:%S"; done | while read -r line; do grep $line /vagrant/access.log; done | grep -E -o 'HTTP/1.1" [1-5][0-9][0-9]' | grep -E -o 'HTTP/1.1" 400' | sort | uniq -c | sed 's:HTTP/1.1" 400:ошибок сервера с кодом 400 зафиксировано:' >> /vagrant/result

#Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта
echo -en "\n\nкоды HTTP ответа\n" >> /vagrant/result
cat /vagrant/access.log | grep -E -o '[0-9]{,2}/[A-Z][a-z][a-z]/[0-9][0-9][0-9][0-9]:[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | sed 's_/_ _g' | sed 's/:/ /' | while read -r line; do date -d "$line" "+%s"; done | while read -r line; do [[ $line -gt $t ]] && echo $line; done | while read -r line; do date --date @$line +"%d/%b/%Y:%H:%M:%S"; done | while read -r line; do grep $line /vagrant/access.log; done | grep -E -o 'HTTP/1.1" [1-5][0-9][0-9]' | grep -E -o '[1-5][0-9][0-9]' | sort | uniq -c | sort -n -r >> /vagrant/result

#В письме должен быть прописан обрабатываемый временной диапазон
echo -en "\n\nРезультаты работы скрипта за период $(date -d@$t)  -  $(date -d@$(head -n1 /vagrant/result))\n" >> /vagrant/result

cat /vagrant/result | mutt -s "Отчет скрипта" mih.kalyujniy@yandex.ru

trap "rm /var/tmp/script.lock" EXIT