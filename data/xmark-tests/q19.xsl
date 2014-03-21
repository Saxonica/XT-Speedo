<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q19. Give an alphabetically ordered list of all
         items along with their location. -->
    
    <!--    
        for    $b in (:document("auction.xml"):)/site/regions//item
        let    $k := $b/name
        order by $k
        return <item name="{$k}">{ $b/location } </item>
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each select="regions//item">
            <xsl:sort select="./name"/>
            <item name="{./name}">
                <xsl:copy-of select="./location"/>
            </item>
        </xsl:for-each>        
    </xsl:template>    
    
</xsl:stylesheet>