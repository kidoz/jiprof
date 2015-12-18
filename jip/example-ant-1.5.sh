#!/bin/sh
mkdir p
cp profile/* p/

#
# Note that the current VM on the OS X has a bug that requires the -javaagent
# argument to be a full path rather than a relative path.
#

$JAVA_HOME/bin/java \
-javaagent:$PWD/p/profile.jar \
-Dprofile.properties=p/ant.profile.properties \
-classpath $ANT_HOME/lib/xml-apis.jar:$ANT_HOME/lib/xercesImpl.jar:$ANT_HOME/lib/optional.jar:$ANT_HOME/lib/ant.jar \
-Dant.home=$ANT_HOME org.apache.tools.ant.Main  dist


