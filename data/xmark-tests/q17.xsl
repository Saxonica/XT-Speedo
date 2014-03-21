<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q17. Which persons don't have a homepage? -->
    
    <!--    
        for    $p in (:document("auction.xml"):)/site/people/person
        where  empty($p/homepage/text())
        return <person>{$p/name}</person>
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each select="people/person[not(homepage/text())]"> 
            <person name="{./name}"/>               
        </xsl:for-each>        
    </xsl:template>    
    
</xsl:stylesheet>