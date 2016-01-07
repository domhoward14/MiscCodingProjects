#! /bin/bash

checkFile()
{
        modsec_file="/usr/local/apache/conf/modsec2.custom.local.conf"
        if [[ -s  $modsec_file ]]; then
                echo "File is present and not empty" ; else
                echo "file does not exists or is empty"
        fi
}


addRule()
{
    declare -a array
    grep -oE --color '*id\:[0-9]+' /usr/local/apache/conf/modsec2.custom.local.conf  | cut -d : -f 2 > arrayinput
    while IFS= read line; do
            array+=("$line"); done < arrayinput
            number=3000000
            unique=2
           #echo "part 1 is working and on of the elements are ${array[0]}"
            while [ "$unique" -ne 1 ]; do
                    unique=1
                    for rule in "${array[@]}"; do
                            if [ "$rule" -eq "$number" ];then
                                    unique=0
                                    (( number++ ))
                            fi
                     done
            done
            echo "$number"
}

getUserInput()
{
        re='[1-5]'

        echo ""
        echo "What would you like to do ? "

        echo ""
        echo "1 : Exclude a specific rule  "
        echo "2 : Increase response body limit"
        echo "3 : Turn off Modsecurity for a domain"
        echo "4 : Turn off Modsecurityy for a specific file on a domain"
        echo "5 : Fix sites theme editor issue:"

        read userChoice

        if [[ $userChoice =~ $re ]]; then

                checkFile; else
                echo ""
                echo "Not a valid input... Please try again."

        fi

        case $userChoice in
                1)
                        mod_sec_1
                        ;;
                2)
                        mod_sec_2
                        ;;
                3)      mod_sec_3
                        ;;
                4)      mod_sec_4
                        ;;
                5)      mod_sec_5
                        ;;
        esac


}

mod_sec_1 ()
{
        echo " You chose to Exclude a specific rule for a domain"
        echo "Input the domain you want to make the rule for"
        read domain
        echo "Input id that you want to remove"
        read remove_id
        echo "you have choosen to remove rule id # $remove_id for the domain $domain"
        echo "Is this correct ?"
        verify
        id_number=$(addRule)
        echo "SecRule SERVER_NAME "\"$domain\"" phase:1,nolog,pass,ctl:ruleRemoveById="$remove_id",id:$id_number" >> "/usr/local/apache/conf/modsec2.custom.local.conf"
}

#Need to include feature that will look for this rule previously made for this domain
mod_sec_2 ()
{
        echo "You chose to Increase responseBodyLimit for a domain"
        echo "Input the domain you want to make the rule for"
        read domain
        echo "Please input the limit you would like to set(For the first time this is usually set to 2024288)."
        read limit
        echo "You have choosen to increase the  responsebodylimit to $limit for the domain $domain"
        echo "Is this correct ?"
        verify
        id_number=$(addRule)
        echo "SecRule SERVER_NAME "$domain" phase:1,nolog,pass,ctl:responseBodyLimit=$limit,id:$id_number" >> "/usr/local/apache/conf/modsec2.custom.local.conf"
}

mod_sec_3 ()
{
        echo "You chose to Turn ModSecurity off for a domain"
        echo "Input the domain you want to make the rule for"
        read domain
        echo "You have choosen to Turn ModSecurity off for the domain $domain"
        echo "Is this correct ?"
        verify
        id_number=$(addRule)
        echo "SecRule SERVER_NAME "\"$domain\"" phase:1,nolog,allow,ctl:ruleEngine=off,id:$id_number" >> "/usr/local/apache/conf/modsec2.custom.local.conf"
}

mod_sec_4 ()
{
        echo "You chose to Turn ModSecurity off for a particular file on a domain"
        echo "Input the domain you want to make the rule for"
        read domain
        echo "Please input the file that you would like to make the rule for"
        read file
        echo "You have choosen to Turn ModSecurity off for the file $file on the domain $domain"
        echo "Is this correct ?"
        verify
        id_number=$(addRule)
        echo "SecRule SERVER_NAME "\"$domain\"" chain,phase:1,nolog,allow,ctl:ruleEngine=off,id:id_number" >> "/usr/local/apache/conf/modsec2.custom.local.conf"
        echo "SecRule REQUEST_FILENAME "^\"$file\""" >> "/usr/local/apache/conf/modsec2.custom.local.conf"
}


mod_sec_5 ()
{
        echo ""
        echo "You chose to Exclude the theme editor rule for a domain"
        echo "Input the domain you want to make the rule for"
        read domain
        echo ""
        echo "you have choosen to remove rule id # 10124530 for the domain $domain"
        echo ""
        echo "Is this correct ?"
        verify
        id_number=$(addRule)
        echo ""
        echo "SecRule SERVER_NAME "\"$domain\"" phase:1,nolog,pass,ctl:ruleRemoveById=10124530,id:$id_number" >> "/usr/local/apache/conf/modsec2.custom.local.conf"
}

verify ()
{
        read answer
        #echo "the input was $answer"
        if [[  "$answer" != "yes"  ]]; then
                echo ""
                echo "This is is the inside of the verify"
                return 1
        fi
}

finish ()
{
        output=`service httpd -t 2>&1`
        syntaxCheck=`echo $output | grep -oi 'Syntax OK'`
        if [ "$syntaxCheck" == "Syntax OK" ]; then
                echo ""
                echo "Checking Apache Syntax ...."
                echo ""
                echo "Syntax is all good "
                service httpd -k restart 2>/dev/null; else
                echo ""
                echo "Syntax is not good "
                echo "Check /usr/local/apache/conf/modsec2.custom.local.conf"
        fi
}

getUserInput
finish

