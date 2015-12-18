<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <xsl:template match="dw-article">
    <!-- MAIN_TABLE_BEGIN -->
    <table width="100%" cellspacing="0" cellpadding="0" border="0" id="v14-body-table">
      <tr valign="top">
        <xsl:call-template name="LeftNav"/>
        <!-- CONTENT_AREA_BEGIN -->
        <td width="100%">
          <!--Main Content Begin-->
          <!-- PAGE_HEAD_BEGIN -->
          <table width="100%" cellspacing="0" cellpadding="0" border="0" id="content-table">
            <tr valign="top">
              <td width="100%">
                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                  <tr>
                    <td>
                      <a name="main">
                        <!-- 5.2 9/18/05 tdc:  Added Accessibility-approved alt text -->
                        <img src="{$path-ibm-i}c.gif" width="592" height="1" alt="{$main-content}" border="0"/>
                      </a>
                    </td>
                  </tr>
                </table>
                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                  <tr valign="top">
                    <xsl:call-template name="BreadcrumbTitle"/>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
          <!-- PAGE_HEAD_END -->
          <!-- CONTENT_BEGIN -->
          <table width="100%" cellspacing="0" cellpadding="0" border="0">
            <tr valign="top">
              <!-- LEFT_GUTTER -->
              <td width="10">
                <img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
              </td>
              <!-- CENTER_COLUMN_BEGIN -->
              <td width="100%">
                <!-- Begin right-aligned table to hold Document Options -->
                <table align="right" cellpadding="0" cellspacing="0" width="160" border="0" class="no-print">
                  <tr>
                    <!-- LEFT_GUTTER -->
                    <td width="10">
                      <img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
                    </td>
                    <td>
                      <xsl:call-template name="DocumentOptions"/>
                      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>

<!-- 5.2 9/13/05 tdc:  Added brazil and russia (they're non-dbcs) -->                    
<!-- v5.0 lk 7/12 - until we verify that this jsp handles dbcs characters validly, remove for local sites -->
        <xsl:choose>
          <xsl:when test="/dw-document//@local-site='brazil' or /dw-document//@local-site= 'russia' or /dw-document//@local-site='worldwide'">
                <xsl:copy-of select="$ssi-s-rating-page"/>
                 <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
           </xsl:when>
           <xsl:otherwise/>
        </xsl:choose>
                      </td>
                  </tr>
                </table>
                <!-- End right-aligned table for Document Options-->
                <!-- Begin level, Author, Date information -->
                <xsl:call-template name="SkillLevel"/>
                <xsl:call-template name="AuthorTop"/>
                <xsl:call-template name="Dates"/>
                <xsl:call-template name="AbstractForDisplay"/>
                <xsl:apply-templates select="docbody"/>
                <xsl:call-template name="Download"/>
                <xsl:call-template name="ResourcesSection"/>
                <xsl:call-template name="AuthorBottom"/>
                <xsl:call-template name="RatingsForm"/>
                <!-- End the center cell of the content section -->
              </td>
              <!-- RIGHT_GUTTER -->
              <td width="10">
                <img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
              </td>
            </tr>
          </table>
          <!-- CONTENT_END -->
        </td>
        <!-- CONTENT_AREA_END -->
      </tr>
    </table>
    <!-- MAIN_TABLE_END -->
    <!-- END OF ARTICLE -->
  </xsl:template>
</xsl:stylesheet>
