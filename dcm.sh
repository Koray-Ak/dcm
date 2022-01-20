#!/bin/bash

help=$1
ssl=$1
ps=$1
inspect=$1
ip=$1
mount=$1
network=$1
version=$1

case $help in
"help" )
echo " About running Docker information"
echo " dcm ps :  List all Container given Host"
echo " dcm version : Show the Docker version information"
echo " dcm version -f : Format the output using the given Go template "
echo ""
echo " dcm inspect : dcm inspect provides detailed information on constructs controlled by Docker"
echo " dcm inspect help : Details for usage"
echo ""
echo " dcm ip [Driver Name] [Contaniner Name] : You can use which container are using Network Driver with dcm network command."
echo " dcm mount [Container Name] : The command shows container Mount Details"
echo " dcm ssl [Domain Name] : The command extend SSL Expire date"
;;
* );;
esac

case $version in
"version" )
if [ "$2" = "-f" ] ; then
docker version --format "{{${3}}}"
elif [ "$1" = "version" ] ; then
docker version
fi

;;

*);;
esac

case $ssl in
"ssl" )
email="peter.korduan@gdi-service.de"
www_destination="$(docker inspect proxy --format "{{json .Mounts}}" | jq -r ".[].Destination" | grep html)"
www_source="$(docker inspect proxy --format "{{json .Mounts}}" | jq -r ".[].Source" | grep html)"
letsencrypt="$(docker inspect proxy --format "{{json .Mounts}}" | jq -r ".[].Source" | grep letsencrypt)"
log_source="$(docker inspect proxy --format "{{json .Mounts}}" | jq -r ".[].Source" | grep log)"
log_destination="$(docker inspect proxy --format "{{json .Mounts}}" | jq -r ".[].Destination" | grep log)"

docker run --rm --interactive --name certbot \
    -v "$www_source:$www_destination" \
    -v "$letsencrypt:/etc/letsencrypt" \
    -v "$log_source:$log_destination" \
certbot/certbot certonly --webroot -w $www_destination -d $2 --email $email
;;
* );;
esac

case $ps in
"ps" )
docker ps -a ;;
* );;
esac

case $inspect in
"inspect" )

if [ "$2" = "help" ] ; then
	echo ""
	echo " Usage : dcm inspect [Container Name] [Options]"
	echo ""
	echo " - Mounts"
	echo "   - .[].Source"
	echo "   - .[].Destination"
	echo " - Config"
	echo "   - .Hostname"
	echo "   - .Domainname"
	echo "   - .Env"
        echo "   - .Cmd"
	echo "   - .Image"
        echo "   - .Labels"
	echo " - NetworkSettings"
	echo " - NetworkSettings.Networks"
	echo "   - .[Network Name].IPAddress   [ You can search which container are using which network driver command : dcm network ls ]"
	echo "   - .[Network Name].Gateway"
	echo "   - .[Network Name].Aliases"
	echo "   - .[Network Name].MacAddress"
	echo ""
#elif [ "$1" = "inspect" ] ; then
#echo "Usage for details command dcm inspect help"

else
docker inspect $2 --format "{{json .${3}}}" | jq -r $4
fi;;
* );;
esac





case $ip in
"ip" )
docker inspect $3 --format "{{json .NetworkSettings.Networks}}" | jq -r ".$2.IPAddress"
;;
* );;
esac


case $mount in
"mount" )
docker inspect $2 --format "{{json .Mounts}}" | jq ;;
* );;
esac

case $network in
"network" )
if [ "$2" = "ls" ] ; then
docker ps --format "table{{.Names}}\t{{.Networks}}"
else
exit
fi ;;

* );;
esac
