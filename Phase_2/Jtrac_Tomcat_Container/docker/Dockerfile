from tomcat:8.0.53
add ./ /tmp/
run cp -r /tmp/jtrac /usr/local/tomcat/webapps/jtrac
run cp /tmp/jtrac.properties /usr/local/tomcat/webapps/jtrac/jtrac.properties
run cp /tmp/jtrac-init.properties /usr/local/tomcat/webapps/jtrac/WEB-INF/classes/jtrac-init.properties
WORKDIR /usr/local/tomcat/webapps
Expose 8080
