<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q3. Return the IDs of all open auctions whose current
        increase is at least twice as high as the initial increase. -->
    
    <!--    
        for    $b in (:document("auction.xml"):)/site/open_auctions/open_auction
        where  $b/bidder[1]/increase *2 <= $b/bidder[last()]/increase
        return <increase first="{$b/bidder[1]/increase}"
        last="{$b/bidder[last()]/increase}"/> 
    -->
         
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="open_auctions/open_auction">
            <xsl:if test="bidder[1]/increase *2 &lt;= bidder[last()]/increase">
                <increase first="{bidder[1]/increase}" last="{bidder[last()]/increase}"/>               
            </xsl:if>                                            
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>