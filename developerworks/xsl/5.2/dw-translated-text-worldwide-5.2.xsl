<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  <!-- ================= START FILE PATH VARIABLES =================== -->
  <!-- 5.0 6/14 tdc:  Added variables for file paths to enable Authoring package files -->
  <!-- ** -->
  <!-- START IMAGE FILE PATHS ################################## -->
  <!-- >> For Internal dW transforms only; comment out for author pkg: -->
<!--  <xsl:variable name="path-dw-images">/developerworks/i/</xsl:variable>
  <xsl:variable name="path-ibm-i">//www.ibm.com/i/</xsl:variable>
  <xsl:variable name="path-v14-icons">
    <xsl:value-of select="$path-ibm-i"/>v14/icons/</xsl:variable>
  <xsl:variable name="path-v14-t">
    <xsl:value-of select="$path-ibm-i"/>v14/t/</xsl:variable>
  <xsl:variable name="path-v14-rules">
    <xsl:value-of select="$path-ibm-i"/>v14/rules/</xsl:variable> -->
  <!-- 5.1 6/29 JPP/EGD -  Added bullets path to list -->
<!--  <xsl:variable name="path-v14-bullets">
    <xsl:value-of select="$path-ibm-i"/>v14/bullets/</xsl:variable>
  <xsl:variable name="path-v14-buttons">
    <xsl:value-of select="$path-ibm-i"/>v14/buttons/</xsl:variable>-->
  <!-- 5.1 7/22 JPP/EGD -  Added dw views path to list -->
<!--  <xsl:variable name="path-dw-views">http://www.ibm.com/developerworks/views/</xsl:variable>-->
  <!-- 5.1 7/25JPP/EGD -  Added dw includes path to list -->
<!--  <xsl:variable name="path-dw-inc">/developerworks/inc/</xsl:variable>-->
  <!-- 5.0 7/28 tdc:  Added stats, rc-images -->
<!--  <xsl:variable name="path-ibm-stats">//stats.www.ibm.com/</xsl:variable>
  <xsl:variable name="path-ibm-rc-images">
    <xsl:value-of select="$path-ibm-stats"/>rc/images/</xsl:variable>-->
  <!-- 5.2 09/13/05 EGD -  Added bullets, views, inc to the author package transforms -->
  <!-- >> For the author package only; comment out for internal transforms -->
  <xsl:variable name="path-author-i">../i/</xsl:variable>
  <xsl:variable name="path-dw-images"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-ibm-i"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-v14-icons"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-v14-t"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-v14-rules"><xsl:value-of select="$path-author-i" /></xsl:variable>
 <xsl:variable name="path-v14-bullets"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-v14-buttons"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-dw-views">http://www.ibm.com/developerworks/views/</xsl:variable>
  <xsl:variable name="path-dw-inc"><xsl:value-of select="$path-author-i" /></xsl:variable>
  <xsl:variable name="path-ibm-stats">http://stats.www.ibm.com/</xsl:variable>
<xsl:variable name="path-ibm-rc-images"><xsl:value-of select="$path-ibm-stats" />rc/images/</xsl:variable>
  
  <!-- END IMAGE FILE PATHS ################################### -->
  <!-- ** -->
  <!-- START JAVASCRIPT PATHS ################################# -->
  <!-- >> For internal dW transforms only; comment out for author pkg: -->
  <!--<xsl:variable name="path-dw-js">/developerworks/js/</xsl:variable>
  <xsl:variable name="path-dw-email-js">/developerworks/email/</xsl:variable>
  <xsl:variable name="path-ibm-common-js">//www.ibm.com/common/v14/</xsl:variable>-->
  <!-- 5.0 7/28 tdc:  Added stats, data-js,  and survey-esites -->
<!--  <xsl:variable name="path-ibm-common-stats">//www.ibm.com/common/stats/</xsl:variable>
  <xsl:variable name="path-ibm-data-js">//www.ibm.com/data/js/</xsl:variable>
  <xsl:variable name="path-ibm-survey-esites">
    <xsl:value-of select="$path-ibm-data-js"/>survey/esites/</xsl:variable> -->
  <!-- >> For the article author package only; comment out for internal transforms:-->
  <xsl:variable name="path-dw-js">http://www.ibm.com/developerworks/js/</xsl:variable>
  <xsl:variable name="path-dw-email-js">http://www.ibm.com/developerworks/email/</xsl:variable>
  <xsl:variable name="path-ibm-common-js">http://www.ibm.com/common/v14/</xsl:variable>
  <xsl:variable name="path-ibm-common-stats">http://www.ibm.com/common/stats/</xsl:variable>
  <xsl:variable name="path-ibm-data-js">http://www.ibm.com/data/js/</xsl:variable>
  <xsl:variable name="path-ibm-survey-esites"><xsl:value-of select="$path-ibm-data-js" />survey/esites/</xsl:variable>
  
  <!-- END JAVASCRIPT PATHS ################################### -->
  <!-- ** -->
  <!-- START CSS PATHS ####################################### -->
  <!-- >> For internal dW transforms only; comment out for author pkg: -->
  <!--<xsl:variable name="path-ibm-common-css">//www.ibm.com/common/v14/</xsl:variable>-->
  <!-- >> For the author package only; comment out for internal transforms:-->
  <xsl:variable name="path-ibm-common-css">http://www.ibm.com/common/v14/</xsl:variable>
  
  <!-- END CSS PATHS ######################################## -->
  <!-- ================= END FILE PATH VARIABLES =================== -->
  <!-- ================= START GENERAL VARIABLES =================== -->
  <xsl:variable name="main-content">skip to main content</xsl:variable>
  <!-- ================= END GENERAL VARIABLES =================== -->
  <!-- 5.0 6/7.tdc:  Added include for ssi stylesheet -->
  <xsl:include href="dw-ssi-worldwide-5.2.xsl"/>
  <!-- In template match="/" -->
  <xsl:variable name="Attrib-javaworld">Reprinted with permission from <a href="http://www.javaworld.com/?IBMDev">JavaWorld magazine</a>. Copyright IDG.net, an IDG Communications company.  Register for free <a href="http://www.javaworld.com/subscribe?IBMDev">JavaWorld email newsletters</a>.
</xsl:variable>
  <!-- In template name="/" -->
  <!-- 4.0 6/1 tdc:  Updated 3.0 to 4.0 -->
  <!-- <xsl:variable name="stylesheet-id">XSLT stylesheet used to transform this file:  dw-document-html-5.0.xsl</xsl:variable> -->
  <!-- 5.2 8/17/05 TDC:  Updated 5.1 to 5.2 -->
  <xsl:variable name="stylesheet-id">XSLT stylesheet used to transform this file:  dw-document-html-5.2.xsl</xsl:variable>
  <!-- In template name="Abstract" and AbstractExtended -->
  <!-- 4.0 10/04 tdc:  changed stylesheet server from www.ibm.com to www.ibm.com -->
  <!-- 4.0 9/28 tdc:  Removed get-products-text per Sera -->
  <!-- 4.0 6/11 tdc:  Optional paragraph following value of abstract or abstract-extended -->
  <!-- In templates "articleJavaScripts",  "summaryJavaScripts", "dwsJavaScripts", "sidefileJavaScripts" -->
  <!-- 4.0 9/9 tdc:  New variables; china needs to refer to different files from worldwide b/c of font problems -->
  <!-- 4.1 12/14 llk:  added subdirectory variable for processing column icon gifs-->
  <xsl:variable name="browser-detection-js-url">http://www.ibm.com/developerworks/js/dwcss.js</xsl:variable>
  <xsl:variable name="default-css-url">http://www.ibm.com/developerworks/css/r1ss.css</xsl:variable>
  <xsl:variable name="col-icon-subdirectory">/developerworks/i/</xsl:variable>
  <!-- In template name="AuthorBottom" -->
  <xsl:variable name="aboutTheAuthor">About the author</xsl:variable>
  <xsl:variable name="aboutTheAuthors">About the authors</xsl:variable>
  <!-- In template name="AuthorTop" -->
  <!-- 5.0 4/17 tdc:  company-name element replaces company attrib -->
  <xsl:variable name="job-co-errormsg">Error:  Please enter a value for the author element's jobtitle attribute, or the company-name element, or both.</xsl:variable>
  <xsl:variable name="updated">Updated </xsl:variable>
  <xsl:variable name="daychar"/>
  <xsl:variable name="monthchar"/>
  <xsl:variable name="yearchar"/>
  <!-- In template name="BundleComponents" -->
  <!-- 5.2 8/22/05 tdc:  Removed dWS variables:   bundle-components-1-text, bundle-components-2a-text, bundle-components-2b-text, installed-together-text, view-components-text, view-download-text, component-note-text-1, component-note-text-2, components-bundle-text -->
  <!-- 5.0 6/1 tdc:  Added pdf-related variables -->
  <xsl:variable name="pdf-alt-letter">PDF format - letter</xsl:variable>
  <xsl:variable name="pdf-alt-a4">PDF format - A4</xsl:variable>
  <xsl:variable name="pdf-text-letter">PDF - Letter</xsl:variable>
  <xsl:variable name="pdf-text-a4">PDF - A4</xsl:variable>
  <!-- 5.2 8/17/05 tdc:  Added pdf-page and pdf-pages -->
  <xsl:variable name="pdf-page">page</xsl:variable>
  <xsl:variable name="pdf-pages">pages</xsl:variable>
  
  <!-- 5.0.1 7/18 llk:  In template name=Document options -->
<xsl:variable name="document-options-heading">Document options</xsl:variable>
  
  <!-- In template name="Download" -->
    <!-- 5.0.1 9/6 llk: made this heading a translated string -->
  <xsl:variable name="options-discuss">Discuss</xsl:variable>
  <!-- 5.0 7/13 tdc:  made Sample code a variable -->
  <xsl:variable name="sample-code">Sample code</xsl:variable>
  <!-- 4.0 6/1 tdc:  Old "Description" heading now named "Filename"; new filedescription variable added. -->
  <!-- 5.0 7/13 tdc:  Changed download-heading value to Download -->
  <xsl:variable name="download-heading">Download</xsl:variable>
  <!-- 5.0 7/13 tdc:  Added plural heading for multiple downloads -->
  <xsl:variable name="downloads-heading">Downloads</xsl:variable>
  <!-- 4.0 6/6 tdc:  Added also available heading -->
  <xsl:variable name="also-available-heading">Also available</xsl:variable>
  <!-- 4.0 6/4 tdc:  Added download-heading-more -->
  <xsl:variable name="download-heading-more">More downloads</xsl:variable>
  <!-- 4.0 6/7 tdc:  Renamed File name to Name -->
  <xsl:variable name="download-filename-heading">Name</xsl:variable>
  <!-- 4.0 6/7 tdc:  Removed File type heading -->
  <xsl:variable name="download-filedescription-heading">Description</xsl:variable>
  <!-- 4.0 6/7 tdc:  Renamed File size to Size -->
  <xsl:variable name="download-filesize-heading">Size</xsl:variable>
  <xsl:variable name="download-method-heading">Download method</xsl:variable>
  <!-- 4.0 6/7 tdc:  Removed alt text for ftp, http, download director download icons, which were removed themselves -->
  <!-- 4.0 6/7 tdc:  Changed from "Which download method should I choose?" -->
  <xsl:variable name="download-method-link">Information about download methods</xsl:variable>
  <!-- 5.0 4/18 tdc:  Added adobe -->
  <xsl:variable name="download-get-adobe">
    <xsl:text disable-output-escaping="yes"><![CDATA[Get Adobe&#174; Reader&#174;]]></xsl:text>
  </xsl:variable>
  <!-- 4.0 6/16 tdc:  download-path variable not used by worldwide; "en_us" doesn't work if inserted into path.  Kept here so xsl resolves. -->
  <xsl:variable name="download-path">en_us</xsl:variable>
  <!-- 5.2 8/22/05 tdc:  Removed variables for dWS download files: dws-declined-url,  dws-form-action-url,  dws-form-license-title, availability-heading, my-dws-heading, content-notification-url, dws-download-text-1, dws-download-text-2, dws-additional-license-text, dws-download-text-3, zip-text, learn-about-dws-url, browse-catalog-url, purchase-subscription-url, dws-more-about-text, dws-support-heading, help-subscription-url, discussion-forums-url, migration-station-url, product-doc-url -->
  <xsl:variable name="product-doc-url">
    <a href="http://www.elink.ibmlink.ibm.com/public/applications/publications/cgibin/pbi.cgi?CTY=US&amp;&amp;FNC=ICL&amp;">Product documentation</a>
  </xsl:variable>
  <xsl:variable name="redbooks-url">
    <a href="http://www.redbooks.ibm.com/">IBM Redbooks</a>
  </xsl:variable>
  <xsl:variable name="tutorials-training-url">
    <a href="/developerworks/training/">Tutorials and training</a>
  </xsl:variable>
  <xsl:variable name="drivers-downloads-url">
    <a href="http://www-1.ibm.com/support/us/all_download_drivers.html">Support downloads</a>
  </xsl:variable>
  <!-- In template name="Footer" -->
  <!-- 5.2 9/14 jpp:  Removed different footers for brand content areas; all content types use s-footer14 include -->
  <xsl:variable name="footer-inc-default">
    <xsl:copy-of select="$ssi-s-footer14"/>
  </xsl:variable>
  <!-- in template name="generalBreadCrumbTrail"  -->
  <!-- 5.0 5/17 tdc:  Changed developerworks-top-url to http://www.ibm.com/developerworks/ -->
  <xsl:variable name="developerworks-top-url">http://www.ibm.com/developerworks/</xsl:variable>
  <!-- 4.0 9/15 tdc:  Power Architecture's overview page is not a portal page, so had to create "-nonportal" -->
  <xsl:variable name="developerworks-top-url-nonportal">http://www.ibm.com/developerworks/</xsl:variable>
  <xsl:variable name="developerworks-top-heading">developerWorks</xsl:variable>
  <!-- 5.1 08/02/2005 jpp:  Added developerworks-secondary-url to http://www-130.ibm.com/developerworks/ for secondary portal pages-->
  <xsl:variable name="developerworks-secondary-url">http://www-130.ibm.com/developerworks/</xsl:variable>
  <!-- in template name="heading"  -->
  <xsl:variable name="figurechar"/>
  <!-- WW site does not use, but need for xsl continuity -->
  <!-- In template name="IconLinks" -->
  <xsl:variable name="icon-discuss-gif">/developerworks/i/icon-discuss.gif</xsl:variable>
  <xsl:variable name="icon-discuss-alt">Discuss</xsl:variable>
  <xsl:variable name="icon-code-gif">/developerworks/i/icon-code.gif</xsl:variable>
  <xsl:variable name="icon-code-download-alt">Download</xsl:variable>
  <xsl:variable name="icon-code-alt">Code</xsl:variable>
  <xsl:variable name="icon-pdf-gif">/developerworks/i/icon-pdf.gif</xsl:variable>
  <xsl:variable name="Summary">Summary</xsl:variable>
  <xsl:variable name="english-source-heading"/>
  <!-- 5/31 lk - added lang value.. used in email to friend for dbcs -->
  <xsl:variable name="lang"/>
  <!-- In template name="Indicators" -->
  <xsl:variable name="level-text-heading">Level: </xsl:variable>
  <!-- In template name="Masthead" -->
  <!-- 4.0 5/26 tdc:  Changed dw-topmast to s-topmast -->
  <!-- 5.2 9/22/05 tdc:  topmast-inc in the WW translated text has been TEMPORARILY redefined to have a value of the include for s-topmast14. -->
  <!-- 5.2 9/28/05 fjc:  there was a space before the #include that needed to be eliminated -->
<xsl:variable name="topmast-inc">
    <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-topmast14.inc" -->]]></xsl:text>
    </xsl:variable>
  <!-- In template name="LeftNav" -->
  <xsl:variable name="moreThisSeries">More in this series</xsl:variable>
  <xsl:variable name="left-nav-in-this-article">In this article:</xsl:variable>
  <!-- 5.0 05/09 tdc:  Added left-nav-in-this-tutorial -->
  <xsl:variable name="left-nav-in-this-tutorial">In this tutorial:</xsl:variable>
    <!-- 5.0.1 9/6 llk:  lefthand navs need to be local site specific -->
  <!-- In template name="LeftNavSummary" -->
    <xsl:variable name="left-nav-top"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-nav14-top.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-rlinks"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-nav14-rlinks.inc" -->]]></xsl:text></xsl:variable>
  <!-- 5.0.1 9/6 llk:  lefthand navs need to be local site specific -->
  <!-- In template name="LeftNavSummaryInc" -->
  <!-- 5.2 09/28 fjc:  Event left nav needed for all -->
    <xsl:variable name="left-nav-autonomic"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-ac-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-autonomic"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-ac-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-db2"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-dm-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-db2"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-dm-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-eserver"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-es-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-eserver"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-es-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-grid"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-gr-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-grid"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-gr-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-ibm"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-nav14.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-java"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-j-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-java"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-j-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-linux"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-l-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-linux"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-l-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-lotus"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-ls-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-lotus"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-ls-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-opensource"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-os-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-opensource"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-os-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-power"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-pa-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-power"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-pa-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-rational"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-r-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-rational"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-r-nav14-events.inc" -->]]></xsl:text></xsl:variable>
<!--  5.2 10/03 fjc: add training inc-->
    <xsl:variable name="left-nav-training-rational"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-r-nav14-training.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-security"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-nav14.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-tivoli"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-tv-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-tivoli"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-tv-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-web"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-wa-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-web"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-wa-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-webservices-summary-spec"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-ws-nav14-standards.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-webservices"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-ws-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-webservices"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-ws-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-websphere"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-w-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-websphere"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-w-nav14-events.inc" -->]]></xsl:text></xsl:variable>
<!-- 5.2 10/03 fjc: add training -->
    <xsl:variable name="left-nav-training-websphere"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-w-nav14-training.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-wireless"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-wi-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-wireless"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-wi-nav14-events.inc" -->]]></xsl:text></xsl:variable>
<!-- 5.2 8/24/05 tdc:  Added workplace.  tdc changed "t-" to "d-" on 8/25/05 per EGD -->
    <xsl:variable name="left-nav-workplace"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-wp-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-workplace"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-wp-nav14-events.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-xml"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-x-nav14-library.inc" -->]]></xsl:text></xsl:variable>
    <xsl:variable name="left-nav-events-xml"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/t-x-nav14-events.inc" -->]]></xsl:text></xsl:variable>

  <!-- In template name="META" -->
  <xsl:variable name="owner-meta-url"> https://www-136.ibm.com/developerworks/secure/feedback.jsp?domain=</xsl:variable>
  <xsl:variable name="dclanguage-content">en-us</xsl:variable>
  <xsl:variable name="ibmcountry-content">zz</xsl:variable>
  <!-- In template name="MonthName" -->
  <xsl:variable name="month-1-text">Jan</xsl:variable>
  <xsl:variable name="month-2-text">Feb</xsl:variable>
  <xsl:variable name="month-3-text">Mar</xsl:variable>
  <xsl:variable name="month-4-text">Apr</xsl:variable>
  <xsl:variable name="month-5-text">May</xsl:variable>
  <xsl:variable name="month-6-text">Jun</xsl:variable>
  <xsl:variable name="month-7-text">Jul</xsl:variable>
  <xsl:variable name="month-8-text">Aug</xsl:variable>
  <xsl:variable name="month-9-text">Sep</xsl:variable>
  <xsl:variable name="month-10-text">Oct</xsl:variable>
  <xsl:variable name="month-11-text">Nov</xsl:variable>
  <xsl:variable name="month-12-text">Dec</xsl:variable>
  <!-- 5.0 5/11 tdc:  Added variables for new PageNavigator template -->
  <!-- In template name="PageNavigator" -->
  <xsl:variable name="page">Page</xsl:variable>
  <xsl:variable name="of">of</xsl:variable>
  <!-- 5.0.1 llk: added for chinese/taiwan page ordering -->
  <xsl:variable name="pageofendtext"></xsl:variable>	
  <!-- 4.0 6/6 tdc:  template name is now RelatedContents, not articleRelatedContents -->
  <!-- In template name="RelatedContents" -->
  <xsl:variable name="related-content-heading">Related content:</xsl:variable>
    <!-- In template name RelatedLinks -->
  <!-- 5.0.1 9/6 llk: added because headings need to be translated -->
  <!-- 5.2 9/22/05 tdc:  Removed colon after Related links -->
  <xsl:variable name="left-nav-related-links-heading">Related links</xsl:variable>
  <xsl:variable name="left-nav-related-links-techlib">technical library</xsl:variable>
  <!-- In template name="Subscriptions" -->
  <xsl:variable name="subscriptions-heading">Subscriptions:</xsl:variable>
  <!-- 4.1 12/08 tdc:  Removed dws link text/url per SL/KB -->
  <xsl:variable name="dw-newsletter-text">dW newsletters</xsl:variable>
  <xsl:variable name="dw-newsletter-url">http://www.ibm.com/developerworks/newsletter/</xsl:variable>
  <!-- 4.0 6/7 tdc:  Added variables for Rational Edge subscription (design request #37) -->
  <xsl:variable name="rational-edge-text">The Rational Edge</xsl:variable>
   <!-- 9/28/05 egd:  Switched URL from subscribe to main Edge page -->
  <xsl:variable name="rational-edge-url">/developerworks/rational/rationaledge/</xsl:variable>
  <!-- In template name="Resources" and "TableofContents" -->
  <!-- 4.0 5/19 tdc:  Renamed resourcelist to resource-list -->
  <xsl:variable name="resource-list-heading">Resources</xsl:variable>
  <!-- In template name="resourcelist/ul" -->
  <!-- 5.0 5/13 tdc:  Changed "article" to "content"; removed the text referring to Discuss link at top of page. -->
  <!-- 4.0 5/19 tdc:  Renamed resourcelist to resource-list -->
  <xsl:variable name="resource-list-forum-text">
  <!-- 9/07/05 tdc:  Replaced call to forumwindow with plain link; changed link wording -->
    <xsl:text disable-output-escaping="yes"><![CDATA[<a href="]]></xsl:text>
                    <xsl:value-of select="/dw-document//forum-url/@url"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[">Participate in the discussion forum</a>.]]></xsl:text></xsl:variable>
  <!-- In template "resources" -->
  <xsl:variable name="resources-learn">Learn</xsl:variable>
  <xsl:variable name="resources-get">Get products and technologies</xsl:variable>
  <xsl:variable name="resources-discuss">Discuss</xsl:variable>
  <!-- In template name="SkillLevel" -->
  <xsl:variable name="level-1-text">Introductory</xsl:variable>
  <xsl:variable name="level-2-text">Introductory</xsl:variable>
  <xsl:variable name="level-3-text">Intermediate</xsl:variable>
  <xsl:variable name="level-4-text">Advanced</xsl:variable>
  <xsl:variable name="level-5-text">Advanced</xsl:variable>
  <!-- In template name="TableOfContents" -->
  <xsl:variable name="tableofcontents-heading">Contents:</xsl:variable>
  <xsl:variable name="ratethisarticle-heading">Rate this page</xsl:variable>
  <!-- 5.0 05/09 tdc:  Added ratethistutorial-heading -->
  <xsl:variable name="ratethistutorial-heading">Rate this tutorial</xsl:variable>
  <!-- In file "dw-ratingsform-4.1.xsl  -->
  <xsl:variable name="domino-ratings-post-url">http://www.alphaworks.ibm.com/developerworks/ratings.nsf/RateArticle?CreateDocument</xsl:variable>
  <xsl:variable name="method">POST</xsl:variable>
  <xsl:variable name="ratings-thankyou-url">http://www.ibm.com/developerworks/thankyou/feedback-thankyou.html</xsl:variable>
  <!-- 4.0 6/30 tdc:  Changed wording based on notes from Leah, Laura Cap., MOC -->
  <!-- 5.0 4/13 tdc:  Added ratings-intro-text -->
  <xsl:variable name="ratings-intro-text">Please take a moment to complete this form to help us better serve you.</xsl:variable>
  <xsl:variable name="ratings-question-text">This content was helpful to me:</xsl:variable>
  <xsl:variable name="ratings-value5-text">Strongly agree (5)</xsl:variable>
  <xsl:variable name="ratings-value4-text">Agree (4)</xsl:variable>
  <xsl:variable name="ratings-value3-text">Neutral (3)</xsl:variable>
  <xsl:variable name="ratings-value2-text">Disagree (2)</xsl:variable>
  <xsl:variable name="ratings-value1-text">Strongly disagree (1)</xsl:variable>
  <xsl:variable name="ratings-value5-width">21%</xsl:variable>
  <xsl:variable name="ratings-value4-width">17%</xsl:variable>
  <xsl:variable name="ratings-value3-width">24%</xsl:variable>
  <xsl:variable name="ratings-value2-width">17%</xsl:variable>
  <xsl:variable name="ratings-value1-width">21%</xsl:variable>
  <xsl:variable name="comments-noforum-text">Comments?</xsl:variable>
  <xsl:variable name="comments-withforum-text">Send us your comments or click Discuss to share your comments with others.</xsl:variable>
  <xsl:variable name="submit-feedback-text">Submit feedback</xsl:variable>
  <!-- in template name="ContentAreaName" -->
  <xsl:variable name="contentarea-ui-name-au">Autonomic computing</xsl:variable>
  <xsl:variable name="contentarea-ui-name-gr">Grid computing</xsl:variable>
  <xsl:variable name="contentarea-ui-name-j">Java technology</xsl:variable>
  <xsl:variable name="contentarea-ui-name-l">Linux</xsl:variable>
  <!-- 5.2 9/28 llk:  changed "Open source projects" to "Open source" -->
  <xsl:variable name="contentarea-ui-name-os">Open source</xsl:variable>
  <!-- 4.0 5/27 tdc:  Updated name from Web services to SOA and Web services -->
  <xsl:variable name="contentarea-ui-name-ws">SOA and Web services</xsl:variable>
  <xsl:variable name="contentarea-ui-name-x">XML</xsl:variable>
  <xsl:variable name="contentarea-ui-name-co">Components</xsl:variable>
  <xsl:variable name="contentarea-ui-name-s">Security</xsl:variable>
  <xsl:variable name="contentarea-ui-name-wa">Web architecture</xsl:variable>
  <xsl:variable name="contentarea-ui-name-wi">Wireless</xsl:variable>
  <!-- 4.0 6/22 tdc:  Changed Scenarios to Sample IT projects per note from Jack P. -->
  <xsl:variable name="contentarea-ui-name-i">Sample IT projects</xsl:variable>
  <xsl:variable name="contentarea-ui-name-db2">DB2</xsl:variable>
  <xsl:variable name="contentarea-ui-name-es">eServer</xsl:variable>
  <xsl:variable name="contentarea-ui-name-lo">Lotus</xsl:variable>
  <xsl:variable name="contentarea-ui-name-r">Rational</xsl:variable>
  <xsl:variable name="contentarea-ui-name-tiv">Tivoli</xsl:variable>
  <xsl:variable name="contentarea-ui-name-web">WebSphere</xsl:variable>
  <!-- 5.2 8/24/05 tdc:  Added workplace -->
  <xsl:variable name="contentarea-ui-name-wp">Workplace</xsl:variable>
  <!-- 5.2 8/22/05 tdc:  Removed contentarea-ui-name-sub for dWS -->
  <!-- 4.0 9/15 tdc:  Added power -->
  <xsl:variable name="contentarea-ui-name-pa">Power Architecture technology</xsl:variable>
  <!-- in template name="TechLibView" -->
  <xsl:variable name="techlibview-db2">http://www.ibm.com/developerworks/views/db2/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-es">http://www.ibm.com/developerworks/views/eserver/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-i">http://www.ibm.com/developerworks/views/ibm/articles.jsp</xsl:variable>
  <xsl:variable name="techlibview-lo">http://www.ibm.com/developerworks/views/lotus/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-r">http://www.ibm.com/developerworks/views/rational/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-tiv">http://www.ibm.com/developerworks/views/tivoli/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-web">http://www.ibm.com/developerworks/views/websphere/library.jsp</xsl:variable>
  <!-- IBM Workplace will go here -->
  <xsl:variable name="techlibview-au">http://www.ibm.com/developerworks/views/autonomic/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-gr">http://www.ibm.com/developerworks/views/grid/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-j">http://www.ibm.com/developerworks/views/java/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-l">http://www.ibm.com/developerworks/views/linux/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-os">http://www.ibm.com/developerworks/views/opensource/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-pa">http://www.ibm.com/developerworks/views/power/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-ws">http://www.ibm.com/developerworks/views/webservices/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-wa">http://www.ibm.com/developerworks/views/web/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-wi">http://www.ibm.com/developerworks/views/wireless/library.jsp</xsl:variable>
  <!-- 5.2 8/24/05 tdc:  Added techlibview-wp -->
  <xsl:variable name="techlibview-wp">http://www.ibm.com/developerworks/views/workplace/library.jsp</xsl:variable>
  <xsl:variable name="techlibview-x">http://www.ibm.com/developerworks/views/xml/library.jsp</xsl:variable>
  <!-- 5.1 08/02/2005 jpp:  Added variables for product landing page URLs for the ProductsLandingURL template -->
  <!-- In template name="ProductsLandingURL" -->
  <xsl:variable name="products-landing-db2">
    <xsl:value-of select="$developerworks-top-url"/>db2/products/</xsl:variable>
  <xsl:variable name="products-landing-es">
    <xsl:value-of select="$developerworks-top-url"/>eserver/products/</xsl:variable>
  <xsl:variable name="products-landing-lo">
    <xsl:value-of select="$developerworks-top-url"/>lotus/products/</xsl:variable>
  <xsl:variable name="products-landing-r">
    <xsl:value-of select="$developerworks-secondary-url"/>rational/products/</xsl:variable>
  <xsl:variable name="products-landing-tiv">
    <xsl:value-of select="$developerworks-top-url"/>tivoli/products/</xsl:variable>
  <xsl:variable name="products-landing-web">
    <xsl:value-of select="$developerworks-top-url"/>apps/transform.wss?URL=/wsdd/products/index.xml&amp;xslURL=/wsdd/xsl/document.xsl&amp;site=wsdd&amp;format=two-column</xsl:variable>
  <!-- 5.2 09/27/2005 jpp: Added variable for Workplace products page --> 
  <xsl:variable name="products-landing-wp">
    <xsl:value-of select="$developerworks-top-url"/>workplace/products/</xsl:variable>
  <!-- SUMMARY DOC SECTION HEADINGS -->
  <xsl:variable name="summary-inThisTutorial">In this tutorial</xsl:variable>
  <xsl:variable name="summary-inThisLongdoc">In this article</xsl:variable>
  <xsl:variable name="summary-inThisPresentation">In this presentation</xsl:variable>
  <xsl:variable name="summary-inThisSample">In this sample</xsl:variable>
  <xsl:variable name="summary-inThisCourse">In this course</xsl:variable>
  <xsl:variable name="summary-objectives">Objectives</xsl:variable>
  <xsl:variable name="summary-prerequisities">Prerequisites</xsl:variable>
  <!-- 5.2 9/22/05 tdc:  Changed R in "Requirements" to lower case -->
  <xsl:variable name="summary-systemRequirements">System requirements</xsl:variable>
  <xsl:variable name="summary-duration">Duration</xsl:variable>
  <xsl:variable name="summary-audience">Audience</xsl:variable>
  <xsl:variable name="summary-languages">Languages</xsl:variable>
  <xsl:variable name="summary-formats">Formats</xsl:variable>
  <xsl:variable name="summary-minor-heading">Summary minor heading</xsl:variable>
  <xsl:variable name="summary-getTheArticle">Get the article</xsl:variable>
  <!-- 5.0 6/2 fjc add whitepaper -->
  <xsl:variable name="summary-getTheWhitepaper">Get the whitepaper</xsl:variable>
  <xsl:variable name="summary-getThePresentation">Get the presentation</xsl:variable>
  <xsl:variable name="summary-getTheDemo">Get the demo</xsl:variable>
  <xsl:variable name="summary-getTheSample">Get the sample</xsl:variable>
  <xsl:variable name="summary-rateThisContent">Rate this content</xsl:variable>
  <xsl:variable name="summary-getTheSpecification">Get the specification</xsl:variable>
  <xsl:variable name="summary-contributors">Contributors: </xsl:variable>
  <xsl:variable name="summary-aboutTheInstructor">About the instructor</xsl:variable>
  <xsl:variable name="summary-aboutTheInstructors">About the instructors</xsl:variable>
  <xsl:variable name="summary-viewSchedules">View schedules and enroll</xsl:variable>
  <xsl:variable name="summary-viewSchedule">View schedule and enroll</xsl:variable>
  <xsl:variable name="summary-aboutThisCourse">About this course</xsl:variable>
  <xsl:variable name="summary-webBasedTraining">Web-based training</xsl:variable>
  <xsl:variable name="summary-instructorLedTraining">Instructor led training</xsl:variable>
  <xsl:variable name="summary-classroomTraining">Classroom training</xsl:variable>
  <xsl:variable name="summary-courseType">Course Type:</xsl:variable>
  <xsl:variable name="summary-courseNumber">Course Number:</xsl:variable>
  <!-- 5.0 5/17 tdc:  Added back summary-scheduleCourse -->
  <xsl:variable name="summary-scheduleCourse">Course</xsl:variable>
  <!-- 5.0 5/17 tdc:  Added back summary-scheduleCenter -->
  <xsl:variable name="summary-scheduleCenter">Education Center</xsl:variable>
  <!-- 5.0 5/17 tdc:  Added back summary-classroomCourse -->
  <xsl:variable name="summary-classroomCourse">Classroom course</xsl:variable>
  <!-- 5.0 5/17 tdc:  Added back summary-onlineInstructorLedCourse -->
  <xsl:variable name="summary-onlineInstructorLedCourse">On-line instructor led course</xsl:variable>
  <!-- 5.0 5/17 tdc:  Added back summary-webBasedCourse -->
  <xsl:variable name="summary-webBasedCourse">Web based course</xsl:variable>
  <!-- 5.0 5/25 fjc:  Added websphere enrollment string-->
  <xsl:variable name="summary-enrollmentWebsphere1">For private offerings of this course, please contact us at </xsl:variable>
  <!-- 5.2 09/28 fjc: Added a period to the sentence  -->
  <xsl:variable name="summary-enrollmentWebsphere2">. IBM internal students should enroll via Global Campus.</xsl:variable>
  <!-- 5.0 6/2 fjc add plural-->
  <xsl:variable name="summary-plural">s</xsl:variable>
  <!-- SUMMARY DOC SECTION HEADINGS END -->
  <xsl:variable name="summary-register">Register now or sign in using your IBM ID and password.</xsl:variable>
  <xsl:variable name="summary-websphereTraining">IBM WebSphere Training and Technical Enablement</xsl:variable>
    	<!-- 5.0.1 9/19 llk need this to be local site specific in the summary pagse -->
  <xsl:variable name="backlink_include"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-backlink.inc" -->]]></xsl:text></xsl:variable>
	<!-- 5.0.1 9/19 llk this needs to be local site specific include -->
	<xsl:variable name="rnav-ratings-link-include"><xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-rating-content.inc" -->]]></xsl:text></xsl:variable>

  <!-- 5.1 7/22 jpp/egd:  BEGIN Added variables for landing-product work -->
  <!-- 5.2 9/14 jpp Added text to be prepended to landing-product titles -->
  <!-- in template name="FullTitle"  -->
  <xsl:variable name="ibm-developerworks-text">IBM developerWorks : </xsl:variable>
  <!-- in template name="TopStory"  -->
  <xsl:variable name="more-link-text">More</xsl:variable>
  <!-- in template name="ProductTechnicalLibrary"  -->
  <xsl:variable name="product-technical-library-heading">Search technical library</xsl:variable>
  <xsl:variable name="technical-library-search-text">Enter keyword or leave blank to view entire technical library:</xsl:variable>
  <!-- in template name="ProductInformation"  -->
  <xsl:variable name="product-information-heading">Product information</xsl:variable>
  <xsl:variable name="product-related-products">Related products:</xsl:variable>
  <!-- in template name="ProductDownloads"  -->
  <xsl:variable name="product-downloads-heading">Downloads, CDs, DVDs</xsl:variable>
  <!-- in template name="ProductLearningResources"  -->
  <xsl:variable name="product-learning-resources-heading">Learning resources</xsl:variable>
  <!-- in template name="ProductSupport"  -->
  <xsl:variable name="product-support-heading">Support</xsl:variable>
  <!-- in template name="ProductCommunity"  -->
  <xsl:variable name="product-community-heading">Community</xsl:variable>
  <!-- in template name="MoreProductInformation"  -->
  <xsl:variable name="more-product-information-heading">More product information</xsl:variable>
  <!-- in template name="Spotlight"  -->
  <xsl:variable name="spotlight-heading">Spotlight</xsl:variable>
  <!-- in template name="LatestContent"  -->
  <xsl:variable name="latest-content-heading">Latest content</xsl:variable>
  <xsl:variable name="more-content-link-text">More content</xsl:variable>
  <!-- in template name="EditorsPicks"  -->
  <xsl:variable name="editors-picks-heading">Editor's picks</xsl:variable>
  <!-- in template name="BreadCrumbTitle"  -->
  <xsl:variable name="products-heading">Products</xsl:variable>
  <!-- END 5.1 7/22 jpp/egd:  Added variables for landing-product work -->
  <!-- PDF document stylesheet strings -->
  <!-- 5.0 7/31 tdc:  Added for tutorial PDFs (from Frank's xsl) -->
  <xsl:variable name="pdfTableOfContents">Table of Contents</xsl:variable>
  <xsl:variable name="pdfSection">Section</xsl:variable>
  <xsl:variable name="pdfSkillLevel">Skill Level</xsl:variable>
  <xsl:variable name="pdfCopyrightNotice">© Copyright IBM Corporation 1994, 2005. All rights reserved.</xsl:variable>
  <xsl:variable name="pdfTrademarks">Trademarks</xsl:variable>
  <!-- 5.2 8/31 fjc:  Added for tutorial PDFs -->
  <xsl:variable name="pdfResource-list-forum-text">Participate in the discussion forum for this content.</xsl:variable>
    <!-- 5.2 09/20 fjc:  subscribe to podcast -->
	<xsl:variable name="download-subscribe-podcasts"><xsl:text disable-output-escaping="yes">Subscribe to developerWorks podcasts</xsl:text></xsl:variable>
  <!-- 5.2 09/20 fjc: in this podcast-->
  <xsl:variable name="summary-inThisPodcast">In this podcast</xsl:variable>
   <!-- 5.2 09/20 fjc: about the podcast contributors -->
  <xsl:variable name="summary-podcastCredits">Podcast credits</xsl:variable>
   <!-- 5.2 09/20 fjc:  for podcast -->
  <xsl:variable name="summary-podcast-not-familiar">Not familiar with podcasting? <a href=" /developerworks/podcast/about.html">Learn more.</a></xsl:variable>
  <!-- 5.2 09/20 fjc:  for podcast -->
  <!-- 5.2 10/13 fjc:  change text -->
  <xsl:variable name="summary-podcast-system-requirements"><xsl:text disable-output-escaping="yes"><![CDATA[To automatically download and synchronize files to play on your computer or your portable audio player (for example, iPod), you'll need to use a podcast client. <a href="http://www.ipodder.org/" target="_blank">iPodder</a> is a free, open-source client that is available for Mac&#174; OS X, Windows&#174;, and Linux. You can also use <a href="http://www.apple.com/itunes/" target="_blank">iTunes</a>, <a href="http://www.feeddemon.com/" target="_blank">FeedDemon</a>, or any number of alternatives available on the Web.]]></xsl:text></xsl:variable>
  <!-- 5.2 10/17 fjc: get the podcast-->
  <xsl:variable name="summary-getThePodcast">Get the podcast</xsl:variable>

</xsl:stylesheet>
