<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" 
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions"
    exclude-result-prefixes="xs map local"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
            
    <xsl:template match="/">
        <out>
            <xsl:variable name="fib" as="map(xs:integer, xs:integer)">
                <xsl:map>
                    <xsl:map-entry key="0" select="0"/>
                    <xsl:map-entry key="1" select="1"/>                         
                </xsl:map>
            </xsl:variable>    
            <xsl:iterate select="2 to 10000">
                <xsl:param name="fib10" select="$fib" as="map(xs:integer, xs:integer)"/>
                <xsl:next-iteration>
                    <xsl:with-param name="fib10" select="map:new(($fib10, map{. := ($fib10(.-1) + $fib10(.-2)) mod 10}))"/>
                </xsl:next-iteration>
                <xsl:on-completion>
                    <!--<xsl:call-template name="mapchange"/>-->
                    <xsl:iterate select="0 to 10000">
                        <xsl:param name="intmap" select="$fib10" as="map(xs:integer, xs:integer)"/>
                        <xsl:choose>
                            <xsl:when test="$intmap(.) = 0">
                                <xsl:next-iteration>
                                    <xsl:with-param name="intmap" select="map:new(($intmap, map{. := $intmap(.)}))"/>
                                </xsl:next-iteration>
                            </xsl:when>
                            <xsl:when test="$intmap(.) mod 3 = 0">
                                <xsl:next-iteration>
                                    <xsl:with-param name="intmap" select="map:new(($intmap, map{. := $intmap(.)-2}))"/>
                                </xsl:next-iteration>
                            </xsl:when>
                            <xsl:when test="$intmap(.) = 2">
                                <xsl:next-iteration>
                                    <xsl:with-param name="intmap" select="map:new(($intmap, map{. := 3}))"/>
                                </xsl:next-iteration>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:next-iteration>
                                    <xsl:with-param name="intmap" select="map:new(($intmap, map{. := $intmap(.)+1}))"/>
                                </xsl:next-iteration>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:on-completion>
                            <map size="{map:size($intmap)}"/>
                            <xsl:for-each select="0 to 100">
                                <numbermap key="{.}" value="{$intmap(.)}"/>
                            </xsl:for-each>                     
                        </xsl:on-completion>
                    </xsl:iterate>
                </xsl:on-completion>     
            </xsl:iterate>            
        </out>
    </xsl:template>
    
    <!--<xsl:template name="mapchange">       
        <xsl:iterate select="0 to 100">
            <xsl:param name="intmap" select="$fib10" as="map(xs:integer, xs:integer)"/>
            <xsl:choose>
                <xsl:when test="$intmap(.) mod 3 = 0">
                    <xsl:next-iteration>
                        <xsl:with-param name="intmap" select="map:new(($intmap, map{. := $intmap(.)+1}))"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-iteration>
                        <xsl:with-param name="intmap" select="map:new(($intmap, map{. := $intmap(.)-1}))"/>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:on-completion>
                <xsl:for-each select="0 to 100">
                    <intmap number="{$intmap(.)}"/>
                </xsl:for-each>                     
            </xsl:on-completion>
        </xsl:iterate>
    </xsl:template>-->
    
</xsl:stylesheet>
