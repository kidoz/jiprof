<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- 5.0 6/20 tdc:  Global:  Put br tags in CDATA; XALAN removes space before slash otherwise -->
  <!-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -->
  <!-- 5.0 05/04 tdc:  Got rid of result prefix from <a> element -->
  <!-- 5.2 fjc 08/12 - for dw-tutorial, internal anchor links now resolve to the page that they are on -->
  <xsl:template match="a">
    <xsl:choose>
      <!-- if the <a> has an href starting with # then it is an internal link -->
      <xsl:when test="starts-with(@href, '#') and //dw-document/dw-tutorial">
      <!-- save all the stuff in variables -->
        <xsl:variable name="this-content" select="."/>
        <xsl:variable name="this-href" select="@href"/>
        <xsl:variable name="all-a" select="//a"/>
        <!-- 5.2 10/18 fjc: -->
        <xsl:variable name="all-h" select="//heading"/>        
        <xsl:variable name="this-anchor" select="substring(@href, 2)"/>
        <!-- now let's find the destination <a> node -->
        <xsl:for-each select="$all-a[@name=$this-anchor]">
          <a xsl:exclude-result-prefixes="fo xsl">
            <!-- find the position of the section where the destination is located -->
            <xsl:variable name="sectionNumber"  select="count(ancestor::section/preceding-sibling::section) + 1"/>
            <!-- if destination will be on a section2.html or greater then make the href point to it -->
            <xsl:if test="number($sectionNumber)>1">
              <xsl:attribute name="href"><xsl:text>section</xsl:text><xsl:value-of select="$sectionNumber"/><xsl:text>.html</xsl:text><xsl:value-of select="$this-href"/></xsl:attribute>
            </xsl:if>
            <!-- if destination is on page other than a section page make it local -->
            <xsl:if test="number($sectionNumber)=1">
              <xsl:attribute name="href"><xsl:value-of select="$this-href"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$this-content"/>
          </a>
        </xsl:for-each>
        <!-- 5.2 10/18 fjc -->
        <xsl:for-each select="$all-h[@refname=$this-anchor]">
          <a xsl:exclude-result-prefixes="fo xsl">
            <!-- find the position of the section where the destination is located -->
            <xsl:variable name="sectionNumber"  select="count(ancestor::section/preceding-sibling::section) + 1"/>
            <!-- if destination will be on a section2.html or greater then make the href point to it -->
            <xsl:if test="number($sectionNumber)>1">
              <xsl:attribute name="href"><xsl:text>section</xsl:text><xsl:value-of select="$sectionNumber"/><xsl:text>.html</xsl:text><xsl:value-of select="$this-href"/></xsl:attribute>
            </xsl:if>
            <!-- if destination is on page other than a section page make it local -->
            <xsl:if test="number($sectionNumber)=1">
              <xsl:attribute name="href"><xsl:value-of select="$this-href"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$this-content"/>
          </a>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>  
       <!-- not dw-tutorial or this is a normal link -->
        <a xsl:exclude-result-prefixes="fo xsl">  
          <xsl:for-each select="@*">
            <xsl:copy/>
          </xsl:for-each>
          <xsl:apply-templates/>
        </a>  
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="Abstract">
    <!-- 5.0 05/11 tdc:  Had to fully-qualify xpaths throughout Abstract template so tutorials could use -->
    <xsl:variable name="icon">
      <xsl:for-each select="key('column-icons', series-title)">
        <xsl:value-of select="@col-icon"/>
      </xsl:for-each>
    </xsl:variable>
    <!-- 5.0 05/03 tdc:  Only use blockquotes for articles and tutorials; otherwise, surround with paragraph tags -->
    <xsl:choose>
      <xsl:when test="(. = ../dw-article) or (. = ../section)">
        <!-- 5.0 7/28 tdc:  Removed extraneous "|" after blockquote tag -->
        <xsl:text disable-output-escaping="yes"><![CDATA[<blockquote>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"><![CDATA[<p>]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$icon!=''">
        <xsl:text disable-output-escaping="yes"><![CDATA[<img src="]]></xsl:text>
        <xsl:value-of select="$col-icon-subdirectory"/>
        <xsl:value-of select="$icon"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[" border="0" alt="Column icon" height="38" width="38" align="left" />]]></xsl:text>
        <xsl:value-of select="/dw-document//abstract"/>
        <!-- 4.0 9/28 tdc:  Removed display-products-text display per Sera -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/dw-document//abstract"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="(. = ../dw-article) or (. = ../section)">
        <xsl:text disable-output-escaping="yes"><![CDATA[</blockquote>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"><![CDATA[</p>]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="AbstractExtended">
    <xsl:variable name="icon">
      <xsl:for-each select="key('column-icons', series-title)">
        <xsl:value-of select="@col-icon"/>
      </xsl:for-each>
    </xsl:variable>
    <!-- 5.0 05/03 tdc:  Only use blockquotes for articles and tutorials; otherwise, surround with paragraph tags -->
    <xsl:choose>
      <xsl:when test="(. = ../dw-article) or (. = ../section)">
        <xsl:text disable-output-escaping="yes"><![CDATA[<blockquote>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"><![CDATA[<p>]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$icon!=''">
        <xsl:text disable-output-escaping="yes"><![CDATA[<img src="]]></xsl:text>
        <xsl:value-of select="$col-icon-subdirectory"/>
        <xsl:value-of select="$icon"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[" border="0" alt="Column icon" height="38" width="38" align="left" />]]></xsl:text>
        <xsl:apply-templates select="/dw-document//abstract-extended"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- 4.0 6/21 tdc:  Deleted dup of following apply-templates statement -->
        <xsl:apply-templates select="/dw-document//abstract-extended"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- 5.0 05/03 tdc:  Only use blockquotes for articles and tutorials; otherwise, surround with paragraph tags -->
    <xsl:choose>
      <xsl:when test="(. = ../dw-article) or (. = ../section)">
        <xsl:text disable-output-escaping="yes"><![CDATA[</blockquote>]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"><![CDATA[</p>]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="AbstractForDisplay">
    <xsl:choose>
      <xsl:when test="/dw-document//abstract-extended !=''">
        <xsl:call-template name="AbstractExtended"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="Abstract"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="Audience">
    <!--  AUDIENCE -->
    <xsl:if test="audience/. !=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-audience"/>
        </span>
      </p>
      <xsl:apply-templates select="audience/*|text()"/>
    </xsl:if>
    <!--   AUDIENCE END -->
  </xsl:template>
  <xsl:template name="AuthorBottom">
    <p>
      <!-- 5.0 05/11 tdc:  Now using only one author anchor name value  -->
      <a name="author">
        <span class="atitle">
          <xsl:choose>
            <xsl:when test="count(//author) = 1">
              <xsl:value-of select="$aboutTheAuthor"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$aboutTheAuthors"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </a>
    </p>
    <xsl:for-each select="author">
      <!-- 5.0 5/11 tdc:  width="75%" for table containing tutorial author info -->
      <xsl:choose>
        <xsl:when test="/dw-document/dw-tutorial">
          <xsl:text disable-output-escaping="yes"><![CDATA[<table border="0" cellspacing="0" cellpadding="0" width="70%">]]></xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text disable-output-escaping="yes"><![CDATA[<table border="0" cellspacing="0" cellpadding="0" width="100%">]]></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <tr>
        <td colspan="2">
          <img src="{$path-ibm-i}c.gif" height="5" width="100%" alt=""/>
        </td>
      </tr>
      <!-- 5.0 5/12 tdc:  Left-aligned the img/bio row -->
      <tr valign="top" align="left">
        <td>
          <p>
            <xsl:apply-templates select="./img"/>
          </p>
        </td>
        <td>
          <p>
            <xsl:apply-templates select="./bio"/>
          </p>
          <!-- ON HOLD:  Automating the link to the view of more articles from this author. -->
        </td>
      </tr>
      <xsl:text disable-output-escaping="yes"><![CDATA[</table>]]></xsl:text>
      <!-- 5.0 5/18 fjc add a br -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
    </xsl:for-each>
    <xsl:if test=". = ../dw-article">
      <xsl:copy-of select="$ssi-s-backlink-rule"/>
    </xsl:if>
  </xsl:template>
  <xsl:template name="AuthorBottomSummary">
  <!-- 5.2 09/20 fjc: Test for bio first-->
    <xsl:if test="/dw-document//bio">
      <p>
        <a name="author">
          <span class="smalltitle">
            <xsl:choose>
            <!-- 5.2 10/14 fjc: -->
              <xsl:when test="/dw-document/dw-summary-podcast" >
                <xsl:value-of select="$summary-podcastCredits"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>                
                    <xsl:when test="(count(//author-summary/bio) = 1)or(count(//author/bio) = 1)">
                      <xsl:value-of select="$aboutTheAuthor"/>
                    </xsl:when>
                    <xsl:when test="(count(//author-summary) > 1)or(count(//author) > 1)">
                      <xsl:value-of select="$aboutTheAuthors"/>
                    </xsl:when>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </a>
      </p>
      <xsl:for-each select="/dw-document//author/bio">
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
            <td colspan="2">
              <img src="{$path-ibm-i}c.gif" height="5" width="100%" alt=""/>
            </td>
          </tr>
          <tr valign="top">
            <td>
              <p>
                <xsl:apply-templates select="../img"/>
              </p>
            </td>
            <td>
              <p>
                <xsl:apply-templates select="../bio"/>
              </p>
              <!-- ON HOLD:  Automating the link to the view of more articles from this author. -->
            </td>
          </tr>
        </table>
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:for-each>
      <!-- 5.2 09/20 fjc:  need to separate author-summary -->
      <xsl:for-each select="/dw-document//author-summary/bio">
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
            <td colspan="2">
              <img src="{$path-ibm-i}c.gif" height="5" width="100%" alt=""/>
            </td>
          </tr>
          <tr valign="top">
            <td>
              <p>
                <xsl:apply-templates select="../img"/>
              </p>
            </td>
            <td>
              <p>
                <xsl:apply-templates select="../bio"/>
              </p>
              <!-- ON HOLD:  Automating the link to the view of more articles from this author. -->
            </td>
          </tr>
        </table>
        <!-- 5.0 5/18 fjc add a br -->
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:for-each>
    </xsl:if>
    <!--  SUMAUTHORBOTTOM END -->
  </xsl:template>  <xsl:template name="InstructorBottomSummary">
    <!--  SUMINSTRUCTORBOTTOM -->
    <!-- 5.2 09/20 fjc: Test for bio first-->
    <xsl:if test="(instructor) and (/dw-document//bio)">
      <p>
        <a name="instructor">
          <span class="smalltitle">
            <xsl:choose>
              <xsl:when test="count(//instructor/bio) = 1">
                <xsl:value-of select="$summary-aboutTheInstructor"/>
              </xsl:when>
              <xsl:when test="count(//instructor/bio) > 1">
                <xsl:value-of select="$summary-aboutTheInstructors"/>
              </xsl:when>
            </xsl:choose>
          </span>
        </a>
      </p>
      <xsl:for-each select="instructor/bio">
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
            <td colspan="2">
              <img src="{$path-ibm-i}c.gif" height="5" width="100%" alt=""/>
            </td>
          </tr>
          <tr valign="top">
            <td>
              <p>
                <xsl:apply-templates select="../img"/>
              </p>
            </td>
            <td>
              <p>
                <xsl:apply-templates select="../bio"/>
              </p>
              <!-- ON HOLD:  Automating the link to the view of more articles from this author. -->
            </td>
          </tr>
        </table>
        <!-- 5.0 5/18 fjc add a br -->
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  <xsl:template name="AuthorTop">
    <p>
      <!-- 5.0 05/10 tdc:  Made xpath for author test fully qualified so each tutorial/section could use-->
      <xsl:for-each select="/dw-document//author">
        <xsl:if test="./bio!=''">
          <!-- 5.0 05/12 tdc:  When tutorial, link to authors page; otherwise go to #author -->
          <!-- 5.0 05/11 tdc:  All author anchor href values now identical -->
          <xsl:choose>
            <xsl:when test="/dw-document/dw-tutorial">
              <xsl:text disable-output-escaping="yes"><![CDATA[<a href="authors.html">]]></xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text disable-output-escaping="yes"><![CDATA[<a href="#author">]]></xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="name">
            <xsl:apply-templates select="name"/>
          </xsl:when>
          <xsl:when test="author-name">
            <!-- 5.2 9/14/05 tdc:  Test should be if Prefix is null -->
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(author-name/Prefix) !=''">
              <xsl:value-of select="author-name/Prefix"/>
              <!-- <xsl:apply-templates select="Prefix"/> -->
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- 5.0 5/12 tdc:  Corrected xpath for GivenName -->
            <xsl:apply-templates select="author-name/GivenName"/>
            <xsl:text> </xsl:text>
            <!-- 5.2 9/14./05 tdc:  Test should be if MiddleName is null -->
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(author-name/MiddleName) !=''">
              <xsl:apply-templates select="author-name/MiddleName"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="author-name/FamilyName"/>
            <!-- 5.2 9/14/05 tdc:  Test if suffix is present before adding a space before it -->
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(author-name/Suffix) !=''">
              <!-- 5.2 9/15/05 tdc:  Added comma per Sarah Furr -->
              <xsl:text>, </xsl:text>
              <xsl:value-of select="author-name/Suffix"/>
            </xsl:if>
            <!-- 5.2 9/14/05 tdc:  Delete space that was here; there's a space before the parenthetical e-mail phrase already. -->
          </xsl:when>
        </xsl:choose>
        <xsl:if test="./bio!=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="/dw-document//@local-site='worldwide'">
            <!-- 4.0 10/14 tdc:  Corrected @email_cc to @email-cc -->
            <!-- 4.1 01/04/05 tdc:  Corrected mailto delimeter and added test for @email-cc occurence -->
            <xsl:if test="@email and @email!=''">
              <xsl:text disable-output-escaping="yes"><![CDATA[ (<a href="mailto:]]></xsl:text>
              <xsl:value-of select="@email"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[?subject=]]></xsl:text>
              <xsl:value-of select="/dw-document//title"/>
              <xsl:if test="@email-cc !=''">
                <xsl:text disable-output-escaping="yes"><![CDATA[&amp;cc=]]></xsl:text>
                <xsl:value-of select="@email-cc"/>
              </xsl:if>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <xsl:value-of select="@email"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>)]]></xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        <xsl:if test="@jobtitle='' and company-name=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <b>
            <font color="red">
              <xsl:value-of select="$job-co-errormsg"/>
            </font>
          </b>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </xsl:if>
        <xsl:if test="@jobtitle!=''">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="@jobtitle"/>
          <xsl:if test="company-name!=''">, </xsl:if>
        </xsl:if>
        <xsl:if test="company-name">
          <xsl:value-of select="company-name"/>
        </xsl:if>
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:for-each>
    </p>
  </xsl:template>
  <xsl:template name="AuthorTopSummary">
    <xsl:if test="(author-tutorial-summary!='') or (author-summary!='') or (author!='')">
      <!-- 5/16 fjc so that instructor could follow without a line space  -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<p>]]></xsl:text>
      <xsl:for-each select="author-tutorial-summary|author-summary|author">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- AUTHOR NAME GOES HERE -->]]></xsl:text>
        <xsl:if test="./bio!=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[<a href="#author">]]></xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="name/. !=''">
            <xsl:apply-templates select="name"/>
          </xsl:when>
          <xsl:when test="contributor-name">
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(contributor-name/Prefix) !=''">
              <xsl:value-of select="contributor-name/Prefix "/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- First Name required-->
            <xsl:apply-templates select="contributor-name/GivenName"/>
            <xsl:text> </xsl:text>
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(contributor-name/MiddleName) !=''">
              <xsl:apply-templates select="contributor-name/MiddleName"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- Last Name required-->
            <xsl:apply-templates select="contributor-name/FamilyName"/>
            <!-- 5.2 9/18/05 tdc:  Testing for blank suffix now -->
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(contributor-name/Suffix) !=''">
              <!-- 5.2 9/16/05 tdc:  Added comma per Sarah Furr -->
              <xsl:text>, </xsl:text>
              <xsl:apply-templates select="contributor-name/Suffix"/>
            </xsl:if>
          </xsl:when>
          <!-- 5.1 9/1/05 tdc:  Start author-name case -->
          <xsl:when test="author-name">
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(author-name/Prefix) !=''">
              <xsl:value-of select="author-name/Prefix "/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- First Name required-->
            <xsl:apply-templates select="author-name/GivenName"/>
            <xsl:text> </xsl:text>
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(author-name/MiddleName) !=''">
              <xsl:apply-templates select="author-name/MiddleName"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- Last Name required-->
            <xsl:apply-templates select="author-name/FamilyName"/>
            <!-- 5.2 9/18/05 tdc:  Testing for blank suffix now -->
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(author-name/Suffix) !=''">
              <!-- 5.2 9/16/05 tdc:  Added comma per Sarah Furr -->
              <xsl:text>, </xsl:text>
              <xsl:apply-templates select="author-name/Suffix"/>
            </xsl:if>
          </xsl:when>
          <!-- 5.1 9/1/05 tdc:  End author-name case -->
        </xsl:choose>
        <xsl:if test="./bio!=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="/dw-document//@local-site='worldwide'">
            <!-- 4.0 10/14 tdc:  Corrected @email_cc to @email-cc -->
            <!-- 4.1 01/04/05 tdc:  Corrected mailto delimeter and added test for @email-cc occurence -->
            <xsl:if test="@email and @email!=''">
              <xsl:text disable-output-escaping="yes"><![CDATA[ (<a href="mailto:]]></xsl:text>
              <xsl:value-of select="@email"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[?subject=]]></xsl:text>
              <xsl:value-of select="/dw-document//title"/>
              <xsl:if test="@email-cc !=''">
                <xsl:text disable-output-escaping="yes"><![CDATA[&amp;cc=]]></xsl:text>
                <xsl:value-of select="@email-cc"/>
              </xsl:if>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <xsl:value-of select="@email"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>)]]></xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        <xsl:if test="@jobtitle='' and company-name=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <b>
            <font color="red">
              <xsl:value-of select="$job-co-errormsg"/>
            </font>
          </b>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </xsl:if>
        <xsl:if test="@jobtitle !=''">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="@jobtitle"/>
          <xsl:if test="company-name!=''">, </xsl:if>
        </xsl:if>
        <xsl:if test="company-name">
          <xsl:value-of select="company-name"/>
        </xsl:if>
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:for-each>
      <!-- 5/16 fjc so that instructor could follow without a line space  -->
      <xsl:if test="not(/dw-document/dw-summary-demo/instructor)">
        <xsl:text disable-output-escaping="yes"><![CDATA[</p>]]></xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <!-- BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB -->
  <!-- 5.0 05/25 tdc:  Added match="b" -->
  <xsl:template match="b">
    <xsl:choose>
      <xsl:when test="@class='red'">
        <span class="rboldcode">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@class='blue'">
        <span class="bboldcode">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@class='green'">
        <span class="gboldcode">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="ancestor::code">
        <span class="boldcode">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <b xsl:exclude-result-prefixes="xsl fo">
          <xsl:for-each select="@*">
            <xsl:copy/>
          </xsl:for-each>
          <xsl:apply-templates/>
        </b>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Added to common from dw-landing product -->
  <xsl:template name="BottomLinks">
    <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
    <xsl:copy-of select="$path-dw-inc"/>
    <xsl:text disable-output-escaping="yes"><![CDATA[s-bottomlinks.inc" -->]]></xsl:text>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Added to common from dw-landing product -->
  <xsl:template name="BrandImage">
    <table border="0" cellpadding="0" cellspacing="0" width="150">
      <tr>
        <td>
          <xsl:variable name="content-area-alt-name">
            <xsl:call-template name="ContentAreaInputName">
              <xsl:with-param name="contentarea">
                <!-- 5.2 9/14 jpp/tdc Fixed test to pick up name attribute -->
                <xsl:value-of select="content-area-primary/@name"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="content-area-logo-url">
            <xsl:call-template name="BrandImageURL">
              <xsl:with-param name="brand-image-url">
                <xsl:value-of select="content-area-primary"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <!-- 5.2 9/14 jpp Added conditional code to leave out logo image on Workplace pages -->
          <xsl:choose>
            <xsl:when test="content-area-primary/@name='workplace'">
            </xsl:when>
            <xsl:otherwise>
              <xsl:text disable-output-escaping="yes"><![CDATA[<img alt="]]></xsl:text>
              <xsl:value-of select="$content-area-alt-name"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[ logo" border="0" height="26" width="140" src="]]></xsl:text>
              <xsl:value-of select="$content-area-logo-url"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[" />]]></xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </table>
    <!-- 5.2 9/14 jpp Added conditional code to leave out br tag for Workplace pages -->
    <xsl:choose>
      <xsl:when test="content-area-primary/@name='workplace'">              
      </xsl:when>
      <xsl:otherwise>
        <!-- Spacer -->
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Moved to common from landing product -->
  <xsl:template name="BrandImageURL">
    <xsl:param name="brand-image-url"/>
    <xsl:choose>
      <xsl:when test="content-area-primary/@name='db2'">
        <xsl:value-of select="$path-dw-images"/>d-dm_logo.gif</xsl:when>
      <xsl:when test="content-area-primary/@name='eserver'">
        <xsl:value-of select="$path-dw-images"/>d-es_logo.gif</xsl:when>
      <xsl:when test="content-area-primary/@name='lotus'">
        <xsl:value-of select="$path-dw-images"/>d-ls_logo.gif</xsl:when>
      <xsl:when test="content-area-primary/@name='rational'">
        <xsl:value-of select="$path-dw-images"/>d-r_logo.gif</xsl:when>
      <xsl:when test="content-area-primary/@name='tivoli'">
        <xsl:value-of select="$path-dw-images"/>d-tv_logo.gif</xsl:when>
      <xsl:when test="content-area-primary/@name='websphere'">
        <xsl:value-of select="$path-dw-images"/>d-w_logo.gif</xsl:when>
      <!-- Workplace placeholder:  As of 8/24/05, Tara says no Workplace logo needed -->
    </xsl:choose>
  </xsl:template>
  <xsl:template name="BreadcrumbTitle">
    <!-- 5.2 tdc:  Are there any considerations nec. for russia and brazil in this template? -->
    <!-- 5.0 5/11 tdc:  Made all xpaths for content-area-xx fully-qualified so tutorials could use -->
    <td width="10" height="18">
      <img src="{$path-ibm-i}c.gif" width="10" height="18" alt=""/>
    </td>
    <td width="100%">
      <img src="{$path-ibm-i}c.gif" width="1" height="6" alt=""/>
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      <xsl:choose>
        <xsl:when test="/dw-document//content-area-primary/@name='none'">
          <a class="bctl" href="{$developerworks-top-url}">
            <xsl:value-of select="$developerworks-top-heading"/>
          </a>
        </xsl:when>
        <!--<xsl:otherwise>
          <xsl:choose>-->
        <!-- 4.1 llk 10/21: added contingency that local-site is worldwide -->
        <!-- 5.2 9/27:  llk remove this condition; opensource now treated same as other content areas -->
        <!--<xsl:when test="/dw-document//content-area-primary/@name='opensource' and /dw-document//@local-site='worldwide'">
              <a class="bctl" href="{$developerworks-top-url}">
                <xsl:value-of select="$developerworks-top-heading"/>
              </a>
              <span class="bct">&nbsp;&nbsp;&gt;&nbsp;&nbsp;</span>
              <xsl:text disable-output-escaping="yes"><![CDATA[<a class="bctl" href="http://www.ibm.com/developerworks/opensource/">]]></xsl:text>
              <xsl:call-template name="ContentAreaName">
                <xsl:with-param name="contentarea">
                  <xsl:value-of select="/dw-document//content-area-primary/@name"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
            </xsl:when>-->
        <!-- 4.1 llk 10/21: added coding to handle local korean server contingency that /oss/ url value for opensource -->
        <!-- 5.0.1 9/6 llk: korea server contingency is no longer; condition should be removed, tom you can remove code from final v5.2 stylesheet -->
        <!--
            <xsl:when test="/dw-document//content-area-primary/@name='opensource' and /dw-document//@local-site='korea'">
              <a class="bctl" href="{$developerworks-top-url}">
                <xsl:value-of select="$developerworks-top-heading"/>
              </a>
              <span class="bct">&nbsp;&nbsp;&gt;&nbsp;&nbsp;</span>
              <xsl:text disable-output-escaping="yes"><![CDATA[<a class="bctl" href="http://www-903.ibm.com/developerworks/kr/oss/">]]></xsl:text>
              <xsl:call-template name="ContentAreaName">
                <xsl:with-param name="contentarea">
                  <xsl:value-of select="content-area-primary/@name"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
            </xsl:when>
-->
        <xsl:otherwise>
          <a class="bctl" href="{$developerworks-top-url}">
            <xsl:value-of select="$developerworks-top-heading"/>
          </a>
          <span class="bct">&nbsp;&nbsp;&gt;&nbsp;&nbsp;</span>
          <xsl:text disable-output-escaping="yes"><![CDATA[<a class="bctl" href="]]></xsl:text>
          <xsl:value-of select="$developerworks-top-url"/>
          <xsl:value-of select="/dw-document//content-area-primary/@name"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[/">]]></xsl:text>
          <xsl:call-template name="ContentAreaName">
            <xsl:with-param name="contentarea">
              <xsl:value-of select="/dw-document//content-area-primary/@name"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <!-- </xsl:otherwise>
      </xsl:choose>-->
      <!-- 5.2 8/22/05 tdc:  Removed test for 'subscription' content area -->
      <!-- 5.1 08/02/2005 jpp: Adds processing for product-landing pages to insert link back to main Products page -->
      <xsl:if test="/dw-document/dw-landing-product">
        <xsl:variable name="products-breadcrumb-url">
          <xsl:call-template name="ProductsLandingURL">
            <xsl:with-param name="product-landing-url">
              <xsl:value-of select="/dw-document//content-area-primary/@name"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($products-breadcrumb-url)">
          <span class="bct">&nbsp;&nbsp;&gt;&nbsp;&nbsp;</span>
          <xsl:text disable-output-escaping="yes"><![CDATA[<a class="bctl" href="]]></xsl:text>
          <xsl:value-of disable-output-escaping="yes" select="$products-breadcrumb-url"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
          <xsl:value-of disable-output-escaping="yes" select="$products-heading"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </xsl:if>
      </xsl:if>
      <!-- 4.0 05/18 tdc:  end of content-area-primary processing -->
      <!-- 4.0 05/18 tdc:  start of content-area-secondary processing -->
      <xsl:choose>
        <xsl:when test="/dw-document//content-area-secondary or /dw-document//content-area-secondary/@name !='none'">
          <span class="bct">&nbsp;|&nbsp;</span>
          <xsl:for-each select="/dw-document//content-area-secondary">
            <!-- 5.2 9/27 llk: remove the condition; opensource now treated like all other content areas-->
            <!--<xsl:choose>
              <xsl:when test="@name='opensource'">
                <a class="bctl" href="http://www-124.ibm.com/developerworks/oss/">
                  <xsl:call-template name="ContentAreaName">
                    <xsl:with-param name="contentarea">
                      <xsl:value-of select="@name"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </a>
              </xsl:when>
              <xsl:otherwise>-->
            <a class="bctl" href="{$developerworks-top-url}{@name}/">
              <xsl:call-template name="ContentAreaName">
                <xsl:with-param name="contentarea">
                  <xsl:value-of select="@name"/>
                </xsl:with-param>
              </xsl:call-template>
            </a>
            <!-- </xsl:otherwise>
            </xsl:choose>-->
            <!-- 4.0 6/16 tdc:  Added greater-than symbol after last entry in bc trail -->
            <xsl:choose>
              <xsl:when test="position()!=last()">
                <span class="bct">&nbsp;|&nbsp;</span>
              </xsl:when>
              <xsl:otherwise>
                <span class="bct">&nbsp;&nbsp;&gt;</span>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <span class="bct">&nbsp;&nbsp;&gt;</span>
        </xsl:otherwise>
      </xsl:choose>
      <img src="{$path-ibm-i}c.gif" width="1" height="1" alt=""/>
      <!-- Page title -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      <xsl:call-template name="DisplayTitles"/>
      <img class="display-img" src="{$path-ibm-i}c.gif" width="1" height="6" alt=""/>
    </td>
    <!-- 5.0 6/10 tdc:  Changed include to variable -->
    <xsl:copy-of select="$ssi-s-site-identifier"/>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd:  Moved to common from dw-landing -->
  <xsl:template name="BulletedLinkAbstracts">
    <xsl:for-each select="link-abstracts">
      <tr valign="top">
        <td>
          <img width="2" src="{$path-v14-bullets}bl-bullet.gif" height="8" class="bullet-spacer" alt=""/>
          <img src="{$path-ibm-i}c.gif" border="0" width="1" height="1" alt=""/>
        </td>
        <td>
          <a href="{url}" class="smallplainlink">
            <b>
              <xsl:value-of select="text"/>
            </b>
          </a>
          <!-- 5.0.1 9/21 this break tag did not have cdata tags around it -->
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <span class="small">
            <xsl:value-of select="abstract-text"/>
          </span>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <img width="1" src="{$path-ibm-i}c.gif" height="8" alt=""/>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Moved to common from landing product -->
  <xsl:template name="BulletedLinks">
    <tr valign="top">
      <td>
        <img width="2" src="{$path-v14-bullets}bl-bullet.gif" height="8" class="bullet-spacer" alt=""/>
        <img src="{$path-ibm-i}c.gif" border="0" width="1" height="1" alt=""/>
      </td>
      <td>
        <a href="{url}" class="smallplainlink">
          <xsl:value-of select="text"/>
        </a>
      </td>
    </tr>
    <tr>
      <td colspan="2">
        <img width="1" src="{$path-ibm-i}c.gif" height="8" alt=""/>
      </td>
    </tr>
  </xsl:template>
  <!-- CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC -->
  <xsl:template match="caption">
    <caption>
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates select="*|text()"/>
    </caption>
  </xsl:template>
  <xsl:template match="code">
    <xsl:if test="@type='inline' or not(@type)">
      <code>
        <xsl:apply-templates/>
      </code>
    </xsl:if>
    <xsl:if test="@type='section'">
      <xsl:apply-templates select="heading"/>
      <xsl:if test="@width">
        <xsl:choose>
          <xsl:when test="contains(@width, '%')">
            <!-- 5.2 10/06/05 tdc:  Changed bgcolor from cccccc to eeeeee -->
            <table border="1" cellspacing="0" cellpadding="5" width="{@width}" bgcolor="#eeeeee">
              <tr>
                <td>
                  <pre>
                    <code class="section">
                      <xsl:apply-templates select="*[not(name() = 'heading')] | text()"/>
                    </code>
                  </pre>
                </td>
              </tr>
            </table>
          </xsl:when>
          <xsl:when test="not(contains(@width, '%'))">
            <xsl:choose>
              <xsl:when test="@width&lt;=600">
                <table border="1" cellspacing="0" cellpadding="5" width="{@width}" bgcolor="#eeeeee">
                  <tr>
                    <td>
                      <pre>
                        <code class="section">
                          <xsl:for-each select="*|text()">
                            <xsl:if test="not(self::heading)">
                              <xsl:apply-templates select="."/>
                            </xsl:if>
                          </xsl:for-each>
                        </code>
                      </pre>
                    </td>
                  </tr>
                </table>
              </xsl:when>
              <xsl:when test="@width>600">
                <table border="1" cellspacing="0" cellpadding="5" width="600" bgcolor="#eeeeee">
                  <tr>
                    <td>
                      <pre>
                        <code class="section">
                          <xsl:for-each select="*|text()">
                            <xsl:if test="not(self::heading)">
                              <xsl:apply-templates select="."/>
                            </xsl:if>
                          </xsl:for-each>
                        </code>
                      </pre>
                    </td>
                  </tr>
                </table>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="not(@width!='')">
        <table border="1" cellspacing="0" cellpadding="5" width="100%" bgcolor="#eeeeee">
          <tr>
            <td>
              <pre>
                <code class="section">
                  <xsl:for-each select="*|text()">
                    <xsl:if test="not(self::heading)">
                      <xsl:apply-templates select="."/>
                    </xsl:if>
                  </xsl:for-each>
                </code>
              </pre>
            </td>
          </tr>
        </table>
      </xsl:if>
      <!-- 5.0 05/03 tdc:  Added break tag to be more consistent with spacing before code section -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Moved to common from landing product -->
  <xsl:template name="ColumnLinks">
    <tr valign="top">
      <td width="18">
        <img src="{$path-v14-icons}fw.gif" width="16" height="16" hspace="2" alt=""/>
      </td>
      <td width="200">
        <a class="fbox" href="{url}">
          <xsl:value-of select="text"/>
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template name="CompanyName">
    <!-- COMPANY NAME-->
    <xsl:if test="company-name/. !=''">
      <p>
        <xsl:value-of select="$summary-contributors"/>
        <xsl:for-each select="company-name">
          <xsl:if test="position() > 1">
            <xsl:text disable-output-escaping="yes"><![CDATA[, ]]></xsl:text>
          </xsl:if>
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </p>
    </xsl:if>
  </xsl:template>
  <xsl:template name="ContentAreaInputName">
    <!-- 5.0.1 llk 7/23 - updated with variables; local teams translate some of them -->
    <xsl:param name="contentarea"/>
    <xsl:choose>
      <xsl:when test="$contentarea = 'autonomic' ">
        <xsl:value-of select="$contentarea-ui-name-au"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'components' ">
        <xsl:value-of select="$contentarea-ui-name-co"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'db2' ">
        <xsl:value-of select="$contentarea-ui-name-db2"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'eserver' ">
        <xsl:value-of select="$contentarea-ui-name-es"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'grid' ">
        <xsl:value-of select="$contentarea-ui-name-gr"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'ibm' ">
        <xsl:value-of select="$contentarea-ui-name-i"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'java' ">
        <xsl:value-of select="$contentarea-ui-name-j"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'linux' ">
        <xsl:value-of select="$contentarea-ui-name-l"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'lotus' ">
        <xsl:value-of select="$contentarea-ui-name-lo"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'opensource' ">
        <xsl:value-of select="$contentarea-ui-name-os"/>
      </xsl:when>
      <!-- 4.0 9/28 tdc:  Added 'technology' -->
      <!-- 4.0 9/15 tdc:  Added power -->
      <xsl:when test="$contentarea = 'power' ">
        <xsl:value-of select="$contentarea-ui-name-pa"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'rational' ">
        <xsl:value-of select="$contentarea-ui-name-r"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'security' ">
        <xsl:value-of select="$contentarea-ui-name-s"/>
      </xsl:when>
      <!-- 5.2 8/22/05 tdc:  Removed 'subscription' -->
      <xsl:when test="$contentarea = 'tivoli' ">
        <xsl:value-of select="$contentarea-ui-name-tiv"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'web' ">
        <xsl:value-of select="$contentarea-ui-name-wa"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'webservices' ">
        <xsl:value-of select="$contentarea-ui-name-ws"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'websphere' ">
        <xsl:value-of select="$contentarea-ui-name-web"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'wireless' ">
        <xsl:value-of select="$contentarea-ui-name-wi"/>
      </xsl:when>
      <!-- 5.2 8/24/05 tdc:  Added workplace -->
      <xsl:when test="$contentarea = 'workplace' ">
        <xsl:value-of select="$contentarea-ui-name-wp"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'xml' ">
        <xsl:value-of select="$contentarea-ui-name-x"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- 5.0 5/17 tdc:   Added ContentAreaMetaKeyword; works with keywords template for Search -->
  <xsl:template name="ContentAreaMetaKeyword">
    <xsl:param name="contentarea"/>
    <xsl:choose>
      <!-- 5.2 8/.24/005 tdc:  Changed "if" tests to "choose/when" tests -->
      <xsl:when test="$contentarea = 'autonomic'">, tttacca</xsl:when>
      <xsl:when test="$contentarea = 'db2'">, ddddmca</xsl:when>
      <xsl:when test="$contentarea = 'eserver'">, dddesca</xsl:when>
      <xsl:when test="$contentarea = 'grid'">, tttgrca</xsl:when>
      <xsl:when test="$contentarea = 'ibm'">, ddditca</xsl:when>
      <xsl:when test="$contentarea = 'java'">, tttjca</xsl:when>
      <xsl:when test="$contentarea = 'linux'">, tttlca</xsl:when>
      <xsl:when test="$contentarea = 'lotus'">, dddlsca</xsl:when>
      <xsl:when test="$contentarea = 'opensource'">, tttosca</xsl:when>
      <xsl:when test="$contentarea = 'power'">, tttpaca</xsl:when>
      <xsl:when test="$contentarea = 'rational'">, dddrca</xsl:when>
      <xsl:when test="$contentarea = 'tivoli'">, dddtdvca</xsl:when>
      <xsl:when test="$contentarea = 'web'">, tttwaca</xsl:when>
      <xsl:when test="$contentarea = 'webservices'">, tttwsca</xsl:when>
      <xsl:when test="$contentarea = 'websphere'">, dddwca</xsl:when>
      <xsl:when test="$contentarea = 'wireless'">, tttwica</xsl:when>
      <!-- 5.2 8/24/05 tdc:  Added workplace -->
      <xsl:when test="$contentarea = 'workplace'">, dddwpca</xsl:when>
      <xsl:when test="$contentarea = 'xml'">, tttxca</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="ContentAreaList">
    <!-- 5.0 4/6 tdc:  Must handle content-area-primary + content-area-secondary -->
    <xsl:value-of select="//content-area-primary/@name"/>
    <xsl:text>, </xsl:text>
    <xsl:for-each select="//content-area-secondary">
      <xsl:choose>
        <xsl:when test="position()=last()">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@name"/>
          <xsl:text>, </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="ContentAreaName">
    <xsl:param name="contentarea"/>
    <xsl:choose>
      <xsl:when test="$contentarea = 'autonomic' ">
        <xsl:copy-of select="$contentarea-ui-name-au"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'grid' ">
        <xsl:copy-of select="$contentarea-ui-name-gr"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'java' ">
        <xsl:copy-of select="$contentarea-ui-name-j"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'linux' ">
        <xsl:copy-of select="$contentarea-ui-name-l"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'opensource' ">
        <xsl:copy-of select="$contentarea-ui-name-os"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'webservices' ">
        <xsl:copy-of select="$contentarea-ui-name-ws"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'xml' ">
        <xsl:copy-of select="$contentarea-ui-name-x"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'components' ">
        <xsl:copy-of select="$contentarea-ui-name-co"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'security' ">
        <xsl:copy-of select="$contentarea-ui-name-s"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'web' ">
        <xsl:copy-of select="$contentarea-ui-name-wa"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'wireless' ">
        <xsl:copy-of select="$contentarea-ui-name-wi"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'ibm' ">
        <xsl:copy-of select="$contentarea-ui-name-i"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'db2' ">
        <xsl:copy-of select="$contentarea-ui-name-db2"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'eserver' ">
        <xsl:copy-of select="$contentarea-ui-name-es"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'lotus' ">
        <xsl:copy-of select="$contentarea-ui-name-lo"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'rational' ">
        <xsl:copy-of select="$contentarea-ui-name-r"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'tivoli' ">
        <xsl:copy-of select="$contentarea-ui-name-tiv"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'websphere' ">
        <xsl:copy-of select="$contentarea-ui-name-web"/>
      </xsl:when>
      <!-- 5.2 8/24/05 tdc:  Added workplace -->
      <xsl:when test="$contentarea= 'workplace' ">
        <xsl:copy-of select="$contentarea-ui-name-wp"/>
      </xsl:when>
      <!-- 5.2 8/22/05 tdc:  Removed 'subscription' -->
      <!-- 4.0 9/15 tdc:  Added power -->
      <xsl:when test="$contentarea= 'power' ">
        <xsl:copy-of select="$contentarea-ui-name-pa"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="CourseType">
    <!-- 5.0 5/18 fjc wrong strings were called -->
    <xsl:value-of select="$summary-courseType"/>
    <xsl:text disable-output-escaping="yes"> </xsl:text>
    <xsl:if test="/dw-document/dw-summary-training/@course-type='web-based'">
      <xsl:value-of select="$summary-webBasedTraining"/>
    </xsl:if>
    <xsl:if test="/dw-document/dw-summary-training/@course-type='online-instructor'">
      <xsl:value-of select="$summary-instructorLedTraining"/>
    </xsl:if>
    <xsl:if test="/dw-document/dw-summary-training/@course-type='classroom'">
      <xsl:value-of select="$summary-classroomTraining"/>
    </xsl:if>
  </xsl:template>
  <!-- DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD -->
  <!-- 5.2 tdc:  Do we need special date handling for russia or brazil in this template? -->
  <!-- 5.1 7/8/05 JPP/Eliz:  Updated date handling for the dw-landing-product content type -->
  <xsl:template name="Dates">
    <!-- here is coding for dates on worldwide site -->
    <p>
      <xsl:choose>
        <!-- 5.1 7/8/05 JPP/Eliz.  Added when test for dw-landing-product content type; prevents display of date published -->
        <xsl:when test="/dw-document/dw-landing-product"/>
        <xsl:when test="/dw-document//@local-site='worldwide'">
          <xsl:variable name="monthname">
            <xsl:call-template name="MonthName">
              <xsl:with-param name="month">
                <xsl:value-of select="//date-published/@month"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:text disable-output-escaping="no"> </xsl:text>
          <xsl:if test="//date-published/@day">
            <xsl:value-of select="//date-published/@day"/>
            <xsl:copy-of select="$daychar"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="$monthname"/>
          <xsl:copy-of select="$monthchar"/>
          <xsl:text disable-output-escaping="no">  </xsl:text>
          <xsl:value-of select="//date-published/@year"/>
          <xsl:copy-of select="$yearchar"/>
        </xsl:when>
        <!-- v5.0.1 8/22 llk - add dots between dd mm yyyy of russian dates -->
        <xsl:when test="/dw-document//@local-site='russia'">
          <xsl:variable name="monthname">
            <xsl:call-template name="MonthName">
              <xsl:with-param name="month">
                <xsl:value-of select="//date-published/@month"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:text disable-output-escaping="no"> </xsl:text>
          <xsl:if test="//date-published/@day">
            <xsl:value-of select="//date-published/@day"/>
            <xsl:copy-of select="$daychar"/>
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:value-of select="$monthname"/>
          <xsl:copy-of select="$monthchar"/>
          <xsl:text disable-output-escaping="no">.</xsl:text>
          <xsl:value-of select="//date-published/@year"/>
          <xsl:copy-of select="$yearchar"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//date-published/@year"/>
          <xsl:copy-of select="$yearchar"/>
          <xsl:text disable-output-escaping="no">  </xsl:text>
          <xsl:variable name="monthname">
            <xsl:call-template name="MonthName">
              <xsl:with-param name="month">
                <xsl:value-of select="//date-published/@month"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$monthname"/>
          <xsl:copy-of select="$monthchar"/>
          <xsl:text disable-output-escaping="no">  </xsl:text>
          <xsl:if test="//date-published/@day!=''">
            <xsl:value-of select="//date-published/@day"/>
            <xsl:copy-of select="$daychar"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="/dw-document//@local-site='worldwide'">
          <!-- 5.0 5/12 tdc:  Changed xpath for date-updated so tutorials can use -->
          <xsl:if test="//date-updated">
            <xsl:variable name="monthupdatedname">
              <xsl:call-template name="MonthName">
                <xsl:with-param name="month">
                  <xsl:value-of select="//date-updated/@month"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <!-- 5.1 7/8/05 JPP/Eliz.  Added test to remove br tag for dw-landing-product content type  -->
            <xsl:if test="not(/dw-document/dw-landing-product)">
              <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </xsl:if>
            <xsl:if test="/dw-document/dw-landing-product">
              <xsl:text disable-output-escaping="yes"><![CDATA[<span class="small">]]></xsl:text>
            </xsl:if>
            <xsl:value-of select="$updated"/>
            <xsl:if test="//date-updated/@day">
              <xsl:value-of select="//date-updated/@day"/>
              <xsl:copy-of select="$daychar"/>
              <xsl:text>  </xsl:text>
            </xsl:if>
            <xsl:value-of select="$monthupdatedname"/>
            <xsl:copy-of select="$monthchar"/>
            <xsl:text>  </xsl:text>
            <xsl:value-of select="//date-updated/@year"/>
            <xsl:copy-of select="$yearchar"/>
            <xsl:if test="/dw-document/dw-landing-product">
              <xsl:text disable-output-escaping="yes"><![CDATA[</span>]]></xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:when>
        <!-- v5.0.1 8/22 llk - add dots between dd mm yyyy of russian dates -->
        <xsl:when test="/dw-document//@local-site='russia'">
          <xsl:if test="//date-updated">
            <xsl:variable name="monthupdatedname">
              <xsl:call-template name="MonthName">
                <xsl:with-param name="month">
                  <xsl:value-of select="//date-updated/@month"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <xsl:value-of select="$updated"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[ ]]></xsl:text>
            <xsl:if test="//date-updated/@day">
              <xsl:value-of select="//date-updated/@day"/>
              <xsl:copy-of select="$daychar"/>
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:value-of select="$monthupdatedname"/>
            <xsl:copy-of select="$monthchar"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="//date-updated/@year"/>
            <xsl:copy-of select="$yearchar"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <!-- 5.0 5/12 tdc:  Changed xpath for date-updated so tutorials can use -->
          <xsl:if test="//date-updated">
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <!-- lk 5/31 - added coding for the date updated area -->
            <xsl:value-of select="//date-updated/@year"/>
            <xsl:copy-of select="$yearchar"/>
            <xsl:text>  </xsl:text>
            <xsl:variable name="monthupdatedname">
              <xsl:call-template name="MonthName">
                <xsl:with-param name="month">
                  <xsl:value-of select="//date-updated/@month"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$monthupdatedname"/>
            <xsl:copy-of select="$monthchar"/>
            <xsl:text>  </xsl:text>
            <xsl:if test="//date-updated/@day">
              <xsl:value-of select="//date-updated/@day"/>
              <xsl:copy-of select="$daychar"/>
              <xsl:text>  </xsl:text>
            </xsl:if>
            <xsl:value-of select="$updated"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>
  <!-- 5.0 05/04 tdc:  Replaced "Default" template with separate Default-* templates with exclude-result-prefixes -->
  <!-- 5.0 5/25 tdc:  Added Default-b template for bold tag
  <xsl:template name="Default-b" match="b">
    <b xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </b>
  </xsl:template> 
   -->
  <xsl:template name="Default-blockquote" match="blockquote">
    <blockquote xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  <!-- 5.0 6/20 tdc:  Added br; used CDATA b/c XALAN removes space before slash -->
  <xsl:template name="Default-br" match="br">
    <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
  </xsl:template>
  <xsl:template name="Default-dd" match="dd">
    <dd xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>
  <xsl:template name="Default-dl" match="dl">
    <dl xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </dl>
  </xsl:template>
  <xsl:template name="Default-i" match="i">
    <i xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  <xsl:template name="Default-li" match="li">
    <li xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template name="Default-ol" match="ol">
    <ol xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>
  <xsl:template name="Default-pre" match="pre">
    <pre xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>
  <xsl:template name="Default-sub" match="sub">
    <sub xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>
  <xsl:template name="Default-sup" match="sup">
    <sup xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>
  <xsl:template name="Default-ul" match="ul">
    <ul xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  <xsl:template name="DisplayTitles">
    <!-- 5.0 5/11 tdc:  Made series-title, title, subtitle xpaths fully-qualified so tutorials can use -->
    <h1>
      <xsl:if test="/dw-document//series/series-title/.!=''">
        <span style="color: #999999">
          <xsl:value-of select="/dw-document//series/series-title"/>
          <xsl:text>: </xsl:text>
        </span>
      </xsl:if>
      <xsl:value-of select="/dw-document//title"/>
      <!-- 05/17 - fjc: add course number to title -->
      <xsl:if test="/dw-document/dw-summary-training/course-number/@display-in-title-area='yes'">
        <xsl:text disable-output-escaping="yes">: </xsl:text>
        <xsl:value-of select="course-number"/>
      </xsl:if>
    </h1>
    <xsl:if test="/dw-document//subtitle/.!=''">
      <p id="subtitle">
        <em>
          <xsl:value-of select="/dw-document//subtitle"/>
        </em>
      </p>
    </xsl:if>
    <!-- 05/17 fjc: write text if webspere and training and subtitile empty -->
    <xsl:if test="subtitle/.='' and /dw-document/dw-summary-training/content-area-primary/@name='websphere'">
      <p id="subtitle">
        <em>
          <xsl:value-of select="$summary-websphereTraining"/>
        </em>
      </p>
    </xsl:if>
  </xsl:template>
  <xsl:template match="div | object | param | embed">
    <xsl:element name="{name()}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="docbody">
    <xsl:apply-templates select="a | b | blockquote | br | code | dl | figure | heading | i | img | ol | p | pre | sidebar | table | sub | sup | ul | text()"/>
  </xsl:template>
  <!-- 5.0 6/2 fjc P tags not showing up -->
  <xsl:template match="//docbody//p|//overview//p|//attribution//p|//audience//p|//copyright//p|//course-number//p|//duration//p|//in-this-doc//p|//prerequisites//p|//resource//p|//system-requirements//p|//trademark//p">
    <!-- <xsl:choose>
          <xsl:when test="(not(preceding-sibling::*[1][name()='heading'][@type='sidebar'])) and (not(preceding-sibling::*[1][name()='heading'][@type='code']))">
-->
    <p>
      <xsl:apply-templates select="*|text()"/>
    </p>
    <!--   </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*|text()"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[</p>]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose> -->
  </xsl:template>
  <!-- 4.1 12/14 tdc: Added dw-summary test (again) -->
  <!-- 5.0 4/18 tdc:  don't think we need this
	<xsl:template match="dw-sidefile | dw-summary/docbody/p">
		<p>
			<xsl:apply-templates select="*|text()"/>
		</p>
	</xsl:template>
	-->
  <xsl:template name="DocumentOptions">
    <!-- 5.0 5/12 tdc:  Made xpaths fully-qualified so that tutorials could use -->
    <!-- 5.0.1 7/18 llk:  Document options was made text variable so it can be translated -->
    <!-- 5.0.1. 8/23 llk:  for local site tutorials; there are no document options until we offer pdfs; local site articles have email but not pdfs -->
    <xsl:choose>
      <!-- 5.2 9/22/05 tdc:  Removed single quote from beginning of //@local site and added single quote at beginning of 'worldwide' -->
      <!-- 5.2 10/19/05 tdc:  Removed single quotes surrounding /dw-document/dw-tutorial -->
      <xsl:when test="/dw-document/dw-tutorial and //@local-site !='worldwide'">
	</xsl:when>
      <xsl:otherwise>
        <table border="0" cellpadding="0" cellspacing="0" width="150">
          <tr>
            <td class="v14-header-1-small">
              <xsl:value-of select="$document-options-heading"/>
            </td>
          </tr>
        </table>
        <table border="0" cellpadding="0" cellspacing="0" class="v14-gray-table-border">
          <tr>
            <td width="150" class="no-padding">
              <table border="0" cellpadding="0" cellspacing="0" width="143">
                <!-- 5.0 6/10 tdc:  Changed include to variable -->
                <xsl:copy-of select="$ssi-s-doc-options-printcss"/>
                <!-- 5.0 6/1 tdc:  Start code for PDF links -->
                <!-- 5.0 6/15 tdc:  xpath changed to limit to tutorials -->
                <!-- START 5.2 10/14/05 tdc:  Order PDF links; A4 first, Letter second -->
                <xsl:if test="/dw-document/dw-tutorial/pdf/@paperSize!=''">
                  <xsl:for-each select="/dw-document/dw-tutorial/pdf[@paperSize='a4']">
                    <xsl:call-template name="PdfInfo">
                      <xsl:with-param name="pdf-alt" select="$pdf-alt-a4"/>
                      <xsl:with-param name="pdf-numpages" select="@pages"/>
                      <xsl:with-param name="pdf-size" select="@size"/>
                      <xsl:with-param name="pdf-text" select="$pdf-text-a4"/>
                      <xsl:with-param name="pdf-url" select="@url"/>
                    </xsl:call-template>
                  </xsl:for-each>
                  <xsl:for-each select="/dw-document/dw-tutorial/pdf[@paperSize='letter']">
                    <xsl:call-template name="PdfInfo">
                      <xsl:with-param name="pdf-alt" select="$pdf-alt-letter"/>
                      <xsl:with-param name="pdf-numpages" select="@pages"/>
                      <xsl:with-param name="pdf-size" select="@size"/>
                      <xsl:with-param name="pdf-text" select="$pdf-text-letter"/>
                      <xsl:with-param name="pdf-url" select="@url"/>
                    </xsl:call-template>
                  </xsl:for-each>
                  <tr valign="top">
                    <td width="8">
                      <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
                    </td>
                    <td width="16">
                      <img src="{$path-v14-icons}sout.gif" width="16" height="16" alt="" vspace="5"/>
                    </td>
                    <td width="122">
                      <p>
                        <!-- 5.0 6/8 tdc:  Adobe link should use variable text -->
                        <a class="smallplainlink" href="http://www.adobe.com/products/acrobat/readstep2.html">
                          <b>
                            <xsl:value-of select="$download-get-adobe" disable-output-escaping="yes"/>
                          </b>
                        </a>
                      </p>
                    </td>
                  </tr>
                </xsl:if>
                <!-- End PDF links -->
                <!-- END 5.2 10/14/05 tdc:  Order the PDF links - A4 first, Letter second -->
                <!-- 5.0 6/20 tdc:  E-mail link removed temporarily for tutorials - not fully supported in Boulder -->
                <!-- 5.2 fix 10/15 llk: email to friend is now valid for local site articles, but not tutorials-->
                <xsl:choose>
									<xsl:when test="//@local-site ='worldwide'">
										<!-- 5.0 6/20 tdc:  E-mail link removed temporarily for tutorials - not fully supported in Boulder -->
										<xsl:if test="not(/dw-document/dw-tutorial)">
											<!-- 5.0 6/10 tdc:  Changed include to variable -->
											<xsl:copy-of select="$ssi-s-doc-options-email"/>
										</xsl:if>
										<!-- 5.2.1 10/15 llk: email to friend is valid for local site articles, but not tutorials-->
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="not(/dw-document/dw-tutorial)">
											<xsl:variable name="titleinput">
												<xsl:call-template name="FullTitle"/>
											</xsl:variable>
											<xsl:variable name="emailabstract">
												<xsl:call-template name="FilterAbstract"/>
											</xsl:variable>
											<form name="email" action="https://www-128.ibm.com/developerworks/secure/email-it.jsp">
												<input type="hidden" name="body" value="{$emailabstract}"/>
												<input type="hidden" name="subject" value="{$titleinput}"/>
												<input type="hidden" name="lang" value="{$lang}"/>
												<!-- generate the submit button as an email-it gif -->
												<xsl:copy-of select="$ssi-s-doc-options-email"/>
											</form>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
                <xsl:if test="/dw-document//forum-url/@url !=''">
                  <tr valign="top">
                    <td width="8">
                      <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
                    </td>
                    <td width="16">
                      <img src="{$path-v14-icons}fw_bold.gif" height="16" width="16" border="0" vspace="3" alt=""/>
                    </td>
                    <td width="122">
                      <p>
                        <!-- 9/07/05 tdc:  Replaced forumwindow.js call with plain link -->
                        <!-- 5.0.1 9/6 llk:  made Discuss heading a translated string and added to translated text string files as well -->
                        <xsl:text disable-output-escaping="yes"><![CDATA[<a class="smallplainlink" href="]]></xsl:text>
                        <xsl:value-of select="/dw-document//forum-url/@url"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                        <b>
                          <xsl:value-of select="$options-discuss"/>
                        </b>
                        <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                      </p>
                    </td>
                  </tr>
                </xsl:if>
                <xsl:if test="/dw-document//target-content-file/@target-content-type='Code sample'">
                  <tr valign="top">
                    <td width="8">
                      <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
                    </td>
                    <td width="16">
                      <img src="{$path-v14-icons}dn.gif" height="16" width="16" border="0" vspace="3" alt=""/>
                    </td>
                    <td width="122">
                      <p>
                        <!-- 5.0 05/10 tdc:  Document Options Downloads link different for tutorials -->
                        <xsl:choose>
                          <xsl:when test="not(/dw-document/dw-tutorial)">
                            <a class="smallplainlink" href="#download">
                              <!-- 5.0 7/13 tdc:  made Sample code a variable -->
                              <b>
                                <xsl:value-of select="$sample-code"/>
                              </b>
                            </a>
                          </xsl:when>
                          <xsl:otherwise>
                            <a class="smallplainlink" href="downloads.html">
                              <!-- 5.0 7/13 tdc:  made Sample code a variable -->
                              <b>
                                <xsl:value-of select="$sample-code"/>
                              </b>
                            </a>
                          </xsl:otherwise>
                        </xsl:choose>
                      </p>
                    </td>
                  </tr>
                </xsl:if>
              </table>
            </td>
          </tr>
        </table>
        <!-- 5.0.1 llk: end condition that was set up at beginning of this template -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="Download">
    <!-- 5.2 tdc:  Any special handling needed for brazil or russia in this template? -->
    <xsl:variable name="downloadTableWidth">
      <xsl:choose>
        <xsl:when test="not(/dw-document/dw-tutorial)">
          <xsl:text disable-output-escaping="yes">100%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <!-- 5.0 5/12 tdc:  Changed download table width from 75 to 70% -->
          <xsl:text disable-output-escaping="yes">70%</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- IF TARGET-CONTENT-FILE -->
    <xsl:if test="target-content-file/@filename!=''">
      <!-- 5.0 7/13 tdc:  Removed DownloadSummaryTop -->
      <!-- begin download table -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      <xsl:if test=". = ../dw-article">
        <xsl:copy-of select="$ssi-s-backlink-rule"/>
      </xsl:if>
      <p>
        <xsl:choose>
          <xsl:when test=". = ../dw-article or . = ../dw-tutorial">
            <xsl:text disable-output-escaping="yes"><![CDATA[<span class="atitle">]]></xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text disable-output-escaping="yes"><![CDATA[<span class="smalltitle">]]></xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <a name="download">
          <!-- 5.0 7/13 tdc:  Changed heading values -->
          <!-- 5.2 10/19 fjc: -->
          <xsl:choose>
            <xsl:when test=". = ../dw-summary-podcast">
              <xsl:value-of select="$summary-getThePodcast"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="count(target-content-file) > 1">
                  <xsl:value-of select="$downloads-heading"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$download-heading"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </a>
        <xsl:text disable-output-escaping="yes"><![CDATA[</span>]]></xsl:text>
      </p>
      <table border="0" cellpadding="0" cellspacing="0" class="data-table-1" width="{$downloadTableWidth}">
        <tr>
          <!-- Description -->
          <xsl:if test="//target-content-file/@file-description !=''">
            <th>
              <xsl:value-of select="$download-filedescription-heading"/>
            </th>
          </xsl:if>
          <th>
            <xsl:value-of select="$download-filename-heading"/>
          </th>
          <!-- 5.0 6/2 fjc align right-->
          <th style="text-align:right;">
            <xsl:value-of select="$download-filesize-heading"/>
          </th>
          <!-- 5.2 10/19 fjc: remove space -->
          <th><xsl:value-of select="$download-method-heading"/>
          </th>
        </tr>
        <!-- CONTENT -->
        <xsl:for-each select="//target-content-file">
          <tr>
            <xsl:if test="@file-description !=''">
              <td class="tb-row">
                <xsl:value-of select="@file-description"/>
              </td>
            </xsl:if>
            <!-- 5.0 04/28 tdc:  chg nowrap="yes" to nowrap="nowrap" -->
            <td nowrap="nowrap">
              <!-- 5.2 09/20 fjc: add audio gif -->
              <xsl:if test="@file-type = 'mp3'">
                <!-- 5.2 09/28 fjc: center the image -->
                <xsl:text disable-output-escaping="yes"><![CDATA[<img src="]]></xsl:text><xsl:value-of select="$path-ibm-i"/><xsl:text disable-output-escaping="yes"><![CDATA[aud.gif" height="16" width="16" alt="audio file" align="middle" border="0" />]]></xsl:text>
              </xsl:if>
              <xsl:value-of select="@filename"/>
            </td>
            <!-- 5.0 04/28 tdc:  chg nowrap="yes" to nowrap="nowrap" -->
            <td nowrap="nowrap" style="text-align:right;">
              <xsl:value-of select="@size"/>
            </td>
            <!-- 5.0 04/28 tdc:  chg nowrap="yes" to nowrap="nowrap" -->
            <td nowrap="nowrap">
              <xsl:if test="@link-method-ftp = 'yes'">
                <xsl:choose>
                  <!-- LOCAL SITES DON'T USE LICENSE DISPLAY SERVLETS -->
                  <xsl:when test="//@local-site != 'worldwide'">
                    <!-- 5.2 09/15/05 jpp:  Added xsl:choose to add onclick and onkeypress attributes to PDF links so PDF requests are captured by SurfAid -->
                    <xsl:choose>
                      <xsl:when test="@file-type= 'pdf' ">
                              &nbsp;<xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" onclick="sa_onclick(this.href)" onkeypress="sa_onclick(this.href)" href="]]></xsl:text>
                        <xsl:value-of select="@url-ftp"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                        <b>FTP</b>
                        <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                              &nbsp;<xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text>
                        <xsl:value-of select="@url-ftp"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                        <b>FTP</b>
                        <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <!-- end of ftp link for local sites -->
                  <xsl:otherwise>
                    <!-- this is a worldwide site -->
                    <xsl:choose>
                      <!-- Only files with @content-type of 'Code sample' should have license display servlet-style URL -->
                      <xsl:when test="@target-content-type = 'Code sample'">
                        <!-- A LINK LIKE THIS IS CREATED 
                       /developerworks/views/download.jsp?contentid=300029&filename=samples.zip&method=ftp -->
                        <!-- 5.0 6/2 tdc:  download.jsp link now has domain so it works in boulder for tutorials -->
                        <!-- 5.0 7/15 tdc:  Corrected FTP link (had mistakenly deleted 'download.jsp' from the url on 6/2 -->
                        <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text><xsl:value-of select="$path-dw-views"/><xsl:text disable-output-escaping="yes"><![CDATA[download.jsp?contentid=]]></xsl:text>
                        <xsl:value-of select="//id/@cma-id"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[&amp;filename=]]></xsl:text>
                        <xsl:value-of select="@filename"/>
                        <!-- 4.0 9/10 tdc:  Added locale parm (sourced from @local-site) per Devin -->
                        <xsl:text disable-output-escaping="yes"><![CDATA[&amp;method=ftp&amp;locale=]]></xsl:text>
                        <xsl:value-of select="//@local-site"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                        <b>FTP</b>
                        <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <!-- NOT A CODE SAMPLE DOWNLOAD, THEREFORE NO LICENSE -->
                        <!-- 5.2 09/15/05 jpp:  Added xsl:choose to add onclick and onkeypress attributes to PDF links so PDF requests are captured by SurfAid -->
                        <xsl:choose>
                          <xsl:when test="@file-type= 'pdf' ">
                            <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" onclick="sa_onclick(this.href)" onkeypress="sa_onclick(this.href)" href="]]></xsl:text>
                            <xsl:value-of select="@url-ftp"/>
                            <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                            <b>FTP</b>
                            <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text>
                            <xsl:value-of select="@url-ftp"/>
                            <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                            <b>FTP</b>
                            <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
                <!-- If http or dd too, then add a vertical bar after the ftp link -->
                <xsl:if test="@link-method-http = 'yes' or @link-method-dd = 'yes'">
                  <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>|<img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
                </xsl:if>
              </xsl:if>
              <xsl:if test="@link-method-http = 'yes'">
                <xsl:choose>
                  <!-- Only worldwide site files with @content-type of 'Code sample' should have license display servlet-style URL -->
                  <xsl:when test="@target-content-type = 'Code sample' and //@local-site ='worldwide'">
                    <!-- A LINK LIKE THIS IS CREATED FOR WORLDWIDE FILES 
                       /developerworks/views/download.jsp?contentid=300029&filename=samples.zip&method=http -->
                    <!-- 5.0 6/2 tdc:  download.jsp link now has domain so it works in boulder for tutorials -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text><xsl:value-of select="$path-dw-views"/><xsl:text disable-output-escaping="yes"><![CDATA[download.jsp?contentid=]]></xsl:text>
                    <xsl:value-of select="//id/@cma-id"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[&amp;filename=]]></xsl:text>
                    <xsl:value-of select="@filename"/>
                    <!-- 4.0 9/10 tdc:  Added locale parm (sourced from @local-site) per Devin -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[&amp;method=http&amp;locale=]]></xsl:text>
                    <xsl:value-of select="//@local-site"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                    <b>HTTP</b>
                    <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- NOT A WORLDWIDE SITE CODE SAMPLE DOWNLOAD, THEREFORE NO LICENSE -->
                    <!-- 5.2 09/15/05 jpp:  Added xsl:choose to add onclick and onkeypress attributes to PDF links so PDF requests are captured by SurfAid -->
                    <xsl:choose>
                      <xsl:when test="@file-type= 'pdf' ">
                        <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" onclick="sa_onclick(this.href)" onkeypress="sa_onclick(this.href)" href="]]></xsl:text>
                        <xsl:value-of select="@url-http"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                        <b>HTTP</b>
                        <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text>
                        <xsl:value-of select="@url-http"/>
                        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                        <b>HTTP</b>
                        <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@link-method-dd = 'yes'">
                  <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
                  <xsl:text>|</xsl:text>
                  <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
                </xsl:if>
              </xsl:if>
              <xsl:if test="@link-method-dd = 'yes'">
                <xsl:choose>
                  <!-- 4.0 9/7 tdc:  Only worldwide site files with @content-type of 'Code sample' should have license display servlet-style URL -->
                  <!-- 4.1 11/19 tdc:  Added local-site check -->
                  <xsl:when test="@target-content-type = 'Code sample' and //@local-site = 'worldwide'">
                    <!-- A LINK LIKE THIS IS CREATED FOR WORLDWIDE FILES 
                       /developerworks/views/download.jsp?contentid=300029&filename=samples.zip&method=dd -->
                    <!-- 5.0 6/2 tdc:  download.jsp link now has domain so it works in boulder for tutorials -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text><xsl:value-of select="$path-dw-views"/><xsl:text disable-output-escaping="yes"><![CDATA[download.jsp?contentid=]]></xsl:text>
                    <xsl:value-of select="//id/@cma-id"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[&amp;filename=]]></xsl:text>
                    <xsl:value-of select="@filename"/>
                    <!-- 4.0 9/10 tdc:  Added locale parm (sourced from @local-site) per Devin -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[&amp;method=dd&amp;locale=]]></xsl:text>
                    <xsl:value-of select="//@local-site"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                    <b>Download Director</b>
                    <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- NOT A WORLDWIDE SITE CODE SAMPLE DOWNLOAD, THEREFORE NO LICENSE -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[<a class="fbox" href="]]></xsl:text>
                    <xsl:value-of select="@url-download-director"/>
                    <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                    <b>Download Director</b>
                    <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </td>
          </tr>
        </xsl:for-each>
      </table>
      <table border="0" cellpadding="0" cellspacing="0">
        <tr valign="top">
          <td colspan="5">
            <img src="{$path-ibm-i}c.gif" border="0" height="12" width="12" alt=""/>
          </td>
        </tr>
        <tr>
          <td>
            <img src="{$path-v14-icons}fw.gif" width="16" height="16" alt=""/>
          </td>
          <td>
            <!-- 5.0 7/19 llk:  korea and china have translated this content -->
            <xsl:choose>
              <xsl:when test="//@local-site ='korea'">
                <a href="/developerworks/kr/library/whichmethod.html" class="fbox">
                  <xsl:value-of select="$download-method-link"/>
                </a>
              </xsl:when>
              <xsl:when test="//@local-site ='china'">
                <a href="/developerworks/cn/whichmethod.html" class="fbox">
                  <xsl:value-of select="$download-method-link"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <a href="/developerworks/library/whichmethod.html" class="fbox">
                  <xsl:value-of select="$download-method-link"/>
                </a>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td>
            <img src="{$path-ibm-i}c.gif" width="50" height="1" alt=""/>
          </td>
          <td>
            <img src="{$path-v14-icons}sout.gif" width="16" height="16" alt=""/>
          </td>
          <td>
            <a href="http://www.adobe.com/products/acrobat/readstep2.html" class="fbox">
              <xsl:value-of select="$download-get-adobe" disable-output-escaping="yes"/>
            </a>
          </td>
        </tr>
      </table>
      <!-- </p> -->
    </xsl:if>
    <!-- end download table -->
    <!-- IF TARGET CONTENT PAGE -->
    <xsl:if test="target-content-page/@link-text!=''">
      <xsl:choose>
        <!-- If not a summary page -->
        <xsl:when test="not(/dw-document/dw-summary)">
          <xsl:choose>
            <!-- If there's a download table, use the More downloads heading -->
            <xsl:when test="target-content-file/@filename!=''">
              <p>
                <span class="smalltitle">
                  <xsl:value-of select="$download-heading-more"/>
                </span>
              </p>
            </xsl:when>
            <!-- If there's not a download table, use the Downloads heading -->
            <xsl:when test="not(target-content-file)">
              <a name="download"/>
              <span class="atitle">
                <xsl:value-of select="$download-heading"/>
              </span>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <!-- If not an article -->
        <xsl:when test="not(/dw-document/dw-article)">
          <xsl:choose>
            <!-- If there's a download table, use the Also available heading -->
            <xsl:when test="target-content-file/@filename!=''">
              <span class="smalltitle">
                <xsl:value-of select="$also-available-heading"/>
              </span>
            </xsl:when>
            <!-- If there's not a download table, there's no heading -->
            <xsl:when test="not(target-content-file)">
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
      <ul>
        <xsl:for-each select="target-content-page">
          <!-- 4.0 6/6 tdc:  Added label for type of target content to each link.  If agreed to, make the text strings variables for the translated text stylesheets.  -->
          <xsl:variable name="content-label">
            <xsl:choose>
              <xsl:when test="@target-content-type = 'Code sample'">
                <xsl:text>Code sample: </xsl:text>
              </xsl:when>
              <xsl:when test="@target-content-type = 'Demo'">
                <xsl:text>Demo: </xsl:text>
              </xsl:when>
              <xsl:when test="@target-content-type = 'Presentation'">
                <xsl:text>Presentation: </xsl:text>
              </xsl:when>
              <xsl:when test="@target-content-type = 'Product documentation'">
                <xsl:text>Product documentation: </xsl:text>
              </xsl:when>
              <xsl:when test="@target-content-type = 'Specification'">
                <xsl:text>Specification: </xsl:text>
              </xsl:when>
              <xsl:when test="@target-content-type = 'Technical article'">
                <xsl:text>Technical article: </xsl:text>
              </xsl:when>
              <!-- 5.0 6/2 fjc add whitepaper-->
              <xsl:when test="@target-content-type = 'Whitepaper'">
                <xsl:text>Whitepaper: </xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <li>
            <xsl:value-of select="$content-label"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[<a href="]]></xsl:text>
            <xsl:value-of select="@url-target-page"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
            <xsl:value-of select="@link-text"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
    <xsl:if test=". = ../dw-article">
      <xsl:copy-of select="$ssi-s-backlink-rule"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="dt">
    <dt>
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <b>
        <xsl:apply-templates select="*|text()"/>
      </b>
    </dt>
  </xsl:template>
  <!-- 5.0 5/16 tdc:  Added DownloadSummaryTop -->
  <!-- 5.0 7/13 tdc:  Removed DownloadSummaryTop; heading to be same for all -->
  <xsl:template name="Duration">
    <!--  DURATION -->
    <xsl:if test="duration/. !=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-duration"/>
        </span>
      </p>
      <xsl:apply-templates select="duration/*|text()"/>
    </xsl:if>
    <!--   DURATION  END -->
  </xsl:template>
  <!-- EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE -->
  <xsl:template name="EndMatter">
    <xsl:comment>FOOTER_BEGIN</xsl:comment>
    <xsl:call-template name="Footer"/>
    <xsl:comment>FOOTER_END</xsl:comment>
    <xsl:comment>
      <xsl:value-of select="$stylesheet-id"/>
    </xsl:comment>
    <xsl:text disable-output-escaping="yes"><![CDATA[</body>]]></xsl:text>
    <xsl:text disable-output-escaping="yes"><![CDATA[</html>]]></xsl:text>
  </xsl:template>
  <xsl:template name="Enrollment">
    <!-- ENROLLMENT -->
    <!-- 5.0 5/18 fjc wrong table & strings-->
    <xsl:if test="enrollment-schedule/.!=''">
      <!-- begin enrollment table -->
      <table border="0" cellpadding="0" cellspacing="0" class="data-table-1" width="100%">
        <tr>
          <!-- Name -->
          <th>
            <a class="fbox" name="schedule">
              <xsl:value-of select="$summary-viewSchedules"/>
            </a>
          </th>
          <!-- Link -->
          <th>
            &nbsp;
          </th>
        </tr>
        <xsl:for-each select="enrollment-schedule">
          <tr>
            <xsl:if test="provider/. !=''">
              <td class="tb-row">
                <xsl:value-of select="provider"/>
              </td>
            </xsl:if>
            <!-- 5.0 04/28 tdc:  chg nowrap="yes" to nowrap="nowrap" -->
            <td nowrap="nowrap">
              <xsl:apply-templates select="course-number/*|text()"/>
            </td>
          </tr>
        </xsl:for-each>
        <!-- 5.0 05/25 fjc:  add string for websphere -->
        <xsl:if test="(/dw-document/dw-summary-training/content-area-primary/@name='websphere') and (/dw-document/dw-summary-training/@course-type='classroom')">
          <tr>
            <td colspan="2">
              <xsl:value-of select="$summary-enrollmentWebsphere1"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[<a href="mailto:tellwtte@us.ibm.com">tellwtte@us.ibm.com</a>]]></xsl:text>
              <xsl:text disable-output-escaping="yes"><![CDATA[<b>]]></xsl:text>
              <xsl:value-of select="$summary-enrollmentWebsphere2"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</b>]]></xsl:text>
            </td>
          </tr>
        </xsl:if>
      </table>
    </xsl:if>
    <!-- end enroll  table -->
  </xsl:template>
  <!-- FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -->
  <xsl:template match="figure">
    <xsl:apply-templates/>
    <!-- 5.0 05/03 tdc:  Added break tag so figure won't butt up against content underneath it -->
    <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
  </xsl:template>
  <xsl:template name="FilterAbstract">
    <xsl:variable name="doublequote">"</xsl:variable>
    <xsl:variable name="singlequote">'</xsl:variable>
    <xsl:variable name="newline">
      <xsl:text>
</xsl:text>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="//abstract!=''">
        <xsl:value-of select="translate(//abstract,$doublequote,$singlequote)"/>
      </xsl:when>
      <xsl:when test="//abstract=''">
        <xsl:value-of select="translate(//abstract-extended,$doublequote,$singlequote)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(//abstract-extended,$doublequote,$singlequote)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="FileFormats">
    <!--  FILE FORMAT -->
    <xsl:if test="file-formats/. !=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-formats"/>
        </span>
      </p>
      <xsl:for-each select="file-formats/file-format">
        <xsl:if test="position() > 1">
          <xsl:text disable-output-escaping="yes"><![CDATA[, ]]></xsl:text>
        </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:if>
    <!--  FILE FORMAT END -->
  </xsl:template>
  <!-- 5.2 9/14 jpp:  Removed different footers for brand content areas -->
  <xsl:template name="Footer">
    <xsl:copy-of select="$footer-inc-default"/>
  </xsl:template>
  <xsl:template name="FrontMatter">
    <xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">]]></xsl:text>
    <!-- 5.0.1 9/6 llk:  lang values are different for each language.-->
    <xsl:choose>
      <xsl:when test="/dw-document//@local-site='china'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN" lang="zh-CN">]]></xsl:text>
      </xsl:when>
      <xsl:when test="/dw-document//@local-site='korea'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">]]></xsl:text>
      </xsl:when>
      <xsl:when test="/dw-document//@local-site='taiwan'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<html xmlns="http://www.w3.org/1999/xhtml" lang="zh-TW" xml:lang="zh-TW">]]></xsl:text>
      </xsl:when>
      <xsl:when test="/dw-document//@local-site='russia'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<html xmlns="http://www.w3.org/1999/xhtml" lang="ru" xml:lang="ru">]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"><![CDATA[<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <head xsl:exclude-result-prefixes="xsl fo">
      <!-- 5.0 6/10 tdc:  Changed include to variable -->
      <xsl:copy-of select="$ssi-s-header-content"/>
      <title>
        <xsl:call-template name="FullTitle"/>
      </title>
      <!-- 5.0 6/10 tdc:  Changed include to variable -->
      <xsl:copy-of select="$ssi-s-header-meta"/>
      <xsl:call-template name="Meta"/>
      <!-- 5.0 6/10 tdc:  Changed include to variable -->
      <xsl:copy-of select="$ssi-s-header-scripts"/>
      <!-- 5.0 6/10 tdc:  Changed include to variable -->
      <xsl:copy-of select="$ssi-s-header-art-tut-styles"/>
      <!-- 5.0 5/12 tdc:  Corrected xpath for test to call JavaScripts template -->
      <!-- 5.0 04/28 tdc:  sidefiles don't need these javascripts -->
      <!-- 5.0 05/17 fjc add the tactic javascript -->
      <xsl:if test="/dw-document/dw-summary-tutorial|/dw-document/dw-summary-demo|/dw-document/dw-summary-spec|/dw-document/dw-summary-presentation|/dw-document/dw-summary-training|/dw-document/dw-summary-sample|/dw-document/dw-summary-long">
        <xsl:text disable-output-escaping="yes"><![CDATA[<script type="text/javascript" language="JavaScript" src="/developerworks/js/tactcodes.js"></script>]]></xsl:text>
      </xsl:if>
      <xsl:if test="not(/dw-document/dw-sidefile)">
        <xsl:call-template name="JavaScripts"/>
      </xsl:if>
    </head>
    <xsl:text disable-output-escaping="yes"><![CDATA[<body>]]></xsl:text>
    <!-- 5.0 6/16 tdc:  Added test for authoring package situation -->
    <!-- Must be an internal editor's file if cma-id != '0', so add the masthead -->
    <xsl:if test="/dw-document//id/@cma-id !='0'">
      <xsl:comment>MASTHEAD_BEGIN</xsl:comment>
      <!-- 5.0 6/29 tdc:  EGD upd masthead; replaced masthead .inc file reference with xsl variable -->
      <!-- <xsl:copy-of select="$ssi-s-topmast14" /> -->
      <!-- 5.0.1 9/6 llk: masthead is called in conditionally depending on the local site value -->
      <!-- 5.2 9/22/05 tdc:  topmast-inc in the WW translated text has been TEMPORARILY redefined so that it matches ssi-s-topmast14.  Local site common and translated text files should be changed eventually to use their own definitions of ssi-s-topmast14. -->
      <xsl:copy-of select="$topmast-inc"/>
      <xsl:comment>MASTHEAD_END</xsl:comment>
    </xsl:if>
  </xsl:template>
  <xsl:template name="FullTitle">
    <xsl:param name="escapeQuotes" select="false()"/>
    <xsl:if test="string-length(//series/series-title) &gt; 0">
      <xsl:choose>
        <xsl:when test="$escapeQuotes and 
                       contains(//series/series-title, '&quot;')">
          <xsl:call-template name="ReplaceSubstring">
            <xsl:with-param name="original" select="//series/series-title"/>
            <xsl:with-param name="substring" select="'&quot;'"/>
            <xsl:with-param name="replacement" select="'\&quot;'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//series/series-title"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>: </xsl:text>
    </xsl:if>
    <xsl:if test="string-length(//title) &gt; 0">
      <xsl:choose>
        <!-- 5.2 09/14/05 jpp:  Added test to preface product landing page titles with IBM developerWorks text -->
        <xsl:when test="/dw-document/dw-landing-product">
          <xsl:copy-of select="$ibm-developerworks-text"/>
          <xsl:value-of select="//title"/>
        </xsl:when>
        <xsl:when test="$escapeQuotes and 
                       contains(//title, '&quot;')">
          <xsl:call-template name="ReplaceSubstring">
            <xsl:with-param name="original" select="//title"/>
            <xsl:with-param name="substring" select="'&quot;'"/>
            <xsl:with-param name="replacement" select="'\&quot;'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <!-- HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH -->
  <!-- 5.0 05/02 tdc:  code, figure, sidebar, table headings now surrounded by br tags, not p -->
  <xsl:template match="heading">
    <!-- 5.2 8/29/05 tdc:  Fixed test for back-to-top-link value of immediately preceding major heading -->
    <!-- 5.2 8/25/05 tdc:  Added test for back-to-top-link value of immediately preceding major heading -->
    <xsl:if test="(/dw-document/dw-article or /dw-document/dw-tutorial) and
                        (@type='major' and . != ../heading[1]) and
                        ((not(string(preceding-sibling::heading[@type='major'][1]/@back-to-top)) or
                           preceding-sibling::heading[@type='major'][1]/@back-to-top = 'yes'))">
      <xsl:copy-of select="$ssi-s-backlink-rule"/>
    </xsl:if>
    <xsl:variable name="newid">
      <xsl:choose>
        <xsl:when test="@refname != ''">
          <xsl:value-of select="@refname"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- 5.0 5/11 tdc:  Tutorials have different fonts for major & minor -->
    <xsl:choose>
      <xsl:when test="@type='major'">
        <xsl:choose>
          <xsl:when test="/dw-document/dw-tutorial">
            <p>
              <a name="{$newid}">
                <span class="smalltitle">
                  <xsl:value-of select="."/>
                </span>
              </a>
            </p>
          </xsl:when>
          <xsl:otherwise>
            <p>
              <a name="{$newid}">
                <span class="atitle">
                  <xsl:value-of select="."/>
                </span>
              </a>
            </p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@type='minor'">
        <xsl:choose>
          <xsl:when test="/dw-document//dw-tutorial">
            <p>
              <a name="{$newid}">
                <b>
                  <xsl:value-of select="."/>
                </b>
              </a>
            </p>
          </xsl:when>
          <xsl:otherwise>
            <p>
              <a name="{$newid}">
                <span class="smalltitle">
                  <xsl:value-of select="."/>
                </span>
              </a>
            </p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- 5.0 05/02 tdc:  moved 'figure' to this heading type list -->
      <xsl:when test="(@type='code') or (@type='figure') or (@type='sidebar') or (@type='table')">
        <!-- 5.0 05/02 tdc:  No breaks before sidebar heading -->
        <xsl:if test="not(@type='sidebar')">
          <!-- 5.0 05/03 tdc:  Only one break needed now before code, figure, sidebar, table headings -->
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </xsl:if>
        <xsl:if test="@type='figure'">
          <xsl:copy-of select="$figurechar"/>
        </xsl:if>
        <a name="{$newid}">
          <b>
            <xsl:value-of select="."/>
          </b>
        </a>
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:when>
    </xsl:choose>
    <!-- 
    <xsl:if test="name(following-sibling::*[1]) = 'p'">
      <xsl:for-each select="following-sibling::*[1]">
        <xsl:call-template name="processParagraph"/>
      </xsl:for-each>
    </xsl:if> -->
  </xsl:template>
  <!-- 
  <xsl:template name="processParagraph">
    <p>
      <xsl:apply-templates select="*|text()"/>
    </p>
  </xsl:template>
  -->
  <!-- I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I -->
  <xsl:template match="img">
    <img xsl:exclude-result-prefixes="fo xsl">
      <xsl:choose>
        <xsl:when test="ancestor::author and not(@align!='')">
          <xsl:for-each select="@*">
            <xsl:copy/>
          </xsl:for-each>
          <xsl:attribute name="align">left</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="@*">
            <xsl:copy/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </img>
  </xsl:template>
  <xsl:template name="InstructorTopSummary">
    <xsl:if test="instructor/. !=''">
      <xsl:if test="not(/dw-document/dw-summary-demo/author)">
        <xsl:text disable-output-escaping="yes"><![CDATA[<p>]]></xsl:text>
      </xsl:if>
      <xsl:for-each select="instructor">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- INSTRUCTOR NAME GOES HERE -->]]></xsl:text>
        <xsl:if test="./bio!=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[<a href="#instructor">]]></xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="name/. !=''">
            <xsl:apply-templates select="name"/>
          </xsl:when>
          <xsl:when test="contributor-name">
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(contributor-name/Prefix) !=''">
              <xsl:value-of select="contributor-name/Prefix "/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- First Name required-->
            <xsl:apply-templates select="contributor-name/GivenName"/>
            <xsl:text> </xsl:text>
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(contributor-name/MiddleName) !=''">
              <xsl:apply-templates select="contributor-name/MiddleName"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <!-- Last Name required-->
            <xsl:apply-templates select="contributor-name/FamilyName"/>
            <!-- 5.2 9/18/05 tdc:  Testing for blank suffix now -->
            <!-- 5.2 9/19/05 tdc:  Used normalize-space for test -->
            <xsl:if test="normalize-space(contributor-name/Suffix) !=''">
              <!-- 5.2 9/16/05 tdc:  Added comma per Sarah Furr -->
              <xsl:text>, </xsl:text>
              <xsl:apply-templates select="contributor-name/Suffix"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="./bio!=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="/dw-document//@local-site='worldwide'">
            <!-- 4.0 10/14 tdc:  Corrected @email_cc to @email-cc -->
            <!-- 4.1 01/04/05 tdc:  Corrected mailto delimeter and added test for @email-cc occurence -->
            <xsl:if test="@email and @email!=''">
              <xsl:text disable-output-escaping="yes"><![CDATA[ (<a href="mailto:]]></xsl:text>
              <xsl:value-of select="@email"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[?subject=]]></xsl:text>
              <xsl:value-of select="/dw-document//title"/>
              <xsl:if test="@email-cc !=''">
                <xsl:text disable-output-escaping="yes"><![CDATA[&amp;cc=]]></xsl:text>
                <xsl:value-of select="@email-cc"/>
              </xsl:if>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <xsl:value-of select="@email"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>)]]></xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        <xsl:if test="@jobtitle='' and company-name=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <b>
            <font color="red">
              <xsl:value-of select="$job-co-errormsg"/>
            </font>
          </b>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </xsl:if>
        <xsl:if test="@jobtitle/. !=''">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="@jobtitle"/>
          <xsl:if test="company-name/. !=''">, </xsl:if>
        </xsl:if>
        <xsl:if test="company-name/. !=''">
          <xsl:value-of select="company-name"/>
        </xsl:if>
        <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      </xsl:for-each>
      <xsl:text disable-output-escaping="yes"><![CDATA[</p>]]></xsl:text>
      <!--  SUM INSTRUCTOR TOP END -->
    </xsl:if>
  </xsl:template>
  <xsl:template name="InThisDoc">
    <!--  IN_THIS_DOC-->
    <xsl:if test="in-this-doc/. !=''">
      <p>
        <span class="smalltitle">
          <xsl:choose>
            <xsl:when test="(. = ../dw-summary-tutorial)">
              <xsl:value-of select="$summary-inThisTutorial"/>
            </xsl:when>
            <xsl:when test="(. = ../dw-summary-long)">
              <xsl:value-of select="$summary-inThisLongdoc"/>
            </xsl:when>
            <xsl:when test="(. = ../dw-summary-sample)">
              <xsl:value-of select="$summary-inThisSample"/>
            </xsl:when>
            <xsl:when test="(. = ../dw-summary-presentation)">
              <xsl:value-of select="$summary-inThisPresentation"/>
            </xsl:when>
            <xsl:when test="(. = ../dw-summary-training)">
              <xsl:value-of select="$summary-inThisCourse"/>
            </xsl:when>
            <!-- 5.2 09/20 fjc: added podcast string-->
            <xsl:when test="(. = ../dw-summary-podcast)">
              <xsl:value-of select="$summary-inThisPodcast"/>
            </xsl:when>
          </xsl:choose>
        </span>
      </p>
      <xsl:apply-templates select="in-this-doc/*|text()"/>
    </xsl:if>
    <!--  IN_THIS_DOC END -->
  </xsl:template>
  <!-- Start: 05/05 tdc:  example template to handle unordered lists within certain document sections -->
  <!-- Could be expanded to match="in-this-doc/ul | objectives/ul | blah/ul -->
  <xsl:template match="in-this-doc/ul">
    <ul>
      <xsl:for-each select="li">
        <xsl:choose>
          <xsl:when test="ul or ol">
            <li>
              <xsl:apply-templates select="*|text()"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <li>
              <xsl:apply-templates select="*|text()"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
              <xsl:if test="position() !=last()">
                <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
              </xsl:if>
            </li>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </ul>
  </xsl:template>
  <!-- KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK -->
  <xsl:template name="keywords">
    <xsl:text disable-output-escaping="yes">&lt;meta name="Keywords" content="</xsl:text>
    <xsl:value-of select="/dw-document//keywords/@content"/>
    <!-- 5.0 5/17 tdc:  Added meta keyword strings for each content area for Search -->
    <xsl:call-template name="ContentAreaMetaKeyword">
      <xsl:with-param name="contentarea">
        <xsl:value-of select="//content-area-primary/@name"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="//content-area-secondary">
      <xsl:call-template name="ContentAreaMetaKeyword">
        <xsl:with-param name="contentarea">
          <xsl:value-of select="./@name"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:text disable-output-escaping="yes">" /&gt;</xsl:text>
  </xsl:template>
  <!-- LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL -->
  <xsl:template name="Languages">
    <!--  LANGUAGES -->
    <!-- 5.0 7/29 tdc:  Changed test to see if /language is not null -->
    <xsl:if test="foreign-language/language!=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-languages"/>
        </span>
      </p>
      <xsl:for-each select="foreign-language/language">
        <xsl:if test="position() > 1">
          <xsl:text disable-output-escaping="yes"><![CDATA[, ]]></xsl:text>
        </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:if>
    <!--  LANGUAGES END -->
  </xsl:template>
  <xsl:template name="LeftNav">
    <xsl:comment>LEFTNAV_BEGIN</xsl:comment>
    <td width="150" id="navigation">
      <!-- 5.0 6/10 tdc:  Changed include to variable -->
      <xsl:copy-of select="$ssi-s-nav14-top"/>
      <table border="0" cellpadding="0" cellspacing="0" width="150">
        <!-- Start:  If part of a series -->
        <xsl:if test="series/series-title !='' and series/series-url != ''">
          <tr>
            <td class="left-nav" colspan="2">
              <a class="left-nav" href="{series/series-url}">
                <xsl:value-of select="$moreThisSeries"/>
                <xsl:text>:</xsl:text>
              </a>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
              <xsl:text disable-output-escaping="yes"><![CDATA[<a class="left-nav-child" href="]]></xsl:text>
              <xsl:value-of select="series/series-url"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <!-- <xsl:value-of select="series/series-title"/> -->
              <!-- 5.0 7/22 tdc:  Remove the ", Part X" text from the series title if present -->
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
        <tr>
          <td class="left-nav-highlight" colspan="2">
            <a class="left-nav" href="#">
              <xsl:value-of select="$left-nav-in-this-article"/>
            </a>
          </td>
        </tr>
        <!-- Start:  Get docbody heading refids and build each TOC link -->
        <xsl:for-each select="//heading">
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
        <!-- End:  Get docbody heading refids and build each TOC link -->
        <!-- Start:  Build links to the standard sections -->
        <xsl:if test="(//target-content-file or //target-content-page)">
          <tr class="left-nav-child-highlight">
            <td>
              <img src="{$path-v14-t}cl-bullet.gif" width="2" height="8" alt=""/>
            </td>
            <td>
              <a class="left-nav-child" href="#download">
                <!-- 5.0 7/13 tdc:  Link text to be plural if more than one target-content-file -->
                <xsl:choose>
                  <xsl:when test="count(//target-content-file) > 1">
                    <xsl:value-of select="$downloads-heading"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$download-heading"/>
                  </xsl:otherwise>
                </xsl:choose>
              </a>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="//resource-list | //resources">
          <tr class="left-nav-child-highlight">
            <td>
              <img src="{$path-v14-t}cl-bullet.gif" width="2" height="8" alt=""/>
            </td>
            <td>
              <a class="left-nav-child" href="#resources">
                <xsl:value-of select="$resource-list-heading"/>
              </a>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="//author/bio/.!=''">
          <tr class="left-nav-child-highlight">
            <td>
              <img src="{$path-v14-t}cl-bullet.gif" width="2" height="8" alt=""/>
            </td>
            <td>
              <!-- 5.0 7/11 tdc:  Corrected href from 'author1' to author' -->
              <a class="left-nav-child" href="#author">
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
        <!-- 5.2 8/22/05 tdc:  Removed xsl:if test for != dWS component, landing, standalone -->
        <xsl:choose>
          <!-- 4.1 12/08 tdc:  If WW and none of the three ID attrib's are present, no Ratings link -->
          <!-- 4.0 8/02 tdc:  added "or cma-id" logic to tests -->
          <!-- do not output the TOC link to the ratings form in this case -->
          <xsl:when test="/dw-document//@local-site = 'worldwide' and
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
            <tr class="left-nav-child-highlight">
              <td>
                <img src="{$path-v14-t}cl-bullet.gif" width="2" height="8" alt=""/>
              </td>
              <td>
                <a class="left-nav-child" href="#rate">
                  <xsl:value-of select="$ratethisarticle-heading"/>
                </a>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
        <!-- BOTTOM NAV BORDER -->
        <tr class="left-nav-last">
          <td width="14">
            <img src="{$path-ibm-i}c.gif" width="14" height="1" alt="" class="display-img"/>
          </td>
          <td width="136">
            <img src="{$path-v14-t}left-nav-corner.gif" width="136" height="19" alt="" class="display-img"/>
          </td>
        </tr>
      </table>
      <xsl:call-template name="RelatedLinks"/>
    </td>
    <xsl:comment>LEFTNAV_END</xsl:comment>
  </xsl:template>
  <xsl:template name="LeftNavSummary">
    <xsl:comment>LEFTNAV_BEGIN</xsl:comment>
    <!-- 5.0.1 9/6 llk: lefthand navs need to be local site specific -->
    <td width="150" id="navigation">
      <xsl:copy-of select="$left-nav-top"/>
      <xsl:call-template name="LeftNavSummaryInc"/>
      <xsl:copy-of select="$left-nav-rlinks"/>
    </td>
    <xsl:comment>LEFTNAV_END</xsl:comment>
  </xsl:template>
  <!-- SUMLEFTNAVINC_END -->
  <!-- 5.2 8/24/05 tdc:  Changed "if" tests to "choose/when" -->
  <xsl:template name="LeftNavSummaryInc">
    <!-- 5.0.1 llk these includes need to be local site specific -->
    <!-- 5.2 09/28 fjc:podcasts point to event inc files -->
    <xsl:choose>
      <xsl:when test="//dw-document/dw-summary-podcast">
        <xsl:choose>
          <xsl:when test="content-area-primary/@name='autonomic'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE auto-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-autonomic"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='db2'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE db2-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-db2"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='eserver'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE eserver-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-eserver"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='grid'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE grid-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-grid"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='ibm'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE ibm-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-ibm"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='java'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE java-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-java"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='linux'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE linux-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-linux"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='lotus'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE lotus-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-lotus"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='opensource'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE opensource-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-opensource"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='power'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE power-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-power"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='rational'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE rational-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-rational"/>
            <!-- 5.0.1 9/19 llk: security is needed by local sites -->
          </xsl:when>
          <xsl:when test="content-area-primary/@name='security'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE security-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-security"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='tivoli'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE tivoli-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-tivoli"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='web'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE web-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-web"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='webservices'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE ibm-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-webservices"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='websphere'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE websphere-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-websphere"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='wireless'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE wireless-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-wireless"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='workplace'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE workplace-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-workplace"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='xml'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE xml-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-events-xml"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="content-area-primary/@name='autonomic'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE auto-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-autonomic"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='db2'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE db2-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-db2"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='eserver'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE eserver-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-eserver"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='grid'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE grid-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-grid"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='ibm'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE ibm-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-ibm"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='java'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE java-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-java"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='linux'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE linux-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-linux"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='lotus'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE lotus-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-lotus"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='opensource'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE opensource-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-opensource"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='power'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE power-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-power"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='rational'">
            <!-- 5.2  01/03 fjc:add training inc -->
            <xsl:choose>
              <xsl:when test="//dw-document/dw-summary-training">
                <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE rational-->]]></xsl:text>
                <xsl:copy-of select="$left-nav-training-rational"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE rational-->]]></xsl:text>
                <xsl:copy-of select="$left-nav-rational"/>
              </xsl:otherwise>
            </xsl:choose>
            <!-- 5.0.1 9/19 llk: security is needed by local sites -->
          </xsl:when>
          <xsl:when test="content-area-primary/@name='security'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE security-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-security"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='tivoli'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE tivoli-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-tivoli"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='web'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE web-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-web"/>
          </xsl:when>
          <!-- 5.1  fjc 08/14 - design request to make spec summary/webservices leftnav 'standards' -->
          <xsl:when test="content-area-primary/@name='webservices'">
            <xsl:choose>
              <xsl:when test="//dw-document/dw-summary-spec">
                <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE ibm-->]]></xsl:text>
                <xsl:copy-of select="$left-nav-webservices-summary-spec"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE ibm-->]]></xsl:text>
                <xsl:copy-of select="$left-nav-webservices"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='websphere'">
            <!-- 5.2  01/03 fjc:add training inc -->
            <xsl:choose>
              <xsl:when test="//dw-document/dw-summary-training">
                <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE websphere-->]]></xsl:text>
                <xsl:copy-of select="$left-nav-training-websphere"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE websphere-->]]></xsl:text>
                <xsl:copy-of select="$left-nav-websphere"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='wireless'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE wireless-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-wireless"/>
          </xsl:when>
          <!-- 5.2 8/24/05 tdc:  Added workplace.  tdc changed "t-" to "d-" on 8/25/05 per EGD -->
          <xsl:when test="content-area-primary/@name='workplace'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE workplace-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-workplace"/>
          </xsl:when>
          <xsl:when test="content-area-primary/@name='xml'">
            <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE xml-->]]></xsl:text>
            <xsl:copy-of select="$left-nav-xml"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <!-- SUMLEFTNAVINC_END -->
  </xsl:template>
  <!-- 5.1 06/23/05 JPP/EGD Added LeftNavProduct template for product pages -->
  <!-- 5.0.1 9/6 llk:  note to self.. these must be made into variable before local sites can use product summary pages -->
  <xsl:template name="LeftNavProduct">
    <xsl:comment>LEFTNAV_BEGIN</xsl:comment>
    <td width="150" id="navigation">
      <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-nav14-top.inc" -->]]></xsl:text>
      <xsl:call-template name="LeftNavProductInc"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/s-nav14-rlinks.inc" -->]]></xsl:text>
    </td>
    <xsl:comment>LEFTNAV_END</xsl:comment>
  </xsl:template>
  <!-- PRODUCTLEFTNAVINC_END -->
  <xsl:template name="LeftNavProductInc">
    <xsl:choose>
      <!-- 5.2 8/24/05 tdc:  Changed "if" tests to "choose/when" tests -->
      <!-- 5.0.1 9/6 llk:  note to self.. these must be made into variable before local sites can use product summary pages -->
      <xsl:when test="content-area-primary/@name='db2'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE db2-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-dm-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='eserver'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE eserver-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-es-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='lotus'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE lotus-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-ls-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='rational'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE rational-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-r-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='tivoli'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE tivoli-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-tv-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='websphere'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE websphere-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-w-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
      <!-- 5.2 8/24/05 tdc:  Added workplace -->
      <xsl:when test="content-area-primary/@name='workplace'">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!-- LEFT NAV INCLUDE workplace-->]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="/developerworks/inc/d-wp-nav14-products.inc" -->]]></xsl:text>
      </xsl:when>
    </xsl:choose>
    <!-- PRODUCTLEFTNAVINC_END -->
  </xsl:template>
  <!-- MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM -->
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
  <!-- OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO -->
  <xsl:template name="Objectives">
    <!--  OBJECTIVES -->
    <xsl:if test="objectives/. !=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-objectives"/>
        </span>
      </p>
      <ul>
        <xsl:for-each select="objectives/objective">
          <li>
            <xsl:value-of select="."/>
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <xsl:if test="position() !=last()">
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
    <!--  OBJECTIVES END -->
  </xsl:template>
  <xsl:template name="Overview">
    <!--  OVERVIEW -->
    <xsl:if test="overview/.!=''">
      <xsl:apply-templates select="overview/*|text()"/>
    </xsl:if>
  </xsl:template>
  <!-- 5.2 8/24/05 tdc:  Removed OwnerTeam - not used any longer -->
  <!-- 
  <xsl:template name="OwnerTeam">
    <xsl:choose> -->
  <!-- 4.0 9/15 tdc:  Added power -->
  <!-- 5.2 8/24/05 tdc:  Corrected xpath from "content-area[1]" to "content-area-primary" -->
  <!-- <xsl:when test="/dw-document//content-area-primary/@name = 'autonomic'
             or /dw-document//content-area-primary/@name = 'grid' 
		or /dw-document//content-area-primary/@name = 'java' 
		or /dw-document//content-area-primary/@name = 'linux' 
		or /dw-document//content-area-primary/@name = 'opensource' 
		or /dw-document//content-area-primary/@name = 'security' 
		or /dw-document//content-area-primary/@name = 'web'  
		or /dw-document//content-area-primary/@name = 'webservices' 
		or /dw-document//content-area-primary/@name = 'wireless'
		or /dw-document//content-area-primary/@name = 'power' 
		or /dw-document//content-area-primary/@name = 'xml'">developerworks</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/dw-document//content-area-primary/@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  -->
  <!-- PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP -->
  <!-- 5.2 10/14/05 tdc:  Part of fix to order PDF links (A4 first, Letter second) -->
  <xsl:template name="PdfInfo">
    <xsl:param name="pdf-alt"/>
    <xsl:param name="pdf-numpages"/>
    <xsl:param name="pdf-size"/>
    <xsl:param name="pdf-text"/>
    <xsl:param name="pdf-url"/>
    <tr valign="top">
      <td width="8">
        <img src="{$path-ibm-i}c.gif" width="8" height="1" alt=""/>
      </td>
      <td width="16">
        <img alt="{$pdf-alt}" height="16" src="{$path-v14-icons}pdf.gif" width="16" vspace="5"/>
      </td>
      <td width="122">
        <p>
          <!-- 5.2 09/19/05 jpp:  Added onclick and onkeypress attributes to anchor tag so PDF requests are captured by SurfAid -->
          <a class="smallplainlink" onclick="sa_onclick(this.href)" onkeypress="sa_onclick(this.href)" href="{$pdf-url}">
            <b>
              <xsl:value-of select="$pdf-text"/>
            </b>
          </a>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <span class="small">
            <xsl:value-of select="$pdf-size"/>
            <!-- 5.2 8/25/05 tdc:  Added test to see if pages attrib is present first -->
            <!-- 5.2 8/17/05 tdc:  Added number of pages info -->
            <!-- 5.2 9/16/05 tdc:  Replace comma with parenthesis per G. Moore -->
            <xsl:if test="$pdf-numpages !=''">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="$pdf-numpages"/>
              <xsl:text> </xsl:text>
              <xsl:choose>
                <xsl:when test="$pdf-numpages = '1'">
                  <xsl:value-of select="$pdf-page"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$pdf-pages"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text>)</xsl:text>
            </xsl:if>
          </span>
        </p>
      </td>
    </tr>
  </xsl:template>
  <xsl:template name="Prerequisites">
    <!--  PREREQUISITES -->
    <xsl:if test="prerequisites/.!=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-prerequisities"/>
        </span>
      </p>
      <xsl:apply-templates select="prerequisites/*|text()"/>
    </xsl:if>
    <!--  PREREQUISITES END -->
  </xsl:template>
  <!-- 5.0 05/03 tdc:  Added ProcessList template for creating lists for things like Resources, etc. -->
  <xsl:template name="ProcessList">
    <xsl:choose>
      <xsl:when test="ul or ol">
        <li>
          <xsl:apply-templates select="*|text()"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li>
          <xsl:apply-templates select="*|text()"/>
          <!-- <xsl:if test="(. = ../resource[@resource-category='Learn'][position() !=last()]) or
					                    (. = ../resource[@resource-category='Get products and technologies'][position() !=last()]) or
                                        (. = ../resource[@resource-category='Discuss'][position() !=last()])"> -->
          <xsl:if test=". = ../resource[position() !=last()]">
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          </xsl:if>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 5.1 08/02/2005 jpp: Added to provide Product Landing page URL strings for BreadCrumbTitle template -->
  <xsl:template name="ProductsLandingURL">
    <xsl:param name="products-landing-url"/>
    <xsl:choose>
      <xsl:when test="content-area-primary/@name='db2'">
        <xsl:value-of select="$products-landing-db2"/>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='eserver'">
        <xsl:value-of select="$products-landing-es"/>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='lotus'">
        <xsl:value-of select="$products-landing-lo"/>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='rational'">
        <xsl:value-of select="$products-landing-r"/>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='tivoli'">
        <xsl:value-of select="$products-landing-tiv"/>
      </xsl:when>
      <xsl:when test="content-area-primary/@name='websphere'">
        <xsl:value-of select="$products-landing-web"/>
      </xsl:when>
      <!-- 5.2 09/27/2005 jpp: Added path for Workplace products page in breadcrumb trail -->
      <xsl:when test="content-area-primary/@name='workplace'">
        <xsl:value-of select="$products-landing-wp"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR -->
  <xsl:template name="Registration">
    <!--  REGISTRATION-->
    <table border="0" cellpadding="0" cellspacing="0">
      <tr valign="top">
        <td colspan="2">
          <img src="{$path-ibm-i}c.gif" border="0" height="12" width="12" alt=""/>
        </td>
      </tr>
      <tr>
        <td>
          <img src="{$path-v14-icons}fw_bold.gif" width="16" height="16" alt=""/>
        </td>
        <td>
          <xsl:if test="registration-enrollment-url/. != ''">
            <xsl:text disable-output-escaping="yes"><![CDATA[<a  class="fbox" href="]]></xsl:text>
            <xsl:value-of select="registration-enrollment-url"/>
            <!-- 5.0 7/28 tdc:  Double-quote relocated to just before onmouseover -->
            <xsl:text disable-output-escaping="yes"><![CDATA[" onmouseover='linkCarryOverQueryString(this)'>]]></xsl:text>
            <b>
              <xsl:value-of select="$summary-register"/>
            </b>
            <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
          </xsl:if>
        </td>
      </tr>
      <tr valign="top">
        <td colspan="2">
          <img src="{$path-ibm-i}c.gif" border="0" height="12" width="12" alt=""/>
        </td>
      </tr>
    </table>
    <!--  REGISTRATION_END-->
  </xsl:template>
  <!-- 5.0 7/25 tdc:  Don't display related links if content-area-primary = 'none' -->
  <xsl:template name="RelatedLinks">
    <xsl:if test="content-area-primary/@name != 'none'">
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
      <table border="0" cellpadding="0" cellspacing="0" width="150">
        <tr>
          <td colspan="2" class="related">
            <!-- 5.0.1 llk 7/12 - this text needs to be translated-->
            <b class="related">
              <xsl:value-of select="$left-nav-related-links-heading"/>
            </b>
          </td>
        </tr>
        <xsl:variable name="primary-techlib-url">
          <xsl:call-template name="TechLibView">
            <xsl:with-param name="contentarea">
              <xsl:value-of select="content-area-primary/@name"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <tr class="rlinks">
          <td>
            <img src="{$path-v14-t}rl-bullet.gif" width="2" height="8" alt=""/>
          </td>
          <td>
            <xsl:text disable-output-escaping="yes"><![CDATA[<a class="rlinks" href="]]></xsl:text>
            <xsl:value-of select="$primary-techlib-url"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
            <xsl:call-template name="ContentAreaName">
              <xsl:with-param name="contentarea">
                <xsl:value-of select="content-area-primary/@name"/>
              </xsl:with-param>
            </xsl:call-template>
            <!-- 5.0.1 9/6  llk this heading needs to be translated -->
            <!-- 5.0.1 9/19 llk need a space between content area and technical library -->
            <xsl:text disable-output-escaping="yes"><![CDATA[ ]]></xsl:text>
            <xsl:value-of select="$left-nav-related-links-techlib"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
          </td>
        </tr>
        <xsl:if test="content-area-secondary/@name !=''">
          <xsl:for-each select="content-area-secondary">
            <xsl:variable name="secondary-techlib-url">
              <xsl:call-template name="TechLibView">
                <xsl:with-param name="contentarea">
                  <xsl:value-of select="@name"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <tr class="rlinks">
              <td>
                <img src="{$path-v14-t}rl-bullet.gif" width="2" height="8" alt=""/>
              </td>
              <td>
                <xsl:text disable-output-escaping="yes"><![CDATA[<a class="rlinks" href="]]></xsl:text>
                <xsl:value-of select="$secondary-techlib-url"/>
                <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
                <xsl:call-template name="ContentAreaName">
                  <xsl:with-param name="contentarea">
                    <xsl:value-of select="@name"/>
                  </xsl:with-param>
                </xsl:call-template>
                <!-- 5.0.1 9/6  llk this heading needs to be translated -->
                <!-- 5.0.1 9/19 llk need a space between content area and technical library -->
                <xsl:text disable-output-escaping="yes"><![CDATA[ ]]></xsl:text>
                <xsl:value-of select="$left-nav-related-links-techlib"/>
                <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
              </td>
            </tr>
          </xsl:for-each>
        </xsl:if>
        <!-- Is TRE the only journal we have to address here?  That's all 4.0 & 4.1 address. -->
        <xsl:if test="content-area-primary/@name='rational' or content-area-secondary/@name='rational'">
          <tr class="rlinks">
            <td>
              <img src="{$path-v14-t}rl-bullet.gif" width="2" height="8" alt=""/>
            </td>
            <td>
              <xsl:text disable-output-escaping="yes"><![CDATA[<a class="rlinks" href="]]></xsl:text>
              <xsl:value-of select="$rational-edge-url"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
              <xsl:copy-of select="$rational-edge-text"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
            </td>
          </tr>
        </xsl:if>
        <tr>
          <td width="14">
            <img src="{$path-ibm-i}c.gif" width="14" height="1" alt="" class="display-img"/>
          </td>
          <td width="136">
            <img src="{$path-ibm-i}c.gif" width="136" height="19" alt="" class="display-img"/>
          </td>
        </tr>
      </table>
    </xsl:if>
  </xsl:template>
  <xsl:template match="resources">
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
      <!-- 5.2 9/08/05 tdc:  Subcategorize if > 3 resource elements and at least 2 diff. subcat's coded -->
      <xsl:when test="$num-resources &gt; 3 and
                                $num-resources - $num-resources-learn != 0 and
                                $num-resources - $num-resources-get != 0 and
                                $num-resources - $num-resources-discuss !=0">
        <!-- <xsl:when test="$num-resources &gt; 3 and
                                (
                                  (($num-resources) - $num-resources-learn + $num-resources-get + $num-resources-discuss) > 0
                                )"> -->
        <xsl:if test="resource[@resource-category='Learn']">
          <b>
            <xsl:value-of select="$resources-learn"/>
          </b>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <ul>
            <xsl:for-each select="resource[@resource-category='Learn']">
              <xsl:apply-templates select="."/>
            </xsl:for-each>
          </ul>
        </xsl:if>
        <xsl:if test="resource[@resource-category='Get products and technologies']">
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <b>
            <xsl:value-of select="$resources-get"/>
          </b>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <ul>
            <xsl:for-each select="resource[@resource-category='Get products and technologies']">
              <xsl:apply-templates select="."/>
            </xsl:for-each>
          </ul>
        </xsl:if>
        <!-- 5.0 5/13 tdc:  Added test for forum-url for Discuss category -->
        <xsl:if test="resource[@resource-category='Discuss'] or /dw-document//forum-url/@url !=''">
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <b>
            <xsl:value-of select="$resources-discuss"/>
          </b>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <ul>
            <xsl:if test="/dw-document//forum-url/@url !=''">
              <li>
                <xsl:copy-of select="$resource-list-forum-text"/>
                <!-- 5.0 5/16 tdc:  Corrected xpath for count function -->
                <xsl:if test="count(resource[@resource-category='Discuss']) > 0">
                  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                </xsl:if>
              </li>
            </xsl:if>
            <xsl:for-each select="resource[@resource-category='Discuss']">
              <xsl:apply-templates select="."/>
            </xsl:for-each>
          </ul>
        </xsl:if>
      </xsl:when>
      <!-- If 3 or fewer resource elements, don't subcategorize -->
      <xsl:otherwise>
        <ul>
          <xsl:if test="/dw-document//forum-url/@url !=''">
            <li>
              <xsl:copy-of select="$resource-list-forum-text"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </li>
          </xsl:if>
          <xsl:for-each select="resource">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="resource">
    <!-- 5.0 05/03 tdc:  List processing now done by generic template, ProcessList -->
    <xsl:call-template name="ProcessList"/>
  </xsl:template>
  <xsl:template match="resource-list/heading | resource/heading">
    <b>
      <xsl:value-of select="."/>
    </b>
  </xsl:template>
  <!-- End:  template "resource-list/heading" -->
  <xsl:template match="resource-list/ul">
    <ul>
      <xsl:if test=". = /dw-document//resource-list/ul[1] and /dw-document//forum-url/@url !=''">
        <li>
          <xsl:copy-of select="$resource-list-forum-text"/>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
          <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
        </li>
      </xsl:if>
      <xsl:for-each select="li">
        <xsl:choose>
          <xsl:when test="ul or ol">
            <li>
              <xsl:apply-templates select="*|text()"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <li>
              <xsl:apply-templates select="*|text()"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
              <!-- 4.0 6/11 tdc:  Only add the second break if it's not the last list element. -->
              <xsl:if test="position() !=last()">
                <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
              </xsl:if>
            </li>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </ul>
  </xsl:template>
  <xsl:template name="ResourcesSection">
    <xsl:variable name="spanClass">
      <xsl:choose>
        <xsl:when test="/dw-document/dw-article or /dw-document/dw-tutorial">
          <xsl:text>atitle</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>smalltitle</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(resource-list) or (resources)">
      <p>
        <a name="resources">
          <span class="{$spanClass}">
            <xsl:value-of select="$resource-list-heading"/>
          </span>
        </a>
      </p>
      <xsl:choose>
        <xsl:when test="resource-list">
          <xsl:apply-templates select="resource-list"/>
        </xsl:when>
        <xsl:when test="resources">
          <xsl:apply-templates select="resources"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <!-- 5.0 05/06 tdc:  only article needs backlink-rule after resources -->
    <xsl:if test=". = ../dw-article">
      <xsl:copy-of select="$ssi-s-backlink-rule"/>
    </xsl:if>
  </xsl:template>
  <!-- SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS -->
  <xsl:template name="SeriesMore">
    <!--  MoreSERIES-->
    <!-- 5.2 10/14 fjc: -->
    <xsl:if test="normalize-space(series/series-title)  and normalize-space(series/series-url)">
      <tr valign="top">
        <td align="right">
          <img alt="" width="150" height="1" src="{$path-v14-rules}gray_rule.gif"/>
          <table width="150" border="0" cellspacing="2" class="v14-gray-table-border">
            <tr>
              <td align="left">
                <p class="small">
                  <b>
                    <xsl:value-of select="$moreThisSeries"/>
                  </b>
                  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                  <xsl:call-template name="Series"/>
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </xsl:if>
    <!--  More SERIES_END-->
  </xsl:template>
  <xsl:template name="Series">
    <!--  SERIES-->
    <xsl:if test="series/series-title !='' and series/series-url != ''">
      <xsl:text disable-output-escaping="yes"><![CDATA[<a  class="smallplainlink" href="]]></xsl:text>
      <xsl:value-of select="series/series-url"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
      <xsl:value-of select="series/series-title"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[</a>]]></xsl:text>
    </xsl:if>
    <!--  SERIES_END-->
  </xsl:template>
  <xsl:template match="sidebar">
    <xsl:variable name="width">
      <xsl:choose>
        <xsl:when test="@width!=''">
          <xsl:value-of select="@width"/>
        </xsl:when>
        <xsl:when test="not(@width!='')">40%</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="align">
      <xsl:choose>
        <xsl:when test="@align!=''">
          <xsl:value-of select="@align"/>
        </xsl:when>
        <xsl:when test="not(@align!='')">right</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <table width="{$width}" cellpadding="0" cellspacing="0" border="0" align="{$align}">
      <tr>
        <!-- Left gutter -->
        <td width="10">
          <img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
        </td>
        <td>
          <table width="100%" cellpadding="5" cellspacing="0" border="1">
            <tr>
              <td bgcolor="#eeeeee">
                <xsl:apply-templates/>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </xsl:template>
  <xsl:template name="SkillLevel">
    <!-- 5.0 05/10 tdc:  Made xpath for skill-level test fully qualified so each tutorial/section could use -->
    <!-- 5.0 5/17 fjc add the course type text here-->
    <xsl:if test="(/dw-document//@course-type)or(/dw-document//@skill-level)">
      <xsl:text disable-output-escaping="yes"><![CDATA[<p>]]></xsl:text>
    </xsl:if>
    <xsl:if test="/dw-document//@course-type">
      <xsl:call-template name="CourseType"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
    </xsl:if>
    <xsl:if test="/dw-document//@skill-level">
      <xsl:variable name="levelname">
        <xsl:call-template name="SkillLevelText"/>
      </xsl:variable>
      <xsl:value-of select="$level-text-heading"/>
      <xsl:value-of select="$levelname"/>
    </xsl:if>
    <xsl:if test="(/dw-document//@course-type)or(/dw-document//@skill-level)">
      <xsl:text disable-output-escaping="yes"><![CDATA[</p>]]></xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="SkillLevelText">
    <!-- 5.0 05/10 tdc:  Made xpath for skill-level test fully qualified so each tutorial/section could use -->
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
  <xsl:template match="span">
    <span>
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates select="*|text()"/>
    </span>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Moved to common from landing product -->
  <xsl:template name="SpecialOffers">
    <xsl:choose>
      <xsl:when test="not(special-offers/@content-area-name='none')">
        <xsl:variable name="special-offers-include-url">
          <xsl:call-template name="SpecialOffersURL">
            <xsl:with-param name="special-offers-url">
              <xsl:value-of select="special-offers/@content-area-name"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of disable-output-escaping="yes" select="$special-offers-include-url"/>
      </xsl:when>
      <xsl:when test="string(special-offers/@custom-file-name)">
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
        <xsl:value-of select="special-offers/@custom-file-name"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[" -->]]></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes"><![CDATA[<!--#include virtual="]]></xsl:text>
        <xsl:copy-of select="$path-dw-inc"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[s-offers14.inc" -->]]></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd Moved to common from landing product -->
  <xsl:template name="SpecialOffersURL">
    <xsl:param name="special-offers-url"/>
    <xsl:choose>
      <xsl:when test="special-offers/@content-area-name='autonomic'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-ac-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='db2'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[d-dm-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='eserver'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[d-es-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='grid'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-gr-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='java'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-j-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='linux'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-l-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='lotus'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[d-ls-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='opensource'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-os-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='power'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-pa-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='rational'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[d-r-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='tivoli'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[d-tv-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='web'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-wa-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='webservices'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-ws-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='websphere'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[d-w-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='wireless'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-wi-offers.inc" -->]]></xsl:when>
      <xsl:when test="special-offers/@content-area-name='xml'"><![CDATA[<!--#include virtual="]]><xsl:copy-of select="$path-dw-inc"/><![CDATA[t-x-offers.inc" -->]]></xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="SystemRequirements">
    <!--  SYSTEM REQUIREMENTS -->
    <xsl:if test="system-requirements/.!=''">
      <p>
        <span class="smalltitle">
          <xsl:value-of select="$summary-systemRequirements"/>
        </span>
      </p>
      <xsl:apply-templates select="system-requirements/*|text()"/>
    </xsl:if>
    <!--   SYSTEM REQUIREMENTS END -->
  </xsl:template>
  <!-- TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT -->
  <xsl:template match="table">
    <table xsl:exclude-result-prefixes="xsl fo">
      <!-- 5.0 6/21 tdc:  Added class and summary attrib's -->
      <xsl:for-each select="@border | @cellpadding | @cellspacing | @class | @cols | @summary | @width">
        <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="*"/>
    </table>
  </xsl:template>
  <xsl:template match="td">
    <td xsl:exclude-result-prefixes="xsl fo">
      <!-- 5.0 6/21 tdc:  Added class and style attrib's -->
      <xsl:for-each select="@bgcolor | @height | @width | @class | @style | @colspan | @rowspan | @align | @valign">
        <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="*|text()"/>
    </td>
  </xsl:template>
  <!-- 5.0 6/21 tdc:  Added th -->
  <xsl:template match="th">
    <th xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </th>
  </xsl:template>
  <!-- 5.0 6/21 tdc:  Added caption -->
  <xsl:template match="caption">
    <caption xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>
  <!-- 5.0 6/21 tdc:  Added em -->
  <xsl:template match="em">
    <em xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  <xsl:template name="TechLibView">
    <xsl:param name="contentarea"/>
    <xsl:choose>
      <xsl:when test="$contentarea= 'db2' ">
        <xsl:value-of select="$techlibview-db2"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'eserver' ">
        <xsl:value-of select="$techlibview-es"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'ibm' ">
        <xsl:value-of select="$techlibview-i"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'lotus' ">
        <xsl:value-of select="$techlibview-lo"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'rational' ">
        <xsl:value-of select="$techlibview-r"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'tivoli' ">
        <xsl:value-of select="$techlibview-tiv"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'websphere' ">
        <xsl:value-of select="$techlibview-web"/>
      </xsl:when>
      <!-- 5.2 8/24/05 tdc:  Added workplace -->
      <xsl:when test="$contentarea= 'workplace' ">
        <xsl:value-of select="$techlibview-wp"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'autonomic' ">
        <xsl:value-of select="$techlibview-au"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'grid' ">
        <xsl:value-of select="$techlibview-gr"/>
      </xsl:when>
      <xsl:when test="$contentarea = 'java' ">
        <xsl:value-of select="$techlibview-j"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'linux' ">
        <xsl:value-of select="$techlibview-l"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'opensource' ">
        <xsl:value-of select="$techlibview-os"/>
      </xsl:when>
      <!-- 5.0 tdc 7/11:  Added power (techlibview-pa had already had been added to translated text) -->
      <xsl:when test="$contentarea= 'power' ">
        <xsl:value-of select="$techlibview-pa"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'webservices' ">
        <xsl:value-of select="$techlibview-ws"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'web' ">
        <xsl:value-of select="$techlibview-wa"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'wireless' ">
        <xsl:value-of select="$techlibview-wi"/>
      </xsl:when>
      <xsl:when test="$contentarea= 'xml' ">
        <xsl:value-of select="$techlibview-x"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- pre-v5 th template
  <xsl:template match="th">
    <td align="center" valign="top">
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <b>
        <xsl:apply-templates select="*|text()"/>
      </b>
    </td>
  </xsl:template>
  -->
  <!-- 5.1 7/22 jpp/egd moved to common from landing product -->
  <xsl:template name="TopStory">
    <xsl:for-each select="//product-top-story">
      <table width="443" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td colspan="2">
            <img alt="" height="3" src="{$path-v14-rules}dblue_rule.gif" width="100%"/>
          </td>
        </tr>
      </table>
      <table width="443" cellpadding="0" cellspacing="0" border="0">
        <tr valign="top">
          <td width="150">
            <a href="{target-file-url}">
              <img src="{main-image-url}" width="150" height="100" border="0" alt="{top-story-heading}"/>
            </a>
          </td>
          <td width="10">
            <img src="{$path-ibm-i}c.gif" width="10" height="1" alt=""/>
          </td>
          <td width="283">
            <img src="{$path-ibm-i}c.gif" width="270" height="8" border="0" alt=""/>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <a href="{target-file-url}" class="feature">
              <xsl:value-of select="top-story-heading"/>
            </a>
            <!-- 5.0.1 9/21 llk - this break tag did not have cdata tags around it -->
            <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
            <xsl:apply-templates select="//top-story-abstract"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;&nbsp;]]></xsl:text>
            <a href="{target-file-url}">
              <xsl:value-of select="$more-link-text"/>
              <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;&gt;]]></xsl:text>
            </a>
          </td>
          <td width="3">
            <img src="{$path-ibm-i}c.gif" width="3" height="1" alt=""/>
          </td>
        </tr>
      </table>
      <!-- Spacer -->
      <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="tr">
    <tr xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="*"/>
    </tr>
  </xsl:template>
  <xsl:template match="tr">
    <tr xsl:exclude-result-prefixes="xsl fo">
      <xsl:for-each select="@*">
        <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="*"/>
    </tr>
  </xsl:template>
  <!-- 5.1 7/22 jpp/egd moved to common from landing product -->
  <xsl:template name="TwoColumnLinks">
    <xsl:param name="sectionCount"/>
    <xsl:param name="sectionPath"/>
    <table width="443" cellspacing="0" cellpadding="0" border="0">
      <tr>
        <td colspan="3">
          <img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/>
        </td>
      </tr>
      <tr valign="top">
        <td width="218">
          <table cellspacing="0" cellpadding="0" border="0">
            <tr valign="top">
              <td colspan="2">
                <img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/>
              </td>
            </tr>
            <xsl:for-each select="$sectionPath">
              <xsl:if test="not(position() > $sectionCount)">
                <xsl:call-template name="ColumnLinks"/>
              </xsl:if>
            </xsl:for-each>
          </table>
        </td>
        <td width="7">
          <img src="{$path-ibm-i}c.gif" width="7" height="8" alt=""/>
        </td>
        <td width="218">
          <table cellspacing="0" cellpadding="0" border="0">
            <tr valign="top">
              <td colspan="2">
                <img src="{$path-ibm-i}c.gif" width="8" height="4" alt=""/>
              </td>
            </tr>
            <xsl:for-each select="$sectionPath">
              <xsl:if test="(position() > $sectionCount)">
                <xsl:call-template name="ColumnLinks"/>
              </xsl:if>
            </xsl:for-each>
          </table>
        </td>
      </tr>
    </table>
  </xsl:template>
  <!-- VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV -->
  <xsl:template name="ViewSchedule">
    <!--  View Schedule-->
    <!-- 5.2 8/31/05 tdc: Added '/course-number' to test -->
    <!-- 5.2 08/09 fjc be sure to test first -->
    <xsl:if test="//enrollment-schedule/course-number">
      <table border="0" cellpadding="0" cellspacing="0">
        <tr valign="top">
          <td colspan="2">
            <img src="{$path-ibm-i}c.gif" border="0" height="12" width="12" alt=""/>
          </td>
        </tr>
        <tr>
          <td>
            <!-- 5.0 5/18 fjc had the wrong GIF-->
            <img src="{$path-v14-icons}d_bold.gif" width="16" height="16" alt=""/>
          </td>
          <td>
            <a class="fbox" href="#schedule">
              <b>
                <xsl:value-of select="$summary-viewSchedules"/>
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
    </xsl:if>
    <!--  View Schedule end-->
  </xsl:template>
</xsl:stylesheet>
