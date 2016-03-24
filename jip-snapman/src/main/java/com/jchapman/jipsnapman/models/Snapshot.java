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
// $Id: Snapshot.java,v 1.1 2008/09/23 04:48:18 jchapman0 Exp $
package com.jchapman.jipsnapman.models;

import java.io.File;

/**
 *
 * @author not attributable
 * @version 1.0
 */
public class Snapshot {
    private final String path; // in ctor
    private final String name; // in ctor
    private final String originalName; // in ctor
    private final String port; // in ctor
    private final String host; // in ctor

    public Snapshot(String path,
                    String name,
                    String originalName,
                    String port,
                    String host) {
        this.path = path;
        this.name = name;
        this.port = port;
        this.host = host;
        this.originalName = originalName;
    }

    public String getOriginalName() {
        return originalName;
    }

    public String getHost() {
        return host;
    }

    public String getPort() {
        return port;
    }

    public String getPath() {
        return path;
    }

    public String getName() {
        return name;
    }

    public String getPathAndName() {
        File pathAndName = new File(path, name);
        return pathAndName.getPath();
    }

    public String getPathAndNameForXML() {
        StringBuffer buf = new StringBuffer();
        buf.append(name.substring(0,name.length()-4));
        buf.append(".xml");
        File pathAndName = new File(path, buf.toString());
        return pathAndName.getPath();
    }

    public String toString() {
        StringBuffer buf = new StringBuffer();
        buf.append("path=").append(path);
        buf.append(" name=").append(name);
        buf.append(" port=").append(port);
        buf.append(" host=").append(host);
        return buf.toString();
    }
}
