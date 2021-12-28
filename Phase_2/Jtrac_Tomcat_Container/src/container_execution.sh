#!/bin/bash
currentpath=$(pwd)

#grep variables from input.properties file
port=$(cat $currentpath/input.properties | grep 'tomcat_port'| cut -d '=' -f 2)
tomcat_container_name=$(cat $currentpath/input.properties | grep 'tomcat_container_name'| cut -d '=' -f 2)
source_file_path=$(cat $currentpath/input.properties | grep 'source_file_path'| cut -d '=' -f 2)
properties_file_path1=$(cat $currentpath/input.properties | grep 'properties_file_path1'| cut -d '=' -f 2)
properties_file_path2=$(cat $currentpath/input.properties | grep 'properties_file_path2'| cut -d '=' -f 2)
username=$(cat $currentpath/input.properties | grep 'mysql_username'| cut -d '=' -f 2)
password=$(cat $currentpath/input.properties | grep 'mysql_user_password'| cut -d '=' -f 2)
mysql_port=$(cat $currentpath/input.properties | grep 'mysql_port'| cut -d '=' -f 2)
database=$(cat $currentpath/input.properties | grep 'database_name'| cut -d '=' -f 2)
mysql_docker_name=$(cat $currentpath/input.properties | grep 'mysql_container_name'| cut -d '=' -f 2)
jtrac_home=$(cat $currentpath/input.properties | grep 'jtrac_home'| cut -d '=' -f 2)
defined_bridge_network_name=$(cat $currentpath/input.properties | grep 'defined_bridge_network_name'| cut -d '=' -f 2)

#create puppetinput.properties file and move to puppet module
echo class yamlfilecreation::var { > $currentpath/puppetinput.properties
echo \$tomcat_container_name = \"$tomcat_container_name\" >> $currentpath/puppetinput.properties
echo \$tomcat_container_port = \"$port\" >> $currentpath/puppetinput.properties
echo } >> $currentpath/puppetinput.properties

sudo cp $currentpath/puppetinput.properties $currentpath/yamlfilecreation/manifests/var.pp

#configure the jtrac.properties file
if [ -f $properties_file_path1 ]; then
    sudo apt-get install sed -y >>$currentpath/error.log 2>&1
    /bin/sed -i "/database.url/s/^/##/g" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/database.url/a database.url=jdbc:mysql://$mysql_docker_name:$mysql_port/$database" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/^##database.url/d" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/database.username/s/^/##/g" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/database.username/a database.username=$username" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/^##database.username/d" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/database.password/s/^/##/g" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/database.password/a database.password=$password" $properties_file_path1 >>$currentpath/error.log 2>&1
    /bin/sed -i "/^##database.password/d" $properties_file_path1 >>$currentpath/error.log 2>&1
else
    echo "Jtrac properties file path is not found.Please give the valid path" >  $currentpath/error.log
    echo "Jtrac properties file path is not found.Please give the valid path" >  $currentpath/info.log
    echo failed > $currentpath/status.log
    exit 0
fi

#configure the jtrac-init.properties file
if [ -f $properties_file_path2 ]; then
    /bin/sed -i "/jtrac.home/s/^/##/g" $properties_file_path2 >>$currentpath/error.log 2>&1
    /bin/sed -i "/^##jtrac.home/d" $properties_file_path2 >>$currentpath/error.log 2>&1
    /bin/sed -i "/^jtrac.home/d" $properties_file_path2 >>$currentpath/error.log 2>&1
    echo jtrac.home=$jtrac_home >> $properties_file_path2
else
	echo "Jtrac init properties file path is not found.Please give the valid path" >  $currentpath/error.log
    echo "Jtrac init properties file path is not found.Please give the valid path" >  $currentpath/info.log
    echo failed > $currentpath/status.log
    exit 0
fi

#copy the properties file and source file to the docker directory
sudo cp -r $source_file_path $currentpath/docker
sudo cp $properties_file_path1 $currentpath/docker/jtrac.properties
sudo cp $properties_file_path2 $currentpath/docker/jtrac-init.properties

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
        echo Tomcat container Creation getting failed.Kindly find the error.log for more information >>$currentpath/error.log
        echo Tomcat container Creation getting failed.Kindly find the error.log for more information > $currentpath/info.log
        echo failed > $currentpath/status.log
        exit 0
fi

if grep "Error" "$currentpath/error.log" ; then
        echo Tomcat container Creation getting failed.Kindly find the error.log for more information >>$currentpath/error.log
        echo Tomcat container Creation getting failed.Kindly find the error.log for more information > $currentpath/info.log
        echo failed > $currentpath/status.log
        exit 0
else
        #echo "success" > $currentpath/status.log
        echo Tomcat container has been created successfully >> $currentpath/error.log
        echo Tomcat container has been created successfully > $currentpath/info.log
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

cd $currentpath/docker
sudo docker build -t jtrac_tomcat_img ./ >>$currentpath/error.log  2>&1
if [ $? == 0 ]; then
    echo Tomcat image is created successfully >>$currentpath/error.log
    sudo docker run -it -d --network $defined_bridge_network_name --name $tomcat_container_name -p $port:8080 jtrac_tomcat_img >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; then
        echo Tomcat container is created successfully >>$currentpath/error.log
        sudo docker logs $tomcat_container_name >>$currentpath/error.log 2>&1
        error_check
    else
        echo Facing issue in Tomcat container creation >>$currentpath/error.log
        echo Facing issue in Tomcat container creation >$currentpath/info.log
        echo failed >$currentpath/status.log
        exit 0 
    fi
else
    echo Facing issue in Tomcat image creation >>$currentpath/error.log
    echo Facing issue in Tomcat image creation >$currentpath/info.log
    echo failed >$currentpath/status.log
    exit 0 
fi
}

#puppet script execution started ------------------------------------------------
puppet_script_execution(){
puppet_error_check() {
    if grep "(err):" "$currentpath/puppeterror.log" ;then
        echo Tomcat YAML Creation getting failed.Kindly find the puppeterror.log for more information >>$currentpath/error.log
        echo Tomcat YAML Creation getting failed.Kindly find the puppeterror.log for more information > $currentpath/info.log
        echo failed > $currentpath/status.log
        exit 0
    else
        echo Tomcat YAML Creation done successfully >>$currentpath/error.log
        echo Tomcat YAML Creation done successfully > $currentpath/info.log
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

#removing source files and folders in docker folder
remove_source_files(){

if [ -d "$currentpath/docker/jtrac" ]
then
    sudo rm -rf $currentpath/docker/jtrac >>$currentpath/error.log 2>&1
fi 

if [ -f "$currentpath/docker/jtrac.properties" ]
then
    sudo rm -rf $currentpath/docker/jtrac.properties
fi

if [ -f "$currentpath/docker/jtrac-init.properties" ]
then
    sudo rm -rf $currentpath/docker/jtrac-init.properties
fi
echo Removed source files and folder in dokcer folder >>$currentpath/error.log
}

#final status started ------------------------------------------------
final_check(){
    sudo docker ps | grep "$tomcat_container_name" >>$currentpath/error.log 2>&1
    if [ $? == 0 ]; then
        if [ -f "/opt/MaaS/DockerContainer/$tomcat_container_name.yaml" ]
        then
            echo Tomcat container and Tomcat YAML file created successfully >>$currentpath/error.log
            echo Tomcat container and Tomcat YAML file created successfully >$currentpath/info.log
            echo success >$currentpath/status.log
            exit 0
        else
            echo Tomcat container only created successful.Tomcat YAML file not created >>$currentpath/error.log
            echo Tomcat container only created successful.Tomcat YAML file not created >$currentpath/info.log
            echo failed >$currentpath/status.log
            exit 0
        fi
else
    echo Tomcat container is not running or not created.Kindly see the error.log for more information >>$currentpath/error.log
    echo Tomcat container name is not exist.Kindly see the error.log for more information >$currentpath/info.log
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
remove_source_files
echo removed source files and folder
final_check
echo final check completed
