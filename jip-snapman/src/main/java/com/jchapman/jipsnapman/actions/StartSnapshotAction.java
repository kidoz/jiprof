/*
 Copyright (c) 2008 Jeff Chapman

 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 * Redistributions of source code must retain the above
      copyright notice, this list of conditions and the following
      disclaimer.
 * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
// $Id: StartSnapshotAction.java,v 1.1 2008/09/23 04:48:15 jchapman0 Exp $
package com.jchapman.jipsnapman.actions;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.awt.event.ActionEvent;

import org.yasl.arch.action.YASLActionHandler;
import org.yasl.arch.application.YASLSwingApplication;
import org.yasl.arch.errors.YASLApplicationException;
import org.yasl.arch.impl.event.YASLActionEvent;
import org.yasl.arch.prefs.PreferencesManager;
import org.yasl.arch.resources.YASLResourceManager;
import com.jchapman.jipsnapman.events.SnapshotEvent;
import com.jchapman.jipsnapman.events.SnapshotEventListener;
import com.jchapman.jipsnapman.events.SnapshotEventManager;
import com.jchapman.jipsnapman.models.Snapshot;
import com.jchapman.jipsnapman.models.SnapshotInfoModel;
import com.jchapman.jipsnapman.utils.JIPSnapManConstants;
import com.mentorgen.tools.util.profile.Start;

/**
 *
 * @author Jeff Chapman
 * @version 1.0
 */
public class StartSnapshotAction
    extends BaseSnapshotAction implements SnapshotEventListener {
  private final SnapshotInfoModel infoModel; // in ctor
  private final SnapshotEventManager snapshotEventManager; // in ctor

  public StartSnapshotAction(String name,
                             SnapshotInfoModel infoModel,
                             SnapshotEventManager snapshotEventManager,
                             YASLSwingApplication yaslSwingApplication) {
    super(name, true, yaslSwingApplication);
    this.infoModel = infoModel;
    this.snapshotEventManager = snapshotEventManager;
  }

  protected void performAction(ActionEvent actionEvent) throws Exception {
    YASLSwingApplication swingApp = getYASLSwingApplication();
    YASLActionHandler actionHandler = swingApp.getActionHandler();
    YASLResourceManager resMan = swingApp.getResourceManager();
    Snapshot snapshot = getSnapshot(actionHandler);
    if (snapshot != null) {
      setPropertiesFromSnapshot(snapshot, swingApp);
      boolean gotException = false;
      try {
        com.mentorgen.tools.util.profile.File.doFile(
            snapshot.getHost(),
            snapshot.getPort(),
            snapshot.getPathAndName());
      }
      catch (IOException ioex) {
        gotException = true;
        updateConsoleLog(ioex, actionHandler);
      }
      // if no exception, ie the above succeeded, then go to start
      // command and report file success
      if (!gotException) {
        updateForSuccessfulCall("file", resMan, actionHandler);
        try {
          Start.doStart(snapshot.getHost(),
                        snapshot.getPort());
        }
        catch (IOException ioex) {
          gotException = true;
          updateConsoleLog(ioex, actionHandler);
        }
      }
      // if no exception, ie the above succeeded, then report
      // start success and send event
      if (!gotException) {
        updateForSuccessfulCall("start", resMan, actionHandler);
        snapshotEventManager.fireSnapshotEvent(new SnapshotEvent(
            SnapshotEvent.ID_SNAPSHOT_STARTED, snapshot));
        this.setEnabled(false);
      }
    } // end if for null snapshot
  }

  private void setPropertiesFromSnapshot(Snapshot snapshot,
                                         YASLSwingApplication swingApp) throws
      YASLApplicationException {
    PreferencesManager prefsManager =
        (PreferencesManager) swingApp.getSingleton(
            YASLSwingApplication.KEY_PREFERENCES_MANAGER);
    prefsManager.setPreference(JIPSnapManConstants.PREF_HOST,
                               snapshot.getHost());
    prefsManager.setPreference(JIPSnapManConstants.PREF_NAME,
                               snapshot.getOriginalName());
    prefsManager.setPreference(JIPSnapManConstants.PREF_PATH,
                               snapshot.getPath());
    prefsManager.setPreference(JIPSnapManConstants.PREF_PORT,
                               snapshot.getPort());
  }

  private Snapshot getSnapshot(YASLActionHandler actionHandler) {
    Snapshot snapshot = null;
    // check path specified
    String path = infoModel.getSnapshotPath();
    if (path == null || path.trim().length() == 0) {
      // display error message
      YASLActionEvent event = getErrorEvent();
      event.addProperty(JIPSnapManConstants.KEY_ERR_MSSG,
                        "err.mssg.nopath");
      actionHandler.getActionByKey(
          JIPSnapManConstants.ACTKEY_ERROR_DISPLAY).actionPerformed(
              event);
      return null; // bail out
    }
    // check path valid
    File pathFile = new File(path);
    if (!pathFile.exists() || !pathFile.isDirectory()) {
      // display error message
      YASLActionEvent event = getErrorEvent();
      event.addProperty(JIPSnapManConstants.KEY_ERR_MSSG,
                        "err.mssg.badpath");
      event.addProperty(JIPSnapManConstants.KEY_ERR_VALUES,
                        new Object[] {pathFile.getPath()});
      actionHandler.getActionByKey(
          JIPSnapManConstants.ACTKEY_ERROR_DISPLAY).actionPerformed(
              event);
      return null; // bail out
    }
    if (!pathFile.canWrite() || !pathFile.canRead()) {
      // display error message
      YASLActionEvent event = getErrorEvent();
      event.addProperty(JIPSnapManConstants.KEY_ERR_MSSG,
                        "err.mssg.rwpath");
      event.addProperty(JIPSnapManConstants.KEY_ERR_VALUES,
                        new Object[] {pathFile.getPath()});
      actionHandler.getActionByKey(
          JIPSnapManConstants.ACTKEY_ERROR_DISPLAY).actionPerformed(
              event);
      return null; // bail out
    }
    // check for port
    String port = infoModel.getSnapshotPort();
    // check for host
    String host = infoModel.getSnapshotHost();
    // check name
    final String origName = infoModel.getSnapshotName();
    String newName = origName;
    // modify name if it already exists and is not empty
    if (origName.length() > 0) {
      boolean nameExists = true;
      String tempName = origName;
      String nameSuffix = ".txt";
      if (origName.endsWith(".txt") || origName.endsWith(".xml")) {
        tempName = origName.substring(0, origName.length() - 4);
        nameSuffix = origName.substring(origName.length() - 4);
      }
      StringBuilder buf = new StringBuilder(tempName);
      int baseLength = buf.length();
      for (int cnt = 0; nameExists; cnt++) {
        buf.setLength(baseLength);
        if (cnt > 0) {
          buf.append(cnt);
        }
        buf.append(nameSuffix);
        File txtPath = new File(pathFile, buf.toString());
        nameExists = txtPath.exists();
      }
      newName = buf.toString();
    }
    // name is empty, create name based on current time
    // but leave origName empty
    else {
      StringBuilder buf = new StringBuilder();
      buf.append(new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date()));
      buf.append(".txt");
      newName = buf.toString();
    }
    return new Snapshot(
        pathFile.getPath(),
        newName,
        origName,
        port,
        host);
  }

  /* ---------------- from SnapshotEventListener --------------- */

  public void handleSnapshotEvent(SnapshotEvent event) {
    switch (event.getId()) {
      case SnapshotEvent.ID_SNAPSHOT_CAPTURED:
      case SnapshotEvent.ID_SNAPSHOT_CAPTURE_FAILED:
        this.setEnabled(true);
        break;
    }
  }
}
