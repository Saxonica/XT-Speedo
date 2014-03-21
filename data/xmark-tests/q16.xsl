<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q16. Return the IDs of those auctions
         that have one or more keywords in emphasis. -->
    
    <!--    
        for $a in (:document("auction.xml"):)/site/closed_auctions/closed_auction
        where exists ($a/annotation/description/parlist/listitem/parlist/
                            listitem/text/emph/keyword/text())
        return <person id="{$a/seller/@person}" />
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each select="closed_auctions/closed_auction[annotation/description/parlist/listitem/parlist/listitem/text/emph/keyword]">            
            <person id="{./seller/@person}"/>                
        </xsl:for-each>        
    </xsl:template>    
    
</xsl:stylesheet>