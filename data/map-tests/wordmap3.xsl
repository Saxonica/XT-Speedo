<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="wordlist" as="xs:string*">
        <xsl:for-each-group select="for $w in doc('prague2011mhk.xml')//text()/tokenize(., '\W+')[.!=''] return lower-case($w)" group-by=".">
            <xsl:sequence select="current-grouping-key()"/>
        </xsl:for-each-group>
    </xsl:variable>          
    
    <xsl:variable name="biggerwordlist" as="xs:string*">
        <xsl:for-each select="$wordlist">
            <xsl:sequence select="., concat(.,'e'), concat(.,'t'), concat(.,'s'), concat(.,'n'), concat(.,'l'), concat(.,'ing'), concat(.,'er'), concat(.,'ed')"/>
        </xsl:for-each>
    </xsl:variable>
        
    <xsl:template match="/">
        <out>
            <xsl:variable name="words" as="map(xs:string, xs:integer)">
                <xsl:map>
                    <xsl:for-each-group select="//text()" group-by="tokenize(., '\W+')[.!='']">
                        <xsl:map-entry key="current-grouping-key()" select="count(current-group())"/>
                    </xsl:for-each-group>
                </xsl:map>
            </xsl:variable>
            
            <wordlist size="{count($wordlist)}" bigsize="{count($biggerwordlist)}"/>                
            
            <xsl:iterate select="$biggerwordlist">
                <xsl:param name="words2" select="$words" as="map(xs:string, xs:integer)"/>
                <xsl:choose>
                    <xsl:when test="map:contains($words2,.)">
                        <xsl:next-iteration>
                            <xsl:with-param name="words2" select="map:new(($words2, map{. := $words2(.)+1}))"/>
                        </xsl:next-iteration>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:next-iteration>
                            <xsl:with-param name="words2" select="map:new(($words2, map{. := 1}))"/>
                        </xsl:next-iteration>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:on-completion>
                    <result initial="{map:size($words)}" final="{map:size($words2)}" difference="{map:size($words2) - map:size($words)}"/>                     
                </xsl:on-completion>
            </xsl:iterate>
            
        </out>
    </xsl:template>
    
</xsl:stylesheet>
