class yamlfilecreation inherits yamlfilecreation::var {

file{   "/opt/MaaS":
	ensure => directory,
		}
->
file{   "/opt/MaaS/DockerContainer":
	ensure => directory,
		}
->
file{   "/opt/MaaS/DockerContainer/$tomcat_container_name.yaml":
	ensure => file,
	content => template ("yamlfilecreation/tomcatdocker.yaml.erb"),
		}

}
