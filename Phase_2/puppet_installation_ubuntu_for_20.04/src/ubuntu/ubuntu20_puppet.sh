#!/bin/bash
currentpath=$(pwd)
sudo rm -rf puppet6-release-focal*
sudo rm -rf *.log
echo inprogress > $currentpath/info.log
type -P puppet > $currentpath/error.log
if [ $? != 0 ] ;    then
    echo puppet is not installed in this machine. >> $currentpath/error.log
    echo Started the puppet installation process. >> $currentpath/error.log
    
    sudo wget https://apt.puppetlabs.com/puppet6-release-focal.deb
    if [ $? == 0 ] ; then
            echo -----------------------------------------   >> $currentpath/error.log
            sudo dpkg -i puppet6-release-focal.deb          >> $currentpath/error.log
	    if [ $? == 0 ] ; then
                echo -----------------------------------------   >> $currentpath/error.log
                sudo apt-get update                              >> $currentpath/error.log
		if [ $? == 0 ] ; then
                	echo -----------------------------------------   >> $currentpath/error.log
                	sudo apt-get install puppet-agent -y            >> $currentpath/error.log
			if [ $? == 0 ] ; then
                    		echo -----------------------------------------   >> $currentpath/error.log
	                    	sudo systemctl start puppet             >> $currentpath/error.log
	 	                sudo systemctl enable puppet            >> $currentpath/error.log
                            	if [ $? == 0 ]
                            	then
                               		echo -----------------------------------------   >> $currentpath/error.log
	                                echo puppet installation is completed in this machine. >> $currentpath/error.log
	                                echo puppet installation is completed in this machine. > $currentpath/info.log
				    	echo success > $currentpath/status.log
                                else 
	                                echo "Error during installation of puppet" >> $currentpath/error.log
					echo "Error during installation of puppet" > $currentpath/info.log
        	                        echo failed > $currentpath/status.log
                	                exit 0
                           	 fi
               		fi
  	       fi
         fi
    fi
else 
        echo puppet is installed in this machine. >> $currentpath/error.log
	echo puppet is installed in this machine. > $currentpath/info.log
	echo success > $currentpath/status.log
fi
