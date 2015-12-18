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
// $Id: MainPanel.java,v 1.1 2008/09/23 04:48:17 jchapman0 Exp $
package com.jchapman.jipsnapman.gui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;
import javax.swing.SwingUtilities;

import org.yasl.arch.application.YASLSwingApplication;
import org.yasl.arch.errors.YASLApplicationException;
import org.yasl.arch.prefs.PreferencesManager;
import org.yasl.arch.resources.YASLResourceManager;
import com.jchapman.jipsnapman.events.SnapshotEvent;
import com.jchapman.jipsnapman.events.SnapshotEventListener;
import com.jchapman.jipsnapman.models.LogsModel;
import com.jchapman.jipsnapman.models.NumbersOnlyDocument;
import com.jchapman.jipsnapman.models.Snapshot;
import com.jchapman.jipsnapman.models.SnapshotInfoModel;
import com.jchapman.jipsnapman.models.SnapshotListModel;
import com.jchapman.jipsnapman.models.SnapshotPathModel;
import com.jchapman.jipsnapman.models.SnapshotsTakenModel;
import com.jchapman.jipsnapman.utils.JIPSnapManConstants;
import org.yasl.text.TextTransferHandler;
import org.yasl.text.EditPopupHandler;

/**
 *
 * @author not attributable
 * @version 1.0
 */
public class MainPanel
        extends JPanel implements SnapshotPathModel,
        SnapshotInfoModel, SnapshotEventListener, LogsModel,
        SnapshotsTakenModel {

    private final YASLSwingApplication swingApp; // in ctor
    private final SnapshotListModel snapshotListModel = new SnapshotListModel();
    private final JList snapsList = new JList(snapshotListModel);
    private final JTextField host = new JTextField();
    private final JTextField path = new JTextField();
    private final JTextField name = new JTextField();
    private final JTextField port = new JTextField();
    private final JTextArea logArea = new JTextArea();
    private final JButton browseButton = new JButton();
    private final JButton startButton = new JButton();
    private final JButton finishButton = new JButton();
    private final JButton launchJipButton = new JButton();
    private final String default_port;
    private final String default_host;

    public MainPanel(YASLSwingApplication swingApp)
            throws
            YASLApplicationException {
        super();
        this.swingApp = swingApp;
        this.default_port = (String)swingApp.getSingleton(JIPSnapManConstants.DEFAULT_PORT);
        this.default_host = (String)swingApp.getSingleton(JIPSnapManConstants.DEFAULT_HOST);
        logArea.setEditable(false);
        logArea.setRows(10);
        logArea.setLineWrap(false);
        path.setEditable(false);
        port.setDocument(new NumbersOnlyDocument());
        initUI();
    }

    public void setBrowsePathAction(Action browsePath) {
        browseButton.setAction(browsePath);
        browseButton.setActionCommand(JIPSnapManConstants.ACT_CMMND_BROWSE_PATH);
    }

    public void setStartSnapshotAction(Action browsePath) {
        startButton.setAction(browsePath);
    }

    public void setFinishSnapshotAction(Action browsePath) {
        finishButton.setAction(browsePath);
    }

    public void setLaunchJIPAction(Action browsePath) {
        launchJipButton.setAction(browsePath);
    }

    public void initFromPreferences()
            throws YASLApplicationException {
        PreferencesManager prefsManager =
                (PreferencesManager) swingApp.getSingleton(
                        YASLSwingApplication.KEY_PREFERENCES_MANAGER);
        // fill port
        if (prefsManager.isPreferenceAvailable(JIPSnapManConstants.PREF_PORT)) {
            port.setText(prefsManager.getPreference(JIPSnapManConstants.
                    PREF_PORT));
        }
        // fill host
        if (prefsManager.isPreferenceAvailable(JIPSnapManConstants.PREF_HOST)) {
            host.setText(prefsManager.getPreference(JIPSnapManConstants.
                    PREF_HOST));
        }
        // fill path
        if (prefsManager.isPreferenceAvailable(JIPSnapManConstants.PREF_PATH)) {
            path.setText(prefsManager.getPreference(JIPSnapManConstants.
                    PREF_PATH));
        }
        // fill base name
        if (prefsManager.isPreferenceAvailable(JIPSnapManConstants.PREF_NAME)) {
            name.setText(prefsManager.getPreference(JIPSnapManConstants.
                    PREF_NAME));
        }
    }

    private void initUI() throws YASLApplicationException {
        // set up cut/copy/paste and d and d for text fields
        TextTransferHandler tTransHandler = new TextTransferHandler();
        EditPopupHandler editPopupHandler = (EditPopupHandler) swingApp.getSingleton(
                JIPSnapManConstants.KEY_EDIT_POPUP_HANDLER);
        logArea.addMouseListener(editPopupHandler);
        logArea.setTransferHandler(tTransHandler);
        logArea.setDragEnabled(true);
        host.addMouseListener(editPopupHandler);
        host.setTransferHandler(tTransHandler);
        host.setDragEnabled(true);
        name.addMouseListener(editPopupHandler);
        name.setTransferHandler(tTransHandler);
        name.setDragEnabled(true);
        port.addMouseListener(editPopupHandler);
        port.setTransferHandler(tTransHandler);
        port.setDragEnabled(true);
        // set up resource manager
        YASLResourceManager resMan = swingApp.getResourceManager();
        String defBundle = resMan.getDefaultBundle();
        // ----------------------------------------
        // set up info panel
        JPanel infoPanel = new JPanel(new BorderLayout(3, 0));
        infoPanel.setBorder(BorderFactory.createTitledBorder(resMan.getString(
                defBundle,
                "label.snapshot.info")));
        JPanel labelsPanel = new JPanel(new GridLayout(4, 1, 3, 3));
        labelsPanel.add(new JLabel(resMan.getString(
                defBundle,
                "label.path")));
        labelsPanel.add(new JLabel(resMan.getString(
                defBundle,
                "label.name")));
        labelsPanel.add(new JLabel(resMan.getString(
                defBundle,
                "label.port")));
        labelsPanel.add(new JLabel(resMan.getString(
                defBundle,
                "label.host")));
        JPanel pathPanel = new JPanel(new BorderLayout(3, 0));
        pathPanel.add(path, BorderLayout.CENTER);
        pathPanel.add(browseButton, BorderLayout.EAST);
        JPanel entryPanel = new JPanel(new GridLayout(4, 1, 3, 3));
        entryPanel.add(pathPanel);
        entryPanel.add(name);
        entryPanel.add(port);
        entryPanel.add(host);
        infoPanel.add(labelsPanel, BorderLayout.WEST);
        infoPanel.add(entryPanel, BorderLayout.CENTER);
        // ----------------------------------------
        // set up snapshot panel
        JPanel capturePanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20,
                1));
        capturePanel.setBorder(BorderFactory.createTitledBorder(resMan.
                getString(
                        defBundle,
                        "label.snapshot.take")));

        capturePanel.add(startButton);
        capturePanel.add(finishButton);

        // ----------------------------------------
        // set up snapshots taken
        JPanel snapsPanel = new JPanel(new BorderLayout(0, 5));
        snapsPanel.setBorder(BorderFactory.createTitledBorder(resMan.getString(
                defBundle,
                "label.snapshots")));
        snapsList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        snapsList.setCellRenderer(new SnapshotListCellRenderer(resMan));
        snapsList.setVisibleRowCount(5);
        JScrollPane snapsPane = new JScrollPane(snapsList);
        snapsPanel.add(snapsPane, BorderLayout.CENTER);
        snapsPanel.add(launchJipButton, BorderLayout.SOUTH);
        // ----------------------------------------
        // logs panel set up
        JScrollPane logsPane = new JScrollPane(logArea);
        logsPane.setBorder(BorderFactory.createTitledBorder(resMan.getString(
                defBundle,
                "label.logs")));
        // ----------------------------------------
        // main panel set up
        this.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        // add panels
        this.add(infoPanel);
        this.add(Box.createVerticalStrut(5));
        this.add(capturePanel);
        this.add(Box.createVerticalStrut(5));
        this.add(snapsPanel);
        this.add(Box.createVerticalStrut(5));
        this.add(logsPane);
    }

    private void setValue(final JTextField label,
                          final String value) {
      Runnable runner = new Runnable() {
        public void run() {
          label.setText(value);
        }
      };
      SwingUtilities.invokeLater(runner);
    }

    /* ------------------- from LogsModel ----------------------- */

    public void updateLog(String value) {
        logArea.append(value);
    }

    /* ---------------- from SnapshotPathModel ------------------ */

    public String getSnapshotPath() {
        return path.getText();
    }

    public void setSnapshotPath(String pathValue) {
        path.setText(pathValue);
    }

    /* ---------------- from SnapshotInfoModel ------------------ */

    public String getSnapshotName() {
      return name.getText().trim();
    }

    public String getSnapshotPort() {
      String portValue = port.getText().trim();
      if("".equals(portValue)) {
        portValue = default_port;
        setValue(port, portValue);
      }
      return portValue;
    }

    public String getSnapshotHost() {
      String hostValue = host.getText().trim();
      if("".equals(hostValue)) {
        hostValue = default_host;
        setValue(host, hostValue);
      }
      return hostValue;
    }

    /* --------------- from SnapshotsTakenModel ----------------- */

    public Snapshot getSelectedSnapshot() {
        return (Snapshot) snapsList.getSelectedValue();
    }

    /* --------------- from SnapshotEventListener --------------- */

    public void handleSnapshotEvent(SnapshotEvent event) {
        switch (event.getId()) {
            case SnapshotEvent.ID_SNAPSHOT_STARTED:
                name.setEditable(false);
                port.setEditable(false);
                host.setEditable(false);
                break;
            case SnapshotEvent.ID_SNAPSHOT_CAPTURED:
                snapshotListModel.addSnapshot(event.getSnapshot());
            case SnapshotEvent.ID_SNAPSHOT_CAPTURE_FAILED:
                name.setEditable(true);
                port.setEditable(true);
                host.setEditable(true);
                break;
        }
    }
}
