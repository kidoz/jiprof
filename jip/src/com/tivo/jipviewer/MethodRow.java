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


class MethodRow {

    private JipMethod mMethod;
    int mCount = 0;
    double mTimeDenominator = 1.0;

    long mTotalTime = 0;
    long mNetTime   = 0;
    
    MethodRow(JipMethod method) {
        mMethod = method;
    }

    JipMethod getMethod() {
        return mMethod;
    }

    void setTimeDenominator(double timeDenominator) {
        if (timeDenominator == 0) {
            throw new RuntimeException("don't divide by zero!");
        }
        mTimeDenominator = timeDenominator;
    }

    double getPercentTotal() {
        double percent = toPercent(mTotalTime / mTimeDenominator);
        return percent;
    }

    double getPercentNet() {
        return toPercent(mNetTime / mTimeDenominator);
    }

    long getCount() {
        return mCount;
    }

    long getTotalTime() {
        return mTotalTime;
    }

    long getNetTime() {
        return mNetTime;
    }

    void addFrame(JipFrame frame) {
        mCount     += frame.getCount();
        mTotalTime += frame.getTotalTime();
        mNetTime   += frame.getNetTime();
    }

    double toPercent(double fraction) {
        return Math.floor(100 * 100 * fraction) / 100;
    }
};
