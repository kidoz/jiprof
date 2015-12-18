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
// $Id: FinishSnapshotAction.java,v 1.1 2008/09/23 04:48:15 jchapman0 Exp $
package com.jchapman.jipsnapman.actions;

import java.io.IOException;

import java.awt.event.ActionEvent;

import org.yasl.arch.action.YASLActionHandler;
import org.yasl.arch.application.YASLSwingApplication;
import org.yasl.arch.resources.YASLResourceManager;
import com.jchapman.jipsnapman.events.SnapshotEvent;
import com.jchapman.jipsnapman.events.SnapshotEventListener;
import com.jchapman.jipsnapman.events.SnapshotEventManager;
import com.jchapman.jipsnapman.models.Snapshot;
import com.mentorgen.tools.util.profile.Finish;

/**
 *
 * @author not attributable
 * @version 1.0
 */
public class FinishSnapshotAction
    extends BaseSnapshotAction implements SnapshotEventListener {
  private final SnapshotEventManager snapshotEventManager; // in ctor
  private Snapshot currentSnapshot = null;

  public FinishSnapshotAction(String name,
                              SnapshotEventManager snapshotEventManager,
                              YASLSwingApplication yaslSwingApplication) {
    super(name, false, yaslSwingApplication);
    this.snapshotEventManager = snapshotEventManager;
  }

  protected void performAction(ActionEvent actionEvent) throws Exception {
    YASLSwingApplication swingApp = getYASLSwingApplication();
    YASLActionHandler actionHandler = swingApp.getActionHandler();
    YASLResourceManager resMan = swingApp.getResourceManager();
    boolean gotException = false;
    try {
      Finish.doFinish(currentSnapshot.getHost(),
                      currentSnapshot.getPort());
    }
    catch (IOException ioex) {
      gotException = true;
      updateConsoleLog(ioex, actionHandler);
    }
    if (!gotException) {
      updateForSuccessfulCall("finish", resMan, actionHandler);
      snapshotEventManager.fireSnapshotEvent(new SnapshotEvent(
          SnapshotEvent.ID_SNAPSHOT_CAPTURED,
          currentSnapshot));
    }
    else {
      snapshotEventManager.fireSnapshotEvent(new SnapshotEvent(
          SnapshotEvent.ID_SNAPSHOT_CAPTURE_FAILED,
          currentSnapshot));
    }
    this.setEnabled(false);
  }

  /* ---------------- from SnapshotEventListener --------------- */

  public void handleSnapshotEvent(SnapshotEvent event) {
    if (event.getId() == SnapshotEvent.ID_SNAPSHOT_STARTED) {
      this.setEnabled(true);
      this.currentSnapshot = event.getSnapshot();
    }
  }
}
