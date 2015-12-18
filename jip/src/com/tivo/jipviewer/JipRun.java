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

import java.util.Collections;
import java.util.Comparator;
import java.util.Map;
import java.util.Set;
import java.util.HashMap;
import java.util.TreeMap;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.List;

class JipRun implements IJipParseHandler {
    private String mDate;

    // current thread, or 0 if none...
    private long mCurThreadId;

    // maps threadId (as Long) to List<JipFrame>
    private Map<Long, List<JipFrame>> mThreads =
        new HashMap<Long, List<JipFrame>>();

    // current interaction id or 0.
    private long mCurInteractionId;

    // current frame or null
    private JipFrame mCurFrame;

    // from each short class name to the full class name
    private Map<String, String> mFullClassNames = new TreeMap();

    // maps from a method to the PerMethodInfo for it.
    private Map<JipMethod, PerMethodInfo> mPerMethods =
        new HashMap<JipMethod, PerMethodInfo>();

    public void setDate(String date) {
        if (mDate != null) {
            throw new RuntimeException("already set date! (" + mDate + ")");
        }
        mDate = date;
    }
    
    public void startThread(long threadId) {
        if (mCurThreadId != 0) {
            throw new RuntimeException("already in thread " + mCurThreadId);
        }
        mCurThreadId = threadId;
    }

    public void endThread() {
        if (mCurThreadId == 0) {
            throw new RuntimeException("there's no thread to end!");
        }
        mCurThreadId = 0;
    }

    public void startInteraction(long id) {
        if (mCurInteractionId != 0) {
            throw new RuntimeException("already in interaction " +
                                       mCurInteractionId);
        }
        mCurInteractionId = id;
    }


    public void endInteraction() {
        if (mCurInteractionId == 0) {
            throw new RuntimeException("there's no interaction to end!");
        }
        mCurInteractionId = 0;
    }

    public void startFrame(String className,
                           String methodName,
                           long count,
                           long time) {

        //System.out.println("startFrame(" + className + ", " +
                           //methodName + ", " + count + ", " + time);

        /*
         * NOTE: I'm basically ignoring className because I don't really
         *       see the usefulness of the split between className and
         *       methodName in profile.xml.  If we're gonna use the classMap,
         *       let's not include the full class name in the methodName.
         */

        JipMethod method = new JipMethod(methodName);
        JipFrame frame = new JipFrame(mCurFrame, method, mCurThreadId,
                                      count, time);

        if (mCurFrame == null) {
            List<JipFrame> vFrame = mThreads.get(mCurThreadId);
            if (vFrame == null) {
                vFrame = new ArrayList<JipFrame>();
                mThreads.put(mCurThreadId, vFrame);
            }
            vFrame.add(frame);
        }
        mCurFrame = frame;
    }

    public void endFrame() {
        mCurFrame.computeNetTime();
        updatePerMethodInfo(mCurFrame);

        // pop!
        mCurFrame = mCurFrame.getParentOrNull();
    }

    // allocations not handled -- i want some examples first -- :)

    public void addToClassMap(String abbrev, String full) {
        mFullClassNames.put(abbrev, full);
    }

    public String toString() {
        StringBuffer buf = new StringBuffer();
        buf.append("JipRun\n");
        buf.append("{\n");

        for(Long threadId: mThreads.keySet()) {
            int i = 1;
            for (JipFrame f: mThreads.get(threadId)) {
                buf.append("* thread " + threadId + " interaction " +i+ "\n");
                buf.append(f);
                i++;
            }
        }
        
        buf.append("}\n");

        return buf.toString();
    }

    public Iterable<Long> threads() {
        return mThreads.keySet();
    }

    long getTotalTimeForAllThreads() {
        long total = 0;
        for (Long threadId: threads()) {
            for (JipFrame frame: mThreads.get(threadId.longValue())) {
                total += frame.getTotalTime();
            }
        }
        return total;
    }

    public Iterable<JipFrame> interactions(long threadId) {
        return mThreads.get(threadId);
    }

    public Iterable<JipFrame> allCallers(JipMethod method) {
        Set<JipFrame> set = new HashSet<JipFrame>();
        PerMethodInfo perMethod = mPerMethods.get(method);
        if (perMethod != null) {
            for (JipFrame frame: perMethod.allFrames()) {
                JipFrame parent = frame.getParentOrNull();
                if (parent != null) {
                    set.add(parent);
                }
            }
        }

        return set;
    }

    public Iterable<JipFrame> allCallees(JipMethod method) {
        Set set = new HashSet<JipFrame>();
        PerMethodInfo perMethod = mPerMethods.get(method);
        if (perMethod != null) {
            for (JipFrame frame: perMethod.allFrames()) {
                for (JipFrame callee: frame.getChildren()) {
                    set.add(callee);
                }
            }
        }

        return set;
    }

    /**
     * Returns an iterable containing PerMethodInfos in descending totalTime
     * order.
     */
    public List<PerMethodInfo> perMethodsInTotalTimeOrder() {
        Comparator cmp = new Comparator<PerMethodInfo>() {
            public int compare(PerMethodInfo a, PerMethodInfo b) {
                long timeA = a.getAllThreadAllFramesTime();
                long timeB = b.getAllThreadAllFramesTime();
                if (timeA < timeB) {
                    return -1;
                } else if (timeA > timeB) {
                    return 1;
                } else {
                    String nameA = a.getMethod().getMethodName();
                    String nameB = a.getMethod().getMethodName();
                    return nameA.compareToIgnoreCase(nameB);
                }
            }
        };
        List v = new ArrayList(mPerMethods.values());
        Collections.sort(v, cmp);
        return v;
    }

    public PerMethodInfo getPerMethod(JipMethod method) {
        PerMethodInfo perMethod = mPerMethods.get(method);
        if (perMethod == null) {
            throw new RuntimeException("unknown method (" + method + ")?");
        }

        return perMethod;
    }

    static class PerMethodInfo {
        private JipMethod mMethod;

        // NOTE: mAllThreadsAllFramesTime includes times from *all* threads.
        private long mAllThreadsAllFramesTime;
        private long mAllThreadsAllFramesTimeIncludingReentrant;
        private List<JipFrame> mvFrame = new ArrayList<JipFrame>();

        PerMethodInfo(JipMethod method) {
            mMethod = method;
        }

        JipMethod getMethod() {
            return mMethod;
        }

        void addFrame(JipFrame frame) {
            mvFrame.add(frame);

            long frameTime = frame.getTotalTime();

            mAllThreadsAllFramesTimeIncludingReentrant += frameTime;

            if (! frame.isReentrant()) {
                mAllThreadsAllFramesTime += frameTime;
            }
        }

        long getAllThreadAllFramesTime() {
            return mAllThreadsAllFramesTime;
        }

        long getAllThreadAllFramesTimeIncludingReentrant() {
            return mAllThreadsAllFramesTimeIncludingReentrant;
        }

        Iterable<JipFrame> allFrames() {
            return mvFrame;
        }

        public String toString() {
            return mMethod.getMethodName();
        }
    }

    private void updatePerMethodInfo(JipFrame frame) {
        JipMethod method = frame.getMethod();
        PerMethodInfo perMethod = mPerMethods.get(method);
        if (perMethod == null) {
            perMethod = new PerMethodInfo(method);
            mPerMethods.put(method, perMethod);
        }
        perMethod.addFrame(frame);
    }
};
