<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template name="main">
        <out>
            <xsl:variable name="numbers" as="map(xs:integer, xs:integer)" select="map:new()"/>
            <xsl:iterate select="1 to 10000">
                <xsl:param name="numbers2" select="$numbers" as="map(xs:integer, xs:integer)"/>
                <!--<result keys="{map:keys($numbers2)}"/>-->                 
                <xsl:next-iteration>
                    <xsl:with-param name="numbers2" select="map:new(($numbers2, map{. := 2*.}))"/>
                </xsl:next-iteration>
                <xsl:on-completion>
                    <final keys="{count(map:keys($numbers2))}"/>
                </xsl:on-completion>
            </xsl:iterate>
        </out>
    </xsl:template>

</xsl:stylesheet>
