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
// $Id: SnapshotListCellRenderer.java,v 1.1 2008/09/23 04:48:17 jchapman0 Exp $
package com.jchapman.jipsnapman.gui;

import java.text.MessageFormat;

import java.awt.Component;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.ListCellRenderer;
import javax.swing.UIManager;
import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;

import org.yasl.arch.resources.YASLResourceManager;
import com.jchapman.jipsnapman.models.Snapshot;

/**
 *
 * @author not attributable
 * @version 1.0
 */
public class SnapshotListCellRenderer
        extends JLabel implements ListCellRenderer {
    protected static Border noFocusBorder;
    private final YASLResourceManager resMan; // in ctor

    public SnapshotListCellRenderer(YASLResourceManager resMan) {
        super();
        this.resMan = resMan;
        if (noFocusBorder == null) {
            noFocusBorder = new EmptyBorder(1, 1, 1, 1);
        }
        setOpaque(true);
        setBorder(noFocusBorder);
    }

    /**
     * Return a component that has been configured to display the specified
     * value.
     *
     * @param list The JList we're painting.
     * @param value The value returned by
     *   list.getModel().getElementAt(index).
     * @param index The cells index.
     * @param isSelected True if the specified cell was selected.
     * @param cellHasFocus True if the specified cell has the focus.
     * @return A component whose paint() method will render the specified
     *   value.
     * @todo Implement this javax.swing.ListCellRenderer method
     */
    public Component getListCellRendererComponent(JList list,
                                                  Object value,
                                                  int index,
                                                  boolean isSelected,
                                                  boolean cellHasFocus) {
        setComponentOrientation(list.getComponentOrientation());
        if (isSelected) {
            setBackground(list.getSelectionBackground());
            setForeground(list.getSelectionForeground());
        }
        else {
            setBackground(list.getBackground());
            setForeground(list.getForeground());
        }
        Snapshot snapshot = (Snapshot) value;
        setEnabled(list.isEnabled());
        setFont(list.getFont());
        setBorder((cellHasFocus) ?
                  UIManager.getBorder("List.focusCellHighlightBorder") :
                  noFocusBorder);
        // display snapshot info
        String displayText = "";
        if (snapshot != null) {
            String template = resMan.getString(resMan.getDefaultBundle(),
                                               "label.snapshot.item");
            displayText = MessageFormat.format(template,
                                               new Object[] {
                                               snapshot.getName(),
                                               snapshot.getHost(),
                                               snapshot.getPort()});
        }
        setText(displayText);
        setVerticalTextPosition(JLabel.CENTER);
        setHorizontalTextPosition(JLabel.TRAILING);
        return this;
    }
}
