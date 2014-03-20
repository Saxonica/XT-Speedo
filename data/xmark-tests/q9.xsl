<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">
    
    <!-- Q9. List the names of persons and the names of the items they bought
         in Europe.  (joins person, closed\_auction, item) -->
    
    <!--    
        for $p in /site/people/person
        let $a := for $t in /site/closed_auctions/closed_auction
        let $n := for $t2 in /site/regions/europe/item
        where  $t/itemref/@item = $t2/@id
        return $t2
        where $p/@id = $t/buyer/@person
        return <item> {$n/name} </item>
        return <person name="{$p/name}">{ $a }</person>
    -->
    
    <!-- Edited so that empty items (for items bought outside Europe) no longer produced -->
         
    <xsl:output encoding="utf-8"/>
    
    <xsl:function name="local:f" as="element(item)*">
        <xsl:param name="root" as="document-node(element(site))"/>
        <xsl:param name="t" as="element(closed_auction)"/>
        <xsl:sequence select="$root/site/regions/europe/item[$t/itemref/@item = ./@id]"/>
    </xsl:function>
    
    <xsl:function name="local:g" as="element(name)*">
        <xsl:param name="root" as="document-node(element(site))"/>
        <xsl:param name="p" as="element(person)"/>
        <xsl:for-each select="$root/site/closed_auctions/closed_auction[$p/@id = ./buyer/@person]">
            <xsl:sequence select="local:f($root, .)/name"/>                           
        </xsl:for-each>            
    </xsl:function>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="people/person">
            <xsl:variable name="a" select="local:g(/, .)" as="element(name)*"/>
            <person name="{./name}">
                <xsl:for-each select="$a">
                <item>
                    <xsl:value-of select="."/>
                </item>                
                </xsl:for-each>
            </person>
        </xsl:for-each>
    </xsl:template> 
    
</xsl:stylesheet>