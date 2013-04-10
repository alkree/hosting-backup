#!/bin/sh

send_to="example@mail.com"
subject="your hosting backup log"
backup_source="/home/u/user"
backup_dest="/home/u/user/backup"
dbuser="user"
dbpass="password"
date=`date '+%Y-%m-%d'`
list=`ls`
# Удаляем бэкапы старше 8 дней
echo Remove old backups > $backup_dest/$date.log
/usr/bin/find $backup_dest -atime +8 -delete
# Бэкапим директории с файлами
echo Open home folder: $backup_source >> $backup_dest/$date.log
cd $backup_source

echo Backup files > $backup_dest/$date.log
for ELEMENT in $list
do
	if [ $ELEMENT != 'backup' ]
	then
		/usr/bin/zip -r $backup_dest/$date-$ELEMENT.zip $ELEMENT >> $backup_dest/$date.log
	fi
done
# Бэкапим базы данных MySQL
echo Backup databases >> $backup_dest/$date.log
db=`mysql -u $dbuser -h localhost -p$dbpass -Bse 'show databases'`
for n in $db; do
        if [ $n != 'information_schema' ]
        then
		echo Backup database $n  >> $backup_dest/$date.log
		/usr/bin/mysqldump -u $dbuser -h localhost -p$dbpass $n | zip > "$backup_dest/$date-$n.zip"
        fi
done

echo Backup finished >> $backup_dest/$date.log
# Отправляем письмо администратору с отчетом о проделанной работе
mail -s $subject $send_to < $backup_dest/$date.log
