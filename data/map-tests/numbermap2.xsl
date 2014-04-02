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
            <xsl:iterate select="2 to 59">
                <xsl:param name="fib10" select="$fib" as="map(xs:integer, xs:integer)"/>
                <xsl:next-iteration>
                    <xsl:with-param name="fib10" select="map:new(($fib10, map{. := ($fib10(.-1) + $fib10(.-2)) mod 10}))"/>
                </xsl:next-iteration>
                <xsl:on-completion>
                    
                    <xsl:variable name="index" as="map(xs:integer, xs:integer*)">
                        <xsl:map>
                            <xsl:for-each-group select="map:keys($fib10)" group-by="$fib10(.)">
                                <xsl:map-entry key="current-grouping-key()" select="current-group()"/>
                            </xsl:for-each-group>
                        </xsl:map>                        
                    </xsl:variable>                    
                    <xsl:for-each select="0 to 9">
                        <numbermap2 digit="{.}" frequency="{count($index(.))}"/>
                    </xsl:for-each>         
                    <xsl:for-each select="0 to 59">
                        <fib last-digit="{$fib10(.)}"/>
                    </xsl:for-each> 
                    
                </xsl:on-completion>     
            </xsl:iterate>            
        </out>
    </xsl:template>
           
</xsl:stylesheet>
