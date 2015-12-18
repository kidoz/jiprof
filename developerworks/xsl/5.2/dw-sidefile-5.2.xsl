<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <xsl:template match="dw-sidefile">
    <!-- MAIN_TABLE_BEGIN -->
    <table width="100%" cellspacing="0" cellpadding="0" border="0" id="v14-body-table">
      <tr valign="top">
        <!-- CONTENT_AREA_BEGIN -->
        <td width="100%">
          <!-- Main Content Begin -->
          <!--Main Content Begin-->
          <!-- PAGE_HEAD_BEGIN -->
          <table width="100%" cellspacing="0" cellpadding="0" border="0" id="content-table">
            <tr valign="top">
              <td width="100%">
                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                  <tr>
                    <td>
                      <!-- 5.0 05/02 tdc:  Had to put name="main" here; Spy doesn't like for <a> to surround comments -->
                      <a name="main">
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
                <!-- Separator rule -->
                <table width="100%" cellpadding="0" cellspacing="0" border="0">
                  <tr>
                    <td>
                      <img alt="" height="1" src="{$path-v14-rules}blue_rule.gif" width="100%"/>
                    </td>
                  </tr>
                </table>
                <!-- Spacer -->
                <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                <xsl:apply-templates select="docbody"/>
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
