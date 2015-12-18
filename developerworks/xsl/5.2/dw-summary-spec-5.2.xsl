<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:xdt="http://www.w3.org/2005/02/xpath-datatypes" exclude-result-prefixes="fn xdt xs">
	<xsl:template match="dw-summary-spec">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!-- MAIN_TABLE_BEGIN  -->]]></xsl:text>
		<!-- BODY_TABLE_BEGIN -->
		<table width="100%" cellspacing="0" cellpadding="0" border="0" id="v14-body-table">
			<tr valign="top">
				<xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV BEGIN -->]]></xsl:text>
				<xsl:call-template name="LeftNavSummary"/>
				<xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV END -->]]></xsl:text>
				<!-- MAIN_AREA_BEGIN -->
				<xsl:text disable-output-escaping="yes"><![CDATA[<!-- MAIN_AREA_BEGIN -->]]></xsl:text>
				<td width="100%">
					<a name="main">
						<xsl:text disable-output-escaping="yes"><![CDATA[<!--Main Content Begin-->]]></xsl:text>
					</a>
					<xsl:text disable-output-escaping="yes"><![CDATA[<!-- PAGE_HEAD_BEGIN -->]]></xsl:text>
					<table width="100%" cellspacing="0" cellpadding="0" border="0" id="content-table">
						<tr valign="top">
							<td width="100%">
								<table width="100%" cellspacing="0" cellpadding="0" border="0">
									<tr>
										<td>
											<img src="{$path-ibm-i}c.gif" width="592" height="1" alt=""/>
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
					<xsl:text disable-output-escaping="yes"><![CDATA[<!-- PAGE_HEAD_END -->]]></xsl:text>
					<xsl:text disable-output-escaping="yes"><![CDATA[<!-- CONTENT_BEGIN -->]]></xsl:text>
					<table width="100%" cellspacing="0" cellpadding="0" border="0">
						<tr valign="top">
							<xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT_GUTTER -->]]></xsl:text>
							<td width="10">
								<img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
							</td>
							<xsl:text disable-output-escaping="yes"><![CDATA[<!-- CENTER_COLUMN_BEGIN -->]]></xsl:text>
							<td width="100%">
								<!-- Begin level, Author, Date information -->
								<xsl:call-template name="SkillLevel"/>
								<xsl:call-template name="CompanyName"/>
								<xsl:call-template name="Dates"/>
								<xsl:call-template name="AbstractForDisplay"/>
								<xsl:call-template name="Overview"/>
								<!-- 5.2 fjc 08/08 - test for optional element before doing it -->
								<xsl:if test="normalize-space(//target-content-file/@filename)">
      								  <xsl:call-template name="Download"/>
      								  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								</xsl:if>
								<xsl:apply-templates select="docbody"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								<xsl:call-template name="ResourcesSection"/>
								<!-- End the center cell of the content section -->
								<xsl:text disable-output-escaping="yes"><![CDATA[<!-- BACK LINK -->]]></xsl:text>
<!-- 5.0.1 9/19 llk: need this backlink to be local site specific-->
								 <xsl:copy-of select="$backlink_include"/>
							</td>
							<xsl:text disable-output-escaping="yes"><![CDATA[<!-- RIGHT_GUTTER -->]]></xsl:text>
							<td width="7">
								<img src="{$path-ibm-i}c.gif" width="7" height="1" alt=""/>
							</td>
							<td width="150" id="right-nav">
								<table align="right" cellpadding="0" cellspacing="0" width="150" border="0" class="no-print">
									<tr valign="top">
										<td>
											<table align="right" cellpadding="0" cellspacing="0" width="150" border="0" class="no-print">
												<tr>
													<xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT_GUTTER -->]]></xsl:text>
													<td width="10">
														<img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
													</td>
													<td>
														<xsl:call-template name="DocumentOptions"/>
														<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
													</td>
												</tr>
											</table>
										</td>
									</tr>
									<tr>
										<td>
											<img src="{$path-ibm-i}c.gif" height="1" width="1" alt=""/>
										</td>
									</tr>
									<tr>
										<td>
											<img src="{$path-ibm-i}c.gif" height="1" width="1" alt=""/>
										</td>
									</tr>
									<!-- 5.0 6/2 fjc made a more in this series template -->
									<xsl:call-template name="SeriesMore"/>
								</table>
							</td>
							<td width="3">
								<img src="{$path-ibm-i}c.gif" width="3" height="1" alt=""/>
							</td>
						</tr>
					</table>
					<xsl:text disable-output-escaping="yes"><![CDATA[<!-- CONTENT_END -->]]></xsl:text>
				</td>
				<xsl:text disable-output-escaping="yes"><![CDATA[<!-- MAIN_AREA_END -->]]></xsl:text>
			</tr>
		</table>
		<xsl:text disable-output-escaping="yes"><![CDATA[<!-- MAIN_TABLE_END  -->]]></xsl:text>
	</xsl:template>
</xsl:stylesheet>
