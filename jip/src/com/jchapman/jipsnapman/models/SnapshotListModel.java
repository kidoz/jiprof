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
// $Id: SnapshotListModel.java,v 1.1 2008/09/23 04:48:18 jchapman0 Exp $
package com.jchapman.jipsnapman.models;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.swing.AbstractListModel;

/**
 *
 * @author not attributable
 * @version 1.0
 */
public class SnapshotListModel
        extends AbstractListModel {
    private static final Comparator snapshotComparator = new SnapshotComp();
    private final List itemsList = new ArrayList();

    public SnapshotListModel() {
        super();
    }

    public void addSnapshot(Snapshot item) {
        int lastIdx;
        synchronized (itemsList) {
            itemsList.add(item);
            Collections.sort(itemsList, snapshotComparator);
            lastIdx = itemsList.size()-1;
        }
        fireContentsChanged(this,0,lastIdx);
    }

    /* --------------------- from ListModel -------------------- */

    /**
     * Returns the value at the specified index.
     *
     * @param index the requested index
     * @return the value at <code>index</code>
     */
    public Object getElementAt(int index) {
        Object obj = null;
        synchronized (itemsList) {
            obj = itemsList.get(index);
        }
        return obj;
    }

    /**
     * Returns the length of the list.
     *
     * @return the length of the list
     */
    public int getSize() {
        int size = 0;
        synchronized (itemsList) {
            size = itemsList.size();
        }
        return size;
    }

    /* --------------- Snapshot Comparator ----------------- */

    private static final class SnapshotComp
            implements Comparator {
        public int compare(Object o1, Object o2) {
            int rtrnValue;
            if (o1 == o2) {
                rtrnValue = 0;
            }
            else if (o1 == null) {
                rtrnValue = 1;
            }
            else if (o2 == null) {
                rtrnValue = -1;
            }
            else {
                rtrnValue = ((Snapshot) o1).getName().compareToIgnoreCase(
                        ((Snapshot) o2).getName());
            }
            return rtrnValue;
        }
    }
}
