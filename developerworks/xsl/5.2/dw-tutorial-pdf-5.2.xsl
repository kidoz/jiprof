<?xml version="1.0" encoding="UTF-8"?>
  <!-- ============================================
    This stylesheet transforms dw-tutorial document type to
    FO files for later processing into a PDF document.

    This version written 21 July  2005 by Frank Consiglio.
    Brought to you by your friends at developerWorks:
    ibm.com/developerWorks.
    =============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:fox="http://xml.apache.org/fop/extensions" xmlns:redirect="http://xml.apache.org/xalan/redirect" extension-element-prefixes="redirect" xmlns:xalan="http://xml.apache.org/xalan">

  <xsl:include href="dw-translated-text-worldwide-5.2.xsl" />
  <!-- 5.2 10/13 fjc add new symbol entities file-->
  <xsl:include href="dw-entities-pdf-5.2.xsl" />
  <xsl:param name="preferencesFile" select="'dw-pdf-preferences-5.2.xml'"/>  
  <!--  The Preferences file holds the fonts, font sizes and spacing, among other things -->
  <xsl:variable name="prefs" select="document($preferencesFile)/preferences"/>
  <!-- Images -->
  <xsl:variable name="ibm-logo-banner" select="$prefs/custom-content-files/ibm-logo-banner"/>
  <xsl:variable name="dw-logo" select="$prefs/custom-content-files/dw-logo"/>
  
  <!-- Fonts -->
  <xsl:variable name="default-font" select="$prefs/fonts/default-body-font"/>
  <xsl:variable name="default-font-size" select="$prefs/fonts/default-body-font/@size"/>
  <xsl:variable name="title-font" select="$prefs/fonts/title-font"/>
  <xsl:variable name="title-font-size" select="$prefs/fonts/title-font/@size"/>
  <xsl:variable name="header-font" select="$prefs/fonts/header-font"/>
  <xsl:variable name="header-font-size" select="$prefs/fonts/header-font/@size"/>
  <xsl:variable name="footer-font" select="$prefs/fonts/footer-font"/>
  <xsl:variable name="footer-font-size" select="$prefs/fonts/footer-font/@size"/>
  <xsl:variable name="major-heading-font" select="$prefs/fonts/major-heading-font"/>
  <xsl:variable name="major-heading-font-size" select="$prefs/fonts/major-heading-font/@size"/>
  <xsl:variable name="heading-font" select="$prefs/fonts/heading-font"/>
  <xsl:variable name="heading-font-size" select="$prefs/fonts/heading-font/@size"/>
  <xsl:variable name="text-font" select="$prefs/fonts/text-font"/>
  <xsl:variable name="text-font-size" select="$prefs/fonts/text-font/@size"/>
  <xsl:variable name="monospaced-font" select="$prefs/fonts/monospaced-font"/>
  <xsl:variable name="monospaced-font-size" select="$prefs/fonts/monospaced-font/@size"/>
  <xsl:variable name="masthead-font" select="$prefs/fonts/masthead-font"/>
  <xsl:variable name="masthead-font-size" select="$prefs/fonts/masthead-font/@size"/>
  <xsl:variable name="subtitle-font" select="$prefs/fonts/subtitle-font"/>
  <xsl:variable name="subtitle-font-size" select="$prefs/fonts/subtitle-font/@size"/>
  <xsl:variable name="section-title-font" select="$prefs/fonts/section-title-font"/>
  <xsl:variable name="section-title-font-size" select="$prefs/fonts/section-title-font/@size"/>
  <xsl:variable name="sidebar-font" select="$prefs/fonts/sidebar-font"/>
  <xsl:variable name="sidebar-font-size" select="$prefs/fonts/sidebar-font/@size"/>
  <xsl:variable name="table-cell-font" select="$prefs/fonts/table-cell-font"/>
  <xsl:variable name="table-cell-font-size" select="$prefs/fonts/table-cell-font/@size"/>
  <xsl:variable name="code-font" select="$prefs/fonts/code-font"/>
  <xsl:variable name="code-font-size" select="$prefs/fonts/code-font/@size"/>
  <!-- Spacing -->
  <xsl:variable name="title-space-before" select="$prefs/fonts/title-space-before"/>
  <xsl:variable name="title-space-after" select="$prefs/fonts/title-space-after"/>
  <xsl:variable name="section-space-before" select="$prefs/fonts/section-space-before"/>
  <xsl:variable name="section-space-after" select="$prefs/fonts/section-space-after"/>
  <xsl:variable name="docbody-space-before" select="$prefs/fonts/docbody-space-before"/>
  <xsl:variable name="docbody-space-after" select="$prefs/fonts/docbody-space-after"/>
  <xsl:variable name="heading-space-before" select="$prefs/fonts/heading-space-before"/>
  <xsl:variable name="heading-space-after" select="$prefs/fonts/heading-space-after"/>
  <xsl:variable name="resource-space-before" select="$prefs/fonts/resource-space-before"/>
  <xsl:variable name="resource-space-after" select="$prefs/fonts/resource-space-after"/>
  <xsl:variable name="default-space-before" select="$prefs/fonts/default-space-before"/>
  <xsl:variable name="default-space-after" select="$prefs/fonts/default-space-after"/>
  <xsl:variable name="minimum-space-before" select="$prefs/fonts/minimum-space-before"/>
  <xsl:variable name="minimum-space-after" select="$prefs/fonts/minimum-space-after"/>
  <xsl:variable name="maximum-space-before" select="$prefs/fonts/maximum-space-before"/>
  <xsl:variable name="maximum-space-after" select="$prefs/fonts/maximum-space-after"/>
 <!-- tables -->
  <xsl:variable name="section-width" select="$prefs/tables/section-width"/>
  <!-- 5.2 08/25 fjc: make code block width variable  -->
  <xsl:variable name="default-code-width" select="$prefs/tables/code-width"/>
  <xsl:variable name="default-table-width" select="$prefs/tables/table-width"/>
  <xsl:variable name="default-sidebar-width" select="$prefs/tables/sidebar-width"/>
  <xsl:variable name="table-column-width" select="$prefs/tables/table-column-width"/>
  <xsl:variable name="header-width-a" select="$prefs/tables/header-width-a"/>
  <xsl:variable name="header-width-b" select="$prefs/tables/header-width-b"/>
  <xsl:variable name="footer-width-a" select="$prefs/tables/footer-width-a"/>
  <xsl:variable name="footer-width-b" select="$prefs/tables/footer-width-b"/> 
  <xsl:variable name="masthead-width" select="$prefs/tables/masthead-width"/>
  <xsl:variable name="masthead-height" select="$prefs/tables/masthead-height"/>
 <!-- Colors   -->
  <xsl:variable name="background-color" select="$prefs/colors/background-color"/>
  <xsl:variable name="foreground-color" select="$prefs/colors/foreground-color"/>
  <xsl:variable name="title-color" select="$prefs/colors/title-color"/>
  <xsl:variable name="subtitle-color" select="$prefs/colors/subtitle-color"/>
  <xsl:variable name="series-color" select="$prefs/colors/series-color"/>
  <xsl:variable name="section-title-color" select="$prefs/colors/section-title-color"/>
  <xsl:variable name="internal-link-color" select="$prefs/colors/internal-link-color"/>
  <xsl:variable name="external-link-color" select="$prefs/colors/external-link-color"/>
  <xsl:variable name="table-th-color" select="$prefs/colors/table-th-color"/>
  <xsl:variable name="table-border-color" select="$prefs/colors/table-border-color"/>
  <xsl:variable name="table-caption-color" select="$prefs/colors/table-caption-color"/>
  <xsl:variable name="code-background-color" select="$prefs/colors/code-background-color"/>
  <xsl:variable name="sidebar-background-color" select="$prefs/colors/sidebar-background-color"/>
  <!-- ============================================
    This variable sets the size of the page.  If 
    it's 'ltr', we an 8.5 x 11 inch page; otherwise,
    we use an A4-sized page.  'ltr' is the default.
    To change the value, you can make the following
    line read select="'A4'", or you can check the
    documentation for your XSLT processor to see 
    how to set variables externally to the style
    sheet.  (For Xalan, add "-PARAM page-size a4"
    to the command.)
    =============================================== -->
  <xsl:template match="dw-document/dw-tutorial">
    <redirect:write file="ltr.fo">
      <xsl:call-template name="PageLayout">
        <xsl:with-param name="pageSize">ltr</xsl:with-param>
      </xsl:call-template>
    </redirect:write>
    <redirect:write file="a4.fo">
      <xsl:call-template name="PageLayout">
        <xsl:with-param name="pageSize">a4</xsl:with-param> 
      </xsl:call-template>
    </redirect:write>
    <!-- <xsl:choose>
      <xsl:when test="normalize-space(/dw-document//pdf/@paperSize)">
        <xsl:if test="/dw-document/dw-tutorial/pdf/@paperSize='letter'">
          <redirect:write file="ltr.fo">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageSize">ltr</xsl:with-param>
            </xsl:call-template>
          </redirect:write>
        </xsl:if>
        <xsl:if test="/dw-document//pdf/@paperSize='a4'">
          <redirect:write file="a4.fo">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageSize">a4</xsl:with-param> 
            </xsl:call-template>
          </redirect:write>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="/dw-document/dw-tutorial/@local-site='worldwide'">
          <redirect:write file="ltr.fo">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageSize">ltr</xsl:with-param>
            </xsl:call-template>
          </redirect:write>
        </xsl:if> -->
      <!-- Future! add named countries HERE 
        <xsl:if test="/dw-document/dw-tutorial/@local-site!='worldwide'">
          <redirect:write file="a4.fo">
            <xsl:call-template name="PageLayout">
              <xsl:with-param name="pageSize">a4</xsl:with-param> 
            </xsl:call-template>
          </redirect:write>
        </xsl:if>
        </xsl:otherwise>
    </xsl:choose>-->
  </xsl:template>
<!-- ============================================
Page Layout creates the whole PDF document.  pageSize is
either a4 or ltr.
=============================================== -->
  <xsl:template name="PageLayout">    
    <xsl:param name="pageSize"/> 
    <!-- ============================================
    The XSL-FO section starts here....
    =============================================== -->
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:fox="http://xml.apache.org/fop/extensions">
      <!-- ============================================
    Define the page layouts.  There are two sets of
    three page mastters here; we use one set for 
    letter-sized paper, the other set for A4.  Could be 2 <pdf> elements.
    Choose size by paperSize which is specified.  
    =============================================== -->
      <fo:layout-master-set>
          <xsl:if  test="$pageSize='a4'">
                <xsl:call-template name="a4Size"/>
          </xsl:if>
          <xsl:if  test="$pageSize='ltr'">
                <xsl:call-template name="letterSize"/>
          </xsl:if>
        <!-- ============================================
    Now we define how we use the page layouts.  One
    is for the first page, one is for the even-
    numbered pages, and one is for odd-numbered pages.
    =============================================== -->
        <fo:page-sequence-master master-name="standard">
          <fo:repeatable-page-master-alternatives>
            <fo:conditional-page-master-reference master-reference="first" page-position="first"/>
            <fo:conditional-page-master-reference master-reference="left" odd-or-even="even"/>
            <fo:conditional-page-master-reference master-reference="right" odd-or-even="odd"/>
          </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
      </fo:layout-master-set>
      <!-- ============================================
    Now that we've defined all of the page layouts,
    we generate the bookmarks for the PDF file. 
    =============================================== -->
      <xsl:call-template name="generate-bookmarks"/>
      <!-- ============================================
    This is where the actual content of the document
    starts. 
    =============================================== -->
      <fo:page-sequence master-reference="standard">
        <!-- ============================================
    We define the static content for the headers 
    and footers of the various page layouts first. 
    =============================================== -->
        <!-- Top of first page has a masthead -->
        <fo:static-content flow-name="masthead">
          <fo:block>
            <fo:table table-layout="fixed">
              <xsl:if  test="$pageSize='a4'">
                  <fo:table-column column-width="530pt"/>
              </xsl:if>
              <xsl:if  test="$pageSize='ltr'">
                  <fo:table-column column-width="550pt"/>
              </xsl:if>
              <fo:table-body>
                <fo:table-row>
    <!-- 5.2 09/20 fjc: masthead change -->
                  <fo:table-cell>
                    <fo:block start-indent="0pt" space-before="5pt" space-after="0pt">
                      <fo:external-graphic src="{$ibm-logo-banner}"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block>
                      <fo:leader leader-pattern="rule" start-indent="0pt"  rule-thickness=".5mm" leader-length="100%"  space-before="0pt" space-after="0pt"/>
                    </fo:block>
                  </fo:table-cell> 
                </fo:table-row>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block text-align="right" space-before="0pt"  space-after="0pt">
                      <fo:external-graphic src="{$dw-logo}"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:block>
        </fo:static-content>
        <!-- Top of odd numbered page -->
        <fo:static-content flow-name="rb-right">
          <fo:block font-family="{$header-font}" font-size="{$header-font-size}" text-align-last="end">
            <fo:table table-layout="fixed">
              <fo:table-column column-width="{$header-width-a}"/>
              <fo:table-column column-width="{$header-width-b}"/>
              <fo:table-body>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block text-align="start" start-indent="-25pt">
                      <xsl:text>ibm.com/developerWorks</xsl:text>
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block text-align="end">      
                      <xsl:text>developerWorks®</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:block>
        </fo:static-content>
        <!-- Bottom of odd numbered page -->
        <fo:static-content flow-name="ra-right">
          <fo:block font-family="{$footer-font}" font-size="{$footer-font-size}"  text-align-last="end">
            <fo:table table-layout="fixed">
              <fo:table-column column-width="{$footer-width-a}"/>
              <fo:table-column column-width="{$footer-width-b}"/>
              <fo:table-body>
                <fo:table-row>
                  <fo:table-cell number-columns-spanned="2">
                    <fo:block text-align="start" start-indent="-25pt">
                      <xsl:value-of select="/dw-document/dw-tutorial/title"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block text-align="start" start-indent="-25pt">
                      <fo:basic-link color="{$external-link-color}" external-destination="http://www.ibm.com/legal/copytrade.shtml"><xsl:value-of select="$pdfCopyrightNotice"/></fo:basic-link>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block text-align="end">
                      <xsl:value-of select="$page"/><xsl:text> </xsl:text>
                      <fo:page-number/><xsl:text> </xsl:text>
                      <xsl:value-of select="$of"/><xsl:text> </xsl:text>
                      <fo:page-number-citation ref-id="TheVeryLastPage"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:block>
        </fo:static-content>
        <!-- Top of even numbered page -->
        <fo:static-content flow-name="rb-left">
          <fo:block font-family="{$header-font}" font-size="{$header-font-size}"  text-align-last="end">
            <fo:table table-layout="fixed">
              <fo:table-column column-width="{$header-width-a}"/>
              <fo:table-column column-width="{$header-width-b}"/>
              <fo:table-body>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block text-align="start"  start-indent="-25pt" >
                      <xsl:text>developerWorks®</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block text-align="end">
                      <xsl:text>ibm.com/developerWorks</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:block>
        </fo:static-content>
        <!-- Bottom of even numbered page -->
        <fo:static-content flow-name="ra-left">
          <fo:block font-family="{$footer-font}" font-size="{$footer-font-size}" text-align-last="end">
            <fo:table table-layout="fixed">
              <fo:table-column column-width="{$footer-width-b}"/>
              <fo:table-column column-width="{$footer-width-a}"/>
              <fo:table-body>
                <fo:table-row>
                  <fo:table-cell number-columns-spanned="2">
                    <fo:block text-align="start" start-indent="-25pt">
                      <xsl:value-of select="/dw-document/dw-tutorial/title"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block text-align="start" start-indent="-25pt">
                      <xsl:value-of select="$page"/><xsl:text> </xsl:text>
                      <fo:page-number/><xsl:text> </xsl:text> 
                      <xsl:value-of select="$of"/><xsl:text> </xsl:text>
                      <fo:page-number-citation ref-id="TheVeryLastPage"/>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block text-align="end">
                      <fo:basic-link  color="{$external-link-color}"  external-destination="http://www.ibm.com/legal/copytrade.shtml"><xsl:value-of select="$pdfCopyrightNotice"/></fo:basic-link>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:block>
        </fo:static-content>
        <!-- End of Static (page header & footer) -->
        <xsl:call-template  name="body"/>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
  <!-- ============================================
    The <dw-tutorial> element contains everything in
    the main part of the document.  This is analogous
    to the <fo:flow flow-name="xsl-region-body">
    element, so we put the main document processing here.  
    =============================================== -->
  <xsl:template name="body">
    <!-- ============================================
    Start generating the content for the main page 
    area (xsl-region-body).
    =============================================== -->
    <fo:flow  flow-name="xsl-region-body" font-family="{$default-font}" font-size="{$default-font-size}">
      <xsl:call-template name="content"/>
  <!-- ============================================
    This one line of code processes everything that goes at the
    end of the document.  The Resources, Info about the author
    =============================================== -->
      <xsl:call-template name="appendix"/>
  <!-- ============================================
    We put an ID at the end of the document so we 
    can do "Page x of y" numbering.
    =============================================== -->
      <fo:block id="TheVeryLastPage" font-size="0pt" line-height="0pt" space-after="0pt"/>
    </fo:flow>
  </xsl:template>
<!-- ============================================
    Named templates
=============================================== -->
<!-- ============================================
    Letter Size  template
=============================================== -->
<xsl:template name="letterSize">
  <fo:simple-page-master margin-right="75pt" margin-left="75pt" page-height="11in" page-width="8.5in" margin-bottom="25pt" margin-top="10pt" master-name="first">
    <fo:region-before region-name="masthead" extent="85pt"/>
    <fo:region-body margin-top="100pt" margin-bottom="75pt"/>
    <fo:region-after region-name="ra-right" extent="50pt"/>
  </fo:simple-page-master>
  <fo:simple-page-master margin-right="75pt" margin-left="75pt" page-height="11in" page-width="8.5in" margin-bottom="25pt" margin-top="50pt" master-name="left">
    <fo:region-before region-name="rb-left" extent="25pt"/>
    <fo:region-body margin-top="50pt" margin-bottom="75pt"/>
    <fo:region-after region-name="ra-left" extent="50pt"/>
  </fo:simple-page-master>
  <fo:simple-page-master margin-right="75pt" margin-left="75pt" page-height="11in" page-width="8.5in" margin-bottom="25pt" margin-top="50pt" master-name="right">
    <fo:region-before region-name="rb-right" extent="25pt"/>
    <fo:region-body margin-top="50pt" margin-bottom="75pt"/>
    <fo:region-after region-name="ra-right" extent="50pt"/>
  </fo:simple-page-master>
</xsl:template>
<!-- ============================================
    A4 paper size template
=============================================== -->
<xsl:template name="a4Size">
  <fo:simple-page-master master-name="first" page-height="29.7cm" page-width="21cm" margin-top="4mm" margin-bottom="1cm" margin-left="2.5cm" margin-right="2.5cm">
    <fo:region-before region-name="masthead" extent="4.0cm"/>
    <fo:region-body margin-top="3.5cm" margin-bottom="2.5cm"/>
    <fo:region-after region-name="ra-right" extent="1.7cm"/>
  </fo:simple-page-master>
  <fo:simple-page-master master-name="left" page-height="29.7cm" page-width="21cm" margin-top="1cm" margin-bottom="1cm" margin-left="2.5cm" margin-right="2.5cm">
    <fo:region-before region-name="rb-left" extent="3.0cm"/>
    <fo:region-body margin-top="1.5cm" margin-bottom="2.5cm"/>
    <fo:region-after region-name="ra-left" extent="1.7cm"/>
  </fo:simple-page-master>
  <fo:simple-page-master master-name="right" page-height="29.7cm" page-width="21cm" margin-top="1cm" margin-bottom="1cm" margin-left="2.5cm" margin-right="2.5cm">
    <fo:region-before region-name="rb-right" extent="3.0cm"/>
    <fo:region-body margin-top="1.5cm" margin-bottom="2.5cm"/>
    <fo:region-after region-name="ra-right" extent="1.7cm"/>
  </fo:simple-page-master>
</xsl:template>
<!-- =====================================================
  generate Bookmarks template 
======================================================== -->
  <xsl:template name="generate-bookmarks" mode="generate-pdf-file">
    <fox:outline internal-destination="TableOfContents">
      <fox:label>
          <xsl:value-of select="$pdfTableOfContents"/>
      </fox:label>
    </fox:outline>
    <!--  Put the section links into bookmark -->
    <xsl:for-each select="/dw-document/dw-tutorial/section">
      <xsl:variable name="sectionNumber" select="position()"/>
      <fox:outline>
        <xsl:attribute name="internal-destination">
            <xsl:text>section</xsl:text>
            <xsl:value-of select="position()"/>
        </xsl:attribute>
        <fox:label>
          <xsl:value-of select="title"/>
        </fox:label>
        <!--  nest the subsection links into bookmark -->
        <xsl:for-each select="docbody">
          <xsl:for-each select="heading">
            <xsl:if test="@type='major'">
              <fox:outline>
<!-- 5.0 08/04 fjc - add section pos to the heading position for the link -->
                <xsl:attribute name="internal-destination">
                    <xsl:value-of select="$sectionNumber"/><xsl:text>-</xsl:text><xsl:value-of select="position()"/>
                </xsl:attribute>
                <fox:label>
                <xsl:value-of select="."/>
                </fox:label>
              </fox:outline>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
        </fox:outline>
        </xsl:for-each>
    <!--  Put the resources  link into bookmark -->
      <xsl:if test="/dw-document/dw-tutorial/resources">      
        <fox:outline>
          <xsl:attribute name="internal-destination">
            <xsl:text>resources</xsl:text>
          </xsl:attribute>
          <fox:label>
            <xsl:value-of select="$resource-list-heading"/>
          </fox:label>
        </fox:outline>
      </xsl:if>
      <xsl:if test="normalize-space(/dw-document//author/bio)!=''">
        <fox:outline>
          <xsl:attribute name="internal-destination">
            <xsl:text>author-bio</xsl:text>
          </xsl:attribute>
          <fox:label>
            <xsl:choose>
              <xsl:when test="count(//author) = 1">
                <xsl:value-of select="$aboutTheAuthor"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$aboutTheAuthors"/>
              </xsl:otherwise>
            </xsl:choose>
          </fox:label>
        </fox:outline>
      </xsl:if>
      <xsl:if test="/dw-document/dw-tutorial/trademarks">      
        <fox:outline>
          <xsl:attribute name="internal-destination">
            <xsl:text>trademarks</xsl:text>
          </xsl:attribute>
          <fox:label>
            <xsl:value-of select="$pdfTrademarks"/>
          </fox:label>
        </fox:outline>
      </xsl:if>
  </xsl:template>
  <!-- ============================================
    Content template
    =============================================== -->
  <xsl:template name="content">    
  <!-- Title & subtitle -->
    <fo:block space-before="{$title-space-before}" space-after="{$title-space-after}"  font-family="{$title-font}" font-size="{$title-font-size}" text-align="start">
      <xsl:if test="normalize-space(/dw-document/dw-tutorial/series/series-title)!=''">      
        <fo:inline color="{$series-color}"><xsl:value-of select="/dw-document/dw-tutorial/series/series-title"/>: </fo:inline>
      </xsl:if>
      <xsl:value-of select="/dw-document/dw-tutorial/title"/>
    </fo:block>
    <xsl:if test="normalize-space(/dw-document/dw-tutorial/subtitle)!=''">      
      <fo:block space-after="{$maximum-space-after}" font-family="{$title-font}" font-size="{$subtitle-font-size}" text-align="start">
            <xsl:value-of select="/dw-document/dw-tutorial/subtitle"/>
      </fo:block>
    </xsl:if>
<!-- Skill Level --> 
    <fo:block  space-after="{$maximum-space-after}" text-align="start">
      <xsl:value-of select="$pdfSkillLevel"/><xsl:text>: </xsl:text>
      <xsl:call-template name="SkillLevelText"/>
    </fo:block>
  <!-- Author -->
  <!-- Make it a link to about the author -->
    <xsl:for-each select="/dw-document/dw-tutorial/author">    
      <fo:block   text-align="start">
        <fo:basic-link color="{$internal-link-color}"><xsl:attribute name="internal-destination"><xsl:text>author-bio</xsl:text></xsl:attribute>
          <xsl:call-template name="AuthorName"/>
        </fo:basic-link>
    <!-- Author Email -->
        <xsl:if test="normalize-space(@email)!=''">        
          <xsl:text> (</xsl:text>
          <fo:basic-link color="{$external-link-color}">
                <xsl:attribute name="external-destination">mailto:<xsl:value-of select="@email"/></xsl:attribute><xsl:value-of select="@email"/>
          </fo:basic-link>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </fo:block>
    <!-- Author Title -->
      <fo:block  text-align="start">
        <xsl:value-of select="@jobtitle"/> 
      </fo:block>
    <!-- Author Company -->
      <fo:block space-after="{$default-space-after}"  text-align="start">
        <xsl:value-of select="company-name"/> 
      </fo:block>
    </xsl:for-each>
    <!-- Date -->
    <xsl:variable name="monthname">
      <xsl:call-template name="MonthName">
        <xsl:with-param name="month">
          <xsl:value-of select="//date-published/@month"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <fo:block space-before="{$maximum-space-before}" text-align="start">
      <xsl:value-of select="/dw-document/dw-tutorial/date-published/@day"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$monthname"/>
      <xsl:copy-of select="$monthchar"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="/dw-document/dw-tutorial/date-published/@year"/>
    </fo:block>
  <!-- Abstract -->
    <fo:block  space-before="{$maximum-space-before}"   text-align="start">
     <xsl:call-template name="AbstractForDisplay"/>
    </fo:block>
    <!-- ============================================
    This one line of code processes everything in 
    the body of the document.  The template that
    processes the <section> elements in turn processes
    everything that's inside it.
    =============================================== -->
    <xsl:call-template name="section"/>
  </xsl:template>
<!-- ===========================================
  Section Template
============================================= -->
  <xsl:template name="section">
    <xsl:for-each select="section">
      <xsl:variable name="sectionNumber" select="position()"/>
      <xsl:variable name="sectionID">
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>section</xsl:text>
            <xsl:value-of select="position()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <fo:block space-before="{$section-space-before}" space-after.optimum="{$section-space-after}"  font-family="{$section-title-font}" font-size="{$section-title-font-size}" text-align="start">
        <xsl:attribute name="id"><xsl:value-of select="$sectionID"/></xsl:attribute>
        <xsl:value-of select="$pdfSection"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$sectionNumber"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="title"/>
      </fo:block>
      <xsl:for-each select="docbody">
        <fo:table  table-layout="fixed">
          <fo:table-column column-width="{$section-width}"/>
          <fo:table-body>
            <fo:table-row>
              <fo:table-cell vertical-align="middle">
                <fo:block space-before.optimum="{$docbody-space-before}" space-after.optimum="{$docbody-space-after}"  font-family="{$default-font}" font-size="{$default-font-size}">
                  <xsl:apply-templates select="*|text()">
                  </xsl:apply-templates>
                </fo:block>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
      </xsl:for-each>
      <xsl:if test="not (position()=last())">
        <fo:block>
          <fo:leader leader-pattern="rule" leader-length="100%" space-before="{$default-space-before}" space-after.optimum="{$default-space-after}"/>
        </fo:block>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
    <!-- ============================================
    Appendix template
    ===============================================  -->
    <xsl:template name="appendix">    
<!-- Resource -->
    <xsl:if test="/dw-document//resources">
        <fo:block break-before="page"   space-after.optimum="{$default-space-after}"  font-family="{$section-title-font}" font-size="{$section-title-font-size}" text-align="start">
          <xsl:attribute name="id"><xsl:text>resources</xsl:text></xsl:attribute>
          <xsl:value-of select="$resource-list-heading"/>
      </fo:block>
      <xsl:apply-templates select="resources"/>
    </xsl:if>
 <!-- About the author --> 
    <xsl:if test="normalize-space(/dw-document//author/bio)!=''">
      <fo:block space-before="{$section-space-before}" space-after.optimum="{$default-space-after}"  font-family="{$section-title-font}" font-size="{$section-title-font-size}" text-align="start">
        <xsl:attribute name="id"><xsl:text>author-bio</xsl:text></xsl:attribute>
          <xsl:choose>
            <xsl:when test="count(//author) = 1">
              <xsl:value-of select="$aboutTheAuthor"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$aboutTheAuthors"/>
            </xsl:otherwise>
          </xsl:choose>
      </fo:block>    
      <xsl:call-template name="AboutTheAuthor"/>
    </xsl:if>
    <!-- Trademarks -->
    <xsl:if test="/dw-document/dw-tutorial/trademarks">   
      <fo:block space-before="{$section-space-before}"   space-after.optimum="{$default-space-after}"  font-family="{$section-title-font}" font-size="{$section-title-font-size}" text-align="start">
        <xsl:attribute name="id"><xsl:text>trademarks</xsl:text></xsl:attribute>
        <xsl:value-of select="$pdfTrademarks"/>
      </fo:block>
      <xsl:apply-templates select="trademarks" />
    </xsl:if> 
  </xsl:template>  
  <!-- ======================================
  Skill Level Template: text from skill level attribute 
  ======================================= -->
  <xsl:template name="SkillLevelText">
    <xsl:choose>
      <xsl:when test="/dw-document//@skill-level = '1' ">
        <xsl:value-of select="$level-1-text"/>
      </xsl:when>
      <xsl:when test="/dw-document//@skill-level = '2' ">
        <xsl:value-of select="$level-2-text"/>
      </xsl:when>
      <xsl:when test="/dw-document//@skill-level = '3' ">
        <xsl:value-of select="$level-3-text"/>
      </xsl:when>
      <xsl:when test="/dw-document//@skill-level = '4' ">
        <xsl:value-of select="$level-4-text"/>
      </xsl:when>
      <xsl:when test="/dw-document//@skill-level = '5' ">
        <xsl:value-of select="$level-5-text"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- ======================================
  About the Author  Template:  the name, and
   bio of all the authors of the tutorial 
  ======================================= -->
  <xsl:template name="AboutTheAuthor">
    <xsl:for-each select="/dw-document/dw-tutorial/author">
    <!-- Author Name -->
      <fo:block space-after="{$minimum-space-after}" text-align="start">
        <xsl:call-template name="AuthorName"/>
      </fo:block>
    <!-- Author Bio -->
      <fo:block space-after="{$maximum-space-after}" text-align="start">
        <xsl:apply-templates select="bio"/>
      </fo:block>
      <xsl:if test="not (position()=last())">
        <fo:block space-after="{$maximum-space-after}" >
          <fo:leader leader-pattern="rule" leader-length="100%" />
        </fo:block>
      </xsl:if>
    </xsl:for-each>  
  </xsl:template>
  <!-- ======================================
  Abstract Template: text from Abstract Element 
  ======================================= -->
  <xsl:template name="AbstractForDisplay">
    <xsl:choose>
      <xsl:when test="/dw-document//abstract-extended !=''">
        <xsl:apply-templates select="/dw-document//abstract-extended"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates  select="/dw-document//abstract"/> 
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- ======================================
  AuthorName  Template:  return the name of 
  the author of the tutorial 
  ======================================= -->
  <xsl:template name="AuthorName">
    <xsl:choose>
      <xsl:when test="normalize-space(name)!=''">
        <xsl:value-of select="name"/>
      </xsl:when>
      <xsl:when test="author-name">
        <xsl:if test="normalize-space(author-name/Prefix)!=''">
          <xsl:value-of select="author-name/Prefix"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space(author-name/GivenName)!=''">        
          <xsl:apply-templates select="author-name/GivenName"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space(author-name/MiddleName)!=''">
          <xsl:apply-templates select="author-name/MiddleName"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space(author-name/FamilyName)!=''">
          <xsl:apply-templates select="author-name/FamilyName"/>
        </xsl:if>
        <xsl:if test="normalize-space(author-name/Suffix)!=''">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="author-name/Suffix"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- ============================================
  Resource template - a unordered list of resources
  =============================================== -->
  <xsl:template match="dw-document//resources">
      <xsl:variable name="num-resources">
        <xsl:value-of select="count(resource)"/>
      </xsl:variable>
  <!-- 5.2 9/08/05 tdc:  Count number of each category of resources -->
      <xsl:variable name="num-resources-learn">
        <xsl:value-of select="count(resource[@resource-category='Learn'])"/>
      </xsl:variable>
      <xsl:variable name="num-resources-get">
        <xsl:value-of select="count(resource[@resource-category='Get products and technologies'])"/>
      </xsl:variable>
      <xsl:variable name="num-resources-discuss">
        <xsl:value-of select="count(resource[@resource-category='Discuss'])"/>
      </xsl:variable>
      <xsl:choose>
        <!-- Subcategorize if there are > 3 resource elements and at least 2 diff. subcat's coded -->
       <xsl:when test="$num-resources &gt; 3 and  $num-resources - $num-resources-learn != 0 and $num-resources - $num-resources-get != 0 and  $num-resources   - $num-resources-discuss !=0">   
          <xsl:if test="resource[@resource-category='Learn']">
            <fo:block  space-after="{$resource-space-after}" font-family="{$heading-font}"  font-size="{$heading-font-size}" text-align="start">
              <xsl:value-of select="$resources-learn"/>
            </fo:block>    
            <fo:list-block provisional-distance-between-starts="1cm"
            provisional-label-separation="0.50cm">
              <xsl:for-each select="resource[@resource-category='Learn']">
              <fo:list-item>
                <fo:list-item-label  start-indent="5mm" end-indent="label-end()" >
                  <fo:block>&#8226;</fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="body-start()" >
                  <fo:block  space-after="{$resource-space-after}">
                    <xsl:apply-templates select="*|text()"/>
                  </fo:block>
                </fo:list-item-body>
              </fo:list-item>
              </xsl:for-each>
            </fo:list-block>    
          </xsl:if>
          <xsl:if test="resource[@resource-category='Get products and technologies']">
            <fo:block  space-after="{$resource-space-after}" font-family="{$heading-font}"  font-size="{$heading-font-size}" text-align="start">
              <xsl:value-of select="$resources-get"/>
            </fo:block>    
            <fo:list-block provisional-distance-between-starts="1cm"
            provisional-label-separation="0.50cm">
              <xsl:for-each select="resource[@resource-category='Get products and technologies']">
              <fo:list-item>
                <fo:list-item-label start-indent="5mm" end-indent="label-end()" >
                  <fo:block>&#8226;</fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="body-start()" >
                  <fo:block  space-after="{$resource-space-after}">
                    <xsl:apply-templates select="*|text()"/>
                  </fo:block>
                </fo:list-item-body>
              </fo:list-item>
              </xsl:for-each>
            </fo:list-block>    
          </xsl:if>
          <xsl:if test="resource[@resource-category='Discuss'] or (normalize-space(/dw-document//forum-url/@url)!='') ">
            <fo:block  space-after="{$resource-space-after}" font-family="{$heading-font}"  font-size="{$heading-font-size}" text-align="start">
              <xsl:value-of select="$resources-discuss"/>
            </fo:block>    
            <fo:list-block provisional-distance-between-starts="1cm"
            provisional-label-separation="0.50cm">
              <!-- 5.2 09/08 fjc: moved to start of discuss category -->
              <!-- 5.2 08/31 fjc: added the Forum URL -->
              <xsl:if test="normalize-space(/dw-document//forum-url/@url)!=''">
                <fo:list-item>
                  <fo:list-item-label start-indent="5mm" end-indent="label-end()" >
                    <fo:block>&#8226;</fo:block>
                  </fo:list-item-label>
                  <fo:list-item-body start-indent="body-start()" >
                    <fo:block  space-after="{$resource-space-after}">
                      <fo:basic-link>
                        <xsl:attribute name="external-destination"><xsl:value-of select="/dw-document//forum-url/@url "/></xsl:attribute>
                        <xsl:attribute name="color"><xsl:value-of select="$external-link-color"/></xsl:attribute>
                        <xsl:value-of select="$pdfResource-list-forum-text"/>
                      </fo:basic-link>
                    </fo:block>
                  </fo:list-item-body>
                </fo:list-item>
              </xsl:if>
              <xsl:for-each select="resource[@resource-category='Discuss']">
                <fo:list-item>
                  <fo:list-item-label start-indent="5mm" end-indent="label-end()" >
                    <fo:block>&#8226;</fo:block>
                  </fo:list-item-label>
                  <fo:list-item-body start-indent="body-start()" >
                    <fo:block  space-after="{$resource-space-after}">
                      <xsl:apply-templates select="*|text()"/>
                    </fo:block>
                  </fo:list-item-body>
                </fo:list-item>
              </xsl:for-each>
            </fo:list-block>    
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        <!-- 5.2 09/09 fjc: make sure that forum-url is included -->
        <xsl:if test="normalize-space(/dw-document//forum-url/@url)!=''">
          <fo:list-item>
            <fo:list-item-label start-indent="5mm" end-indent="label-end()" >
              <fo:block>&#8226;</fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()" >
              <fo:block  space-after="{$resource-space-after}">
                <fo:basic-link>
                  <xsl:attribute name="external-destination"><xsl:value-of select="/dw-document//forum-url/@url "/></xsl:attribute>
                  <xsl:attribute name="color"><xsl:value-of select="$external-link-color"/></xsl:attribute>
                  <xsl:value-of select="$pdfResource-list-forum-text"/>
                </fo:basic-link>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </xsl:if>
        <xsl:for-each select="resource">
          <fo:list-block provisional-distance-between-starts="1cm" provisional-label-separation="0.50cm">
            <fo:list-item>
              <fo:list-item-label start-indent="5mm" end-indent="label-end()" >
                <fo:block>&#8226;</fo:block>
              </fo:list-item-label>
              <fo:list-item-body start-indent="body-start()" >
                <fo:block  space-after="{$resource-space-after}">
                  <xsl:apply-templates select="*|text()"/>
                </fo:block>
              </fo:list-item-body>
            </fo:list-item>
          </fo:list-block>    
        </xsl:for-each>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
<!-- ======================================
 Template - Monthname
========================================= -->
  <xsl:template name="MonthName">
      <xsl:param name="month"/>
      <xsl:choose>
        <xsl:when test="not(number($month))">
          <xsl:value-of select="$month"/>
        </xsl:when>
        <xsl:when test="$month = '01' ">
          <xsl:value-of select="$month-1-text"/>
        </xsl:when>
        <xsl:when test="$month = '02' ">
          <xsl:value-of select="$month-2-text"/>
        </xsl:when>
        <xsl:when test="$month = '03' ">
          <xsl:value-of select="$month-3-text"/>
        </xsl:when>
        <xsl:when test="$month = '04' ">
          <xsl:value-of select="$month-4-text"/>
        </xsl:when>
        <xsl:when test="$month = '05' ">
          <xsl:value-of select="$month-5-text"/>
        </xsl:when>
        <xsl:when test="$month = '06' ">
          <xsl:value-of select="$month-6-text"/>
        </xsl:when>
        <xsl:when test="$month = '07' ">
          <xsl:value-of select="$month-7-text"/>
        </xsl:when>
        <xsl:when test="$month = '08' ">
          <xsl:value-of select="$month-8-text"/>
        </xsl:when>
        <xsl:when test="$month = '09' ">
          <xsl:value-of select="$month-9-text"/>
        </xsl:when>
        <xsl:when test="$month = '10' ">
          <xsl:value-of select="$month-10-text"/>
        </xsl:when>
        <xsl:when test="$month = '11' ">
          <xsl:value-of select="$month-11-text"/>
        </xsl:when>
        <xsl:when test="$month = '12' ">
          <xsl:value-of select="$month-12-text"/>
        </xsl:when>
      </xsl:choose>
    </xsl:template>
  <!-- ============================================
  resource Template - a single resource
  =============================================== -->
  <xsl:template match="resource">
    <xsl:apply-templates select="*|text()"/>
  </xsl:template>
  <!-- ============================================
  trademark Template - a single resource
  =============================================== -->
  <xsl:template match="dw-document//trademarks">
    <xsl:for-each select="trademark">
      <fo:block space-after="{$minimum-space-after}" text-align="start">
        <xsl:apply-templates/>
      </fo:block>
    </xsl:for-each>
  </xsl:template>
  <!-- ============================================
  Code Template - 
  =============================================== -->
  <xsl:template match="code">
    <xsl:choose>
    
      <xsl:when test="@type='inline'">
          <fo:inline font-family="{$monospaced-font}" font-size="{$monospaced-font-size}">
            <xsl:apply-templates select="*|text()"/>
          </fo:inline>
      </xsl:when>
      <xsl:when test="@type='section'">

        <fo:block space-after="0.5cm" /> 
        <!-- 5.2 09/08 fjc: heading requested to be outside of code block like in HTML -->
        <xsl:if test="(normalize-space(heading)!='') and heading/@type='code'">
          <fo:block space-after="1pt" text-align="start" font-weight="bold" font-family="{$header-font}" font-size="{$header-font-size}">
            <xsl:value-of select="heading"/>
          </fo:block>
        </xsl:if>
            <!-- 5.2 10/06 fjc: Make the code block text indent .25cm-->
          <fo:table table-layout="fixed" border-width="1" border-style="solid" border-color="{$table-border-color}" background-color="{$code-background-color}" start-indent=".25cm"> 
            <!-- 5.2 08/25 fjc: Make the code block width the @width attribute -->
            <!-- 5.2 08/25 fjc: range test before using the input value -->
            <xsl:choose>
              <xsl:when test="normalize-space(@width)!=''">
                <xsl:variable name="code-width" select="@width"/>
                <xsl:choose>
                  <xsl:when test="contains($code-width, 'px')">
                    <xsl:choose>
                      <xsl:when test="substring-before($code-width, 'px') > $default-code-width">
                        <xsl:attribute name="width"><xsl:value-of select="$default-code-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="width"><xsl:value-of select="$code-width"/></xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:when test="contains($code-width, '%')">
                <!-- 09/01 fjc: bug with % -->                
                    <xsl:attribute name="width"><xsl:value-of select="ceiling(($default-code-width * substring-before($code-width, '%')) div  100 )"/><xsl:text>pt</xsl:text>  </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="$code-width > $default-code-width">
                        <xsl:attribute name="width"><xsl:value-of select="$default-code-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="width"><xsl:value-of select="$code-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise><xsl:attribute name="width"><xsl:value-of select="$default-code-width"/><xsl:text>pt</xsl:text></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <fo:table-column column-width="proportional-column-width(100)" />
            <fo:table-body> 
              <fo:table-row> 
                <fo:table-cell>
                  <fo:block space-after="{$minimum-space-after}" white-space-collapse="false" wrap-option="no-wrap"  font-family="{$code-font}" font-size="{$code-font-size}" >
                     <xsl:apply-templates select="*[not(self::heading)]|text()"/>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row> 
            </fo:table-body> 
          </fo:table> 
          <fo:block space-after="0.5cm"/> 
        </xsl:when>
        <xsl:otherwise>
          <fo:inline font-family="{$monospaced-font}" font-size="{$monospaced-font-size}">
            <xsl:apply-templates select="*|text()"/>
          </fo:inline>
      </xsl:otherwise>
    
    </xsl:choose>
  </xsl:template>
  <!-- =================================
  Sidebar template... basically a code template without border
  ==================================== -->
  <xsl:template match="sidebar">
    <fo:block   space-after="0.5cm"/> 
    <fo:table table-layout="fixed"  start-indent=".5cm" end-indent=".5cm">  
      <!-- 5.2 08/25 fjc: Make the sidebar  block width the @width attribute -->
      <!-- 5.2 08/25 fjc: range test before using the input value -->
      <xsl:choose>
        <xsl:when test="normalize-space(@width)!=''">
          <xsl:variable name="sidebar-width" select="@width"/>
          <xsl:choose>
            <xsl:when test="contains($sidebar-width, 'px')">
              <xsl:choose>
                <xsl:when test="substring-before($sidebar-width, 'px') > $default-sidebar-width">
                  <xsl:attribute name="width"><xsl:value-of select="$default-sidebar-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="width"><xsl:value-of select="$sidebar-width"/></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="contains($sidebar-width, '%')">
              <!-- 09/01 fjc: bug with % -->
              <xsl:attribute name="width"><xsl:value-of select="ceiling(($default-sidebar-width * substring-before($sidebar-width, '%')) div  100 )"/><xsl:text>pt</xsl:text></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$sidebar-width > $default-sidebar-width">
                  <xsl:attribute name="width"><xsl:value-of select="$default-sidebar-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="width"><xsl:value-of select="$sidebar-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise><xsl:attribute name="width"><xsl:value-of select="$default-sidebar-width"/><xsl:text>pt</xsl:text></xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <fo:table-column column-width="proportional-column-width(100)" />
      <fo:table-body> 
        <fo:table-row> 
          <fo:table-cell background-color="{$sidebar-background-color}">
            <fo:block text-align="left" space-after="{$minimum-space-after}" font-family="{$sidebar-font}" font-size="{$sidebar-font-size}">
              <xsl:apply-templates select="*|text()"/>
            </fo:block>
            <fo:block space-after="0.5cm"/>
          </fo:table-cell>
        </fo:table-row> 
      </fo:table-body> 
    </fo:table> 
    <fo:block space-after="0.5cm"/>
  </xsl:template>
  <!-- ============================================
  	All the HTML elements go next
  =============================================== -->
  <!-- ============================================
    Processing for the anchor tag is complex.  First
    of all, if this is a named anchor, we write an empty
    <fo:block> with the appropriate id.  (In the special
    case that the next element is an <h1>, we ignore
    the element altogether and put the id on the <h1>.)
    Next, if this is a regular anchor and the href
    starts with a hash mark (#), we create a link with
    an internal-destination.  Otherwise, we create a
    link with an external destination. 
    =============================================== -->
  <xsl:template match="a">
    <xsl:choose>
      <xsl:when test="@name">
        <xsl:if test="not(name(following-sibling::*[1]) = 'h1')">
          <fo:block line-height="0pt" space-after="0pt" font-size="0pt" id="{@name}"/>
        </xsl:if>
      </xsl:when>
      <!-- 5.2 10/20 fjc  -->
      <xsl:when test="@href">
        <fo:basic-link>
          <xsl:choose>
            <xsl:when test="starts-with(@href, '#')">
              <xsl:attribute name="internal-destination"><xsl:value-of select="substring(@href, 2)"/></xsl:attribute>
              <xsl:attribute name="color"><xsl:value-of select="$internal-link-color"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="starts-with(@href, 'section') and contains(@href, '.html')">
              <xsl:choose>              
                <xsl:when test="contains(@href,'#')">
                  <xsl:attribute name="internal-destination"><xsl:value-of select="substring-after(@href, '#')"/></xsl:attribute>
                  <xsl:attribute name="color"><xsl:value-of select="$internal-link-color"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="internal-destination"><xsl:value-of select="substring-before(@href, '.html')"/></xsl:attribute>
                  <xsl:attribute name="color"><xsl:value-of select="$internal-link-color"/></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="@href = 'resources.html'">
              <xsl:attribute name="internal-destination">resources</xsl:attribute>
              <xsl:attribute name="color"><xsl:value-of select="$internal-link-color"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="@href = 'authors.html'">
              <xsl:attribute name="internal-destination">author-bio</xsl:attribute>
              <xsl:attribute name="color"><xsl:value-of select="$internal-link-color"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="@href = 'index.html'">
              <xsl:attribute name="internal-destination">section1</xsl:attribute>
              <xsl:attribute name="color"><xsl:value-of select="$internal-link-color"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="@href = 'downloads.html'">
              <xsl:attribute name="internal-destination">resources</xsl:attribute>
            </xsl:when>
            <xsl:when test="@href = 'rating.html'">
              <xsl:attribute name="internal-destination">resources</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="external-destination"><xsl:value-of select="@href"/></xsl:attribute>
              <xsl:attribute name="color"><xsl:value-of select="$external-link-color"/></xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="*|text()"/>
        </fo:basic-link>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- ============================================
    For bold elements, we just change the font-weight.
    =============================================== -->
  <xsl:template match="b">
    <fo:inline font-weight="bold">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    A blockquote is indented on both sides.
    =============================================== -->
  <xsl:template match="blockquote">
    <fo:block start-indent="1.5cm" end-indent="1.5cm" space-after="{$default-space-after}">
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    We handle a break element by inserting an 
    empty <fo:block>.
    =============================================== -->
  <xsl:template match="br">
    <fo:block> </fo:block>
  </xsl:template>
  <!-- ============================================
    We're handling <center> as a block element; if
    you use it, it creates a new paragraph that's 
    centered on the page. 
    =============================================== -->
  <xsl:template match="center">
    <fo:block text-align="center">
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    We don't do anything with the <dl> element, we
    just handle the elements it contains.  Notice
    that we're ignoring any text that appears 
    in the <dl> itself; I'm not sure if that's
    the right call.
    =============================================== -->
  <xsl:template match="dl">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <!-- ============================================
    A definition term is rendered in bold.  We 
    specify keep-with-next here, although it doesn't
    always work with FOP.
    =============================================== -->
  <xsl:template match="dt">
    <fo:block font-weight="bold"  keep-with-next="always">
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    We handle each <dd> element as an indented block
    beneath the defined term.  If the following 
    element is another <dd>, that means it's another
    definition for the same term.  In that case, 
    we don't put as much vertical space after the 
    block. 
    =============================================== -->
  <xsl:template match="dd">
    <fo:block start-indent="1cm">
      <xsl:attribute name="space-after"><xsl:choose><xsl:when test="name(following::*[1]) = 'dd'"><xsl:text>3pt</xsl:text></xsl:when><xsl:otherwise><xsl:text>12pt</xsl:text></xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    The HTML <em> element is rendered as normal. 
    =============================================== -->
  <xsl:template match="em">
     <xsl:value-of select="."/>
  </xsl:template>
  <!-- ============================================
   heading - this is a special one.  Major headings are bookmark
   links and the section and heading positions are used for the ID
    ============================================== -->
  <xsl:template match="heading">
  <!-- 5.2 08/04 fjc Get  the section position and add to the heading postion to use in the heading link ID -->
    <!-- 5.2 10/18 fjc: -->
    <xsl:if test="normalize-space(@refname)">
      <fo:inline><xsl:attribute name="id"><xsl:value-of select="@refname"/></xsl:attribute></fo:inline>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@type='major'">
        <xsl:variable name="sectionPos" select="count(ancestor::section/preceding-sibling::section) + 1"/>
        <fo:block font-family="{$major-heading-font}" font-size="{$major-heading-font-size}" space-after.optimum="{$heading-space-after}" space-before.optimum="{$heading-space-before}" keep-with-next="always" text-align="start">
        <xsl:attribute name="id"><xsl:value-of select="$sectionPos"/><xsl:text>-</xsl:text><xsl:value-of select="count(preceding-sibling::heading) + 1"/></xsl:attribute>
          <xsl:value-of select="."/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block font-size="{$heading-font-size}" font-family="{$heading-font}" space-after.optimum="{$heading-space-after}" space-before.optimum="{$heading-space-before}" keep-with-next="always" text-align="start">
          <xsl:value-of select="."/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- ============================================
    Italics.  You can't get much simpler than that.
    =============================================== -->
  <xsl:template match="i">
    <fo:inline font-style="italic">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    For the <img> element, we use the src attribute
    as it comes from HTML.  We also check for any 
    width and height attributes. 
   =============================================== -->
  <xsl:template match="img">
    <fo:inline>
      <fo:external-graphic src="{@src}">
        <xsl:if test="@width">
          <xsl:attribute name="width"><xsl:choose><xsl:when test="contains(@width, 'px')"><xsl:value-of select="@width"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(@width, 'px')"/></xsl:otherwise></xsl:choose></xsl:attribute>
        </xsl:if>
        <xsl:if test="@height">
          <xsl:attribute name="height"><xsl:choose><xsl:when test="contains(@height, 'px')"><xsl:value-of select="@height"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(@height, 'px')"/></xsl:otherwise></xsl:choose></xsl:attribute>
        </xsl:if>
      </fo:external-graphic>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    We handle an ordered list with two complications:
    If the list appears inside another list (either 
    an <ol> or <ul>), we don't put any vertical space
    after it.  The other issue is that we indent the
    list according to how deeply nested the list is. 
    =============================================== -->
  <xsl:template match="ol">
    <fo:list-block provisional-distance-between-starts="1cm" provisional-label-separation="0.5cm">
      <xsl:attribute name="space-after"><xsl:choose><xsl:when test="ancestor::ul or ancestor::ol"><xsl:text>0pt</xsl:text></xsl:when><xsl:otherwise><xsl:text>12pt</xsl:text></xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:attribute name="start-indent"><xsl:variable name="ancestors"><xsl:choose><xsl:when test="count(ancestor::ol) or count(ancestor::ul)"><xsl:value-of select="1 + 
                                    (count(ancestor::ol) + 
                                     count(ancestor::ul)) * 
                                    1.25"/></xsl:when><xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise></xsl:choose></xsl:variable><xsl:value-of select="concat($ancestors, 'cm')"/></xsl:attribute>
      <xsl:apply-templates select="*"/>
    </fo:list-block>
  </xsl:template>
  <!-- ============================================
    When we handle items in an ordered list, we need
    to check if the list has a start attribute.  If
    it does, we change the starting number accordingly.
    Once we've figured out where to start counting,
    we check the type attribute to see what format
    the numbers should use.  
    =============================================== -->
  <xsl:template match="ol/li">
    <fo:list-item>
      <fo:list-item-label end-indent="label-end()">
        <fo:block space-before="{$default-space-before}">
          <xsl:variable name="value-attr">
            <xsl:choose>
              <xsl:when test="../@start">
                <xsl:number value="position() + ../@start - 1"/>
              </xsl:when>
              <xsl:otherwise>
                    <xsl:number value="position()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="../@type='i'">
              <xsl:number value="$value-attr" format="i. "/>
            </xsl:when>
            <xsl:when test="../@type='I'">
              <xsl:number value="$value-attr" format="I. "/>
            </xsl:when>
            <xsl:when test="../@type='a'">
              <xsl:number value="$value-attr" format="a. "/>
            </xsl:when>
            <xsl:when test="../@type='A'">
              <xsl:number value="$value-attr" format="A. "/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number value="$value-attr" format="1. "/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block>
          <xsl:apply-templates select="*|text()"/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>
    <!-- ============================================
    When we handle ordered lists tems in an ordered list,     
    =============================================== 
  <xsl:template match="ol/ol">
    <fo:list-item>
      <fo:list-item-label end-indent="label-end()">
              <fo:block></fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block>
          <fo:list-block provisional-distance-between-starts="1cm" provisional-label-separation="0.5cm">
            <xsl:attribute name="space-after"><xsl:choose><xsl:when test="ancestor::ul or ancestor::ol"><xsl:text>0pt</xsl:text></xsl:when><xsl:otherwise><xsl:text>12pt      </xsl:text></xsl:otherwise></xsl:choose></xsl:attribute>
            <xsl:attribute name="start-indent"><xsl:variable name="ancestors"><xsl:choose><xsl:when test="count(ancestor::ol) or count(ancestor::ul)"><xsl:value-of select="1 + 
                                          (count(ancestor::ol) + 
                                           count(ancestor::ul)) * 
                                          1.25"/></xsl:when><xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise></xsl:choose></xsl:variable><xsl:value-of select="concat($ancestors,       'cm')"/></xsl:attribute>
            <xsl:apply-templates select="*"/>
          </fo:list-block>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>-->
  <!-- ============================================
    Your basic paragraph.
    =============================================== -->
  <xsl:template match="p">
    <!-- 5.0 8/01 tdc:  Added space-after attribute -->
    <fo:block space-after="{$default-space-after}">
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    Preformatted text is rendered in a monospaced
    font.  We also have to set the wrap-option
    and white-space-collapse properties.  
    =============================================== -->
  <xsl:template match="pre">
    <fo:block font-family="{$text-font}" white-space-collapse="false" wrap-option="no-wrap">
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    The <small> element is rendered with a relative
    font size.  That means putting one <small>
    element inside another creates really small 
    text.  
    =============================================== -->
  <xsl:template match="small">
    <fo:inline font-size="80%">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    For strikethrough text, we use the text-decoration
    property.  
    =============================================== -->
  <xsl:template match="strike">
    <fo:inline text-decoration="line-through">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    Strongly emphasized text is simply rendered
    in bold. 
    =============================================== -->
  <xsl:template match="strong">
    <fo:inline font-weight="bold">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    For subscript text, we use the vertical-align
    property and decrease the font size.  
    =============================================== -->
  <xsl:template match="sub">
    <fo:inline vertical-align="sub" font-size="75%">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    Superscript text changes the vertical-align
    property also, and uses a smaller font.
    =============================================== -->
  <xsl:template match="sup">
    <fo:inline vertical-align="super" font-size="75%">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    Tables are a hassle.  The main problem we have
    is converting the td elements into some 
    number of <fo:table-column> elements.  We do 
    this recursively with a named template called build-columns.
    Once we've processed the cols attribute, we 
    invoke all of the templates for the children 
    of this element. 
    =============================================== -->
   <xsl:template name="max_rows"> 
     <!-- 5.2 09/01 fjc:  use th and td -->
    <xsl:for-each select="tr"> 
      <xsl:sort select="count(th)" order="descending"/> 
      <xsl:sort select="count(td)" order="descending"/> 
      <xsl:choose>
        <xsl:when test="th">             
         <xsl:if test="position() = 1"> 
          <xsl:value-of select="count(th)"/> 
         </xsl:if> 
       </xsl:when>
       <xsl:otherwise>
         <xsl:if test="position() = 1"> 
          <xsl:value-of select="count(td)"/> 
         </xsl:if> 
       </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each> 
   </xsl:template> 
  <!-- ============================================
    This template generates an <fo:table-column>
    element for each th of
    the HTML <table> tag.  The template processes
    the first counter, then invokes itself with the 
    rest of the count. 
    =============================================== -->
   <xsl:template name="build-columns"> 
    <xsl:param name="counter"/> 
    <xsl:variable name="max_rows"> 
     <xsl:call-template name="max_rows"/> 
    </xsl:variable> 
    <fo:table-column ><xsl:attribute name="column-width"><xsl:call-template name="process-col-width">
      <xsl:with-param name="colNum" select="$counter"/></xsl:call-template></xsl:attribute>
    </fo:table-column>    
    <xsl:if test="$counter &lt; $max_rows"> 
     <xsl:call-template name="build-columns"> 
      <xsl:with-param name="counter" select="$counter +1"/> 
     </xsl:call-template> 
    </xsl:if> 
   </xsl:template> 

  <xsl:template name="process-col-width">
    <xsl:param name="colNum"/>
    <!-- 5.2 08/24 fjc: set width of column using the TH width attribute -->
    <xsl:choose>
      <xsl:when test="tr/th">           
        <xsl:for-each select="tr/th">
          <xsl:if test="position()=$colNum">
            <xsl:choose>
              <xsl:when test="normalize-space(@width)!=''">
              <!-- when a width attribute is present -->
                <xsl:variable name="col-width" select="@width"/>
                <xsl:choose>
                  <xsl:when test="contains($col-width, '%')">
                    <!-- when the width is a % -->
                    <xsl:text>proportional-column-width(</xsl:text><xsl:value-of select="substring-before($col-width, '%')"/><xsl:text>)</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($col-width, 'px')">
                    <!-- when it is 'px' -->
                    <xsl:value-of select="$col-width"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- it is just a number -->
                    <xsl:value-of select="$col-width"/><xsl:text>px</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <!-- no width is here,  so make all columns proportionally equal - - -  100 X (1/num of th) -->
                <xsl:text>proportional-column-width(</xsl:text><xsl:value-of select="ceiling(100 * (1 div count(ancestor::tr//th)))"/><xsl:text>)</xsl:text>
              </xsl:otherwise>
            </xsl:choose>                  
          </xsl:if>
        </xsl:for-each>
      </xsl:when>

    <!-- 5.2 09/01 fjc: no <th> look for <td> -->
      <xsl:otherwise>
        <xsl:for-each select="tr/td">
          <xsl:if test="position()=$colNum">
            <xsl:choose>
              <xsl:when test="normalize-space(@width)!=''">
              <!-- when a width attribute is present -->
                <xsl:variable name="col-width" select="@width"/>
                <xsl:choose>
                  <xsl:when test="contains($col-width, '%')">
                    <!-- when the width is a % -->
                    <xsl:text>proportional-column-width(</xsl:text><xsl:value-of select="substring-before($col-width, '%')"/><xsl:text>)</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($col-width, 'px')">
                    <!-- when it is 'px' -->
                    <xsl:value-of select="$col-width"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- it is just a number -->
                    <xsl:value-of select="$col-width"/><xsl:text>px</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <!-- no width is here,  so make all columns proportionally equal - - -  100 X (1/num of td) -->
                <xsl:text>proportional-column-width(</xsl:text><xsl:value-of select="ceiling(100 * (1 div count(ancestor::tr//td)))"/><xsl:text>)</xsl:text>
              </xsl:otherwise>
            </xsl:choose>                  
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
   </xsl:choose>
  </xsl:template>


  <xsl:template match="table"> 
    <fo:block space-after="0.5cm"/> 
    <fo:table table-layout="fixed" border="1pt solid #efefef"> 
      <!-- 5.2 08/25 fjc: Make the table width setable with the @width attribute -->
      <!-- 5.2 08/25 fjc: range test before using the input value -->
      <xsl:choose>
        <xsl:when test="normalize-space(@width)!=''">
          <xsl:variable name="table-width" select="@width"/>
          <xsl:choose>
            <xsl:when test="contains($table-width, 'px')">
              <xsl:choose>
                <xsl:when test="substring-before($table-width, 'px') > $default-table-width">
                  <xsl:attribute name="width"><xsl:value-of select="$default-table-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="width"><xsl:value-of select="$table-width"/></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="contains($table-width, '%')">
              <!-- 09/01 fjc: bug with % -->
              <xsl:attribute name="width"><xsl:value-of select="ceiling(($default-table-width * substring-before($table-width, '%')) div  100) "/><xsl:text>pt</xsl:text></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$table-width > $default-table-width">
                  <xsl:attribute name="width"><xsl:value-of select="$default-table-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="width"><xsl:value-of select="$table-width"/><xsl:text>pt</xsl:text></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise><xsl:attribute name="width"><xsl:value-of select="$default-table-width"/><xsl:text>pt</xsl:text></xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="build-columns"> 
       <xsl:with-param name="counter" select="1"/> 
      </xsl:call-template> 
      <fo:table-body> 
        <xsl:apply-templates select="caption"/> 
        <xsl:apply-templates select="tr"/> 
      </fo:table-body> 
    </fo:table> 
    <fo:block space-after="0.5cm"/> 
  </xsl:template> 
   <!-- ============================================
    For an HTML table row, we create an XSL-FO table
    row, then invoke the templates for everything 
    inside it. 
    =============================================== -->
  <xsl:template match="tr"> 
    <fo:table-row> 
     <xsl:apply-templates select="th"/> 
     <xsl:apply-templates select="td"/> 
    </fo:table-row> 
   </xsl:template> 
<!-- ==============================================
For the caption,  FOP doesn't support table-caption.
We add a row then a coulmn of full width to the end of the table. 
================================================= -->
  <xsl:template match="caption">
    <fo:table-row >
      <fo:table-cell padding-start="3pt" padding-end="3pt" padding-before="3pt" padding-after="3pt" background-color="{$table-caption-color}" border-style="solid" border-color="{$table-caption-color}" border-width="1pt">
        <xsl:attribute name="number-columns-spanned"><xsl:value-of select="count(../tr/td)"/></xsl:attribute>
      <fo:block  color="{$background-color}" font-family="{$table-cell-font}" font-size="{$table-cell-font-size}"  >
        <xsl:apply-templates select="*|text()"/>
      </fo:block>
    </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  <!-- ============================================
    For a table cell, we put everything inside a
    <fo:table-cell> element.  We set the padding
    property correctly, then we set the border 
    style.  For the border style, we look to see if
    any of the ancestor elements we care about 
    specified a solid border.  Next, we check for the 
    rowspan, colspan, and align attributes.  Notice 
    that for align, we check this element, then go
    up the ancestor chain until we find the <table>
    element or we find something that specifies the 
    alignment. 
    =============================================== -->
  <xsl:template match="td">
    <fo:table-cell padding-start="3pt" padding-end="3pt" padding-before="3pt" padding-after="3pt">
      <xsl:if test="@colspan">
        <xsl:attribute name="number-columns-spanned"><xsl:value-of select="@colspan"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@rowspan">
        <xsl:attribute name="number-rows-spanned"><xsl:value-of select="@rowspan"/></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="border-bottom-style"><xsl:text>solid</xsl:text></xsl:attribute>
      <xsl:attribute name="border-bottom-color"><xsl:value-of select="$table-border-color"/></xsl:attribute>
      <xsl:attribute name="border-bottom-width"><xsl:text>1pt</xsl:text></xsl:attribute>
      <xsl:variable name="align">
        <xsl:choose>
          <xsl:when test="@align">
            <xsl:choose>
              <xsl:when test="@align='center'">
                <xsl:text>center</xsl:text>
              </xsl:when>
              <xsl:when test="@align='right'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:when test="@align='justify'">
                <xsl:text>justify</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>start</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::tr[@align]">
            <xsl:choose>
              <xsl:when test="ancestor::tr/@align='center'">
                <xsl:text>center</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::tr/@align='right'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::tr/@align='justify'">
                <xsl:text>justify</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>start</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::thead">
            <xsl:text>center</xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::table[@align]">
            <xsl:choose>
              <xsl:when test="ancestor::table/@align='center'">
                <xsl:text>center</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::table/@align='right'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::table/@align='justify'">
                <xsl:text>justify</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>start</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>start</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <fo:block font-family="{$table-cell-font}" font-size="{$table-cell-font-size}"  text-align="{$align}">
        <xsl:apply-templates select="*|text()"/>
      </fo:block>
    </fo:table-cell>
  </xsl:template> 
  <!-- ============================================
    Skip over <thead> & <tfoot>
    ============================================== -->
  <!-- ============================================
    If there's a <th> element, we process it just 
    like a normal <td>, except the font-weight is 
    always bold and the text-align is always center. 
    =============================================== -->
  <xsl:template match="th">
      <fo:table-cell padding-start="3pt" padding-end="3pt" padding-before="3pt" padding-after="3pt" background-color="{$table-th-color}">
      <xsl:if test="@colspan">
        <xsl:attribute name="number-columns-spanned"><xsl:value-of select="@colspan"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@rowspan">
        <xsl:attribute name="number-rows-spanned"><xsl:value-of select="@rowspan"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@border='1' or 
                    ancestor::tr[@border='1'] or
                    ancestor::thead[@border='1'] or
                    ancestor::table[@border='1']">
        <xsl:attribute name="border-style"><xsl:text>solid</xsl:text></xsl:attribute>
        <xsl:attribute name="border-color"><xsl:value-of select="$table-border-color"/></xsl:attribute>
        <xsl:attribute name="border-width"><xsl:text>1pt</xsl:text></xsl:attribute>
      </xsl:if>
      <xsl:variable name="align">
        <xsl:choose>
          <xsl:when test="@align">
            <xsl:choose>
              <xsl:when test="@align='center'">
                <xsl:text>center</xsl:text>
              </xsl:when>
              <xsl:when test="@align='right'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:when test="@align='justify'">
                <xsl:text>justify</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>start</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::tr[@align]">
            <xsl:choose>
              <xsl:when test="ancestor::tr/@align='center'">
                <xsl:text>center</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::tr/@align='right'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::tr/@align='justify'">
                <xsl:text>justify</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>start</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::thead">
            <xsl:text>center</xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::table[@align]">
            <xsl:choose>
              <xsl:when test="ancestor::table/@align='center'">
                <xsl:text>center</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::table/@align='right'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::table/@align='justify'">
                <xsl:text>justify</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>start</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>start</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <fo:block  font-weight="bold" font-family="{$table-cell-font}" font-size="{$table-cell-font-size}"  text-align="{$align}">
        <xsl:apply-templates select="*|text()"/>
      </fo:block>
    </fo:table-cell>
  </xsl:template> 
  <!-- ============================================
    The title of the document is rendered in a large
    bold font, centered on the page.  This is the 
    <title> element in the <head> in <html>.
    =============================================== -->
  <xsl:template match="title">
    <fo:block space-after="12pt" font-family="{$title-font}" font-size="{$title-font-size}">
      <xsl:apply-templates select="*|text()"/>
    </fo:block>
  </xsl:template>
  <!-- ============================================
    Teletype text is rendered in a monospaced font.
    =============================================== -->
  <xsl:template match="tt">
    <fo:inline font-family="{$text-font}">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    For underlined text, we use the text-decoration
    property.
    =============================================== -->
  <xsl:template match="u">
    <fo:inline text-decoration="underline">
      <xsl:apply-templates select="*|text()"/>
    </fo:inline>
  </xsl:template>
  <!-- ============================================
    The unordered list is pretty straightforward; 
    the only complication is calculating the space-
    after and start-indent properties.  If this 
    list is inside another list, we don't put any 
    space after this one, and we calculate the 
    indentation based on the nesting level of this 
    list. 
    =============================================== -->
  <xsl:template match="ul">
    <fo:list-block provisional-distance-between-starts="0.5cm" provisional-label-separation="0.5cm">
      <xsl:attribute name="space-after"><xsl:choose><xsl:when test="ancestor::ul or ancestor::ol"><xsl:text>0pt</xsl:text></xsl:when><xsl:otherwise><xsl:text>8pt</xsl:text></xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:attribute name="start-indent"><xsl:variable name="ancestors"><xsl:choose><xsl:when test="count(ancestor::ol) or count(ancestor::ul)"><xsl:value-of select="1 + 
                                    (count(ancestor::ol) + 
                                     count(ancestor::ul)) * 
                                    1.25"/></xsl:when><xsl:otherwise><xsl:text>1.50</xsl:text></xsl:otherwise></xsl:choose></xsl:variable><xsl:value-of select="concat($ancestors, 'cm')"/></xsl:attribute>
      <xsl:apply-templates select="*"/>
    </fo:list-block>
  </xsl:template>
  <!-- ============================================
    List items inside unordered lists are easy; we
    just have to use the correct Unicode character
    for the bullet.  
    =============================================== -->
  <xsl:template match="ul/li">
    <fo:list-item>
      <fo:list-item-label end-indent="label-end()">
        <fo:block space-before="8pt">&#8226;</fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block>
          <xsl:apply-templates select="*|text()"/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>
  <!-- ============================================
    unordered lists items inside unordered lists are not so easy   
    =============================================== 
  <xsl:template match="ul/ul">
    <fo:list-item>
      <fo:list-item-label end-indent="label-end()">
              <fo:block></fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block>
          <fo:list-block provisional-distance-between-starts="0.5cm" provisional-label-separation="0.5cm">
            <xsl:attribute name="space-after"><xsl:choose><xsl:when test="ancestor::ul or ancestor::ol"><xsl:text>0pt</xsl:text></xsl:when><xsl:otherwise><xsl:text>8pt    </xsl:text>  </xsl:otherwise></xsl:choose></xsl:attribute>
            <xsl:attribute name="start-indent"><xsl:variable name="ancestors"><xsl:choose><xsl:when test="count(ancestor::ol) or count(ancestor::ul)"><xsl:value-of select="1 + 
                                          (count(ancestor::ol) + 
                                           count(ancestor::ul)) * 
                                          1.25"/></xsl:when><xsl:otherwise><xsl:text>1.50</xsl:text></xsl:otherwise></xsl:choose></xsl:variable><xsl:value-of select="concat($ancestors,       'cm')"/></xsl:attribute>
            <xsl:apply-templates select="*"/>
          </fo:list-block>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>  -->
</xsl:stylesheet>
