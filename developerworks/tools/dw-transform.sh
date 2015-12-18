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

function get_dialog_program() {
  local dialog_pgm=
  local dialog_pgm_list="dialog"
  local sess_mgr_pid=
  local sess_pgm=
  if [ -n "$SESSION_MANAGER" ]; then
    sess_mgr_pid=$(basename $(echo $SESSION_MANAGER | awk -F: ' { print $2 } '))
  fi
  if [ ! -z "$sess_mgr_pid" ]; then
    sess_pgm="$(basename $(ps -p $sess_mgr_pid -o comm=))"
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

mydir="$(dirname "$0")"
dwxmlvalidate="`GetDwDir`/tools/dwxmlxslt.sh"

   dialog_pgm=`get_dialog_program`
test -f "$dwxmlvalidate"
if [ $? -eq 0 ] ; then
   if [  $# -gt 0 ] ; then
      "$dwxmlvalidate"  "$@"
      retcode=$?
   else
      "$dwxmlvalidate" "${mydir}/index.xml"
      retcode=$?
   fi
else
  case "$dialog_pgm" in
    "dialog")
      dialog --msgbox "Error: Cannot locate validation file '${dwxmlvalidate}'." 7 50
    ;;
    "gdialog")
      gdialog --msgbox "Error: Cannot locate validation file '${dwxmlvalidate}'." 7 50
    ;;
    "zenity")
      zenity --error --text="Cannot locate validation file '${dwxmlvalidate}'." 2>/dev/null
    ;;
    "kdialog")
      kdialog --error "Error: Cannot locate validation file '${dwxmlvalidate}'."
    ;;
  esac
  retcode=1
fi
exit $retcode


