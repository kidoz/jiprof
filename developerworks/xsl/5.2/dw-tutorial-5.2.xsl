<?xml version="1.0" encoding="UTF-8"?>
<!-- ========================================= -->
<!-- developerWorks Stylesheet:  dw-tutorial-5.0.xsl 
       The source code contained herein is licensed under the IBM International
       License Agreement for Non-Warranted Programs.  
       Copyright (C) 2005 International Business Machines Corporation
       All Rights Reserved. -->
<!-- ========================================= -->
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:redirect="http://xml.apache.org/xalan/redirect" extension-element-prefixes="redirect" exclude-result-prefixes="xsl fo">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- ========================================= -->
  <!-- Global variables -->
  <!-- ========================================= -->
  <xsl:variable name="sectionCount" select="count(/dw-document/dw-tutorial/section)"/>
  <xsl:variable name="downloadCount">
    <xsl:choose>
      <xsl:when test="/dw-document/dw-tutorial/target-content-file or /dw-document/dw-tutorial/target-content-page">
        <xsl:number value="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number value="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="resourceCount">
    <xsl:choose>
      <xsl:when test="/dw-document/dw-tutorial/resources">
        <xsl:number value="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number value="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="authorCount">
    <xsl:number value="1"/>
  </xsl:variable>
  <xsl:variable name="ratingCount">
    <xsl:number value="1"/>
  </xsl:variable>
  <xsl:variable name="pageCount">
    <xsl:value-of select="$sectionCount + $downloadCount + $resourceCount + $authorCount + $ratingCount"/>
  </xsl:variable>
  <!-- ========================================= -->
  <!-- match="dw-tutorial -->
  <!-- ========================================= -->
  <xsl:template match="dw-tutorial">
    <xsl:for-each select="section">
      <xsl:call-template name="ProcessUniqueSections"/>
    </xsl:for-each>
    <xsl:call-template name="ProcessStandardSections"/>
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="ProcessUniqueSections" -->
  <!-- ========================================= -->
  <xsl:template name="ProcessUniqueSections">
    <xsl:param name="pageType"/>
    <!-- 5.0 6/16 tdc:  Added choose/when for authoring package situation -->
    <xsl:choose>
      <!-- Must be an internal editor's file if cma-id != '0', so produce multiple output files -->
      <xsl:when test="/dw-document/dw-tutorial/id/@cma-id !='0'">
        <xsl:choose>
          <xsl:when test=". = ../section[1]">
            <!-- 5.0 05/10 tdc:  No need to concat file name for index.html -->
            <redirect:write file="index.html">
              <xsl:call-template name="PageLayout">
                <!-- Note:  pageType param is passed down thru several levels of templates -->
                <xsl:with-param name="pageType">section</xsl:with-param>
              </xsl:call-template>
            </redirect:write>
          </xsl:when>
          <xsl:otherwise>
            <redirect:write select="concat('section', position(), '.html')">
              <xsl:call-template name="PageLayout">
                <xsl:with-param name="pageType">section</xsl:with-param>
              </xsl:call-template>
            </redirect:write>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- Must be an external author's file if cma-id = '0'; produce one big file with a rule separating sections -->
        <xsl:choose>
          <xsl:when test=". = ../section[1]">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageType">section</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <hr noshade="noshade"/>
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageType">section</xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="ProcessStandardSections" -->
  <!-- ========================================= -->
  <xsl:template name="ProcessStandardSections">
    <!-- 5.0 6/16 tdc:  Added choose/when for authoring package situation -->
    <xsl:choose>
      <!-- Must be an internal editor's file if cma-id != '0', so produce multiple output files -->
      <xsl:when test="/dw-document/dw-tutorial/id/@cma-id !='0'">
        <!-- Start:  Downloads section -->
        <xsl:if test="target-content-file or target-content-page">
          <redirect:write file="downloads.html">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageType">downloads</xsl:with-param>
            </xsl:call-template>
          </redirect:write>
        </xsl:if>
        <!-- Start:  Resources section -->
        <xsl:if test="resource-list or resources">
          <redirect:write file="resources.html">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageType">resources</xsl:with-param>
            </xsl:call-template>
          </redirect:write>
        </xsl:if>
        <!-- Start:  Authors section -->
        <redirect:write file="authors.html">
          <xsl:call-template name="PageLayout">
            <xsl:with-param name="pageType">authors</xsl:with-param>
          </xsl:call-template>
        </redirect:write>
        <!-- Start:  Ratings section -->
        <redirect:write file="rating.html">
          <xsl:call-template name="PageLayout">
            <xsl:with-param name="pageType">rating</xsl:with-param>
          </xsl:call-template>
        </redirect:write>
      </xsl:when>
      <xsl:otherwise>
        <!-- Must be an external author's file if cma-id = '0'; produce one big file with a rule separating sections -->
        <xsl:if test="target-content-file or target-content-page">
          <!-- Start:  Downloads section -->
          <hr noshade="noshade"/>
          <xsl:call-template name="PageLayout">
            <xsl:with-param name="pageType">downloads</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <!-- Start:  Resources section -->
        <xsl:if test="resource-list or resources">
          <hr noshade="noshade"/>
          <xsl:call-template name="PageLayout">
            <xsl:with-param name="pageType">resources</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <!-- Start:  Authors section -->
        <hr noshade="noshade"/>
        <xsl:call-template name="PageLayout">
          <xsl:with-param name="pageType">authors</xsl:with-param>
        </xsl:call-template>
        <!-- Start:  Ratings section -->
        <hr noshade="noshade"/>
        <xsl:call-template name="PageLayout">
          <xsl:with-param name="pageType">rating</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="PageLayout" -->
  <!-- ========================================= -->
  <xsl:template name="PageLayout">
    <xsl:param name="pageType"/>
    <!-- 5.0 6/16 tdc:  Added test for authoring package situation -->
    <!-- Include the standard HTML preamble if internally-produced file, or, if author's file and first section only -->
    <xsl:if test="(/dw-document/dw-tutorial/id/@cma-id != '0') or (/dw-document/dw-tutorial/id/@cma-id = '0' and . = ../section[1])">
      <xsl:call-template name="FrontMatter"/>
    </xsl:if>
    <!-- MAIN_TABLE_BEGIN -->
    <table width="100%" cellspacing="0" cellpadding="0" border="0" id="v14-body-table">
      <tr valign="top">
        <!-- Call appropriate nav builder based on pageType -->
        <xsl:choose>
          <xsl:when test="$pageType='section'">
            <xsl:call-template name="LeftNavUniqueSection">
              <xsl:with-param name="pageType" select="$pageType"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="LeftNavStandardSection">
              <xsl:with-param name="pageType" select="$pageType"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
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
                      <xsl:call-template name="PageNavigator">
                        <xsl:with-param name="pageType" select="$pageType"/>
                        <xsl:with-param name="pageNavigatorAlignment">center</xsl:with-param>
                        <xsl:with-param name="thisPageNumber">
                          <xsl:choose>
                            <xsl:when test="$pageType='section'">
                              <xsl:value-of select="position()"/>
                            </xsl:when>
                            <xsl:when test="$pageType='downloads'">
                              <xsl:value-of select="$sectionCount + $downloadCount"/>
                            </xsl:when>
                            <xsl:when test="$pageType='resources'">
                              <xsl:value-of select="$sectionCount + $downloadCount + $resourceCount"/>
                            </xsl:when>
                            <xsl:when test="$pageType='authors'">
                              <xsl:value-of select="$sectionCount + $downloadCount + $resourceCount + $authorCount"/>
                            </xsl:when>
                            <xsl:when test="$pageType='rating'">
                              <xsl:value-of select="$pageCount"/>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:with-param>
                      </xsl:call-template>
                      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                      <xsl:call-template name="DocumentOptions"/>
                      <xsl:if test="not($pageType='rating')">
                        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                        <!-- 5.0 6/10 tdc:  Changed include to variable -->
                        <xsl:copy-of select="$ssi-s-rating-tutorial"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                      </xsl:if>
                    </td>
                  </tr>
                </table>
                <!-- End right-aligned table for Document Options -->
                <!-- Start:  Determine page type and fill with appropriate contents -->
                <xsl:choose>
                  <xsl:when test="$pageType='section'">
                    <xsl:if test=". = ../section[1]">
                      <xsl:call-template name="SkillLevel"/>
                      <xsl:call-template name="AuthorTop"/>
                      <xsl:call-template name="Dates"/>
                      <xsl:call-template name="AbstractForDisplay"/>
                    </xsl:if>
                    <xsl:apply-templates select="title"/>
                    <xsl:apply-templates select="docbody"/>
                  </xsl:when>
                  <xsl:when test="$pageType='downloads'">
                    <xsl:call-template name="Download"/>
                  </xsl:when>
                  <xsl:when test="$pageType='resources'">
                    <xsl:call-template name="ResourcesSection"/>
                  </xsl:when>
                  <xsl:when test="$pageType='authors'">
                    <xsl:call-template name="AuthorBottom"/>
                  </xsl:when>
                  <xsl:when test="$pageType='rating'">
                    <xsl:call-template name="RatingsForm"/>
                  </xsl:when>
                </xsl:choose>
                <!-- End the center cell of the content section -->
                <xsl:if test="not(($pageType='downloads') or ($pageType='authors') or ($pageType='rating'))">
                  <!-- 5.0 6/10 tdc:  Changed include to variable -->
                  <!-- 5.2 8/31/05 tdc:  Added test for back-to-top-link value of section's last major heading.
                          If 'no', then don't display back-to-top nor bottom page navigator -->
                  <xsl:if test="((not(string(docbody/heading[@type='major'][last()]/@back-to-top)) or
                                         docbody/heading[@type='major'][last()]/@back-to-top = 'yes'))">
                    <xsl:copy-of select="$ssi-s-backlink-rule"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                    <!-- Seems I shouldn't have to process PageNavigator again since I've constructed it earlier -->
                    <xsl:call-template name="PageNavigator">
                      <xsl:with-param name="pageType" select="$pageType"/>
                      <xsl:with-param name="pageNavigatorAlignment">right</xsl:with-param>
                      <xsl:with-param name="thisPageNumber">
                        <xsl:choose>
                          <xsl:when test="$pageType='section'">
                            <xsl:value-of select="position()"/>
                          </xsl:when>
                          <xsl:when test="$pageType='downloads'">
                            <xsl:value-of select="$sectionCount + $downloadCount"/>
                          </xsl:when>
                          <xsl:when test="$pageType='resources'">
                            <xsl:value-of select="$sectionCount + $downloadCount + $resourceCount"/>
                          </xsl:when>
                          <xsl:when test="$pageType='authors'">
                            <xsl:value-of select="$sectionCount + $downloadCount + $resourceCount + $authorCount"/>
                          </xsl:when>
                          <xsl:when test="$pageType='rating'">
                            <xsl:value-of select="$pageCount"/>
                          </xsl:when>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:if>
                </xsl:if>
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
    <!-- 5.0 6/16 tdc:  Added test for authoring package situation -->
    <!-- Add ending /body and /html tags  if internally-produced file, or, if author's file and rating section only -->
    <xsl:if test="(/dw-document/dw-tutorial/id/@cma-id != '0')  or (/dw-document/dw-tutorial/id/@cma-id = '0' and $pageType = 'rating')">
      <xsl:call-template name="EndMatter"/>
    </xsl:if>
  </xsl:template>
  <!-- END OF TUTORIAL -->
  <!-- ========================================= -->
  <!-- name="LeftNavUniqueSection" -->
  <!-- ========================================= -->
  <xsl:template name="LeftNavUniqueSection">
    <xsl:param name="pageType"/>
    <!-- LEFTNAV_BEGIN -->
    <td width="150" id="navigation">
      <xsl:copy-of select="$ssi-s-nav14-top"/>
      <table border="0" cellpadding="0" cellspacing="0" width="150">
        <xsl:call-template name="LeftNavTop"/>
        <!-- Step 1:  Add the "In this tutorial" link -->
        <xsl:choose>
          <xsl:when test=". = ../section[1]">
            <tr>
              <td class="left-nav-highlight" colspan="2">
                <a class="left-nav" href="index.html">
                  <xsl:value-of select="$left-nav-in-this-tutorial"/>
                </a>
              </td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td class="left-nav" colspan="2">
                <a class="left-nav" href="index.html">
                  <xsl:value-of select="$left-nav-in-this-tutorial"/>
                </a>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Step 2:  Create links for each preceding section if they exist -->
        <xsl:for-each select="preceding-sibling::section">
          <tr class="left-nav-child">
            <td class="left-nav" colspan="2">
              <xsl:text disable-output-escaping="yes"><![CDATA[<a class="left-nav-child" href="]]></xsl:text>
              <xsl:choose>
                <xsl:when test=". = ../section[1]">
                  <xsl:text>index.html</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('section',position(),'.html')"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <xsl:value-of select="title"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
            </td>
          </tr>
        </xsl:for-each>
        <!-- Step 3a:  Now process *this* section -->
        <xsl:choose>
          <!-- Show section title and major headings - all highlighted -->
          <xsl:when test=". = ../section[1]">
            <tr class="left-nav-child-highlight">
              <td class="left-nav" colspan="2">
                <a class="left-nav-child" href="index.html">
                  <xsl:value-of select="title"/>
                </a>
              </td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <tr class="left-nav-child-highlight">
              <td class="left-nav" colspan="2">
                <xsl:text disable-output-escaping="yes"><![CDATA[<a class="left-nav-child" href="]]></xsl:text>
                <xsl:value-of select="concat('section',position(),'.html')"/>
                <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                <xsl:value-of select="title"/>
                <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Step 3b:  Get docbody heading refids for this section and build each TOC link -->
        <xsl:for-each select="docbody/heading">
          <xsl:variable name="newid">
            <xsl:choose>
              <xsl:when test="@refname != ''">
                <xsl:value-of select="concat('#', @refname)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('#', generate-id())"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="toctext">
            <xsl:choose>
              <xsl:when test="@alttoc != ''">
                <xsl:value-of select="@alttoc"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="@type='major'">
            <tr class="left-nav-child-highlight">
              <td>
                <img src="{$path-v14-t}cl-bullet.gif" width="2" height="8" alt=""/>
              </td>
              <td>
                <a class="left-nav-child" href="{$newid}">
                  <xsl:value-of select="$toctext"/>
                </a>
              </td>
            </tr>
          </xsl:if>
        </xsl:for-each>
        <!-- Step 4:  Create links for each of the following sections -->
        <xsl:call-template name="FollowingSectionsNav">
          <!-- Set the base section (calling) position from which the following sections are offset -->
          <xsl:with-param name="callingPosition" select="position()"/>
        </xsl:call-template>
        <!-- Step 5:  Build links to the standard sections -->
        <xsl:if test="(//target-content-file or //target-content-page)">
          <xsl:choose>
            <xsl:when test="$pageType='downloads'">
              <tr class="left-nav-child-highlight">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="downloads.html">
                    <xsl:value-of select="$download-heading"/>
                  </a>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr class="left-nav-child">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="downloads.html">
                    <xsl:value-of select="$download-heading"/>
                  </a>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="//resource-list | //resources">
          <tr class="left-nav-child">
            <td class="left-nav" colspan="2">
              <a class="left-nav-child" href="resources.html">
                <xsl:value-of select="$resource-list-heading"/>
              </a>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="//author/bio/.!=''">
          <tr class="left-nav-child">
            <td class="left-nav" colspan="2">
              <a class="left-nav-child" href="authors.html">
                <xsl:choose>
                  <xsl:when test="count(//author) = 1">
                    <xsl:value-of select="$aboutTheAuthor"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$aboutTheAuthors"/>
                  </xsl:otherwise>
                </xsl:choose>
              </a>
            </td>
          </tr>
        </xsl:if>
        <!-- 5.0 5/12 tdc:  Removed test for dWS content types; they don't use V5 -->
        <xsl:choose>
          <!-- 5.2 9/13/05 tdc:  Added brazil and russia to test -->
          <!-- 4.1 12/08 tdc:  If WW and none of the three ID attrib's are present, no Ratings link -->
          <!-- 4.0 8/02 tdc:  added "or cma-id" logic to tests -->
          <!-- do not output the TOC link to the ratings form in this case -->
          <xsl:when test="(/dw-document//@local-site = 'brazil' or /dw-document//@local-site ='russia' or /dw-document//@local-site = 'worldwide') and
                                                (
                                                  not(//id) or
                                                     (
                                                        (not(//id/@content-id) or //id/@content-id = '') and
                                                        (not(//id/@cma-id) or //id/@cma-id = '') and
                                                        (not(//id/domino-uid) or //id/@domino-uid = '')
                                                      )
                                                  )
                                            "/>
          <xsl:otherwise>
            <tr class="left-nav-child">
              <td class="left-nav" colspan="2">
                <a class="left-nav-child" href="rating.html">
                  <xsl:value-of select="$ratethistutorial-heading"/>
                </a>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <!-- BOTTOM NAV BORDER -->
        <xsl:call-template name="LeftNavBottom"/>
      </table>
      <!-- <xsl:call-template name="RelatedLinks"/> -->
    </td>
    <!-- LEFTNAV_END -->
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="LeftNavBottom" -->
  <!-- ========================================= -->
  <xsl:template name="LeftNavBottom">
    <tr class="left-nav-last">
      <td width="14">
        <img src="{$path-ibm-i}c.gif" width="14" height="1" alt="" class="display-img"/>
      </td>
      <td width="136">
        <img src="{$path-v14-t}left-nav-corner.gif" width="136" height="19" alt="" class="display-img"/>
      </td>
    </tr>
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="LeftNavStandardSection" -->
  <!-- ========================================= -->
  <xsl:template name="LeftNavStandardSection">
    <xsl:param name="pageType"/>
    <!-- LEFTNAV_BEGIN -->
    <td width="150" id="navigation">
      <!-- 5.0 6.10 tdc:  Changed include to variable -->
      <xsl:copy-of select="$ssi-s-nav14-top"/>
      <table border="0" cellpadding="0" cellspacing="0" width="150">
        <xsl:call-template name="LeftNavTop"/>
        <tr>
          <td class="left-nav" colspan="2">
            <a class="left-nav" href="index.html">
              <xsl:value-of select="$left-nav-in-this-tutorial"/>
            </a>
          </td>
        </tr>
        <xsl:for-each select="section">
          <tr class="left-nav-child">
            <td class="left-nav" colspan="2">
              <xsl:text disable-output-escaping="yes"><![CDATA[<a class="left-nav-child" href="]]></xsl:text>
              <xsl:choose>
                <xsl:when test=". = ../section[1]">
                  <xsl:text>index.html</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('section',position(),'.html')"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <xsl:value-of select="title"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
            </td>
          </tr>
        </xsl:for-each>
        <!-- Downloads page link -->
        <xsl:if test="(//target-content-file or //target-content-page)">
          <xsl:choose>
            <xsl:when test="$pageType='downloads'">
              <tr class="left-nav-child-highlight">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="downloads.html">
                    <xsl:value-of select="$download-heading"/>
                  </a>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr class="left-nav-child">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="downloads.html">
                    <xsl:value-of select="$download-heading"/>
                  </a>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <!-- Resources page link -->
        <xsl:if test="//resource-list | //resources">
          <xsl:choose>
            <xsl:when test="$pageType='resources'">
              <tr class="left-nav-child-highlight">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="resources.html">
                    <xsl:value-of select="$resource-list-heading"/>
                  </a>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr class="left-nav-child">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="resources.html">
                    <xsl:value-of select="$resource-list-heading"/>
                  </a>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <!-- Authors page link -->
        <xsl:if test="//author/bio/.!=''">
          <xsl:choose>
            <xsl:when test="$pageType='authors'">
              <tr class="left-nav-child-highlight">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="authors.html">
                    <xsl:choose>
                      <xsl:when test="count(//author) = 1">
                        <xsl:value-of select="$aboutTheAuthor"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$aboutTheAuthors"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <tr class="left-nav-child">
                <td class="left-nav" colspan="2">
                  <a class="left-nav-child" href="authors.html">
                    <xsl:choose>
                      <xsl:when test="count(//author) = 1">
                        <xsl:value-of select="$aboutTheAuthor"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$aboutTheAuthors"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <!-- Ratings page link -->
        <xsl:choose>
          <xsl:when test="$pageType='rating'">
            <tr class="left-nav-child-highlight">
              <td class="left-nav" colspan="2">
                <a class="left-nav-child" href="rating.html">
                  <xsl:value-of select="$ratethistutorial-heading"/>
                </a>
              </td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <!-- 5.2 9/13/05 tdc:  Added test for content areas and id's -->
              <!-- do not output the TOC link to the ratings form in this case -->
              <xsl:when test="(/dw-document//@local-site = 'brazil' or /dw-document//@local-site ='russia' or /dw-document//@local-site = 'worldwide') and
                                                (
                                                  not(//id) or
                                                     (
                                                        (not(//id/@content-id) or //id/@content-id = '') and
                                                        (not(//id/@cma-id) or //id/@cma-id = '') and
                                                        (not(//id/domino-uid) or //id/@domino-uid = '')
                                                      )
                                                  )
                                            "/>
              <xsl:otherwise>
                <tr class="left-nav-child">
                  <td class="left-nav" colspan="2">
                    <a class="left-nav-child" href="rating.html">
                      <xsl:value-of select="$ratethistutorial-heading"/>
                    </a>
                  </td>
                </tr>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <!-- BOTTOM NAV BORDER -->
        <xsl:call-template name="LeftNavBottom"/>
      </table>
      <!-- <xsl:call-template name="RelatedLinks"/> -->
    </td>
    <!-- LEFTNAV_END -->
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="LeftNavTop" -->
  <!-- ========================================= -->
  <xsl:template name="LeftNavTop">
    <!-- Start:  If part of a series -->
    <xsl:if test="/dw-document//series/series-title !='' and /dw-document//series/series-url != ''">
      <tr>
        <td class="left-nav" colspan="2">
          <a class="left-nav" href="{/dw-document//series/series-url}">
            <xsl:value-of select="$moreThisSeries"/>
            <xsl:text>:</xsl:text>
          </a>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<a class="left-nav-child" href="]]></xsl:text>
          <xsl:value-of select="/dw-document//series/series-url"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
          <!-- 5.0 5/13 tdc:  Remove the ", Part X" text from the series title if present -->
          <xsl:choose>
            <xsl:when test="contains(/dw-document//series/series-title, ', Part')">
              <xsl:value-of select="substring-before(/dw-document//series/series-title, ', Part')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="/dw-document//series/series-title"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </td>
      </tr>
      <!-- Separator -->
      <tr>
        <td width="14" class="dw-left-nav-separator">
          <img src="{$path-ibm-i}c.gif" width="14" height="6" alt=""/>
        </td>
        <td width="136" class="dw-left-nav-separator">
          <img src="{$path-ibm-i}c.gif" width="136" height="6" alt=""/>
        </td>
      </tr>
    </xsl:if>
    <!-- End:  If part of a series -->
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="FollowingSectionsNav" -->
  <!-- ========================================= -->
  <xsl:template name="FollowingSectionsNav">
    <xsl:param name="callingPosition"/>
    <!-- This "for-each" resets the value of "position()" to be the position of each following section -->
    <xsl:for-each select="following-sibling::section">
      <tr class="left-nav-child">
        <td class="left-nav" colspan="2">
          <xsl:text disable-output-escaping="yes"><![CDATA[<a class="left-nav-child" href="]]></xsl:text>
          <!-- Example:  If this is the 3rd section following section #2 (the calling section), this section's URL is section5.html -->
          <xsl:value-of select="concat('section',$callingPosition+position(),'.html')"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
          <xsl:value-of select="title"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>
  <!-- ========================================= -->
  <!-- name="PageNavigator" -->
  <!-- ========================================= -->
  <xsl:template name="PageNavigator">
    <xsl:param name="pageType"/>
    <xsl:param name="thisPageNumber"/>
    <xsl:param name="pageNavigatorAlignment"/>
    <xsl:variable name="previousPageUrl">
      <xsl:choose>
        <xsl:when test="$pageType='section'">
          <xsl:choose>
            <xsl:when test=". = ../section[2]">
              <xsl:text>index.html</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('section',position() - 1,'.html')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pageType='downloads'">
          <xsl:value-of select="concat('section',$sectionCount,'.html')"/>
        </xsl:when>
        <xsl:when test="$pageType='resources'">
          <xsl:choose>
            <xsl:when test="$downloadCount = 1">
              <xsl:text>downloads.html</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('section',$sectionCount,'.html')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pageType='authors'">
          <xsl:choose>
            <xsl:when test="$resourceCount = 1">
              <xsl:text>resources.html</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$downloadCount = 1">
                  <xsl:text>downloads.html</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('section',$sectionCount,'.html')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pageType='rating'">
          <xsl:text>authors.html</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nextPageUrl">
      <xsl:choose>
        <xsl:when test="$pageType='section'">
          <xsl:choose>
            <xsl:when test="following-sibling::section">
              <xsl:value-of select="concat('section',position() + 1,'.html')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$downloadCount=1">
                  <xsl:text>downloads.html</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="$resourceCount=1">
                      <xsl:text>resources.html</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>authors.html</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pageType='downloads'">
          <xsl:choose>
            <xsl:when test="$resourceCount=1">
              <xsl:text>resources.html</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>authors.html</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pageType='resources'">
          <xsl:text>authors.html</xsl:text>
        </xsl:when>
        <xsl:when test="$pageType='authors'">
          <xsl:text>rating.html</xsl:text>
        </xsl:when>
        <xsl:when test="$pageType='rating'">
          <xsl:text>#</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- Begin Next/Previous links, top -->
    <!-- 5.0 5/12 tdc:  Added class="no-print" to PageNavigator table -->
    <table cellspacing="0" cellpadding="0" border="0" width="150" align="{$pageNavigatorAlignment}" class="no-print">
      <tr>
        <td width="21" align="left">
          <xsl:choose>
            <xsl:when test=". = ../section[1]">
              <img src="{$path-ibm-i}c.gif" width="21" height="1" alt=""/>
            </xsl:when>
            <xsl:otherwise>
              <a class="fbox" href="{$previousPageUrl}">
                <!-- 5.2 9/06 05 tdc:  Added alt text for arrow_lt.gif -->
                <!-- 5.0.1 9/19 llk: note to self.. alt text needs to be translated-->
                <img border="0" align="middle" height="21" src="{$path-v14-buttons}arrow_lt.gif" width="21" alt="Go to the previous page"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td align="center" valign="middle">
          <xsl:value-of select="$page"/>&nbsp;<xsl:value-of select="$thisPageNumber"/>&nbsp;<xsl:value-of select="$of"/>&nbsp;<xsl:value-of select="$pageCount"/>
        </td>
        <td width="21" align="right">
          <xsl:choose>
            <xsl:when test="$pageType='rating'">
              <img src="{$path-ibm-i}c.gif" width="21" height="1" alt=""/>
            </xsl:when>
            <xsl:otherwise>
              <a class="fbox" href="{$nextPageUrl}">
                <!-- 5.2 9/06/05 tdc:  Added alt text for arrow_rd.gif -->
                <!-- 5.0.1 9/19 llk: note to self.. alt text needs to be translated-->
                <img border="0" align="middle" height="21" src="{$path-v14-buttons}arrow_rd.gif" width="21" alt="Go to the next page"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </table>
  </xsl:template>
  <!-- 5.0 5/11 tdc:  Added section/title template -->
  <!-- ========================================= -->
  <!-- match="section/title" -->
  <!-- ========================================= -->
  <xsl:template match="section/title">
    <p>
      <span class="atitle">
        <xsl:value-of select="."/>
      </span>
    </p>
  </xsl:template>
</xsl:stylesheet>
