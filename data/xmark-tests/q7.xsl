<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q7. How many pieces of prose are in our database? -->
    
    <!--    
        for $p in (:document("auction.xml"):)/site
        return count($p//description) + count($p//annotation) + count($p//email)
    -->
         
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:value-of select="count(//description) + count(//annotation) + count(//email)"/>  
    </xsl:template>
    
</xsl:stylesheet>