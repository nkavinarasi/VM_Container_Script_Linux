#!/bin/bash
currentpath=$(pwd)

username=$(cat $currentpath/input.properties | grep 'mysql_username'| cut -d '=' -f 2)
password=$(cat $currentpath/input.properties | grep 'mysql_user_password'| cut -d '=' -f 2)
rootpassword=$(cat $currentpath/input.properties | grep 'mysql_root_password'| cut -d '=' -f 2)
database=$(cat $currentpath/input.properties | grep 'database_name'| cut -d '=' -f 2)
port=$(cat $currentpath/input.properties | grep 'mysql_port'| cut -d '=' -f 2)
container_name=$(cat $currentpath/input.properties | grep 'container_name'| cut -d '=' -f 2)
defined_bridge_network_name=$(cat $currentpath/input.properties | grep 'defined_bridge_network_name'| cut -d '=' -f 2)

sudo mkdir -p /opt/$container_name

echo class yamlfilecreation::var { > $currentpath/puppetinput.properties
echo \$mysql_container_name = \"$container_name\" >> $currentpath/puppetinput.properties
echo \$mysql_container_port = \"$port\" >> $currentpath/puppetinput.properties
echo \$mysql_username = \"$username\" >> $currentpath/puppetinput.properties
echo \$mysql_user_password = \"$password\" >> $currentpath/puppetinput.properties
echo \$mysql_root_password = \"$rootpassword\" >> $currentpath/puppetinput.properties
echo \$mysql_dbname = \"$database\" >> $currentpath/puppetinput.properties
echo } >> $currentpath/puppetinput.properties

sudo cp $currentpath/puppetinput.properties $currentpath/yamlfilecreation/manifests/var.pp

#docker validation started ------------------------------------------------
docker_validation(){
docker_service_check(){
    fw_status=`sudo systemctl is-active docker`
if [ "$fw_status" == "active" ];
then
    echo Docker is in running state >>$currentpath/error.log
    #echo success >$currentpath/status.log
else
    echo Dokcer is in stopped state >>$currentpath/error.log
    sudo systemctl start docker >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; 
    then
        echo Docker started successfully >>$currentpath/error.log
        #echo success >$currentpath/status.log
    else
        echo Faced issue while start the docker service. >>$currentpath/error.log
        echo Faced issue while start the docker service. >$currentpath/info.log
        echo failed >$currentpath/status.log
        exit 0
    fi
fi
}

sudo docker version >>$currentpath/error.log 2>&1
if [ $? == 0 ]; 
then
    echo Docker installed in this VM >$currentpath/error.log 2>&1
    docker_service_check
else
    echo Docker is not installed in this VM.Please check and execute the script again. >>$currentpath/error.log 2>&1
    echo Docker is not installed in this VM.Please check and execute the script again. >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0
fi
}

#puppet validation started ------------------------------------------------
puppet_validation(){
puppet_service_check(){
    fw_status=`sudo systemctl is-active puppet`
if [ "$fw_status" == "active" ];
then
    echo puppet is in running state >>$currentpath/error.log
    #echo success >$currentpath/status.log
else
    echo Dokcer is in stopped state >>$currentpath/error.log
    sudo systemctl start puppet >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; 
    then
        echo puppet started successfully >>$currentpath/error.log
        #echo success >$currentpath/status.log
    else
        echo Faced issue while start the puppet service. >>$currentpath/error.log
        echo Faced issue while start the puppet service. >$currentpath/info.log
        echo failed >$currentpath/status.log
        exit 0
    fi
fi
}

sudo puppet --version >>$currentpath/error.log 2>&1
if [ $? == 0 ]; 
then
    echo puppet installed in this VM >>$currentpath/error.log 2>&1
    puppet_service_check
else
    echo puppet is not installed in this VM.Please check and execute the script again. >>$currentpath/error.log 2>&1
    echo puppet is not installed in this VM.Please check and execute the script again. >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0
fi
}
#docker script execution started ------------------------------------------------
docker_execution(){
error_check(){
if grep "error" "$currentpath/error.log" ; then 
        echo MySQL container Creation getting failed.Kindly find the error.log for more information >>$currentpath/error.log
        echo MySQL container Creation getting failed.Kindly find the error.log for more information > $currentpath/info.log
        echo failed > $currentpath/status.log
        exit 0
fi

if grep "Error" "$currentpath/error.log" ; then
        echo MySQL container Creation getting failed.Kindly find the error.log for more information >>$currentpath/error.log
        echo MySQL container Creation getting failed.Kindly find the error.log for more information > $currentpath/info.log
        echo failed > $currentpath/status.log
        exit 0
else
        #echo "success" > $currentpath/status.log
        echo MySQL container has been created successfully >> $currentpath/error.log
        echo MySQL container has been created successfully > $currentpath/info.log
fi

}

sudo docker network ls | grep $defined_bridge_network_name >>$currentpath/error.log 2>&1
if [ $? == 0 ]; then
    echo Network "$defined_bridge_network_name" is already exist >>$currentpath/error.log 
else
    sudo docker network create -d bridge $defined_bridge_network_name >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; then
        echo Network "$defined_bridge_network_name" is created >>$currentpath/error.log
    else
        echo Network "$defined_bridge_network_name" is not created >>$currentpath/error.log 
        echo Network "$defined_bridge_network_name" is not created >$currentpath/info.log
        echo failed >$currentpath/status.log
        exit 0 
    fi
fi

echo sudo docker pull mysql:5.7.34 >>$currentpath/error.log 2>&1
if [ $? == 0 ]; then
    echo MySQL image is created successfully >>$currentpath/error.log
    sudo docker run -d --network $defined_bridge_network_name -v /opt/$container_name:/var/lib/mysql --name $container_name -e MYSQL_USER=$username -e MYSQL_PASSWORD=$password -e MYSQL_ROOT_PASSWORD=$rootpassword  -e MYSQL_DATABASE=$database -p $port:3306 mysql:5.7.34 >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; then
        echo MySQL container is created successfully >>$currentpath/error.log
        sudo docker logs $container_name >>$currentpath/error.log 2>&1
        error_check
    else
        echo Facing issue in MySQL container creation >>$currentpath/error.log
        echo Facing issue in MySQL container creation >$currentpath/info.log
        echo failed >$currentpath/status.log
        exit 0 
    fi
else
    echo Facing issue in MySQL image creation >>$currentpath/error.log
    echo Facing issue in MySQL image creation >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0 
fi

}
#puppet script execution started ------------------------------------------------
puppet_script_execution(){
puppet_error_check() {
    if grep "(err):" "$currentpath/puppeterror.log" ;then
        echo MySQL YAML Creation getting failed.Kindly find the puppeterror.log for more information >>$currentpath/error.log
        echo MySQL YAML Creation getting failed.Kindly find the puppeterror.log for more information > $currentpath/info.log
        echo failed > $currentpath/status.log
        exit 0
    else
        echo MySQL YAML Creation done successfully >>$currentpath/error.log
        echo MySQL YAML Creation done successfully > $currentpath/info.log
        echo success > $currentpath/status.log
    fi
}

#Without sudo execution
puppet_execution() {
puppet apply -v -d --modulepath="$currentpath" -e "include yamlfilecreation" --logdest  $currentpath/puppeterror.log
if [ $? == 0 ]; then
    echo puppet script execution done successfully >>$currentpath/error.log
    puppet_error_check
else
    echo Facing issue while puppet script execution.Kindly see the puppeterror.log for more information >>$currentpath/error.log
    echo Facing issue while puppet script execution.Kindly see the puppeterror.log for more information >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0 
fi
}

#Sudo execution
sudo_puppet_execution() {
sudo puppet apply -v -d --modulepath="$currentpath" -e "include yamlfilecreation" --logdest  $currentpath/puppeterror.log
if [ $? == 0 ]; then
    echo puppet script execution done successfully >>$currentpath/error.log
    puppet_error_check
else
    echo Facing issue while puppet script execution.Kindly see the puppeterror.log for more information >>$currentpath/error.log
    echo Facing issue while puppet script execution.Kindly see the puppeterror.log for more information >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0 
fi
}

#user privileges check
ROOT_UID=0
if [ "$UID" -eq "$ROOT_UID" ]; then 
echo "You are root user" >> $currentpath/info.log 
echo "You are root user"
puppet_execution  
else
    sudo touch privilege_check.log > /dev/null
    sudo mv privilege_check.log /opt/ > /dev/null
    
    if [ $? -eq 0 ] ; then
        sudo rm -rf /opt/privilege_check.log > /dev/null
        sudo echo "You are not root user.But having user permission to execute the script" >> $currentpath/error.log
	    sudo echo "You are not root user.But having user permission to execute the script" > $currentpath/info.log
        sudo_puppet_execution
    else
        sudo echo "You are not root or sudo user" > $currentpath/info.log
	    sudo echo "You are not root or sudo user" >> $currentpath/error.log
        echo failed >$currentpath/status.log
        exit 0
    fi
fi

}

#final status started ------------------------------------------------
final_check(){
    sudo docker ps | grep "$container_name" >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; then
        if [ -f "/opt/MaaS/DockerContainer/$container_name.yaml" ]
        then
            echo MySQL container and MySQL YAML file created successfully >>$currentpath/error.log
            echo MySQL container and MySQL YAML file created successfully >$currentpath/info.log
            echo success >$currentpath/status.log
            exit 0
        else
            echo MySQL container only created successful.MySQL YAML file not created >>$currentpath/error.log
            echo MySQL container only created successful.MySQL YAML file not created >$currentpath/info.log
            echo failed >$currentpath/status.log
            exit 0
        fi
else
    echo MySQL container is not running or not created.Kindly see the error.log for more information >>$currentpath/error.log
    echo MySQL container name is not exist.Kindly see the error.log for more information >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0 
fi

}
#scrit execution order
docker_validation
echo docker validation completed 
puppet_validation
echo puppet validation completed 
docker_execution
echo docker execution completed
puppet_script_execution
echo puppet execution completed
final_check
echo final check completed