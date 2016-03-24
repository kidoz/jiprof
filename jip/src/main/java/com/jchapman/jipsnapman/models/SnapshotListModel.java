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

import javax.swing.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import static java.lang.String.CASE_INSENSITIVE_ORDER;

/**
 * @author not attributable
 * @version 1.0
 */
public class SnapshotListModel extends AbstractListModel {

    private static final Comparator<Snapshot> SNAPSHOT_COMPARATOR = new SnapshotComparator();
    private final List<Snapshot> itemsList = new ArrayList<>();

    public SnapshotListModel() {
        super();
    }

    public void addSnapshot(Snapshot item) {
        int lastIdx;
        synchronized (itemsList) {
            itemsList.add(item);
            Collections.sort(itemsList, SNAPSHOT_COMPARATOR);
            lastIdx = itemsList.size() - 1;
        }

        fireContentsChanged(this, 0, lastIdx);
    }

    /* --------------------- from ListModel -------------------- */

    /**
     * Returns the value at the specified index.
     *
     * @param index the requested index
     * @return the value at <code>index</code>
     */
    public Object getElementAt(int index) {
        synchronized (itemsList) {
            return itemsList.get(index);
        }
    }

    /**
     * Returns the length of the list.
     *
     * @return the length of the list
     */
    public int getSize() {
        synchronized (itemsList) {
            return itemsList.size();
        }
    }

    /* --------------- Snapshot Comparator ----------------- */

    private static final class SnapshotComparator implements Comparator<Snapshot> {

        public int compare(Snapshot firstSnapshot, Snapshot secondSnapshot) {
            if (firstSnapshot == secondSnapshot) {
                return 0;
            }

            if (firstSnapshot == null) {
                return 1;
            }

            if (secondSnapshot == null) {
                return -1;
            }

            return CASE_INSENSITIVE_ORDER.compare(firstSnapshot.getName(), secondSnapshot.getName());
        }
    }
}
