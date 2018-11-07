#!/bin/bash
# Ramin
SCRIPT_DIR="/root/scripts/"
DOMAIN_LIST=$(cat /etc/virtual/domainowners | cut -d ":" -f1)
MAIL_LIST_DIR="/etc/virtual/"
MAILFILE="/passwd"
URL_MA_EXIST="/root/scripts/.URL_mail_account_exist"
PASSG_FILE="/root/scripts/passgenerator.php"
CSV_EXPORT="/root/MailServer_NewUsers.csv"
DATE=$(date +%D)


        rm "$SCRIPT_DIR.domain_list" "$URL_MA_EXIST" "$CSV_EXPORT"

for DOMAINS in $DOMAIN_LIST
do
        echo $DOMAINS >> .domain_list
        if [ -f $MAIL_LIST_DIR$DOMAINS$MAILFILE ];then
                find $MAIL_LIST_DIR$DOMAINS$MAILFILE ! -empty >> .URL_mail_account_exist
        else
                echo $MAIL_LIST_DIR$DOMAINS$MAILFILE >> DA_change_pass.logs
        fi
done

FILE_MAILA="    /etc/virtual/DOMAIN.com/passwd
"

for MFILE in $(cat $FILE_MAILA)
do
#       echo $MFILE
        ANAME=$(echo "$MFILE" | cut -d ":" -f6 | cut -d "/" -f3)
#               echo $ANAME
        DNAME=$(echo "$MFILE" | cut -d ":" -f6 | cut -d "/" -f5)
#               echo $DNAME
        PASS_TMP=$(date +%s%N | md5sum | base64 | head -c 10)
#               echo $PASS_TMP
        sed -i 's/password1234/'$PASS_TMP'/g' $PASSG_FILE
        PASSG=$(php $PASSG_FILE)
#               echo $PASSG
        MUSER=$(echo $MFILE | cut -d ":" -f1)
        OCUSER=$(echo $MFILE | cut -d : -f 3,4,5,6,7,8,9)
#               echo $MUSER
        echo "$MUSER:$PASSG:$OCUSER" >> $MAIL_LIST_DIR$DNAME$MAILFILE'.new'
#       sed -i 's/^\("$MUSER":\)[^:]*\(:.*\)$/\1'$PASSG'\2/g' $MAIL_LIST_DIR$DNAME$MAILFILE
        sed -i 's/'$PASS_TMP'/password1234/g' $PASSG_FILE
        echo "$DNAME;$MUSER;$PASS_TMP;$DATE" >> $CSV_EXPORT
done

