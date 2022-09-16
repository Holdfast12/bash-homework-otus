cat /vagrant/access.log | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq -c | sort -n -r | head > ./iplist
cat /vagrant/access.log | grep -E -o '(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]' | sort | uniq -c | sort -n -r | head > ./urllist

stat -c %Z /vagrant/script.sh

#создается файл, к котором содержатся временные отметки записей, занесенных после последнего запуска скрипта
test -f /vagrant/timesample || touch /vagrant/timesample
cat /vagrant/access.log | grep -E -o '[0-9]{,2}/[A-Z][a-z][a-z]/[0-9][0-9][0-9][0-9]:[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | sed 's_/_ _g' | sed 's/:/ /' | while read -r line; do date -d "$line" "+%s"; done | while read -r line; do [[ $line -gt $(stat -c '%y' /vagrant/timesample | date "+%s") ]] && echo $line; done | while read -r line; do date --date @$line +"%d/%b/%Y:%H:%M:%S"; done
