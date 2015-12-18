<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- 4.0 5/19 tdc:  ratings attribute to ratings-form -->
  <!-- 4.0 5/19 tdc:  Changed content-area[1] to content-area-primary -->
  <xsl:template name="RatingsForm">
    <xsl:variable name="spanClass">
      <xsl:choose>
        <xsl:when test="/dw-document/dw-article | /dw-document/dw-sidefile | /dw-document/dw-tutorial">
          <xsl:text>atitle</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>smalltitle</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- 5.2 8/17 2005 tdc:  Added no-print for rating heading -->
    <p class="no-print">
      <span class="{$spanClass}">
        <a name="rate">
          <!-- 5.0 5/13 tdc:  Rating heading differs depending on document type -->
          <xsl:choose>
            <xsl:when test="/dw-document/dw-tutorial">
              <xsl:value-of select="$ratethistutorial-heading"/>
            </xsl:when>
            <!-- 5.2 8/18/05 tdc:  Corrected xpath (was /dw-document/article) -->
            <xsl:when test="/dw-document/dw-article">
              <xsl:value-of select="$ratethisarticle-heading"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$summary-rateThisContent"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </span>
    </p>
    <!-- 5.2 8/17/05 tdc:  Surrounded form with no-print class -->
    <span class="no-print">
    <xsl:choose>
      <!-- WORLDWIDE, BRAZIL, RUSSIA SITES -->
      <!-- 9/13/05 tdc:  Added brazil and russia -->
      <xsl:when test="@local-site='brazil' or @local-site='russia' or @local-site='worldwide'">
        <xsl:if test="(/dw-document//id/@cma-id !='') or (/dw-document//id/@content-id !='') or (/dw-document//id/@domino-uid !='')">
<!-- 5.0 6/3 tdc:  added domain to url so tutorials could use -->
<!-- 5.0 7/15 tdc:  Had to remove //www.ibm.com from the path again; didn't work for articles.  Tutorials will be hosed until we can get //www.ibm.com working for everything -->
          <form method="post" action="//www-128.ibm.com/developerworks/utils/RatingsHandler">
            <xsl:variable name="titleinput">
              <xsl:call-template name="FullTitle"/>
            </xsl:variable>
            <input type="hidden" name="ArticleTitle" value="{$titleinput}"/>
            <xsl:variable name="contentareaforinput">
              <xsl:call-template name="ContentAreaInputName">
                <xsl:with-param name="contentarea">
                  <xsl:value-of select="content-area-primary/@name"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:if test="count(content-area-secondary) > 0">
                <xsl:text>, </xsl:text>
                <xsl:for-each select="content-area-secondary">
                  <xsl:if test="position()!=1">, </xsl:if>
                  <xsl:call-template name="ContentAreaInputName">
                    <xsl:with-param name="contentarea">
                      <xsl:value-of select="@name"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:if>
            </xsl:variable>
            <input type="hidden" name="Zone" value="{$contentareaforinput}"/>
            <input type="hidden" name="RedirectURL" value="{$ratings-thankyou-url}"/>
            <xsl:variable name="id">
              <xsl:choose>
                <xsl:when test="/dw-document//content-area-primary/@name = 'db2' or /dw-document//content-area-primary/@name = 'websphere'">
                  <xsl:choose>
                    <xsl:when test="/dw-document//id/@cma-id !=''">
                      <xsl:value-of select="/dw-document//id/@cma-id"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="/dw-document//id/@content-id"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <!-- For all non-db2 and non-websphere content... -->
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="/dw-document//id/@cma-id !=''">
                      <xsl:value-of select="/dw-document//id/@cma-id"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="/dw-document//id/@domino-uid"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <input type="hidden" name="ArticleID" value="{$id}"/>
            <!-- 5.0 5/13 tdc:  Tutorial rating form width 74% -->
            <xsl:choose>
              <xsl:when test="/dw-document/dw-tutorial">
                <img alt="" height="1" src="{$path-v14-rules}gray_rule.gif" width="443"/>
              </xsl:when>
              <xsl:otherwise>
                <img alt="" height="1" src="{$path-v14-rules}gray_rule.gif" width="100%"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <!-- 5.0 5/13 tdc:  Tutorial rating form width 74% -->
            <xsl:choose>
              <xsl:when test="/dw-document/dw-tutorial">
              <!-- 5.0 6/10 tdc:  Changed include to variable -->
              <xsl:copy-of select="$ssi-s-rating-form-tutorial" />
              </xsl:when>
              <xsl:otherwise>
                 <xsl:copy-of select="$ssi-s-rating-form" />
              </xsl:otherwise>
            </xsl:choose>
          </form>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </xsl:if>
      </xsl:when>
       <xsl:when test="'/dw-document/dw-article' or '/dw-document/dw-summary-long' or '/dw-document/dw-summary-presentation' or '/dw-document/dw-summary-sample'">
		<xsl:if test="not(/dw-document//@ratings-form='no')">
			<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tr valign="top">
					<td><form method="{$method}" action="{$domino-ratings-post-url}">
						<xsl:variable name="titleinput"><xsl:call-template name="FullTitle"/></xsl:variable>
						<input type="hidden" name="ArticleTitle" value="{$titleinput}"/>
						<xsl:variable name="contentareaforinput">
						       <xsl:call-template name="ContentAreaInputName">
							<xsl:with-param name="contentarea"><xsl:value-of select="content-area-primary/@name"/></xsl:with-param>
							</xsl:call-template>
							<xsl:if test="count(content-area-secondary) !='0'"><xsl:text>, </xsl:text>
							<xsl:for-each select="content-area-secondary"><xsl:if test="position()!=1">, </xsl:if>
							<xsl:call-template name="ContentAreaInputName"><xsl:with-param name="contentarea"><xsl:value-of select="@name"/></xsl:with-param>
							</xsl:call-template>
							</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						<input type="hidden" name="Zone" value="{$contentareaforinput}"/>
						<input type="hidden" name="RedirectURL" value="{$ratings-thankyou-url}"/>
						<xsl:variable name="ratings-localsite">
						<xsl:value-of select="/dw-document/dw-article/@local-site"/>
						</xsl:variable>
						<input type="hidden" name="localsite" value="{$ratings-localsite}"/>
					<xsl:if test="/dw-document/dw-article/@local-site='china' or /dw-document/dw-article/@local-site='korea'">
						<xsl:text disable-output-escaping="yes"><![CDATA[<script language="javascript">document.write('<input type="hidden" name="url" value="'+location.href+'">');</script>]]></xsl:text>
						</xsl:if>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td><img src="//www.ibm.com/i/c.gif" width="100" height="8" border="0" alt=""/>
									</td>
								</tr>
								<tr valign="top">
									<td>
									<input type="RADIO" name="Rating" value="1"/>
									<xsl:value-of select="$ratings-value1-text"/>
									</td>
								</tr>
								<tr valign="top">
									<td>
									<input type="RADIO" name="Rating" value="2"/>
									<xsl:value-of select="$ratings-value2-text"/>
									</td>
								</tr>
								<tr valign="top">
									<td>
									<input type="RADIO" name="Rating" value="3"/>
									<xsl:value-of select="$ratings-value3-text"/>
									</td>
								</tr>
								<tr valign="top">
									<td>
									<input type="RADIO" name="Rating" value="4"/>
									<xsl:value-of select="$ratings-value4-text"/>
									</td>
								</tr>
								<tr valign="top">
									<td>
									<input type="RADIO" name="Rating" value="5"/>
									<xsl:value-of select="$ratings-value5-text"/>
									</td>
								</tr>
							</table>
<!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
							<xsl:variable name="formtext">
								<xsl:choose>
									<xsl:when test="//forum-url/@url=''"><xsl:value-of select="$comments-noforum-text"/></xsl:when>
									<xsl:when test="//forum-url/@url!=''"><xsl:value-of select="$comments-withforum-text"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$comments-noforum-text"/></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
								<xsl:choose>
									<xsl:when test="/dw-document//@local-site='korea' or /dw-document//@local-site='taiwan'"></xsl:when>
									<xsl:otherwise>
									<b><xsl:value-of select="$formtext"/></b>
	           <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      <textarea name="Comments" id="Comments" wrap="virtual" rows="5" cols="60">&#160;</textarea>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
									</xsl:otherwise>
								</xsl:choose>
	 <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text><input type="SUBMIT" value="{$submit-feedback-text}"/>
								</form>
							</td>
						</tr>
						<tr valign="top">
							<td bgcolor="#FFFFFF"><img src="//www.ibm.com/i/c.gif" width="100" height="8" border="0" alt=""/>
							</td>
						</tr>
					</table>
				</xsl:if>
			</xsl:when>
			<!-- 5.0.1 8/18 ratings form for tutorials -->
			<xsl:when test="/dw-document/dw-tutorial">
				<xsl:if test="not(/dw-document//@ratings-form='no')">
					<table width="440" cellspacing="0" cellpadding="0" border="0">
						<tr valign="top">
							<td><form method="{$method}" action="{$domino-ratings-post-url}">
							<xsl:variable name="titleinput">
								<xsl:call-template name="FullTitle"/></xsl:variable>
								<input type="hidden" name="ArticleTitle" value="{$titleinput}"/>
								<xsl:variable name="contentareaforinput"><xsl:call-template name="ContentAreaInputName">
								<xsl:with-param name="contentarea"><xsl:value-of select="content-area-primary/@name"/>
								</xsl:with-param>
								</xsl:call-template>
								<xsl:if test="count(content-area-secondary) !='0'">
									<xsl:text>, </xsl:text>
									<xsl:for-each select="content-area-secondary">
									<xsl:if test="position()!=1">, </xsl:if>
									<xsl:call-template name="ContentAreaInputName">
									<xsl:with-param name="contentarea">
									<xsl:value-of select="@name"/>
									</xsl:with-param>
									</xsl:call-template>
									</xsl:for-each>
								</xsl:if>
							</xsl:variable>
							<input type="hidden" name="Zone" value="{$contentareaforinput}"/>
							<input type="hidden" name="RedirectURL" value="{$ratings-thankyou-url}"/>
							<xsl:variable name="ratings-localsite"><xsl:value-of select="/dw-document/dw-tutorial/@local-site"/></xsl:variable>
							<input type="hidden" name="localsite" value="{$ratings-localsite}"/>
							<xsl:if test="/dw-document/dw-tutorial/@local-site='china' or /dw-document/dw-tutorial/@local-site='korea'">
							<xsl:text disable-output-escaping="yes"><![CDATA[<script language="javascript">document.write('<input type="hidden" name="url" value="'+location.href+'">');</script>]]></xsl:text>
							</xsl:if>
								<table border="0" cellpadding="0" cellspacing="0" width="440">
									<tr>
										<td><img src="//www.ibm.com/i/c.gif" width="100" height="8" border="0" alt=""/>
										</td>
									</tr>
									<tr valign="top">
										<td><input type="RADIO" name="Rating" value="1"/><xsl:value-of select="$ratings-value1-text"/></td>
									</tr>
									<tr valign="top">
										<td><input type="RADIO" name="Rating" value="2"/><xsl:value-of select="$ratings-value2-text"/></td>
									</tr>
									<tr valign="top">
										<td><input type="RADIO" name="Rating" value="3"/><xsl:value-of select="$ratings-value3-text"/></td>
									</tr>
									<tr valign="top">
										<td><input type="RADIO" name="Rating" value="4"/><xsl:value-of select="$ratings-value4-text"/></td>
									</tr>
									<tr valign="top">
										<td><input type="RADIO" name="Rating" value="5"/><xsl:value-of select="$ratings-value5-text"/></td>
									</tr>
								</table>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
								<xsl:variable name="formtext">
								<xsl:choose>
									<xsl:when test="//forum-url/@url=''"><xsl:value-of select="$comments-noforum-text"/></xsl:when>
									<xsl:when test="//forum-url/@url!=''"><xsl:value-of select="$comments-withforum-text"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$comments-noforum-text"/></xsl:otherwise>
								</xsl:choose>
								</xsl:variable>
									<!-- 5.01 7/30 : LLK : removed /dw-article on the condition; ratings now attached to summary pages as well -->
								<xsl:choose>
									<xsl:when test="/dw-document//@local-site='korea' or /dw-document//@local-site='taiwan'"></xsl:when>
										<xsl:otherwise>
											<b>
												<xsl:value-of select="$formtext"/>
											</b>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text><textarea name="Comments" id="Comments" wrap="virtual" rows="5" cols="55">&#160;</textarea>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
										</xsl:otherwise>
									</xsl:choose>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
									<input type="SUBMIT" value="{$submit-feedback-text}"/>
								</form>
							</td>
						</tr>
						<tr valign="top">
							<td bgcolor="#FFFFFF">
								<img src="//www.ibm.com/i/c.gif" width="100" height="8" border="0" alt=""/>
							</td>
						</tr>
					</table>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise/>
    </xsl:choose>
    </span>
    <!-- 5.2 8/17/05 tdc:  Surrounded back link with no-print -->
    <!-- 5.0 5/11 tdc:  Only articles and side files need need back link -->
    <xsl:if test="/dw-document/dw-article">
      <!-- 5.0 6/10 tdc:  Changed include to variable -->
      <!-- 5.2 9/16/05 tdc:  Moved span inside of xsl:if -->
      <span class="no-print">
         <xsl:copy-of select="$ssi-s-backlink" />
      </span>
      </xsl:if>    
  </xsl:template>
</xsl:stylesheet>

