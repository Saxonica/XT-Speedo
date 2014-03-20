<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q12.  For each richer-than-average person, list the number of items 
         currently on sale whose price does not exceed 0.02% of the 
         person's income. -->
    
    <!--    
        for $p in (:doc("xmark1.xml"):)/site/people/person
        let $l := for $i in (:doc("xmark1.xml"):)/site/open_auctions/open_auction/initial
                where $p/profile/@income > (5000 * $i)
                return $i
        where  $p/profile/@income > 50000
        return <items person="{$p/name}">{ count ($l) }</items>
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:variable name="p" select="people/person[profile/@income > 50000]"/>
        <xsl:for-each select="$p">
            <xsl:variable name="i" select="/site/open_auctions/open_auction/initial[current()/profile/@income > (5000 * .)]"/>
            <items name="{current()/name}">
                <xsl:value-of select="count($i)"/>
            </items>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>