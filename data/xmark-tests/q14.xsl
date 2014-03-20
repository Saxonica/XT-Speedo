<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q14. Return the names of all items whose description contains the 
         word `gold' -->
    
    <!--    
        for $i in (:document("auction.xml"):)/site//item
        where contains ($i/description,"gold")
        return ($i/name, $i/description)
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="//item[contains(./description,'gold')]">
            <xsl:copy-of select="current()/name"/>
            <xsl:copy-of select="current()/description"/>            
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>