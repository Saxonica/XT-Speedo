<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q4. List the reserves of those open auctions where a
        certain person issued a bid before another person. -->
    
    <!--    
        for    $b in /site/open_auctions/open_auction
        where  $b/bidder/personref[@person="person18829"] <<
        $b/bidder/personref[@person="person10487"]
        return <history>{ $b/reserve }</history> 
    -->
    
    <!--    
        for    $b in /site/open_auctions/open_auction
        where  $b/bidder[personref/@person="person18829"]/following-sibling::
        bidder[personref/@person="person10487"]
        return <history>{ $b/reserve }</history> 
    -->
         
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="open_auctions/open_auction">
            <xsl:if test="bidder[personref/@person = 'person16']/following-sibling::bidder[personref/@person='person250']">
                <history>
                    <xsl:value-of select="reserve"/>
                </history>               
            </xsl:if>                                            
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>