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

import java.awt.Container;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.text.NumberFormat;
import java.util.HashMap;
import java.util.Map;

import javax.swing.BoxLayout;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTable;
import javax.swing.SwingConstants;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableColumn;
import javax.swing.table.TableColumnModel;
import javax.swing.table.TableModel;

class MethodViewer extends Container implements ChangeListener, MouseListener {
    private ValueModel<JipMethod> mModel;
    private JLabel mLabel;
    private JTable mCallers;
    private JTable mSelf;
    private JTable mCallees;
    private JipRun mRun;

    private MethodRowTableModel mSelfModel    = new MethodRowTableModel();
    private MethodRowTableModel mCallersModel = new MethodRowTableModel();
    private MethodRowTableModel mCalleesModel = new MethodRowTableModel();

    MethodViewer(JipRun run, ValueModel<JipMethod> model) {
        mRun = run;
        mModel = model;
        mModel.addChangeListener(this);
        
        mLabel = makeLabel("method:");

        mCallers = makeTableForMethodRows(mCallersModel);
        mSelf    = makeTableForMethodRows(mSelfModel);
        mCallees = makeTableForMethodRows(mCalleesModel);

        // listen some...
        mCallers.addMouseListener(this);
        mCallees.addMouseListener(this);

        add(makeLabel("called by:"));
        add(new JScrollPane(mCallers));
        add(new JSeparator());
        add(mLabel);
        add(mSelf);
        add(new JSeparator());
        add(makeLabel("calls:"));
        add(new JScrollPane(mCallees));
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    }

    public void changed(Object source) {
        JipMethod method = mModel.getValue();

        mCallersModel.clear();
        mSelfModel.clear();
        mCalleesModel.clear();

        if (method != null) {

            // do callers...
            Map<JipMethod, MethodRow> rows = new HashMap<JipMethod, MethodRow>();
            long allCallersTime = 0;
            for (JipFrame caller: mRun.allCallers(method)) {
                JipMethod callerMethod = caller.getMethod();
                MethodRow mr = rows.get(callerMethod);
                if (mr == null) {
                    mr = new MethodRow(callerMethod);
                    mCallersModel.add(mr);
                    rows.put(callerMethod, mr);
                }
                mr.addFrame(caller);
                allCallersTime += caller.getTotalTime();
            }
            for (MethodRow mr: rows.values()) {
                mr.setTimeDenominator(allCallersTime);
            }

            // do self...
            JipRun.PerMethodInfo perMethod = mRun.getPerMethod(method);
            long selfTotalTimeIncReentrant =
                perMethod.getAllThreadAllFramesTimeIncludingReentrant();

            MethodRow selfRow = new MethodRow(method);
            selfRow.setTimeDenominator(selfTotalTimeIncReentrant);
            for (JipFrame frame: perMethod.allFrames()) {
                selfRow.addFrame(frame);
            }
            mSelfModel.add(selfRow);
            
            // do callees...
            rows = new HashMap<JipMethod, MethodRow>();
            for (JipFrame callee: mRun.allCallees(method)) {
                JipMethod calleeMethod = callee.getMethod();
                MethodRow mr = rows.get(calleeMethod);
                if (mr == null) {
                    mr = new MethodRow(calleeMethod);
                    mr.setTimeDenominator(selfTotalTimeIncReentrant);
                    mCalleesModel.add(mr);
                    rows.put(calleeMethod, mr);
                }
                mr.addFrame(callee);
            }
        }
    }


    // A renderer that displays doubles with a fixed number of decimal columns
    static class MyDoubleRenderer extends DefaultTableCellRenderer {
        NumberFormat mFormat;

        MyDoubleRenderer() {
            super();
            setHorizontalAlignment(SwingConstants.RIGHT);
        }

        public void setValue(Object value) {
            if (mFormat == null) {
                mFormat = (NumberFormat) NumberFormat.getInstance().clone();
                mFormat.setMinimumFractionDigits(2);
            }
            setText(mFormat.format(value));
        }
    };
    
    static int svWidth[] = {50, 100, 50, 50, 50, 190, 200, 190};

    static JTable makeTableForMethodRows(TableModel model) {
        TableSorter sorter = new TableSorter(model);
        JTable table = new JTable(sorter);
        sorter.setTableHeader(table.getTableHeader());

        TableColumnModel colModel = table.getColumnModel();
        int nCol = model.getColumnCount();
        for (int iCol=0; iCol < nCol; iCol++) {
            TableColumn col = colModel.getColumn(iCol);
            if (iCol < svWidth.length) {
                col.setPreferredWidth(svWidth[iCol]);
            }
        }
        table.doLayout();

        table.setDefaultRenderer(Double.class, new MyDoubleRenderer());
        return table;
    }

    private JLabel makeLabel(String text) {
        JLabel label = new JLabel(text);
        //label.setHorizontalTextPosition(JLabel.LEFT);
        return label;
    }

    //
    // MouseListener
    //

    public void mouseClicked(MouseEvent e) {
        if ((e.getSource() != mCallers) && (e.getSource() != mCallees)) {
            return;
        }

        if (e.getButton() != MouseEvent.BUTTON1) {
            return;
        }

        if (e.getID() != MouseEvent.MOUSE_CLICKED) {
            return;
        }

        if (e.getClickCount() != 2) {
            return;
        }

        // ok...button1 was double-clicked on either mCallers or mCallees.

        // find the index of the row in the view...
        JTable table = (JTable) e.getSource();
        int iRow = table.rowAtPoint(e.getPoint());


        // convert to index of the row in the unsorted model...
        TableSorter sorter = (TableSorter) table.getModel();
        iRow = sorter.modelIndex(iRow);

        // get the row from the unsorted model...
        MethodRowTableModel rowModel =
            (MethodRowTableModel) sorter.getTableModel();

        MethodRow row = rowModel.getRow(iRow);

        // update the model!
        mModel.setValue(row.getMethod());
    }

    public void mouseEntered(MouseEvent e) {
    }

    public void mouseExited(MouseEvent e) {
    }

    public void mousePressed(MouseEvent e) {
    }

    public void mouseReleased(MouseEvent e) {
    }
};
