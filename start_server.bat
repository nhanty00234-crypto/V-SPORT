@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-25.0.2"
set "CATALINA_HOME=D:\BiKipVoCong\TaiNguyenIntelliji\apache-tomcat-10.1.54"
set "MAVEN_PATH=D:\CNTT\netbeans-28-bin\netbeans\java\maven\bin\mvn.cmd"

echo Building project...
call "%MAVEN_PATH%" clean package -DskipTests

echo Deploying to Tomcat...
copy /Y "target\Backend_java-1.0-SNAPSHOT.war" "%CATALINA_HOME%\webapps\Backend_java.war"

echo Starting Tomcat...
call "%CATALINA_HOME%\bin\catalina.bat" start

echo Waiting for Tomcat to start...
timeout /t 5 /nobreak > nul

echo Opening browser...
start http://localhost:8080/Backend_java/
