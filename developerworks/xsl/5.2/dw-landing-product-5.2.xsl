<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:xdt="http://www.w3.org/2005/02/xpath-datatypes" exclude-result-prefixes="fn xdt xs">
	<xsl:template match="dw-landing-product">
		<xsl:comment>MAIN_TABLE_BEGIN</xsl:comment>
		<xsl:comment>BODY_TABLE_BEGIN</xsl:comment>
		<table width="100%" cellspacing="0" cellpadding="0" border="0" id="v14-body-table">
			<tr valign="top">
				<xsl:comment>LEFT_NAV_BEGIN</xsl:comment>
				<xsl:call-template name="LeftNavProduct"/>
				<xsl:comment>LEFT_NAV_END</xsl:comment>
				<xsl:comment>MAIN_AREA_BEGIN</xsl:comment>
				<xsl:comment>MAIN_AREA_BEGIN</xsl:comment>
				<td width="100%">
					<a name="main">
						<xsl:comment>Main Content Begin</xsl:comment>
					</a>
					<xsl:comment>PAGE_HEAD_BEGIN</xsl:comment>
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
				<xsl:comment>PAGE_HEAD_END</xsl:comment>
				<xsl:comment>CONTENT_BEGIN</xsl:comment>
				<table width="100%" cellspacing="0" cellpadding="0" border="0">
					<tr valign="top">
						<xsl:comment>LEFT_GUTTER</xsl:comment>
							<td width="10">
								<img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
							</td>
							<xsl:comment>CENTER_COLUMN_BEGIN</xsl:comment>
							<td width="443">
								<!-- Begin center column -->
								<xsl:call-template name="AbstractProduct"/>
								<!-- Begin Date updated -->
								<table width="443" cellpadding="0" cellspacing="0" border="0">                 
                                     <tr valign="top">
                                               <td align="right">
                                                       <!-- 5.2 09/19/05 jpp:  Do not display "Updated" date if type=product-condensed -->
                                                       <xsl:choose>
                                                        <xsl:when test="not(/dw-document/dw-landing-product/@page-type='product-condensed')">
                                                            <xsl:call-template name="Dates"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>                                                            
                                                            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                                                        </xsl:otherwise>
                                                     </xsl:choose>				                                                                
		                                  </td>
                                     </tr>
                                </table>								
								<!-- Begin Top story -->
								<xsl:call-template name="TopStory"/>
								<!-- Begin Product Technical Library -->
								<xsl:call-template name="ProductTechnicalLibrary"/>
								<!-- Begin Product information -->
								<!-- 5.2 09/19/05 jpp:  Display Product information section for type=product or type=product-condensed -->
								<xsl:if test="(/dw-document/dw-landing-product/@page-type='product') or (/dw-document/dw-landing-product/@page-type='product-condensed')">
								      <xsl:if test="string(product-information)">
									    <xsl:call-template name="ProductInformation"/>
									</xsl:if>
								</xsl:if>								
                                                     <!-- Begin Downloads -->
								<!-- 5.2 09/19/05 jpp:  Check for elements before processing-->
                                                     <xsl:choose>
                                                          <xsl:when test="string(product-downloads-form)">
                                                              <xsl:call-template name="ProductDownloads"/>
                                                          </xsl:when>
                                                          <xsl:when test="string(product-downloads)">
                                                              <xsl:call-template name="ProductDownloads"/>
                                                          </xsl:when>
                                                          <xsl:otherwise></xsl:otherwise>
                                                    </xsl:choose>
                                                     <!-- Begin Learning resources -->
								<xsl:call-template name="ProductLearningResources"/>
                                                     <!-- Begin Support -->
								<xsl:call-template name="ProductSupport"/>
								<!-- Begin Community -->
								<!-- 5.2 09/19/05 jpp:  Check for elements before processing-->
                                                     <xsl:choose>
                                                          <xsl:when test="string(product-community-form)">
                                                              <xsl:call-template name="ProductCommunity"/>
                                                          </xsl:when>
                                                          <xsl:when test="string(product-community)">
                                                              <xsl:call-template name="ProductCommunity"/>
                                                          </xsl:when>
                                                          <xsl:otherwise></xsl:otherwise>
                                                    </xsl:choose>
								<!-- Begin More Product Information -->
								<!-- 5.2 09/19/05 jpp:  Do not display More Product Information section for type=product or type=product-condensed -->
								<xsl:if test="not(/dw-document/dw-landing-product/@page-type='product' or /dw-document/dw-landing-product/@page-type='product-condensed')">
								    <xsl:if test="string(product-more-information)">
								        <xsl:call-template name="MoreProductInformation"/>
								    </xsl:if>
								</xsl:if>	
                                                     <!-- Begin BottomLinks -->
								<xsl:call-template name="BottomLinks"/>
								<!-- Spacer -->
								<xsl:text disable-output-escaping="yes"><![CDATA[<br /><br />]]></xsl:text>								
							<!-- End center column -->								
							</td>
							<xsl:comment>GUTTER</xsl:comment>
							<td width="7">
								<img src="{$path-ibm-i}c.gif" width="7" height="1" alt=""/>
							</td>
							<td width="100%">
							    <!-- Begin BrandImage -->
								<xsl:call-template name="BrandImage"/>
	                                            <!-- Begin Spotlight-->
								<xsl:call-template name="Spotlight"/>
                                                   <!-- Begin LatestContent-->
								<!-- 5.2 09/19/05 jpp:  Check for element before processing-->
                                                     <xsl:if test="string(product-latest-content)">
								    <xsl:call-template name="LatestContent"/>
								</xsl:if>
                                                   <!-- Begin Editor's Picks-->
								<!-- 5.2 09/19/05 jpp:  Check for element before processing-->
                                                     <xsl:if test="string(product-editors-picks)">
                                                         <xsl:call-template name="EditorsPicks"/>
                                                     </xsl:if>
                                                   <!-- Begin Special Offers-->
								<xsl:call-template name="SpecialOffers"/>
								<!-- Spacer -->
								<xsl:text disable-output-escaping="yes"><![CDATA[<br /><br />]]></xsl:text>
							</td>
							<td width="3">
							 <img src="{$path-ibm-i}c.gif" width="3" height="1" alt=""/>
							 </td>							
						</tr>
					</table>				
					<xsl:comment>CONTENT_END</xsl:comment>
				</td>
				<xsl:comment>MAIN_AREA_END</xsl:comment>
			</tr>
		</table>
		<xsl:comment>MAIN_TABLE_END</xsl:comment>
	</xsl:template>
	
	<xsl:template name="AbstractProduct">
	    <table width="443" cellpadding="0" cellspacing="0" border="0">                 
              <tr valign="top">
                 <td>
			<xsl:for-each select="/dw-document/dw-landing-product/abstract-special-chars">     
			     <xsl:value-of select="." />
			</xsl:for-each>
		    </td>
              </tr>
              <tr><td><img alt="" height="6" width="8" border="0" src="{$path-ibm-i}c.gif" /></td></tr>
           </table>           
       </xsl:template>
       
	<xsl:template name="ProductTechnicalLibrary">
	<table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$product-technical-library-heading"/></td>
	         </tr>
         </table>
         <!-- Intentionally not using string test here to allow for null results -->
          <xsl:if test="product-technical-library-search">
            <xsl:variable name="product-by">
                 <xsl:value-of select="product-technical-library-search"/>
            </xsl:variable>
            <xsl:text disable-output-escaping="yes"><![CDATA[<form name="librarySearch" action="]]></xsl:text><xsl:value-of select="$path-dw-views"/>
            <xsl:value-of select="content-area-primary/@name"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[/libraryview.jsp" method="get">]]></xsl:text>
		    <input type="hidden" size="40" name="product_by" value="{$product-by}" />          	     	
          	<table cellspacing="0" cellpadding="0" border="0" width="443">          	
          	<tr><td colspan="2"><img src="{$path-ibm-i}c.gif" width="1" height="10" alt=""/></td></tr>
          	<tr>
          	<td width="5"><img src="{$path-ibm-i}c.gif" width="5" height="1" alt=""/></td>
          	<td nowrap="nowrap" colspan="2"><label for="searchKeyword"><xsl:value-of select="$technical-library-search-text"/></label></td>
          	</tr>
          	<tr>
          	<td><img src="{$path-ibm-i}c.gif" width="5" height="1" alt=""/></td>
          	<td nowrap="nowrap">
          	<table cellspacing="0" cellpadding="0" border="0">
	    	<tr>
           	<td><input type="text" name="search_by" id="searchKeyword" class="small" size="60" maxlength="100" value=""/></td>
           	<td><img src="{$path-ibm-i}c.gif" width="4" height="1" alt=""/><input type="image" src="{$path-v14-buttons}go.gif" size="21" style="border;0" name="Go" alt="Go"/></td>	
          	</tr>
        	</table>
		</td>		
		</tr>
		<tr><td colspan="2"><img src="{$path-ibm-i}c.gif" width="1" height="4" alt=""/></td></tr>		
		</table>	
		<xsl:text disable-output-escaping="yes"><![CDATA[</form>]]></xsl:text>
	   </xsl:if>	   
        <xsl:if test="string(product-technical-library)">
            <xsl:call-template name="TwoColumnLinks">                     
				<xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-technical-library/page-section-links/page-section-link) div 2)"/>
				<xsl:with-param name="sectionPath" select="product-technical-library/page-section-links/page-section-link"/>                              
			</xsl:call-template>
        </xsl:if>
          <!-- Spacer -->
        <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
	    </table>
	</xsl:template>
	
	<xsl:template name="ProductInformation">
	   <table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$product-information-heading"/></td>
	         </tr>
          </table>         
          <xsl:call-template name="TwoColumnLinks">                     
	          <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-information/page-section-links/page-section-link) div 2)"/>
		   <xsl:with-param name="sectionPath" select="product-information/page-section-links/page-section-link"/>                              
          </xsl:call-template>
          <xsl:if test="string(product-information-related)">
                <table border="0" cellpadding="0" cellspacing="0" width="443">
		       <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/></td></tr>
		       <tr>
		          <td>
		               <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
		               <xsl:value-of select="$product-related-products"/>
		          </td>
		       </tr>
		   </table>                
                <xsl:call-template name="TwoColumnLinks">                     
	               <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-information-related/page-section-links/page-section-link) div 2)"/>
		        <xsl:with-param name="sectionPath" select="product-information-related/page-section-links/page-section-link"/>                              
                </xsl:call-template>          
          </xsl:if>
          <!-- Spacer -->
             <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
		</table>          
       </xsl:template>
       
     <xsl:template name="ProductDownloads">	
	   <table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$product-downloads-heading"/></td>
	         </tr>
          </table>
          <xsl:if test="string(product-downloads-form)">          
               <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
					<xsl:copy-of select="$path-dw-inc"/>
                    <xsl:value-of select="product-downloads-form"/>
               <xsl:text disable-output-escaping="yes"><![CDATA[" -->]]></xsl:text>
            </xsl:if>
            <xsl:call-template name="TwoColumnLinks">                     
	             <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-downloads/page-section-links/page-section-link) div 2)"/>
		      <xsl:with-param name="sectionPath" select="product-downloads/page-section-links/page-section-link"/>                              
            </xsl:call-template>            
          <!-- Spacer -->
             <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
		</table>
       </xsl:template>
       
       <xsl:template name="ProductLearningResources">	
	   <table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$product-learning-resources-heading"/></td>
	         </tr>
          </table>
          <xsl:if test="string(product-learning-resources-form)">
               <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
					<xsl:copy-of select="$path-dw-inc"/>
                    <xsl:value-of select="product-learning-resources-form"/>
               <xsl:text disable-output-escaping="yes"><![CDATA[" -->]]></xsl:text>               
          </xsl:if>
        <xsl:call-template name="TwoColumnLinks">                     
	          <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-learning-resources/page-section-links/page-section-link) div 2)"/>
		   <xsl:with-param name="sectionPath" select="product-learning-resources/page-section-links/page-section-link"/>                              
          </xsl:call-template>
          <!-- Spacer -->
             <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
		</table>
       </xsl:template>
       
       <xsl:template name="ProductSupport">	
	   <table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$product-support-heading"/></td>
	         </tr>
          </table>
          <xsl:if test="string(product-support-form)">
             <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
					<xsl:copy-of select="$path-dw-inc"/>
                    <xsl:value-of select="product-support-form"/>
               <xsl:text disable-output-escaping="yes"><![CDATA[" -->]]></xsl:text>            
		   </xsl:if>
         <xsl:call-template name="TwoColumnLinks">                     
	          <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-support/page-section-links/page-section-link) div 2)"/>
		   <xsl:with-param name="sectionPath" select="product-support/page-section-links/page-section-link"/>                              
          </xsl:call-template>
          <!-- Spacer -->
             <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
		</table>
       </xsl:template>
       
       <xsl:template name="ProductCommunity">	
	   <table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$product-community-heading"/></td>
	         </tr>
          </table>
          <xsl:if test="string(product-community-form)">
               <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
					<xsl:copy-of select="$path-dw-inc"/>
                    <xsl:value-of select="product-community-form"/>
               <xsl:text disable-output-escaping="yes"><![CDATA[" -->]]></xsl:text>               
          </xsl:if> 
	   <xsl:call-template name="TwoColumnLinks">                     
	          <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-community/page-section-links/page-section-link) div 2)"/>
		   <xsl:with-param name="sectionPath" select="product-community/page-section-links/page-section-link"/>                              
          </xsl:call-template>
          <!-- Spacer -->
             <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
		</table>
       </xsl:template> 
       
       <xsl:template name="MoreProductInformation">
	   <table border="0" cellpadding="0" cellspacing="0" width="443">
	        <tr>
	             <td class="v14-header-2"><xsl:value-of select="$more-product-information-heading"/></td>
	         </tr>
          </table>         
          <xsl:call-template name="TwoColumnLinks">                     
	          <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-more-information/page-section-links/page-section-link) div 2)"/>
		   <xsl:with-param name="sectionPath" select="product-more-information/page-section-links/page-section-link"/>                              
          </xsl:call-template>
          <xsl:choose>
		<xsl:when test="string(product-more-information-related)">
		   <table border="0" cellpadding="0" cellspacing="0" width="443">
		       <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/></td></tr>
		       <tr>
		          <td>
		               <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
		               <xsl:value-of select="$product-related-products"/>
		          </td>
		       </tr>
		   </table>                
                <xsl:call-template name="TwoColumnLinks">                     
	               <xsl:with-param name="sectionCount" select="ceiling(count(/dw-document/dw-landing-product/product-more-information-related/page-section-links/page-section-link) div 2)"/>
		        <xsl:with-param name="sectionPath" select="product-more-information-related/page-section-links/page-section-link"/>                              
                </xsl:call-template>          
             </xsl:when>
             <xsl:otherwise>
                <xsl:if test="string(product-more-information-related-form)">
                   <table border="0" cellpadding="0" cellspacing="0" width="443">
		       <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/></td></tr>
		       <tr>
		          <td>
		               <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
		               <xsl:text>Related products:</xsl:text>
		          </td>
		       </tr>
		      </table>
		      <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
					  <xsl:copy-of select="$path-dw-inc"/>
                      <xsl:value-of select="product-more-information-related-form"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[" -->]]></xsl:text>             
                </xsl:if>
             </xsl:otherwise>
	   </xsl:choose>
          <!-- Spacer -->
             <table border="0" cellpadding="0" cellspacing="0" width="443">
		     <tr><td><img src="{$path-ibm-i}c.gif" width="8" height="14" alt=""/></td></tr>
		</table>          
       </xsl:template>
                   
 <xsl:template name="Spotlight">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
	        <tr>
	             <!-- 5.2 09/15/05 jpp:  Changed heading class to correct value -->
	             <td class="v14-header-1-small"><xsl:value-of select="$spotlight-heading"/></td>
	         </tr>
  </table>	
  <table width="100%" class="v14-gray-table-border" cellspacing="0" cellpadding="0" border="0">
        <tr>
			<td colspan="2"><img width="1" src="{$path-ibm-i}c.gif" height="5" alt="" />
			    <table cellspacing="0" cellpadding="0" border="0">
				    <xsl:for-each select="product-spotlight/page-section-links/page-section-link">
						 <xsl:call-template name="BulletedLinks"/>
				    </xsl:for-each>
			    </table> 
				<img width="1" src="{$path-ibm-i}c.gif" height="2" alt="" />
			</td>
		 </tr>
	</table>   
      <!-- Spacer -->
		 <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>  
 </xsl:template> 
 
<xsl:template name="LatestContent">
     <table border="0" cellpadding="0" cellspacing="0" width="100%">
          <tr>
               <!-- 5.2 09/15/05 jpp:  Changed heading class to correct value -->
	        <td class="v14-header-2-small"><xsl:value-of select="$latest-content-heading"/></td>
	   </tr>
     </table>
     <table width="100%" class="v14-gray-table-border" cellspacing="0" cellpadding="0" border="0">
         <tr>
		<td colspan="2"><img width="1" src="{$path-ibm-i}c.gif" height="5" alt="" />
						  <xsl:choose>
                                  <xsl:when test="count(product-latest-content/page-section-category/subhead) &gt; 1">
                                          <xsl:for-each select="product-latest-content/page-section-category">
                                             <xsl:if test="string(subhead)">   
                                                   <table cellspacing="0" cellpadding="0" border="0">
                                                        <tr><td>
                                                             <b class="small">
                                                                   <xsl:value-of select="subhead"/>
                                                             </b>
                                                        </td></tr>
                                                        <tr><td><img width="1" src="{$path-ibm-i}c.gif" height="4" alt="" /></td></tr>
                                                   </table>
                                                   <table cellspacing="0" cellpadding="0" border="0">
                                                            <xsl:call-template name="BulletedLinkAbstracts"/>
                                                   </table>
                                             </xsl:if>
                                             <xsl:if test="string(more-link) and string(subhead)">
                                                  <table cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
             						                <td width="100%"><img width="100%" src="{$path-ibm-i}c.gif" height="1" alt="" /></td>
                                                              <td align="right" width="18" class="ipt"><img src="{$path-v14-icons}fw.gif" height="16" width="16" alt="" /></td>
                                                              <td width="72" class="npl" align="left" nowrap="nowrap">
                                                                   <a class="smallplainlink" href="{more-link}">
                                                                        <xsl:value-of select="$more-content-link-text"/>
                                                                   </a>                                                                      
                                                              </td>
                                                        </tr>
                                                         <tr><td><img width="1" src="{$path-ibm-i}c.gif" height="8" alt="" /></td></tr>
                                                  </table>
                                                </xsl:if>                                              
                                          </xsl:for-each>                                        
                                  </xsl:when>
					<xsl:otherwise>
                                         <table cellspacing="0" cellpadding="0" border="0">	
                                              <xsl:for-each select="product-latest-content/page-section-category">
                                                   <xsl:call-template name="BulletedLinkAbstracts"/>
                                              </xsl:for-each>
                                         </table>
                                         <xsl:for-each select="product-latest-content/page-section-category">
                                              <xsl:if test="string(more-link)">
                                                  <table cellspacing="0" cellpadding="0" border="0">                                                                                                               
             						         <tr>
             						                <td width="100%"><img width="100%" src="{$path-ibm-i}c.gif" height="1" alt="" /></td>
                                                              <td align="right" width="18" class="ipt"><img src="{$path-v14-icons}fw.gif" height="16" width="16" alt="" /></td>
                                                              <td width="72" class="npl" align="left" nowrap="nowrap">
                                                                   <a class="smallplainlink" href="{more-link}">
                                                                        <xsl:value-of select="$more-content-link-text"/>
                                                                   </a>                                                                      
                                                              </td>
                                                        </tr>
                                                  </table>
                                                  </xsl:if>
                                             </xsl:for-each>	                   
                                  </xsl:otherwise>                                  
                         </xsl:choose>
		     <img width="1" src="{$path-ibm-i}c.gif" height="2" alt="" />
		</td>
	  </tr>
	</table>
	<xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
</xsl:template>
 
<xsl:template name="EditorsPicks">
     <table border="0" cellpadding="0" cellspacing="0" width="100%">
	        <tr>
	             <!-- 5.2 09/15/05 jpp:  Changed heading class to correct value -->
	             <td class="v14-header-2-small"><xsl:value-of select="$editors-picks-heading"/></td>
	         </tr>
     </table>
	 <table width="100%" class="v14-gray-table-border" cellspacing="0" cellpadding="0" border="0">
             <tr>
			<td colspan="2"><img width="1" src="{$path-ibm-i}c.gif" height="5" alt="" />
			    <table cellspacing="0" cellpadding="0" border="0">
				    <xsl:for-each select="product-editors-picks/page-section-links/page-section-link">
						 <xsl:call-template name="BulletedLinks"/>
				    </xsl:for-each>
			    </table> 
				<img width="1" src="{$path-ibm-i}c.gif" height="2" alt="" />
			</td>
		</tr>
	</table>  
	 <!-- Spacer -->
	 <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text> 	
 </xsl:template>
 </xsl:stylesheet>