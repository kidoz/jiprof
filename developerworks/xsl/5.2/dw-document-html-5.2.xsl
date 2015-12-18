<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:redirect="http://xml.apache.org/xalan/redirect" extension-element-prefixes="redirect" exclude-result-prefixes="xsl fo">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <xsl:key name="column-icons" match="column-info" use="@col-name"/>
  <!-- Start:  Subordinate stylesheets -->
  <!-- 5.2 9/13/05 tdc:  Added brazil and russia include files (commented out) -->
  <!-- Each local site includes only their own translated text file here.  -->
 <xsl:include href="dw-translated-text-worldwide-5.2.xsl"/>
  <!--<xsl:include href="dw-translated-text-brazil-5.2.xsl"/>-->
<!--<xsl:include href="dw-translated-text-china-5.2.xsl"/>-->
<!--<xsl:include href="dw-translated-text-korea-5.2.xsl"/>-->
<!--<xsl:include href="dw-translated-text-taiwan-5.2.xsl"/>-->
<!-- <xsl:include href="dw-translated-text-russia-5.2.xsl"/> -->
  <!-- General includes for all doc types:  -->
  <xsl:include href="dw-entities-5.2.xsl"/>
  <xsl:include href="dw-javascripts-5.2.xsl"/>
  <xsl:include href="dw-meta-5.2.xsl"/>
  <xsl:include href="dw-ratingsform-5.2.xsl"/>
  <xsl:include href="xslt-utilities-5.2.xsl"/>
  <xsl:include href="dw-common-5.2.xsl"/>
  <!-- Specific includes for each doc type:  -->
  <xsl:include href="dw-article-5.2.xsl"/>
      <!-- 5.1 5/26 tdc:  Added dw-landing-product-5.1 -->
  <xsl:include href="dw-landing-product-5.2.xsl"/>
  <xsl:include href="dw-sidefile-5.2.xsl"/>
  <xsl:include href="dw-summary-demo-5.2.xsl"/>
  <xsl:include href="dw-summary-longdoc-5.2.xsl"/>
  <!-- 5.2 09/20 fjc: add summary-podcast -->
  <xsl:include href="dw-summary-podcast-5.2.xsl"/>
  <xsl:include href="dw-summary-presentation-5.2.xsl"/>
  <xsl:include href="dw-summary-sample-5.2.xsl"/>
  <xsl:include href="dw-summary-spec-5.2.xsl"/>
  <xsl:include href="dw-summary-training-5.2.xsl"/>
  <xsl:include href="dw-summary-tutorial-5.2.xsl"/>  
  <xsl:include href="dw-tutorial-5.2.xsl"/>
  <!-- End:  Subordinate stylesheets -->
  <!-- START COMMON CODE FOR ALL CONTENT TYPES -->
  <xsl:template match="/">
    <!-- 5.0 05/10 tdc:  Tutorial pages are build completely within dw-tutorial-x.x stylesheet -->
    <xsl:choose>
      <xsl:when test="not(dw-document/dw-tutorial)">
        <!-- 5.0 05/09 tdc:  Created and refer to FrontMatter template -->
        <xsl:call-template name="FrontMatter"/>
        <xsl:apply-templates select="dw-document/dw-article |
        												dw-document/dw-landing-product | 
			                                             dw-document/dw-sidefile |
                                                         dw-document/dw-summary-demo |
                                                         dw-document/dw-summary-long | 
                                                         dw-document/dw-summary-podcast |
                                                         dw-document/dw-summary-presentation | 
                                                         dw-document/dw-summary-sample | 
                                                         dw-document/dw-summary-spec |
                                                         dw-document/dw-summary-training |
                                                         dw-document/dw-summary-tutorial"/>
        <!-- 5.0 05/09 tdc:  Created and refer to EndMatter template -->
        <xsl:call-template name="EndMatter"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="dw-document/dw-tutorial"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
