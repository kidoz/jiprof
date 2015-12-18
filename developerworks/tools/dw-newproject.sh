#!/bin/sh
# See the "Author guidelines" tab at 
# http://www.ibm.com/developerworks/aboutdw/
# for more information on how to use this program.
# © Copyright IBM Corporation 2004. All rights reserved.

function GetdWVersion() {
# Read current dwVersion from dwversion.txt file.
# Default value is 5.2
   local mydir
   mydir=`dirname $0`
   if [ -f "$mydir/dwversion.txt" ]; then
      cat $mydir/dwversion.txt
   else 
      echo "5.2"
   fi
}

function copyDwFiles() {
   local dwVersion dwDir
   dwVersion=`GetdWVersion`
   dwDir=`GetDwDir`
   if [ "$1" = "tutorial" ]; then
     sed 's///g;s/\\/\//g;s/id cma-id="0"/id cma-id="12345"/' "${dwdir}/tools/template-dw-tutorial-${dwVersion}.xml" > "${dwdir}/${projname}/index.xml"
   else
     sed 's///g;s/\\/\//g' "${dwdir}/tools/template-dw-article-${dwVersion}.xml" > "${dwdir}/${projname}/index.xml"
   fi
   cp "--preserve"  "${dwdir}/tools/dw-transform.sh" "${dwdir}/${projname}"
}

function GetDwDir() {
# Get dw directory (parent of dir from which tool runs)
   local dwdir tooldir
   tooldir=`dirname $0`
   dwdir=`(cd $tooldir/..; pwd)`
   echo $dwdir
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

# Main code
# Note dialogs here because dialog calls in functions 
# failed under Fedora Core 3.
echo "in min"
   retry=1
   firstpass=1
   tmpfl="/tmp/${USER}-dw-new-project"
   origdefname=""
   defname=""
   retcode=1;
   ptype="article"
   while getopts "t:" arg
     do
       case $arg in 
         t) ptype=${OPTARG};;
       esac
     done
   shift $(($OPTIND - 1))
   if [ -z $1 ]; then
     if [ "$ptype" = "tutorial" ]; then
       origdefname="my-tutorial"
     else
       origdefname="my-article"
     fi
   else
      origdefname=$1
   fi
   dialog_pgm=`get_dialog_program`
   while [ $retry -eq 1 ]
   do
      if [ $firstpass -eq 0 ] || [ -z $defname ]; then
         defname=$origdefname
      fi
      firstpass=0;
      d_text2="Do not include path elements (/) in the name"
      case "$dialog_pgm" in
        "dialog")
          if dialog --title "IBM developerWorks" --inputbox "Please provide a name for your new project folder. The name must be a folder name without path elements" 0 0 $defname 2>$tmpfl ; then
             projname=`cat $tmpfl`
             rm -f $tmpfl
          else
             retry=0
          fi
        ;;
        "gdialog")
          projname=$(gdialog --title "IBM developerWorks" --inputbox "Please provide a name for your new project folder.\nDo not include path elements (/) in the name" 10 60 $defname 2>&1 )
        ;;
        "zenity")
          projname=$(zenity --title "IBM developerWorks" --entry --text="Please provide a name for your new project folder.
Do not include path elements (/) in the name" --entry-text="$defname")
        ;;
        "kdialog")
          projname=$(kdialog --title "IBM developerWorks" --inputbox "Please provide a name for your new project folder. Do not include path elements (/) in the name" "$defname")
        ;;
      esac
      if [ -z "$projname" ] ; then
        retry=0
      fi
      if [ $retry -eq 1 ]; then
         dwdir=`GetDwDir`
         projbase=$(basename "$projname")
         if [ "$projname" != "$projbase" ] ; then
            msgtxt="Error: $projname invalid. You must specify a simple name without path elements"
         elif [ -e  "${dwdir}/${projname}" ]; then
            msgtxt="Error: $projname exists" 
         else
            if mkdir "${dwdir}/${projname}" 2>/dev/null ; then
               copyDwFiles "$ptype"
               retry=0
               retcode=0
            else
               msgtxt="Error: Cannot create folder $projname" 
            fi
         fi
      fi
      if [ $retry -eq 1 ]; then

        case "$dialog_pgm" in
          "dialog")
             if dialog --title "IBM developerWorks" --msgbox "$msgtxt" 0 0 ; then
                continue
             else
               retry=0
             fi
          ;;
          "gdialog")
             if gdialog --title "IBM developerWorks" --msgbox "$msgtxt" 10 60 ; then
                continue
             else
               retry=0
             fi
          ;;
          "zenity")
             zenity --title "IBM developerWorks" --error --text="$msgtxt" 2>/dev/null
             if [ $? ]; then
                continue
             else
               retry=0
             fi
          ;;
          "kdialog")
             if kdialog --title "IBM developerWorks" --error "$msgtxt" ; then
                continue
             else
               retry=0
             fi
          ;;
        esac
      fi
   done
   exit $retcode
