<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- Start:  template="META" -->
  <!-- 5.0 5/12 tdc:  Made xpaths fully-qualified so that tutorials can use -->
  <xsl:template name="Meta">
    <xsl:variable name="filteredabstract">
      <xsl:call-template name="FilterAbstract"/>
    </xsl:variable>
    <xsl:text disable-output-escaping="yes">&lt;meta name="Abstract" content="</xsl:text>
    <!-- 5.0 05/02 tdc:  Sidefiles only:  Use title for meta abstract (no abstract element in dw-sidefile) -->
    <xsl:choose>
      <xsl:when test="dw-document/dw-sidefile">
        <xsl:value-of select="dw-document/dw-sidefile/title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filteredabstract"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">" /&gt;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;meta name="Description" content="</xsl:text>
    <!-- 5.0 05/02 tdc:  Sidefiles only:  Use title for meta description (no abstract element in dw-sidefile) -->
    <xsl:choose>
      <xsl:when test="dw-document/dw-sidefile">
        <xsl:value-of select="dw-document/dw-sidefile/title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filteredabstract"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text disable-output-escaping="yes">" /&gt;</xsl:text>
    <xsl:call-template name="keywords"/>
    <!-- 5.0 5/12 tdc:  corrected xpath -->
    <xsl:if test="not(/dw-document/dw-subscription-landing)">
      <xsl:variable name="dcdate">
        <xsl:choose>
          <xsl:when test="//date-updated">
            <xsl:value-of select="//date-updated/@year"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="//date-updated/@month"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="//date-updated/@day"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//date-published/@year"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="//date-published/@month"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="//date-published/@day"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text disable-output-escaping="yes">&lt;meta name="DC.Date" scheme="iso8601" content="</xsl:text>
      <xsl:value-of select="$dcdate"/>
      <xsl:text disable-output-escaping="yes">" /&gt;</xsl:text>
    </xsl:if>
    <!-- See if we can put meta Source tag in the s-header-meta.inc file instead of here. -->
    <xsl:text disable-output-escaping="yes">&lt;meta name="Source" content="Based on v14 Template Generator, Template 14.0" /&gt;</xsl:text>
     <!-- 5.0 5/12 tdc:  corrected xpath -->
    <xsl:if test="not(/dw-document/dw-subscription-landing)">
      <xsl:variable name="copyrightyear">
        <xsl:value-of select="//date-published/@year"/>
      </xsl:variable>
      <xsl:text disable-output-escaping="yes">&lt;meta name="DC.Rights" content="Copyright (c) </xsl:text>
      <xsl:value-of select="$copyrightyear"/>
      <xsl:text disable-output-escaping="yes"> by IBM Corporation" /&gt;</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="dw-document/dw-article">
        <xsl:text disable-output-escaping="yes"> &lt;meta name="Robots" content="index,follow" /&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="dw-document/dw-sidefile">
        <xsl:text disable-output-escaping="yes"> &lt;meta name="Robots" content="noindex,nofollow" /&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"> &lt;meta name="Robots" content="index,follow" /&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="effectivedate">
      <xsl:value-of select="//date-published/@year"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="//date-published/@month"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="//date-published/@day"/>
    </xsl:variable>
    <xsl:text disable-output-escaping="yes">&lt;meta name="IBM.Effective" scheme="W3CDTF" content="</xsl:text>
    <xsl:value-of select="$effectivedate"/>
    <xsl:text disable-output-escaping="yes">" /&gt;</xsl:text>
    <xsl:variable name="lastupdated">
      <xsl:if test="//meta-last-updated">
        <xsl:value-of select="concat(//meta-last-updated/@day, //meta-last-updated/@month, //meta-last-updated/@year, //meta-last-updated/@initials)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:text disable-output-escaping="yes">&lt;meta name="Last update" content="</xsl:text>
    <xsl:value-of select="$lastupdated"/>
    <xsl:text disable-output-escaping="yes">" /&gt;</xsl:text>
  </xsl:template>
  <!-- End:  template="META" -->
</xsl:stylesheet>
