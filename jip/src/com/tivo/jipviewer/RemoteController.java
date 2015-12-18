/*/////////////////////////////////////////////////////////////////////

Copyright (C) 2006 TiVo Inc.  All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

+ Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
+ Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
+ Neither the name of TiVo Inc nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
  POSSIBILITY OF SUCH DAMAGE.

/////////////////////////////////////////////////////////////////////*/

package com.tivo.jipviewer;

import java.awt.Component;
import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;

class RemoteController extends Container implements ActionListener {
    JTextField mHostname;
    SpinnerNumberModel mPortModel;
    JTextField mState;
    JButton    mButton;
    Boolean    mIsRunning = null;
    Boolean    mNextIsRunning = null;

    RemoteController() {
        mPortModel = new SpinnerNumberModel(15599, 0, 65355, 1);
        JSpinner portSpinner = new JSpinner(mPortModel);
        
        mHostname = makeTextInput("localhost");
        mState    = makeTextOutput("state");
        mButton   = makeButton("start/stop");

        Container pair = makePair(makeLabel("server hostname"), mHostname);
        add(pair);
        
        pair = makePair(makeLabel("server port"), portSpinner);
        add(pair);

        pair = makePair(makeLabel("state"), mState);
        add(pair);

        add(mButton);

        updateState();
        
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    }

    private void updateState() {
        String state = "unknown";
        String buttonLabel = "stop";
        if (mIsRunning == null || mIsRunning.booleanValue()) {
            if (mIsRunning != null) {
                state = "running";
            }
            buttonLabel = "stop";
            mNextIsRunning = false;
        } else {
            state = "stopped";
            buttonLabel = "start";
            mNextIsRunning = true;
        }
        mState.setText(state);
        mButton.setText(buttonLabel);

        String btnCmd = buttonLabel;
        mButton.setActionCommand(btnCmd);
    }

    public void actionPerformed(ActionEvent e) {
        String cmd = e.getActionCommand();
        if (cmd.equals("start") || cmd.equals("stop")) {
            changeState(cmd);
        } else {
            throw new RuntimeException("unexpected button cmd ("+cmd+")");
        }
    }

    // snarfed from ClientHelper.java
    void changeState(String command) {
        String hostname = mHostname.getText();
        int port = mPortModel.getNumber().intValue();
        if (send(command, hostname, port)) {
            // i'm assuming that if we didn't get a socket error from
            // send, then the profiler changed state.  ymmv.
            mIsRunning = mNextIsRunning;
            updateState();
        }
    }

    /**
     * sends the given message to the given server:port.
     * returns true iff there were no *detectable* errors.
     * (note that this doesn't mean there weren't errors!)
     */
    static boolean send(String command, String server, int port) {
        try {
            Socket socket = new Socket(server, port);
            OutputStream os = socket.getOutputStream();
            BufferedOutputStream out = new BufferedOutputStream(os);
            out.write(command.getBytes());
            out.write('\r');
            out.flush();
            socket.close();
            return true;
        } catch (IOException e) {
            String msg = ("Trouble sending '" + command + "' to " + server +
                          ":" + port + ":\n" + e);
            String title = "error";
            JOptionPane.showMessageDialog(null, msg, title,
                                          JOptionPane.ERROR_MESSAGE);
            return false;
        }
    }
    

    private Container makePair(Component left, Component right) {
        Container pair = new Container();
        pair.add(left);
        pair.add(makeLabel("   "));  // inelegant spacer!
        pair.add(right);
        pair.setLayout(new BoxLayout(pair, BoxLayout.X_AXIS));
        return pair;
    }

    private JButton makeButton(String text) {
        JButton button = new JButton(text);
        button.addActionListener(this);
        return button;
    }

    private JLabel makeLabel(String text) {
        JLabel label = new JLabel(text);
        return label;
    }

    private JTextField makeTextInput(String text) {
        JTextField field = new JTextField(text);
        return field;
    }

    private JTextField makeTextOutput(String text) {
        JTextField field = new JTextField(text);
        field.setEditable(false);
        return field;
    }
};
