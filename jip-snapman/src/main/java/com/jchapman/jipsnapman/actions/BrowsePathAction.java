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
// $Id: BrowsePathAction.java,v 1.1 2008/09/23 04:48:14 jchapman0 Exp $
package com.jchapman.jipsnapman.actions;

import java.io.File;

import java.awt.event.ActionEvent;
import javax.swing.JFileChooser;

import org.yasl.arch.application.YASLSwingApplication;
import org.yasl.arch.errors.YASLApplicationException;
import org.yasl.arch.impl.action.YASLSwingAbstractAction;
import org.yasl.arch.prefs.PreferencesManager;
import com.jchapman.jipsnapman.events.SnapshotEvent;
import com.jchapman.jipsnapman.events.SnapshotEventListener;
import com.jchapman.jipsnapman.models.SnapshotPathModel;
import com.jchapman.jipsnapman.utils.JIPSnapManConstants;
import org.yasl.arch.resources.YASLResourceManager;

/**
 *
 * @author Jeff Chapman
 * @version 1.0
 */
public class BrowsePathAction
        extends YASLSwingAbstractAction implements SnapshotEventListener {
    private final SnapshotPathModel snapshotPathModel; // in ctor

    public BrowsePathAction(String name,
                            SnapshotPathModel pathModel,
                            YASLSwingApplication yaslSwingApplication) {
        super(name, true, yaslSwingApplication);
        snapshotPathModel = pathModel;
    }

    protected void performAction(ActionEvent actionEvent)
            throws Exception {
        String actionCommand = actionEvent.getActionCommand();
        YASLSwingApplication swingApp = getYASLSwingApplication();
        YASLResourceManager resMan = swingApp.getResourceManager();
        String defBundle = resMan.getDefaultBundle();
        String prevPath = getPreviousPath(actionCommand, swingApp);
        JFileChooser chooser = new JFileChooser(prevPath);
        chooser.setDialogTitle(resMan.getString(defBundle, "dlg.title.selectpath"));
        chooser.setApproveButtonText(resMan.getString(defBundle, "bttn.select"));
        chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        int returnVal = chooser.showDialog(swingApp.getJFrame(), null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = chooser.getSelectedFile();
            setPathInModel(actionCommand, file.getPath());
        }
    }

    private void setPathInModel(String actionCommand,
                                String path) {
        if (JIPSnapManConstants.ACT_CMMND_BROWSE_PATH.equals(actionCommand)) {
            snapshotPathModel.setSnapshotPath(path);
        }
    }

    private String getPreviousPath(String actionCommand,
                                   YASLSwingApplication swingApp)
            throws YASLApplicationException {
        String prevPath = null;
        if (JIPSnapManConstants.ACT_CMMND_BROWSE_PATH.equals(actionCommand)) {
            prevPath = snapshotPathModel.getSnapshotPath();
            if (prevPath == null || prevPath.length() == 0) {
                PreferencesManager prefsManager =
                        (PreferencesManager) swingApp.getSingleton(
                                YASLSwingApplication.KEY_PREFERENCES_MANAGER);
                prevPath = prefsManager.getPreference(
                        JIPSnapManConstants.PREF_PATH, "");
            }
        }

        return prevPath;
    }

    /* --------------- from SnapshotEventListener --------------- */

    public void handleSnapshotEvent(SnapshotEvent event) {
        switch (event.getId()) {
            case SnapshotEvent.ID_SNAPSHOT_STARTED:
                this.setEnabled(false);
                break;
            case SnapshotEvent.ID_SNAPSHOT_CAPTURED:
                this.setEnabled(true);
                break;
        }
    }
}
