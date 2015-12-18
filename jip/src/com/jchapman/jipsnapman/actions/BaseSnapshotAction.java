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
// $Id: BaseSnapshotAction.java,v 1.1 2008/09/23 04:48:14 jchapman0 Exp $
package com.jchapman.jipsnapman.actions;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.text.MessageFormat;

import org.yasl.arch.action.YASLActionHandler;
import org.yasl.arch.application.YASLSwingApplication;
import org.yasl.arch.impl.action.YASLSwingAbstractAction;
import org.yasl.arch.impl.event.YASLActionEvent;
import org.yasl.arch.resources.YASLResourceManager;
import com.jchapman.jipsnapman.utils.JIPSnapManConstants;

/**
 *
 * @author not attributable
 * @version 1.0
 */
abstract class BaseSnapshotAction
    extends YASLSwingAbstractAction {

  public BaseSnapshotAction(String name,
                            boolean initEnabled,
                            YASLSwingApplication yaslSwingApplication) {
    super(name, initEnabled, yaslSwingApplication);
  }

  protected void updateConsoleLog(Exception ex,
                                  YASLActionHandler actionHandler)
      throws IOException {
    StringWriter swriter = new StringWriter();
    ex.printStackTrace(new PrintWriter(swriter));
    swriter.flush();
    swriter.close();
    updateConsoleLog(swriter.toString(), actionHandler);
  }

  protected boolean updateConsoleLog(Process proc,
                                     YASLActionHandler actionHandler) throws
      IOException {
    boolean gotException = false;
    StringBuffer buf = new StringBuffer();
    // get the err stream
    InputStream errStream = proc.getErrorStream();
    BufferedReader errIn = new BufferedReader(new InputStreamReader(
        errStream));
    readFromStream(errIn, buf);
    errIn.close();
    // if buf has content, then assume we received an exception
    gotException = buf.length() > 0;
    // get the standard in stream
    InputStream inStream = proc.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(inStream));
    readFromStream(in, buf);
    in.close();
    // if we got something then update log
    if (buf.length() > 0) {
      updateConsoleLog(buf.toString(), actionHandler);
    }
    return gotException;
  }

  private void readFromStream(BufferedReader in,
                              StringBuffer buf) throws IOException {
    for (String line = in.readLine(); line != null; line = in.readLine()) {
      buf.append(line);
      buf.append('\n');
    }
  }

  protected YASLActionEvent getErrorEvent() {
    YASLActionEvent event = new YASLActionEvent(
        this,
        YASLActionEvent.ACTION_PERFORMED,
        "");
    event.addProperty(JIPSnapManConstants.KEY_ERR_DLGTITLE,
                      "dlg.title.missing");
    return event;
  }

  protected void updateForSuccessfulCall(String call,
                                         YASLResourceManager resMan,
                                         YASLActionHandler actionHandler) throws
      IOException {
    StringBuffer buf = new StringBuffer();
    buf.append(MessageFormat.format(
        resMan.getString(resMan.getDefaultBundle(), "app.mssg.call.success"),
        new Object[] {call}));
    buf.append('\n');
    updateConsoleLog(buf.toString(), actionHandler);
  }

  protected void updateConsoleLog(String message,
                                  YASLActionHandler actionHandler) throws
      IOException {
    YASLActionEvent event = new YASLActionEvent(
        this,
        YASLActionEvent.ACTION_PERFORMED,
        "");
    event.addProperty(JIPSnapManConstants.KEY_LOGS_DATA,
                      message);
    actionHandler.getActionByKey(
        JIPSnapManConstants.ACTKEY_LOG_DISPLAY).actionPerformed(
            event);
  }

}
