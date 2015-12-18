#!/bin/bash
# See the "Author guidelines" tab at 
# http://www.ibm.com/developerworks/aboutdw/
# for more information on how to use this program.
# © Copyright IBM Corporation 2004. All rights reserved.

function GetDwDir() {
# Get dw directory (parent of dir from which this tool runs)
   local dwdir tooldir
   tooldir=`dirname "$0"`
   dwdir=`(cd "$tooldir/.."; pwd)`
   echo "$dwdir"
}

function GetdWVersion() {
#  Read current dwVersion from dwversion.txt file.
# Default value is 4.0
   local mydir
   mydir=`dirname "$0"`
   test -f "$mydir/dwversion.txt"
   if [ $? -eq 0  ]; then
      cat "$mydir/dwversion.txt"
   else 
      echo "4.0"
   fi
}

function find_link() {
  linkval=`which "$1"`
  while [  -L "$linkval" ]; do
    linkval="$(readlink "$linkval")"
  done
  echo "$(basename "$linkval")"
}

function get_dialog_program() {
  local dialog_pgm=
  local dialog_pgm_list="dialog"
  local sess_mgr_pid=
  local sess_pgm=
  if [ -n "$SESSION_MANAGER" ]; then
    sess_mgr_pid=$(basename $(echo $SESSION_MANAGER | awk -F: ' { print $2 } '))
  fi
  if [ ! -z "$sess_mgr_pid" ]; then
    if [ -L "/proc/$sess_mgr_pid/exe" ] ; then
      sess_pgm="$(basename $(readlink "/proc/$sess_mgr_pid/exe"))"
    else 
      sess_pgm="$(find_link $(ps -p $sess_mgr_pid -o comm=))"
    fi
    if [ ".$sess_pgm" = ".gnome-session" ]; then
      dialog_pgm_list="zenity gdialog $dialog_pgm_list"
    elif [ ".$sess_pgm" = ".kdeinit" ]; then
      dialog_pgm_list="kdialog $dialog_pgm_list"
    fi
  fi
  for pgm in $dialog_pgm_list;
    do
      if [ ! -z "$(type -p $pgm 2>/dev/null)" ] ; then 
        dialog_pgm="$(basename $(type -p $pgm 2>/dev/null))"
        break
      fi
    done
  echo "$dialog_pgm"
}


function findJava() {
  mydir=`dirname "$0"`
  ibmj214=`find /opt -maxdepth 1 -name "IBMJava2-14*" -o -name "IBMJava2-*-14*" -type d | sort -r`
  java14ibm=""
  for dir in $ibmj214; do
    if [  -n "`type -p ${dir}/bin/java`" ]; then
       java14ibm="${dir}/bin/java"
       break
    fi
  done
  
  if [ -z "$java14ibm" ]; then
     ibmjava=`find /opt -type f -name "java" 2>/dev/null | grep "IBMJava2[-]*[^-]*-1[4-9]"`
     if [ ! -z "$(type -p java 2>/dev/null)" ] ; then 
        whichjava="$(type -p java 2>/dev/null)"
     fi

     optjava=`find /opt -type f -name "java" 2>/dev/null | grep -v "IBM"`
     usrjava=`find /usr -type f -name "java" 2>/dev/null | grep -v "IBM"`
     java15pgm=""
     java14pgm=""
     for jpgm in $ibmjava $whichjava $optjava $usrjava; do
        javacheck=`$jpgm -cp "${mydir}/dwxmlxslt.jar" DeveloperWorksJavaCheck | head -n 1`
#        echo "$javacheck"

        javalevel=`echo "$javacheck" | awk -F"\t" '{print $1}'`
        javaruntimelevel=`echo "$javacheck" | awk -F"\t" '{print $2}'`
        javavendor=`echo "$javacheck" | awk -F"\t" '{print $3}'`
        if [ "$javalevel" = "1.4" ] ; then
           if [ -n "`echo "$javavendor" | grep "IBM"`" ] ; then
              java14ibm=$jpgm
           elif [ -z "$java14pgm" ] ; then
              java14pgm="$jpgm"
           fi
        elif [ "$javalevel" = "1.5" ]; then
           if [ -z "$java15pgm" ] ; then
              java15pgm="$jpgm"
           fi
        fi
     done
  fi
  if [ -n "$java14ibm" ] ; then
      echo "$java14ibm"
  elif [ -n "$java14pgm" ] ; then
     echo "$java14pgm"
  elif [ -n "$java15pgm" ] ; then
     echo "$java15pgm"
  else
     echo ""
  fi
}

function displayMessage() {
  dialog_pgm=`get_dialog_program`
  title="IBM developerWorks"
  msg="$1"
  msgtype="${2:-"info"}"
  case "$dialog_pgm" in
    "dialog")
      dialog --title "$title" --msgbox "$msg" 0 0 
    ;;
    "gdialog")
      gdialog --title "$title" --msgbox "$msg" 25 60 
    ;;
    "zenity")
      # Zenity or GTk must use XML markup internally as <> cause problems
      msg2="$(echo "$msg" | sed -e 's/>/\&gt;/g;s/</\&lt;/g')"
      if [[ "$msgtype" == "error" ]] ; then
        zenity --title "$title" --error --text="$msg2" 2>/dev/null
      else
        zenity --title "$title" --info --text="$msg2" 2>/dev/null
      fi
    ;;
    "kdialog")
      if [[ "$msgtype" == "error" ]] ; then
        kdialog --title "$title" --error "$msg"
      else
        kdialog --title "$title" --msgbox "$msg"
      fi
    ;;
  esac
  echo ""
}

# Main routine start6s here
if [ $# -gt 0 ] ; then
   javapgm=`findJava`
   dialog_pgm=`get_dialog_program`
   if [ -n "$javapgm" ] ; then
      xalanver=$($javapgm org.apache.xalan.Version 2>>/dev/null)
      if [ -z "$xalanver" ]; then
         displayMessage "The script requires Apache Xalan Java version 2.5 or better" "error"
      else
         xalanvernum=$(echo "$xalanver" | awk ' { print $3 } ' | sed -e 's/\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')
         xvmaj=${xalanvernum%.*}
         xvmin=${xalanvernum#*.}
         if [ $xvmaj -gt 2 ] || [ $xvmaj -eq 2 -a $xvmin -ge 5 ] ; then 
            xmlFile="$1"
            dwDir=`GetDwDir`
            dwVersion=`GetdWVersion`
            schemaFile="${dwDir}/schema/${dwVersion}/dw-document-${dwVersion}.xsd"
            xslFile="${dwDir}/xsl/${dwVersion}/dw-document-html-${dwVersion}.xsl"

            mycp="${dwDir}/tools/dwxmlxslt.jar"
            if [ ! -z "$CLASSPATH" ]; then
               mycp="$mycp:$CLASSPATH"
            fi
            result=`$javapgm -cp "$mycp" DeveloperWorksXML "$xmlFile" "$schemaFile" "$xslFile"`
            echo "$result" | tail -n 2 | grep -q "^Output file"
            if [ $? -ne 0 ] ; then
              displayMessage "$result" "error"
            else 
              displayMessage "$result" "info"
            fi
         else
             displayMessage "Xalan Java version $xalanvernum not 2.5 or greater"  "error"
         fi
      fi
   else
      displayMessage "Error: Could not find suitable Java 1.4 version" "error"
   fi
else
   displayMessage "Error: No arguments specified" "error"
fi

