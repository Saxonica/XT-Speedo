<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q15. Print the keywords in emphasis in annotations of closed auctions. -->
    
    <!--    
        for $a in (:document("auction.xml"):)/site/closed_auctions/closed_auction/annotation/
                    description/parlist/listitem/parlist/listitem/text/emph/keyword
        return <text>{ $a }</text>
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each select="closed_auctions/closed_auction/annotation/description/parlist/listitem/parlist/listitem/text/emph/keyword">            
            <text>
                <xsl:copy-of select="."/>
            </text>
        </xsl:for-each>
    </xsl:template>    
    
</xsl:stylesheet>