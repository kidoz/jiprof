<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xsl fo">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" encoding="UTF-8"/>
  <!-- 5.2 9/07/05 tdc:  Removed forumwindow javascripts; Discuss link will be plain URL -->
  <xsl:template name="emailFriendJavaScripts">
    <!-- START E-MAIL IT! SCRIPTS - MUST OCCUR IN THIS ORDER -->
    <script type="text/javascript" language="JavaScript">var emailAbstract = "<xsl:call-template name="FilterAbstract"/>"; </script>
<!-- 5.0 05/02 tdc:  Remove grabtitle.js and emailfriend2.js; already called by s-header-scripts.inc -->
    <!-- END OF E-MAIL IT! SCRIPTS -->
  </xsl:template>
  <xsl:template name="JavaScripts">
    <!-- 5.2 9/07/05 tdc:  Removed forumJavaScripts -->
    <xsl:call-template name="emailFriendJavaScripts"/>
    <!-- 4.0 5/26 tdc:  Removed demo scripts -->
  </xsl:template>
</xsl:stylesheet>
