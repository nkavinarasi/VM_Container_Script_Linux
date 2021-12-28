#!/bin/bash
currentpath=$(pwd)
sudo rm -rf puppet6-release-focal*
sudo rm -rf *.log
echo inprogress > $currentpath/info.log

puppet_validation(){
    echo -----------------------------------------   >> $currentpath/error.log
    if [ -f "/opt/puppetlabs/bin/puppet" ]
    then
	    echo puppet installation is completed in this machine. >> $currentpath/error.log
	    echo puppet installation is completed in this machine. > $currentpath/info.log
        sudo rm -rf $currentpath/puppet6-release-focal.deb > /dev/null
		echo success > $currentpath/status.log
    else 
	    echo "Error during installation of puppet" >> $currentpath/error.log
	    echo "Error during installation of puppet" > $currentpath/info.log
        sudo rm -rf $currentpath/puppet6-release-focal.deb > /dev/null
        echo failed > $currentpath/status.log
        exit 0
    fi
}

start_puppet_service(){
    enable_service(){
        echo -----------------------------------------   >> $currentpath/error.log
        sudo systemctl enable puppet >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Puppet service enabled successfully >> $currentpath/error.log
            puppet_validation
        else
            systemctl enable puppet >> $currentpath/error.log 2>&1
            if [ $? == 0 ] ; 
            then
                echo Puppet service enabled successfully >> $currentpath/error.log
                puppet_validation
            else
                echo Facing issue while enable puppet service >> $currentpath/error.log
                echo Facing issue while enable puppet service > $currentpath/info.log
                echo failed > $currentpath/status.log
                exit 0
            fi
        fi
    }

    echo -----------------------------------------   >> $currentpath/error.log
    sudo systemctl start puppet >> $currentpath/error.log 2>&1
	if [ $? == 0 ] ; 
    then
        echo Puppet service started successfully >> $currentpath/error.log
        enable_service
    else
        systemctl start puppet >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Puppet service started successfully >> $currentpath/error.log
            enable_service
        else
            echo Facing issue while start the puppet service >> $currentpath/error.log
            echo Facing issue while start the puppet service > $currentpath/info.log
            echo failed > $currentpath/status.log
            exit 0
        fi
    fi
}

create_slink(){
    execution_permission(){
        echo -----------------------------------------   >> $currentpath/error.log
        sudo chmod ugo+x /usr/bin/puppet >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Adding execute permission to the user for symlink successfully >> $currentpath/error.log
            start_puppet_service
        else
            chmod ugo+x /usr/bin/puppet >> $currentpath/error.log 2>&1
            if [ $? == 0 ] ; 
            then
                echo Adding execute permission to the user for symlink successfully >> $currentpath/error.log
                start_puppet_service
            else
                echo Facing issue while Adding execute permission to the symlink >> $currentpath/error.log
                echo Facing issue while Adding execute permission to the symlink > $currentpath/info.log
                echo failed > $currentpath/status.log
                exit 0
            fi
        fi
    }
if [ ! -f "/usr/bin/puppet" ] ;
then
    echo -----------------------------------------   >> $currentpath/error.log
    sudo ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet >> $currentpath/error.log 2>&1
	if [ $? == 0 ] ; 
    then
        echo Created symlink successfully >> $currentpath/error.log
        execution_permission
    else
        ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Created symlink successfully >> $currentpath/error.log
            execution_permission
        else
            echo Facing issue while create symlink >> $currentpath/error.log
            echo Facing issue while create symlink > $currentpath/info.log
            echo failed > $currentpath/status.log
            exit 0
        fi
    fi
else
    echo -----------------------------------------   >> $currentpath/error.log
    echo Symlink has already created for puppet service >> $currentpath/error.log
    execution_permission
fi
}

install_puppet(){
    echo -----------------------------------------   >> $currentpath/error.log
    sudo apt-get install puppet-agent -y >> $currentpath/error.log
	if [ $? == 0 ] ; 
    then
        echo Puppet installation has done successfully >> $currentpath/error.log
        create_slink
    else
        apt-get install puppet-agent -y >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Puppet installation has done successfully >> $currentpath/error.log
            create_slink
        else
            echo Facing issue while install puppet >> $currentpath/error.log
            echo Facing issue while install puppet > $currentpath/info.log
            echo failed > $currentpath/status.log
            exit 0
        fi
    fi
}


ubuntu_update(){
    echo -----------------------------------------   >> $currentpath/error.log
    sudo apt-get update >> $currentpath/error.log 2>&1
	if [ $? == 0 ] ; 
    then
        echo Ubuntu Update has been done successfully >> $currentpath/error.log
        install_puppet
    else
        apt-get update >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Ubuntu Update has been done successfully >> $currentpath/error.log
            install_puppet
        else
            echo Facing issue while execute update command >> $currentpath/error.log
            echo Facing issue while execute update command > $currentpath/info.log
            echo failed > $currentpath/status.log
            exit 0
        fi
    fi
}


install_dep_file(){
    echo -----------------------------------------   >> $currentpath/error.log
    sudo dpkg -i puppet6-release-focal.deb >> $currentpath/error.log 2>&1
	if [ $? == 0 ] ; 
    then
        echo Puppet package puppet6-release-focal.deb installed successfully >> $currentpath/error.log
        ubuntu_update
    else
        dpkg -i puppet6-release-focal.deb >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Puppet package puppet6-release-focal.deb installed successfully >> $currentpath/error.log
            ubuntu_update
        else
            echo Facing issue while install the puppet6-release-focal.deb package >> $currentpath/error.log
            echo Facing issue while install the puppet6-release-focal.deb package > $currentpath/info.log
            echo failed > $currentpath/status.log
            exit 0
        fi
    fi
}

download_deb_file(){
    sudo wget https://apt.puppetlabs.com/puppet6-release-focal.deb --no-check-certificate >> $currentpath/error.log 2>&1
    if [ $? == 0 ] ; 
    then
        echo Puppet package puppet6-release-focal.deb is downloaded successfully >> $currentpath/error.log
        install_dep_file
    else
        wget https://apt.puppetlabs.com/puppet6-release-focal.deb --no-check-certificate >> $currentpath/error.log 2>&1
        if [ $? == 0 ] ; 
        then
            echo Puppet package puppet6-release-focal.deb is downloaded successfully >> $currentpath/error.log
            install_dep_file
        else
            echo Facing issue while download the puppet6-release-focal.deb package >> $currentpath/error.log
            echo Facing issue while download the puppet6-release-focal.deb package > $currentpath/info.log
            echo failed > $currentpath/status.log
            exit 0
        fi
    fi
}

type -P puppet > $currentpath/error.log
if [ $? != 0 ] ;    
then
    echo puppet is not installed in this machine. >> $currentpath/error.log
    echo Started the puppet installation process. >> $currentpath/error.log
    download_deb_file
else 
    echo puppet is already installed in this machine. >> $currentpath/error.log
	echo puppet is already installed in this machine. > $currentpath/info.log
	echo success > $currentpath/status.log
fi
