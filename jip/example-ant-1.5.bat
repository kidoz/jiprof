@echo off

if not "%JAVA_HOME%" == "" goto gotJH
echo JAVA_HOME is required. Please set JAVA_HOME
goto end
:gotJH

if not "%ANT_HOME%" == "" goto gotAnt
echo ANT_HOME is required. Please set ANT_HOME
goto end
:gotAnt

mkdir p
copy profile\* p\

%JAVA_HOME%\bin\java -javaagent:p\profile.jar -Dprofile.properties=p\ant.profile.properties  -classpath %JAVA_HOME%\lib\tools.jar;%ANT_HOME%\lib\xml-apis.jar;%ANT_HOME%\lib\xercesImpl.jar;%ANT_HOME%\lib\optional.jar;%ANT_HOME%\lib\ant.jar; -Dant.home=%ANT_HOME% org.apache.tools.ant.Main  dist

:end