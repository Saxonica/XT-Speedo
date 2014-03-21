<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q18.Convert the currency of the reserve of all open auctions to 
         another currency. -->
    
    <!--    
        declare namespace f="http://f/";
        declare function f:convert ($v)
        {
        2.20371 * $v (: convert Dfl to Euro :)
        };
        
        for    $i in (:document("auction.xml"):)/site/open_auctions/open_auction
        return f:convert($i/reserve)
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each select="open_auctions/open_auction/reserve"> 
            <reserve>
                <xsl:value-of select="(.) * 2.20371"/> <!-- Parentheses added to avoid XT driver bug -->
            </reserve>
        </xsl:for-each>        
    </xsl:template>    
    
</xsl:stylesheet>