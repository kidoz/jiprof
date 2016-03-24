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

import java.util.ArrayList;
import java.util.List;
import javax.swing.table.AbstractTableModel;

class MethodRowTableModel extends AbstractTableModel {

    public static final int PERCENT_TOTAL = 0;
    public static final int TOTAL_TIME    = 1;
    public static final int COUNT         = 2;
    public static final int PERCENT_NET   = 3;
    public static final int NET_TIME      = 4;
    public static final int METHOD_NAME   = 5;
    public static final int CLASS_NAME    = 6;
    public static final int PACKAGE_NAME  = 7;

    List<MethodRow> mvRow = new ArrayList<MethodRow>();

    public void add(MethodRow row) {
        mvRow.add(row);
        int iLast = mvRow.size();
        fireTableRowsInserted(iLast, iLast);
    }

    public void clear() {
        int iLast = mvRow.size();
        mvRow.clear();
        fireTableRowsDeleted(0, iLast);
    }

    public MethodRow getRow(int iRow) {
        return mvRow.get(iRow);
    }

    public int getRowCount() {
        return mvRow.size();
    }
    
    public int getColumnCount() {
        return 8;
    }

    public String getColumnName(int iColumn) {
        switch (iColumn) {
          case PERCENT_TOTAL: return "%total";
          case PERCENT_NET:   return "%net";
          case COUNT:         return "count";
          case TOTAL_TIME:    return "total";
          case NET_TIME:      return "net";
          case METHOD_NAME:   return "method";
          case CLASS_NAME:    return "class";
          case PACKAGE_NAME:  return "package";
          default:            throw new RuntimeException("bad column index");
        }
    }
        
    public Class getColumnClass(int iColumn) {
        switch (iColumn) {
          case PERCENT_TOTAL: return Double.class;
          case PERCENT_NET:   return Double.class;
          case COUNT:         return Long.class;
          case TOTAL_TIME:    return Double.class;
          case NET_TIME:      return Double.class;
          case METHOD_NAME:   return String.class;
          case CLASS_NAME:    return String.class;
          case PACKAGE_NAME:  return String.class;
          default:            throw new RuntimeException("bad column index");
        }
    }

    public Object getValueAt(int iRow, int iColumn) {
        MethodRow row =  mvRow.get(iRow);

        switch (iColumn) {
          case PERCENT_TOTAL: return new Double(row.getPercentTotal());
          case PERCENT_NET:   return new Double(row.getPercentNet());
          case COUNT:         return new Long(row.getCount());
          case TOTAL_TIME:    return new Double(toMsec(row.getTotalTime()));
          case NET_TIME:      return new Double(toMsec(row.getNetTime()));
          case METHOD_NAME:   return row.getMethod().getMethodName();
          case CLASS_NAME:    return row.getMethod().getClassName();
          case PACKAGE_NAME:  return row.getMethod().getPackageName();
          default:            throw new RuntimeException("bad column index");
        }
    }

    private static double toMsec(long time) {
        final double timeToMsec = 1000.0 * 1000.0;
        return Math.floor((time / timeToMsec) * 10) / 10.0;
    }
};
