<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q13. List the names of items registered in Australia along with 
         their descriptions. -->
    
    <!--    
        for $i in (:document("auction.xml"):)/site/regions/australia/item
        return <item name="{$i/name}">{ $i/description }</item>
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each select="regions/australia/item">            
            <items name="{current()/name}">
                <xsl:copy-of select="current()/description"/>
            </items>
        </xsl:for-each>
    </xsl:template>    
    
</xsl:stylesheet>