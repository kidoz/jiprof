<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:xdt="http://www.w3.org/2005/02/xpath-datatypes" exclude-result-prefixes="fn xdt xs">
	<xsl:template match="dw-summary-podcast">
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
								<xsl:call-template name="AuthorTopSummary"/>
								<xsl:call-template name="Dates"/>
								<xsl:call-template name="AbstractForDisplay"/>
								<span>
								  <p>
								    <xsl:copy-of select="$summary-podcast-not-familiar"/>
								  </p>
								</span>
								 <!-- <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                                                     5.2 10/14 fjc: -->
                                                      <table border="0" cellpadding="0" cellspacing="0">
                                                        <tr valign="top">
                                                          <td colspan="2">
                                                            <img src="{$path-ibm-i}c.gif" border="0" height="12" width="12" alt=""/>
                                                          </td>
                                                        </tr>
                                                        <tr>
                                                          <td>
                                                            <img src="{$path-v14-icons}d_bold.gif" width="16" height="16" alt=""/>
                                                          </td>
                                                          <td>
                                                            <a class="fbox" href="#download">
                                                              <b>
								           <xsl:copy-of select="$summary-getThePodcast"/>
                                                              </b>
                                                            </a>
                                                          </td>
                                                        </tr>
                                                        <tr valign="top">
                                                          <td colspan="2">
                                                            <img src="{$path-ibm-i}c.gif" border="0" height="12" width="12" alt=""/>
                                                          </td>
                                                        </tr>
                                                      </table>
								
								<xsl:if test="//in-this-doc">
								  <xsl:call-template name="InThisDoc"/>
								  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								</xsl:if>

								<xsl:if test="//audience">
								<xsl:call-template name="Audience"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								</xsl:if>
                                                      
                                                     <p>
                                                         <span class="smalltitle">
                                                             <xsl:value-of select="$summary-systemRequirements"/>
                                                         </span>
                                                     </p>
                                                      <xsl:choose>
                                                        <xsl:when test="system-requirements/@insert-std-text='yes'">
                                                          <span>
        								  <p>
        								    <xsl:copy-of select="$summary-podcast-system-requirements"/>
        								  </p>
                                                          </span>
                                                        </xsl:when>
                                                        <xsl:when test="not(system-requirements/@insert-std-text)">
                                                          <span>
        								  <p>
        								     <xsl:copy-of select="$summary-podcast-system-requirements"/>
        								  </p>
                                                          </span>
                                                        </xsl:when>
                                                      </xsl:choose>
                                                      <xsl:apply-templates select="system-requirements/*|text()"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>

								<xsl:if test="//foreign-language">
								<xsl:call-template name="Languages"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								</xsl:if>
								<xsl:apply-templates select="docbody"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								<!-- 5.2 10/11 fjc: Add the Duration-->
								<xsl:call-template name="Duration"/>								
								<!-- 5.2 fjc 08/08 - test for optional element before doing it -->
								<xsl:if test="normalize-space(//target-content-file/@filename)!=''">
      								  <xsl:call-template name="Download"/>
      								  <!-- 5.2 09/20 fjc:  If it's a podcast put subscrige text and link-->
                                                          <table border="0" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                              <td>
                                                                <img src="//www.ibm.com/i/v14/icons/fw_bold.gif" height="16" width="16" border="0" vspace="3" alt="" />
                                                              </td>
                                                              <td>
                                                                <a class="fbox" href="/developerworks/podcast/about.html#subscribe">
                                                                  <b><xsl:value-of select="$download-subscribe-podcasts" disable-output-escaping="yes"/>
                                                                  </b>
                                                                </a>
                                                              </td>
                                                            </tr>
                                                          </table>
      								  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								   <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								</xsl:if>
								<!-- 5.2 fjc 08/08 - test for optional element before doing it -->
								<xsl:if test="(//resources or //resource-list)">
								   <xsl:call-template name="ResourcesSection"/>
								   <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								   <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								 </xsl:if>
								<!-- 5.2 fjc 08/08 - test for optional element before doing it -->
								<xsl:if test="//author-summary/bio">
								<xsl:call-template name="AuthorBottomSummary"/>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								</xsl:if>
								<xsl:text disable-output-escaping="yes"><![CDATA[<!-- RATING FORM -->]]></xsl:text>
								<xsl:call-template name="RatingsForm"/>
								<!-- End the center cell of the content section -->
								<xsl:text disable-output-escaping="yes"><![CDATA[<!-- BACK LINK -->]]></xsl:text>
								<xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-backlink.inc" -->]]></xsl:text>
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
									<tr valign="top">
										<td>
											<table align="right" cellpadding="0" cellspacing="0" width="150" border="0" class="no-print">
												<tr>
													<td>
														<xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-rating-content.inc" -->]]></xsl:text>
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
