<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <out>
            <xsl:variable name="words" as="map(xs:string, xs:string*)" select="map:new()"/>
            <xsl:iterate select="//*/tokenize(., '\W+')[.!='']">
                <xsl:param name="words2" select="$words" as="map(xs:string, xs:string)"/>
                <result keys="{count(map:keys($words2))}"/>            
                <xsl:next-iteration>
                    <xsl:with-param name="words2" select="map:new(($words2, map{. := .}))"/>
                </xsl:next-iteration>
                <xsl:on-completion>
                    <final keys="{count(map:keys($words2))}"/>
                </xsl:on-completion>
            </xsl:iterate>
        </out>
    </xsl:template>
    
</xsl:stylesheet>
