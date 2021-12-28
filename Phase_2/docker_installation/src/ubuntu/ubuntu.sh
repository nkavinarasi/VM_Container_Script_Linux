# !/bin/bash
currentpath=$(pwd)

FILE_UBUNTU="/etc/os-release"

log_file=message.log
status_log_file=status.log
error_file=error.log
echo "inprogress" > $currentpath/$status_log_file
echo Identifying the OS... >> $currentpath/$error_file

if [ -f $FILE_UBUNTU ]
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

    "ubuntu")
                VERSION=`sudo cat /etc/os-release | grep '^VERSION_ID=' | awk -F=  '{ print $2 }'`
		#VERSION="${VERSION//\"}"
		VERSION=`echo $VERSION | tr -d '"'`
		        if [ ${VERSION:0:2} == 16 ]
                then
                        echo OS version Identified as \""16\"" >> $currentpath/$error_file
                        URL="https://download.docker.com/linux/ubuntu/"
						FILENAME="xenial"
                    elif [ ${VERSION:0:2} == 17 ]
                    then
                        echo OS version Identified as \""17\"" >> $currentpath/$error_file
                        URL="https://download.docker.com/linux/ubuntu/"
			            FILENAME="artful"

                    elif [ ${VERSION:0:2} == 18 ]
                    then
                        echo OS version Identified as \""18\"" >> $currentpath/$error_file
                        URL="https://download.docker.com/linux/ubuntu/"
		                FILENAME="bionic"
                    elif [ ${VERSION:0:2} == 20 ]
                    then
                        echo OS version Identified as \""20\"" >> $currentpath/$error_file
                        URL="https://download.docker.com/linux/ubuntu/"
		                FILENAME="focal"
                else
                    echo Unable to proceed with ubuntu operating system version $VERSION.  >> $currentpath/$error_file
                    echo Unable to proceed with ubuntu operating system version $VERSION. > $currentpath/$log_file
                    echo failed > $currentpath/$status_log_file
                    exit 0
                fi

		echo $URL >> $currentpath/$error_file
		echo $FILENAME >> $currentpath/$error_file
		
        #wget
        echo Checking whether wget is installed or not... >> $currentpath/$error_file
		type -P wget >> $currentpath/$error_file
		if [ $? != 0 ]
		then
            echo installing the wget..>> $currentpath/$error_file
			sudo /usr/bin/apt-get -y install wget >> $currentpath/$error_file 2>&1
		fi
        #curl
		echo Checking whether curl is installed or not... >> $currentpath/$error_file
		type -P curl >> $currentpath/$error_file
		if [ $? != 0 ]
		then
            echo installing the curl..>> $currentpath/$error_file
			sudo /usr/bin/apt-get -y install curl >> $currentpath/$error_file
		fi
		
		sudo /usr/bin/wget -c -v --no-check-certificate -P /var/tmp/ $URL >> $currentpath/$error_file
		
		if [ $? != 0 ]
                then
			echo "Failed to download the url \""$URL\""" > $currentpath/$log_file
			echo "Failed to download the url \""$URL\""" >> $currentpath$error_file
                        echo "failed" > $currentpath/$status_log_file
                        exit 0;
		fi	
 		;;
		
esac

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
COMMAND1="sudo apt-get install -y  curl  apt-transport-https ca-certificates software-properties-common"
echo Executing the command $COMMAND1 >> $currentpath/$error_file
$COMMAND1 >> $currentpath/$error_file
if [ $? != 0 ]
then

	 echo "Error during installation @ command1" >>  $currentpath/$error_file
	 echo "Error during installation" >  $currentpath/$log_file
	 echo "failed" > $currentpath/$status_log_file
	 exit 0;
fi

# @command2
echo Adding the GPG key for the official Docker repository to this VM >> $currentpath/$error_file
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add >> $currentpath/$error_file 2>&1
if [ $? != 0 ]
then
    echo "Error during installation @ command2" >>  $currentpath/$error_file
    echo "Error during installation" > $currentpath/$log_file
	echo "failed" > $currentpath/$status_log_file
    exit 0;
fi



# @command3
echo Adding the Docker repository to APT sources >> $currentpath/$error_file
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >>  $currentpath/$error_file
if [ $? != 0 ]
then
    echo "Error during installation @ command3" >>  $currentpath/$error_file
    echo "Error during installation" > $currentpath/$log_file
	echo "failed" > $currentpath/$status_log_file
    exit 0;
fi

# @command4
echo installing Docker >> $currentpath/$error_file
sudo apt-get update -y && sudo apt-get install -y docker-ce >> $currentpath/$error_file 2>&1
if [ $? != 0 ]
then

    echo "Error during installation @ command4" >>  $currentpath/$error_file
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
esac
