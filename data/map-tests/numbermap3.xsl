<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" 
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions"
    exclude-result-prefixes="xs map local"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template name="main">
        <out>
            <xsl:variable name="quadratic-map" as="map(xs:integer, xs:integer)">
                <xsl:map>
                    <xsl:for-each select="1 to 10000">
                        <xsl:map-entry key="." select="((.*.) + (3*.) + 7) mod 100"/>
                    </xsl:for-each>
                </xsl:map>
            </xsl:variable>
                        
            <xsl:iterate select="1 to 10000">
                <xsl:param name="map2" select="$quadratic-map" as="map(xs:integer, xs:integer)"/>
                <xsl:choose>
                    <xsl:when test="$map2(.) mod 7 = 0">
                        <xsl:next-iteration>
                            <xsl:with-param name="map2" select="map:new(($map2, map{. := 0}))"/>
                        </xsl:next-iteration>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:next-iteration>
                            <xsl:with-param name="map2" select="map:new(($map2, map{. := $map2(.)+1}))"/>
                        </xsl:next-iteration>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:on-completion>
                    <xsl:for-each select="1 to 100">
                        <result initial="{$quadratic-map(.)}" final="{$map2(.)}"/>
                    </xsl:for-each>
                                         
                </xsl:on-completion>
            </xsl:iterate>
                    
        </out>
    </xsl:template>
    
    
</xsl:stylesheet>
