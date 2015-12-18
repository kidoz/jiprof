<?xml version="1.0" encoding="UTF-8"?>
<!-- THIS STYLESHEET CONTAINS XSL VARIABLES, THE CONTENT OF WHICH
        DUPLICATES SSI FILES USED BY ARTICLES AND TUTORIALS.  IF THE
        CORRESPONDING SSI FILES ARE UPDATED, THESE VARIABLE DEFINITIONS
        MUST BE UPDATED AND AN ANNOUNCEMENT MADE TO ALL WHO MAY HAVE
        THIS FILE ON THEIR LOCAL MACHINES (EDITORS, AUTHORS, CMA TEAM AT 
        A MINIMUM).
-->
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  
<!-- 5.2 9/14 jpp: Removed d-dm-footer14.inc -->
<!-- d-dm-nav14-library.inc  NOT NEEDED -->
<!-- 5.2 9/14 jpp: Removed d-ds-footer14.inc -->
<!-- 5.2 9/14 jpp: Removed d-es-footer14.inc -->
<!-- 5.2 9/14 jpp: Removed d-ls-footer14.inc -->
<!-- 5.2 9/14 jpp: Removed d-r-footer14.inc -->
<!-- 5.2 9/14 jpp: Removed d-tv-footer14.inc -->
<!-- 5.2 9/14 jpp: Removed d-w-footer14.inc -->

<!-- s-backlink-rule.inc -->
<xsl:variable name="ssi-s-backlink-rule">
<!-- Spacer -->
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<!-- Separator rule -->
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
<td><img alt="" height="1" src="{$path-v14-rules}blue_rule.gif" width="100%"/></td>
</tr>
</table>
<!-- BACK_LINK -->
<table align="right" cellpadding="0" cellspacing="0" class="no-print">
<tr align="right">
<td>
<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td valign="middle">
<img alt="" border="0" height="16" src="{$path-v14-icons}u_bold.gif" width="16"/>
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
</td>
<td align="right" valign="top">
<a class="fbox" href="#main"><b>Back to top</b></a>
</td>
</tr>
</table>
</td>
</tr>
</table>
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<!-- BACK_LINK_END -->
</xsl:variable>

<!-- s-backlink.inc -->
<xsl:variable name="ssi-s-backlink">
<!-- BACK_LINK -->
<table align="right" cellpadding="0" cellspacing="0">
<tr align="right">
<td>
<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td valign="middle">
<img alt="" border="0" height="16" src="{$path-v14-icons}u_bold.gif" width="16"/>
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
</td>
<td align="right" valign="top">
<a class="fbox" href="#main"><b>Back to top</b></a>
</td>
</tr>
</table>
</td>
</tr>
</table>
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<!-- BACK_LINK_END -->
</xsl:variable>

<!-- s-doc-options-email.inc" -->
<xsl:variable name="ssi-s-doc-options-email">
<!-- 5.0 7/28 tdc:  document.write statement now uses variable for paths -->
<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" type="text/javascript">
<!--
document.write('<tr valign="top"><td width="8"><img src="]]></xsl:text><xsl:value-of select="$path-ibm-i"/><xsl:text disable-output-escaping="yes"><![CDATA[c.gif" width="8" height="1" alt=""/></td><td width="16"><img src="]]></xsl:text><xsl:value-of select="$path-v14-icons"/><xsl:text disable-output-escaping="yes"><![CDATA[em.gif" height="16" width="16" vspace="3" alt="Email this page" /></td><td width="122"><p><a class="smallplainlink" href="javascript:void newWindow()"><b>E-mail this page</b></a></p></td></tr>');
//-->
</script>]]></xsl:text>
<noscript><tr valign="top">
<td width="8"><img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/></td>
<td width="16"><img src="{$path-ibm-i}c.gif" height="16" width="16" alt="" /></td>
<td width="122" class="small"><p><span class="ast">Document options requiring JavaScript are not displayed</span></p></td>
</tr>
</noscript>
</xsl:variable>

<xsl:variable name="ssi-s-doc-options-printcss">
<!-- 5.0 7/28 tdc:  document.write statement now uses variable for paths -->
<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" type="text/javascript">
<!--
document.write('<tr valign="top"><td width="8"><img src="]]></xsl:text><xsl:value-of select="$path-ibm-i"/><xsl:text disable-output-escaping="yes"><![CDATA[c.gif" width="8" height="1" alt=""/></td><td width="16"><img alt="Set printer orientation to landscape mode" height="16" src="]]></xsl:text>
<xsl:value-of select="$path-v14-icons"/>
<xsl:text disable-output-escaping="yes"><![CDATA[printer.gif" width="16" vspace="3" /></td><td width="122"><p><b><a class="smallplainlink" href="javascript:print()">Print this page</a></b></p></td></tr>');
//-->
</script>
<noscript></noscript>]]></xsl:text>
</xsl:variable>

<!-- s-doc-options-default.inc -->
<xsl:variable name="ssi-s-doc-options-default">
<xsl:value-of select="$ssi-s-doc-options-printcss"/>
<xsl:value-of select="$ssi-s-doc-options-email"/>
</xsl:variable>

<!-- s-footer14.inc -->
<xsl:variable name="ssi-s-footer14">
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td class="bbg" height="19">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
<td><span class="spacer">&nbsp;&nbsp;&nbsp;&nbsp;</span><a class="mainlink" href="http://www.ibm.com/ibm/">About IBM</a></td>
<td class="footer-divider" width="27">&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td><a class="mainlink" href="http://www.ibm.com/privacy/">Privacy</a></td>
<td class="footer-divider" width="27">&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td><a class="mainlink" href="http://www.ibm.com/contact/">Contact</a></td>
</tr>
</table>
</td>
</tr>
</table>
<!-- 5.2 09/14/05 jpp:  Removed CVM survey script from footer -->
<!-- 5.0 7/28 tdc:  Inserted xsl variable for path -->
<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript1.2" type="text/javascript" src="]]></xsl:text><xsl:value-of select="$path-ibm-common-stats"/><xsl:text disable-output-escaping="yes"><![CDATA[stats.js"></script>]]></xsl:text>
<noscript><img src="{$path-ibm-rc-images}uc.GIF?R=noscript" width="1" height="1" alt="" border="0" /></noscript>
</xsl:variable>

<!-- s-header-art-tut-styles.inc -->
<xsl:variable name="ssi-s-header-art-tut-styles">
<!-- Alternate code font style -->
<!-- 5.2 10/04/05 tdc:  Changed font-size from 100% to 11px -->
<style type="text/css">
code.section {font-family: Andale Mono, Lucida Console, Monaco, fixed, monospace; font-size: 11px}
.boldcode {font-family: Andale Mono, Lucida Console, Monaco, fixed, monospace; font-size: 11px; font-weight: bold} .rboldcode {font-family: Andale Mono, Lucida Console, Monaco, fixed, monospace; font-size: 11px; font-weight: bold; color: #ff0000}
.gboldcode {font-family: Andale Mono, Lucida Console, Monaco, fixed, monospace; font-size: 11px; font-weight: bold; color: #ff6600}
.bboldcode {font-family: Andale Mono, Lucida  Console, Monaco, fixed, monospace; font-size: 11px; font-weight: bold; color: #3c5f84}
</style>
<!-- Heading styles -->
<style type="text/css">
.atitle { font-family:arial,sans-serif; font-size:18px; }
</style>
</xsl:variable>

<!-- s-header-content.inc -->
<xsl:variable name="ssi-s-header-content">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</xsl:variable>

<!-- s-header-meta.inc -->
<xsl:variable name="ssi-s-header-meta">
<meta http-equiv="PICS-Label" content='(PICS-1.1 "http://www.icra.org/ratingsv02.html" l gen true r (cz 1 lz 1 nz 1 oz 1 vz 1) "http://www.rsac.org/ratingsv01.html" l gen true r (n 0 s 0 v 0 l 0) "http://www.classify.org/safesurf/" l gen true r (SS~~000 1))' />
<link rel="schema.DC" href="http://purl.org/DC/elements/1.0/" />
<link rel="SHORTCUT ICON" href="http://www.ibm.com/favicon.ico" />
<meta name="Owner" content="dW Information/Raleigh/IBM" />
<meta name="DC.Language" scheme="rfc1766" content="en-US" />
<meta name="IBM.Country" content="ZZ" />
<meta name="Security" content="Public" />
</xsl:variable>

<!-- s-header-scripts.inc -->
<xsl:variable name="ssi-s-header-scripts">
<!-- STYLESHEETS/SCRIPTS -->
<!-- for tables -->
<link rel="stylesheet" type="text/css" media="screen,print" href="{$path-ibm-common-css}table.css" /> 
<!-- end for tables -->
<!-- 5.0 7/28 tdc:  Inserted xsl variables for paths -->
<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" src="]]></xsl:text><xsl:value-of select="$path-dw-js"/><xsl:text disable-output-escaping="yes"><![CDATA[dwcss14.js" type="text/javascript"></script>]]></xsl:text>
<link rel="stylesheet" type="text/css" href="{$path-ibm-common-css}main.css" />
<link rel="stylesheet" type="text/css" media="all" href="{$path-ibm-common-css}screen.css" />
<link rel="stylesheet" type="text/css" media="print" href="{$path-ibm-common-css}print.css" />

<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" src="]]></xsl:text><xsl:value-of select="$path-ibm-common-js"/><xsl:text disable-output-escaping="yes"><![CDATA[detection.js" type="text/javascript"></script>]]></xsl:text>

<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" src="]]></xsl:text><xsl:value-of select="$path-dw-js"/><xsl:text disable-output-escaping="yes"><![CDATA[dropdown.js" type="text/javascript"></script>]]></xsl:text>

<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" src="]]></xsl:text><xsl:value-of select="$path-dw-email-js"/><xsl:text disable-output-escaping="yes"><![CDATA[grabtitle.js" type="text/javascript"></script>]]></xsl:text>

<xsl:text disable-output-escaping="yes"><![CDATA[<script language="JavaScript" src="]]></xsl:text><xsl:value-of select="$path-dw-email-js"/><xsl:text disable-output-escaping="yes"><![CDATA[emailfriend2.js" type="text/javascript"></script>]]></xsl:text>
</xsl:variable>

<!-- s-nav14-rlinks.inc NOT NEEDED -->

<!-- s-nav14-top.inc -->
<xsl:variable name="ssi-s-nav14-top">
<table border="0" cellpadding="0" cellspacing="0" width="150">
<tr>
<td class="left-nav-spacer"><a class="left-nav-overview" href="http://www.ibm.com/developerworks">&nbsp;</a></td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="150">
<tr>
<!-- 5.2 8/31/05 tdc:  Changed th to td (correcting old template generator error) -->
<td class="left-nav-overview" colspan="2"><a class="left-nav-overview" href="http://www.ibm.com/developerworks">developerWorks</a></td>
</tr>
</table>
</xsl:variable>

<!-- s-nav14.inc NOT NEEDED -->

<!-- s-rating-form-tutorial.inc -->
<xsl:variable name="ssi-s-rating-form-tutorial">
<table border="0" cellpadding="0" cellspacing="0" class="v14-gray-table-border" width="443">
<tr>
<td width="425">
<table cellspacing="0" cellpadding="0" border="0" width="100%">
<tr>
<td colspan="2"><p>Please take a moment to complete this form to help us better serve you.</p></td>
</tr>
<tr valign="top">
<td width="132"><img alt="" height="1" src="{$path-ibm-i}c.gif" width="132"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<p><label for="Goal">Did the information help you to achieve your goal?</label></p>
</td>
<td width="293"><img alt="" height="6" src="{$path-ibm-i}c.gif" width="293"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><input type="radio" name="Goal" id="Goal" value="Yes" />Yes</td>
<td><input type="radio" name="Goal" id="Goal" value="No" />No</td>
<td><input type="radio" name="Goal" id="Goal" value="Don't know" />Don't know</td>
</tr>
</table>
</td>

</tr>
<!-- Spacer -->
<tr><td colspan="2"><img src="{$path-ibm-i}c.gif" width="8" height="12" alt="" /></td></tr>
<tr valign="top">
<td width="132"><img alt="" height="1" src="{$path-ibm-i}c.gif" width="132"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<p><label for="Comments">Please provide us with comments to help improve this page:</label></p>
</td>
<td width="293"><img alt="" height="6" src="{$path-ibm-i}c.gif" width="293"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><textarea name="Comments" id="Comments" wrap="virtual" rows="5" cols="35" class="iform">&nbsp;</textarea></td>
</tr>
</table>
</td>
</tr>
<!-- Spacer -->
<tr><td colspan="2"><img src="{$path-ibm-i}c.gif" width="8" height="12" alt="" /></td></tr>
<tr valign="top">
<td width="132"><img alt="" height="1" src="{$path-ibm-i}c.gif" width="132"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<p><label for="Rating">How useful is the information?
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
(1 = Not at all,
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
5 = Extremely useful)</label></p>
</td>
<td width="293"><img alt="" height="6" src="{$path-ibm-i}c.gif" width="293"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><input type="radio" name="Rating" id="Rating" value="1" />1</td>
<td><input type="radio" name="Rating" id="Rating" value="2" />2</td>
<td><input type="radio" name="Rating" id="Rating" value="3" />3</td>
<td><input type="radio" name="Rating" id="Rating" value="4" />4</td>
<td><input type="radio" name="Rating" id="Rating" value="5" />5</td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>

<table cellspacing="0" cellpadding="0" border="0" width="443" class="v14-gray-table-border">
<!-- Spacer -->
<tr><td colspan="2"><img src="{$path-ibm-i}c.gif" width="8" height="8" alt="" /></td></tr>
<tr>
<td width="8"><img src="{$path-ibm-i}c.gif" width="8" height="1" alt="" /></td>
<td colspan="2"><input type="image" src="{$path-v14-buttons}submit.gif" border="0" width="120" height="21" alt="Submit" /></td>
</tr>
<tr><td colspan="2"><img src="{$path-ibm-i}c.gif" width="8" height="8" alt="" /></td></tr>
</table>
</xsl:variable>

<!-- s-rating-form.inc -->
<xsl:variable name="ssi-s-rating-form">
<table border="0" cellpadding="0" cellspacing="0" class="v14-gray-table-border" width="100%">
<tr>
<td width="100%">
<table cellspacing="0" cellpadding="0" border="0" width="100%">
<tr>
<td colspan="3"><p>Please take a moment to complete this form to help us better serve you.</p></td>
</tr>
<tr valign="top">
<td width="140"><img alt="" height="1" src="{$path-ibm-i}c.gif" width="140"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<p><label for="Goal">Did the information help you to achieve your goal?</label></p>
</td>
<td width="303"><img alt="" height="6" src="{$path-ibm-i}c.gif" width="303"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><input type="radio" name="Goal" id="Goal" value="Yes" />Yes</td>
<td><input type="radio" name="Goal" id="Goal" value="No" />No</td>
<td><input type="radio" name="Goal" id="Goal" value="Don't know" />Don't know</td>
</tr>
</table>
</td>
<td width="100%">&nbsp;</td>
</tr>
<!-- Spacer -->
<tr><td colspan="3"><img src="{$path-ibm-i}c.gif" width="8" height="12" alt="" /></td></tr>
<tr valign="top">
<td width="140"><img alt="" height="1" src="{$path-ibm-i}c.gif" width="140"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<p><label for="Comments">Please provide us with comments to help improve this page:</label></p>
</td>
<td width="303"><img alt="" height="6" src="{$path-ibm-i}c.gif" width="303"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><textarea name="Comments" id="Comments" wrap="virtual" rows="5" cols="35" class="iform">&nbsp;</textarea></td>
</tr>
</table>
</td>
<td width="100%">&nbsp;</td>
</tr>
<!-- Spacer -->
<tr><td colspan="3"><img src="{$path-ibm-i}c.gif" width="8" height="12" alt="" /></td></tr>
<tr valign="top">
<td width="140"><img alt="" height="1" src="{$path-ibm-i}c.gif" width="140"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<p><label for="Rating">How useful is the information?
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
(1 = Not at all,
<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
5 = Extremely useful)</label></p>
</td>
<td width="303"><img alt="" height="6" src="{$path-ibm-i}c.gif" width="303"/><xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><input type="radio" name="Rating" id="Rating" value="1" />1</td>
<td><input type="radio" name="Rating" id="Rating" value="2" />2</td>
<td><input type="radio" name="Rating" id="Rating" value="3" />3</td>
<td><input type="radio" name="Rating" id="Rating" value="4" />4</td>
<td><input type="radio" name="Rating" id="Rating" value="5" />5</td>
</tr>
</table>
</td>
<td width="100%">&nbsp;</td>
</tr>
</table>
</td>
</tr>
</table>
<table cellspacing="0" cellpadding="0" border="0" width="100%" class="v14-gray-table-border">
<!-- Spacer -->
<tr><td colspan="3"><img src="{$path-ibm-i}c.gif" width="8" height="8" alt="" /></td></tr>
<tr>
<td width="8"><img src="{$path-ibm-i}c.gif" width="8" height="1" alt="" /></td>
<td colspan="3"><input type="image" src="{$path-v14-buttons}submit.gif" border="0" width="120" height="21" alt="Submit" /></td>
</tr>
<tr><td colspan="3"><img src="{$path-ibm-i}c.gif" width="8" height="8" alt="" /></td></tr>
</table>
</xsl:variable>

<!-- s-rating-page.inc -->
<xsl:variable name="ssi-s-rating-page">
<table border="0" cellpadding="0" cellspacing="0" width="150">
<tr><td class="v14-header-1-small">Rate this page</td></tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" class="v14-gray-table-border">
<tr>
<td width="150" class="no-padding">
<table border="0" cellpadding="0" cellspacing="0" width="143">
<tr valign="top">
<td width="8"><img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/></td>
<td><img src="{$path-v14-icons}d_bold.gif" height="16" width="16" border="0" vspace="3" alt=""/></td>
<td width="125"><p><a class="smallplainlink" href="#rate"><b>Help us improve this content</b></a></p></td>
</tr>
</table>
</td>
</tr>
</table>
</xsl:variable>

<!-- s-rating-tutorial.inc -->
<xsl:variable name="ssi-s-rating-tutorial">
<table border="0" cellpadding="0" cellspacing="0" width="150">
<tr><td class="v14-header-1-small">Rate this tutorial</td></tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" class="v14-gray-table-border">
<tr>
<td width="150" class="no-padding">
<table border="0" cellpadding="0" cellspacing="0" width="143">
<tr valign="top">
<td width="8"><img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/></td>
<td><img src="{$path-v14-icons}d_bold.gif" height="16" width="16" border="0" vspace="3" alt=""/></td>
<td width="125"><p><a class="smallplainlink" href="rating.html"><b>Help us improve this content</b></a></p></td>
</tr>
</table>
</td>
</tr>
</table>
</xsl:variable>

<!-- s-site-identifier.inc -->
<xsl:variable name="ssi-s-site-identifier">
<td width="192" class="no-print"><img src="{$path-dw-images}dw.gif" width="192" height="18" alt="developerWorks" /></td>
</xsl:variable>

</xsl:stylesheet>
