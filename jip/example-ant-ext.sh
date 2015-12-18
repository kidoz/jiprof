#!/bin/sh
mkdir p
cp profile/* p/

$JAVA_HOME/bin/java \
-javaagent:$PWD/p/profile.jar \
-Dprofile.properties=src/example-properties/ant.ext.profile.properties \
-classpath $ANT_HOME/lib/launcher.jar \
-Dant.home=$ANT_HOME \
-Djava.ext.dirs=$ANT_HOME/lib:$PWD/profile \
org.apache.tools.ant.launch.Launcher dist



#-Dant.library.dir=$ANT_HOME/lib \