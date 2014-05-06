<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xqf="urn:xq.internal-function" xmlns:f="internal" version="2.0">
    <xsl:import href="xq-spectrum.xsl"/>

    <!-- input xml is a single 'text-file' element containing the file uri: eg. 
        <text-file>
           xqdoc-display1.xqy
        </text-file> 
    -->
    <xsl:template match="/">
        
        <xsl:variable name="text-file-uri" select="f:path-to-uri(normalize-space(text-file))"/>
        <xsl:variable name="file-content" as="xs:string" select="unparsed-text($text-file-uri)"/>
        <xsl:variable name="tokens" as="element()*" select="xqf:show-xquery($file-content)"/>
        
        <xquery-tokens>
            <pre xmlns="http://www.w3.org/1999/xhtml">
                <xsl:sequence select="$tokens"/>                
            </pre>
        </xquery-tokens>
        
    </xsl:template>

    <xsl:function name="f:path-to-uri">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="matches($path, '^[A-Za-z]:.*')">
                <xsl:value-of select="concat('file:/', $path)"/>
            </xsl:when>
            <xsl:when test="starts-with($path, '/')">
                <xsl:value-of select="concat('file://', $path)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
