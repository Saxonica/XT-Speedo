<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q2. Return the initial increases of all open auctions. -->
        
    <!--    
        for $b in (:document("auction.xml"):)/site/open_auctions/open_auction
        return <increase> {$b/bidder[1]/increase } </increase>   
    -->
    
    <!-- Edited to not duplicate 'increase' tags -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="/site">
        <xsl:for-each select="/site/open_auctions/open_auction">
            <xsl:copy-of select="bidder[1]/increase"/>                                    
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>