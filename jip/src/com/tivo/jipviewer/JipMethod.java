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

/**
 * Represents a method.
 * It's immutable.
 *
 * Some definitions:
 *    if constructed with the name 'com.tivo.trio.util.Dict:getString',
 *    
 *       methodName = getString
 *       className  = Dict
 *       package    = com.tivo.trio.util
 *    
 */

class JipMethod {
    final String mName;

    // these are just so i don't keep parsing them out
    // on every call.  they're fully computable from mName!
    final String mMethodName;
    final String mClassName;
    final String mPackageName;

    JipMethod(String name) {
        mName = name;

        //
        // pre-compute all the subnames.
        //

        // method name...
        int iColon = mName.lastIndexOf(':');
        mMethodName = mName.substring(iColon+1);
        if (iColon == -1) {
            mClassName = "";
            mPackageName = "";
        } else {
            String fullClass = mName.substring(0, iColon);
            int iDot = fullClass.lastIndexOf('.');
            mClassName = fullClass.substring(iDot+1);
            if (iDot == -1) {
                mPackageName = "";
            } else {
                mPackageName = fullClass.substring(0,iDot);
            }
        }
    }

    String getName() {
        return mName;
    }

    String getClassName() {
        return mClassName;
    }

    String getMethodName() {
        return mMethodName;
    }

    String getPackageName() {
        return mPackageName;
    }

    //
    // from object
    //
    
    @Override public String toString() {
        return mName;
    }
    
    @Override public boolean equals(Object object) {
        if (! (object instanceof JipMethod)) {
            throw new RuntimeException("other isA " + object.getClass());
        }
        JipMethod other = (JipMethod) object;
        return mName.equals(other.mName);
    }

    @Override public int hashCode() {
        return mName.hashCode();
    }
};
