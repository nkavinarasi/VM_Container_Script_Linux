# !/bin/bash
currentpath=$(pwd)

FILE_CENTOS="/etc/centos-release"
FILE_UBUNTU="/etc/os-release"

log_file=message.log
status_log_file=status.log
error_file=error.log
echo "inprogress" > $currentpath/$status_log_file
echo Identifying the OS... >> $currentpath/$error_file

if [ -f $FILE_CENTOS ]
then
        STATUS=`sudo cat $FILE_CENTOS |sed s/\ release.*//`
	if [ "$STATUS" == "CentOS" ] || [ "$STATUS" == "CentOS Linux" ]
	then
        echo OS Identified as \""Centos\"" >> $currentpath/$error_file
		OSNAME="CentOS"
			fi
	
	elif [ -f $FILE_UBUNTU ]
then
        STATUS=`sudo cat $FILE_UBUNTU | grep '^ID=' | awk -F=  '{ print $2 }'`
        echo OS Identified as \""$STATUS\"" >> $currentpath/$error_file
        OSNAME=$STATUS
	
else
        echo Unable to proceed with this operating system. >> $currentpath/$error_file
        echo Unable to proceed with this operating system.  > $currentpath/$log_file
        echo failed > $currentpath/$status_log_file
        exit 0
fi

echo Identifing the OS version >> $currentpath/$error_file

case "$OSNAME" in

        "CentOS")
		
		VERSION=`sudo cat /etc/centos-release | sed s/.*release\ // | sed s/\ .*//`

                if [ ${VERSION:0:1} == 7 ]
                then
                        echo OS version Identified as \""7\"" >> $currentpath/$error_file
                        URL="https://download.docker.com/linux/centos/docker-ce.repo"
						
		else
                echo Unable to proceed with CentOS operating system version $VERSION.  >> $currentpath/$error_file
                echo Unable to proceed with CentOS operating system version $VERSION. > $currentpath/$log_file
                echo failed > $currentpath/$status_log_file
                exit 0
                fi

	        COMMAND1=" sudo yum install -y yum-utils device-mapper-persistent-data lvm2"
            COMMAND2="sudo yum-config-manager --add-repo $URL"
            COMMAND3="sudo yum install -y docker-ce "
            COMMAND4="sudo systemctl start docker"    
            
# Executing the commands

echo Executing the commands..>>$currentpath/$error_file
echo Checking whether Docker is installed or not... >> $currentpath/$error_file
type -P docker >> $currentpath/$error_file
if [ $? != 0 ]
then
    echo Docker is not installed in this machine... >> $currentpath/$error_file
    echo Started the installation process.. >> $currentpath/$error_file
    echo $URL >> $currentpath/$error_file
else 
    echo "Docker is already installed in this machine. Kindly check and try again." >> $currentpath/$log_file
    echo "Docker is already installed in this machine. Kindly check and try again." >> $currentpath/$error_file
    echo "success" > $currentpath/$status_log_file
    exit 0
fi

if /usr/bin/curl --output /dev/null --silent --head --fail "$URL"

then
    echo "This URL Exist" >> $currentpath/$error_file
else
	echo $URL
	echo "Invalid URL" >> $currentpath/$error_file
    echo "Invalid URL $URL" >    $currentpath/$log_file
	echo "failed" > $currentpath/$status_log_file
	exit 0;
fi


# @command1
echo Executing the command $COMMAND1 >> $currentpath/$error_file
$COMMAND1 >> $currentpath/$error_file
if [ $? != 0 ]
then

	 echo "Error during installation @ $command1" >>  $currentpath/$error_file
	 echo "Error during installation" >  $currentpath/$log_file
	 echo "failed" > $currentpath/$status_log_file
	 exit 0;
fi

# @command2
echo Executing the command $COMMAND2 >> $currentpath/$error_file
$COMMAND2 >> $currentpath/$error_file
if [ $? != 0 ]
then
    echo "Error during installation @ $command2" >>  $currentpath/$error_file
    echo "Error during installation" > $currentpath/$log_file
	echo "failed" > $currentpath/$status_log_file
    exit 0;
fi


# @command3
echo Executing the command $COMMAND2 >> $currentpath/$error_file
$COMMAND3 >> $currentpath/$error_file
if [ $? != 0 ]
then
    echo "Error during installation @ $command2" >>  $currentpath/$error_file
    echo "Error during installation" > $currentpath/$log_file
	echo "failed" > $currentpath/$status_log_file
    exit 0;
fi

# @command4
echo Executing the command $COMMAND3 >> $currentpath/$error_file	
$COMMAND4 >> $currentpath/$error_file
if [ $? != 0 ]
then

    	echo "Error during installation @ $command3" >>  $currentpath/$error_file
    	echo "Error during installation" > $currentpath/$log_file
	echo "failed" > $currentpath/$status_log_file
	exit 0;
else
	echo "Docker installation is successfully completed." >> $currentpath/$log_file
    	echo "Docker installation is successfully completed." >> $currentpath/$error_file
	echo "success" > $status_log_file
        exit 0;
fi
;;

  "ubuntu")
    
    sudo chmod 775 $currentpath/src/ubuntu/ubuntu.sh > /dev/null
    sudo bash ./src/ubuntu/ubuntu.sh > $currentpath/null.log 2>&1
    sudo rm -rf  $currentpath/null.log
    exit 0
;;
esac
