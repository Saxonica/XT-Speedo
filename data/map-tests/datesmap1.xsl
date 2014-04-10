<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <out>
            <xsl:variable name="dates" as="map(xs:date, xs:string)" select="map:new()"/>
            <xsl:iterate select="1 to 10">
                <xsl:param name="dates2" select="$dates" as="map(xs:date, xs:string)"/>
                <!--<result keys="{map:keys($dates2)}"/>-->                 
                <xsl:next-iteration>
                    <xsl:with-param name="dates2" select="map:new(($dates2, map{2014-.-1 := .}))"/>
                </xsl:next-iteration>
                <xsl:on-completion>
                    <final keys="{count(map:keys($dates2))}"/>
                </xsl:on-completion>
            </xsl:iterate>
        </out>
    </xsl:template>
    
</xsl:stylesheet>
