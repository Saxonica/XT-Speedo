<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q5.  How many sold items cost more than 40? -->
    
    <!--    
        count(for $i in (:document("auction.xml"):)/site/closed_auctions/closed_auction
        where  $i/price >= 40 
        return $i/price) 
    -->
         
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:value-of select="count(closed_auctions/closed_auction/price[. >= 40])"/>        
    </xsl:template>
    
</xsl:stylesheet>