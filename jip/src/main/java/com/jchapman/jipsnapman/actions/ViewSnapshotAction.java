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
// $Id: ViewSnapshotAction.java,v 1.1 2008/09/23 04:48:15 jchapman0 Exp $
package com.jchapman.jipsnapman.actions;

import java.io.File;
import java.io.IOException;
import java.text.MessageFormat;

import java.awt.event.ActionEvent;

import org.yasl.arch.action.YASLActionHandler;
import org.yasl.arch.application.YASLSwingApplication;
import org.yasl.arch.impl.event.YASLActionEvent;
import org.yasl.arch.resources.YASLResourceManager;
import com.jchapman.jipsnapman.events.SnapshotEvent;
import com.jchapman.jipsnapman.events.SnapshotEventListener;
import com.jchapman.jipsnapman.models.Snapshot;
import com.jchapman.jipsnapman.models.SnapshotsTakenModel;
import com.jchapman.jipsnapman.utils.JIPSnapManConstants;

/**
 *
 * @author not attributable
 * @version 1.0
 */
public class ViewSnapshotAction
        extends BaseSnapshotAction implements SnapshotEventListener {
    private final SnapshotsTakenModel snapshotsTakenModel; // in ctor

    public ViewSnapshotAction(String name,
                              SnapshotsTakenModel snapshotsTaken,
                              YASLSwingApplication yaslSwingApplication) {
        super(name, false, yaslSwingApplication);
        this.snapshotsTakenModel = snapshotsTaken;
    }

    protected void performAction(ActionEvent actionEvent)
            throws Exception {
        YASLSwingApplication swingApp = getYASLSwingApplication();
        YASLActionHandler actionHandler = swingApp.getActionHandler();
        YASLResourceManager resMan = swingApp.getResourceManager();
        Snapshot currentSnapshot = snapshotsTakenModel.getSelectedSnapshot();
        if (currentSnapshot != null) {
            String viewerJarName = (String) swingApp.getSingleton(
                    JIPSnapManConstants.KEY_JIP_VIEWER_JAR);
            String defBundle = resMan.getDefaultBundle();
            String javaHome = System.getProperty("java.home");
            File viewerJarFilePath = new File(System.getProperty("user.dir"));
            // make viewer call
            // {0}/bin/java -jar {1} {2}
            Object[] cmmndArgs = {javaHome,
                                 viewerJarName,
                                 currentSnapshot.getPathAndNameForXML()};
            String viewTemplate = resMan.getString(defBundle, "call.viewer");
            String viewCommand = MessageFormat.format(viewTemplate, cmmndArgs);
            // we must start the viewer in a separate thread since the
            // process will not end until the user closes the
            // viewer
            Runnable runner = new ViewSnapshotRunner(
                    viewCommand,
                    viewerJarFilePath,
                    this,
                    actionHandler);
            new Thread(runner).start();
        }
        else {
            // display error message
            YASLActionEvent event = getErrorEvent();
            event.addProperty(JIPSnapManConstants.KEY_ERR_MSSG,
                              "err.mssg.noselsnapshot");
            actionHandler.getActionByKey(
                    JIPSnapManConstants.ACTKEY_ERROR_DISPLAY).actionPerformed(
                            event);
        }
    }

    private static final class ViewSnapshotRunner
            implements Runnable {
        private final String viewCommand; // in ctor
        private final BaseSnapshotAction baseSnapAction; // in ctor
        private final YASLActionHandler actionHandler; // in ctor
        private final File viewerJarFilePath; // in ctor

        ViewSnapshotRunner(String viewCommand,
                           File viewerJarFilePath,
                           BaseSnapshotAction baseSnapAction,
                           YASLActionHandler actionHandler) {
            this.viewCommand = viewCommand;
            this.baseSnapAction = baseSnapAction;
            this.actionHandler = actionHandler;
            this.viewerJarFilePath = viewerJarFilePath;
        }

        public void run() {
            try {
                Process viewProcess = Runtime.getRuntime().exec(
                        viewCommand,
                        null,
                        viewerJarFilePath);
                baseSnapAction.updateConsoleLog(viewProcess, actionHandler);
            }
            catch (IOException ioex) {

            }
        }
    }

    /* ---------------- from SnapshotEventListener --------------- */

    public void handleSnapshotEvent(SnapshotEvent event) {
        if (event.getId() == SnapshotEvent.ID_SNAPSHOT_CAPTURED) {
            this.setEnabled(true);
        }
    }
}
