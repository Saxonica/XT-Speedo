<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q8.  List the names of persons and the number of items they bought.
    (joins person, closed_auction) -->
    
    <!--    
        for $p in (:document("auction.xml"):)/site/people/person
        let $a := for $t in (:document("auction.xml"):)/site/closed_auctions/closed_auction
        where $t/buyer/@person = $p/@id
        return $t
        return <item person="{$p/name}"> {count ($a)} </item>
    -->
    
<!--    <result xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xsl:version="2.0">        
        <xsl:for-each select="/site/people/person">
            <xsl:variable name="a" 
                select="/site/closed_auctions/closed_auction[buyer/@person = current()/@id]"/>
            <item person="{name}"><xsl:value-of select="count($a)"/></item>  
        </xsl:for-each>        
    </result>  -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="people/person">
            <xsl:variable name="a" 
                select="/site/closed_auctions/closed_auction[buyer/@person = current()/@id]"/>
            <item person="{name}">
                <xsl:value-of select="count($a)"/>
            </item>  
        </xsl:for-each>
    </xsl:template> 
    
</xsl:stylesheet>