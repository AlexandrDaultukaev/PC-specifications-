#! /bin/bash

date
echo $USER
hostname

# cpu_data=$(lscpu -J)
#set -o noclobber
model_arc_thpercore=$( lscpu | grep 'Модель:\|Архитектура:\|Потоков на ядро:')
cpu=$( lscpu | grep 'CPU МГц' -m 1 )
cpus=$( lscpu | grep 'CPU(s)' -m 1 )
echo -e "\tПроцессор\n$model_arc_thpercore\n$cpu\n$cpus"
cat /proc/meminfo > file.txt

echo -e "\tОперативная память"
mem_total=$(awk '$1 == "MemTotal:" {print "Всего " $2" kB"}' file.txt)
mem_available=$(awk '$1 == "MemAvailable:" {print "Доступно " $2" kB"}' file.txt)
echo -e "$mem_total\n$mem_available"

echo -e "\tЖёсткий диск"
df -h /home > file.txt
hd_used=$(awk 'NR == 2{print "Использовано " $3}' file.txt)
hd_free=$(awk 'NR == 2{print "Доступно " $4}' file.txt)
mounted=$(awk 'NR == 2{print "Смонтировано в / " $2}' file.txt)
echo -e "$hd_used\n$hd_free\n$mounted"
free -h > file.txt
swap_total=$(awk 'NR == 3{print "SWAP Всего " $2}' file.txt)
swap_available=$(awk 'NR == 3{print "SWAP Доступно " $4}' file.txt)
echo -e "$swap_total\n$swap_available"

echo -e "\tСетевые интерфейсы"
echo -e "Количество: $(ls -A /sys/class/net | wc -l)"
ls -A /sys/class/net > file.txt
name1=$(awk 'NR == 1{print $1}' file.txt)
name2=$(awk 'NR == 2{print $1}' file.txt)
ifconfig -a > file.txt
mac1=$(awk '{if ($1 == "ether") {print $2}}' file.txt)
mac2=$(awk -v other_mac="$mac1" '{if ($1 == "ether" && $2 != other_mac) {print $2}}' file.txt)
if [ -z "$mac2" ]
then
    mac2="none"
fi
if [ -z "$mac1" ]
then
    mac1="none"
fi
ip1=$(awk '{if ($1 == "inet") {print $2; exit;}}' file.txt)
ip2=$(awk -v other_ip="$ip1" '{if ($1 == "inet" && $2 != other_ip) {print $2}}' file.txt)
#speed1=$(cat /sys/class/net/$name1/speed)
speed1="none"
if [ $ip2 == "127.0.0.1" ]
then
    speed2="none"
fi
if [ $ip1 == "127.0.0.1" ]
then
    speed1="none"
fi

echo -e "№ | Имя сет. инт. | MAC-адрес         | IP-адрес     | Скорость соед. |"
echo -e "1 | $name1            | $mac1 | $ip1    | $speed1           |"
echo -e "2 | $name2     | $mac2              | $ip2  | $speed2               |"
