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

import java.awt.BorderLayout;
import java.awt.Container;
import java.util.Enumeration;

import javax.swing.JTree;
import javax.swing.tree.DefaultMutableTreeNode;

class ByPackageViewer extends Container {

    ByPackageViewer(JipRun run) {
        setLayout(new BorderLayout());
        add(makeTree(run), BorderLayout.CENTER);
    }

    //
    // tree view of the world...
    //

    static class TreeNode extends DefaultMutableTreeNode {
        // name of this part of the package space
        String mName;

        // starts as 1.  is set during computeTotals.  is always non-0!
        private double mTimeDenominator = 1.0;
        
        // stats for methods in this package
        private long mSelfNetTime;
        private long mSelfCount;

        // stats for methods in this package and its "sub"packages.
        private long mTotalNetTime;
        private long mTotalCount;

        TreeNode(String name) {
            mName = name;
        }

        String getName() {
            return mName;
        }

        void addFrame(JipFrame frame) {
            mSelfNetTime += frame.getNetTime();
            mSelfCount   += frame.getCount();
        }

        private void computeTotals() {
            computeTotalsHelper();

            // *after* we've computed mTotalNetTime on the root,
            // set mTimeDenominator (if non-zero).
            if (mTotalNetTime > 0) {
                for(Enumeration nodes = breadthFirstEnumeration();
                    nodes.hasMoreElements();
                    /**/) {
                    TreeNode kid = (TreeNode) nodes.nextElement();
                    kid.mTimeDenominator = mTotalNetTime;
                }
            }
        }
        
        private void computeTotalsHelper() {
            for(Enumeration kids = children(); kids.hasMoreElements(); /**/) {
                TreeNode kid = (TreeNode) kids.nextElement();
                kid.computeTotalsHelper();
                mTotalCount   += kid.mTotalCount;
                mTotalNetTime += kid.mTotalNetTime;
            }

            mTotalCount += mSelfCount;
            mTotalNetTime += mSelfNetTime;
        }
        
        public String toString() {
            String str = (mName + "  " +
                          toPercent(mTotalNetTime/mTimeDenominator) +
                          " " +
                          toMsec(mTotalNetTime) + "ms");
            
            if (!isLeaf() && mSelfNetTime != 0) {
                str = (str + "  (self: " +
                       toPercent(mSelfNetTime/mTimeDenominator) + " " +
                       + toMsec(mSelfNetTime) + "ms)");
            }
            return str;
        }

        private static long toMsec(long time) {
            final double timeToMsec = 1000.0 * 1000.0;
            return Math.round(time / timeToMsec);
        }

        String toPercent(double fraction) {
            double p = Math.floor(100 * 100 * fraction) / 100;
            return Double.toString(p) + "%";
        }
    }

    static JTree makeTree(JipRun run) {
        TreeNode root = makePackageTree(run);

        return new JTree(root);
    }    

    private static TreeNode makePackageTree(JipRun run) {
        TreeNode root = new TreeNode("root");
        
        for(Long threadId: run.threads()) {
            for (JipFrame f: run.interactions(threadId)) {
                visitFrameForPackaging(root, f);
            }
        }

        root.computeTotals();
        return root;
    }

    private static void visitFrameForPackaging(TreeNode root, JipFrame frame) {
        String pkg = frame.getMethod().getPackageName();

        // add info for this frame
        TreeNode node = findOrCreateNode(root, pkg);
        node.addFrame(frame);

        // add info for this frame's children
        for (JipFrame childFrame: frame.getChildren()) {
            visitFrameForPackaging(root, childFrame);
        }
    };

    private static TreeNode findOrCreateNode(TreeNode node, String pkgName) {
        if (pkgName.equals("")) {
            // we found the node.
            return node;
        }

        // split out the next part of the name.
        String name;
        String rest;
        int iDot = pkgName.indexOf('.');
        if (iDot == -1) {
            name = pkgName;
            rest = "";
        }
        else {
            name = pkgName.substring(0,iDot);
            rest = pkgName.substring(iDot+1);
        }

        // does the name exist already as a kid of the node we were given?
        for(Enumeration kids = node.children(); kids.hasMoreElements(); /**/) {
            TreeNode kid = (TreeNode) kids.nextElement();
            if (kid.getName().equals(name)) {
                return findOrCreateNode(kid, rest);
            }
        }

        // didn't find it, so make a new node, and look for the rest...
        TreeNode newKid = new TreeNode(name);
        node.add(newKid);
        return findOrCreateNode(newKid, rest);
    }
}
