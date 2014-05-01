<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map local"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="doc" select="/"/>
    
    <xsl:function name="local:function" as="xs:integer">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="element()*"/>
        <xsl:sequence select="count($value)"/>
    </xsl:function>
    
    <xsl:template match="/">
        <out>
            <xsl:variable name="words" as="map(xs:string, element()*)">
                <xsl:map>
                    <xsl:for-each-group select="//*" group-by="tokenize(., '\W+')[.!='']">
                        <xsl:map-entry key="current-grouping-key()" select="current-group()"/>
                    </xsl:for-each-group>
                </xsl:map>
            </xsl:variable>           
                        
            <read>
                <xsl:sequence select="map:for-each-entry($words, local:function)"/>
            </read>
        </out>
    </xsl:template>
    
</xsl:stylesheet>
