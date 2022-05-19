#!/bin/bash
# Simple script that checks if the domain passed on arg1 has any SPF records.
# It try to resolve if is a redirect, ptr or include type.
# I put the OK in the line end just for my own convenience, as i use this to add to postfix whitelist.
# Requires dog package.

if ! command -v dog &> /dev/null
then
    echo "Command dog could not be found, if in arch try: sudo pacman -S dog"
    exit
fi


# search for spf records on the arg1 specified domain
dnsRecords=(`dog TXT $1|grep "v=spf"|cut -d\" -f2-|sed -e 's/"//g'`)

# loops through the results, gets the type and value and print the value
for (( record=0; record < ${#dnsRecords[@]}; record++))
do
    isRedirectType=`echo ${dnsRecords[$record]}|cut -d= -f1`
    if [ $isRedirectType == "redirect" ]
    then
        type=`echo ${dnsRecords[$record]}|cut -d= -f1`
        value=`echo ${dnsRecords[$record]}|cut -d= -f2`
    else
        type=`echo ${dnsRecords[$record]}|cut -d: -f1`
        value=`echo ${dnsRecords[$record]}|cut -d: -f2-`
    fi
    if [[ $type == "ip4" || $type == "ip6" ]]
    then
        echo "$value OK"
    elif [[ $type == "include" || $type == "ptr" || $type == "redirect" ]]
    then
        ./spf.sh $value
    fi
done
