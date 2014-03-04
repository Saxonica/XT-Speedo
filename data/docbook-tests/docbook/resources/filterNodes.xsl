<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="f">
    
    <xsl:template match="node() | @*" mode="filterNodes">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="filterNodes"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Transform MS Word titles to XHTML titles. -->
    <xsl:template match="xhtml:div[xhtml:p[@class = 'MsoTitle']]" mode="filterNodes">
        <h1 xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="xhtml:p[@class = 'MsoTitle']"/>
        </h1>
    </xsl:template>
    
    <!-- Unwrap xhtml:div nodes and keep only the child nodes. -->
    <xsl:template match="xhtml:div | xhtml:center" mode="filterNodes">
        <xsl:apply-templates select="node()" mode="filterNodes"/>
    </xsl:template>
    
    <!-- Separate adjacent spans with one space for avoiding 
        joining last wortd of previous span with first word of next span. -->
    <xsl:template match="text()[string-length(normalize-space()) > 0]
                                [parent::xhtml:span/preceding-sibling::*[1][self::xhtml:span]]" 
                mode="filterNodes"
                priority="1">
        <xsl:text> </xsl:text>
        <xsl:copy/>
    </xsl:template>
    
    <!-- Filter xhtml:head and empty nodes. -->
    <xsl:template match="xhtml:head" mode="filterNodes" priority="2"/>
    <xsl:template match="*[not(node())]
            [not(local-name() = 'img' 
               or local-name() = 'ph' 
               or local-name() = 'br' 
               or local-name() = 'col' 
               or local-name() = 'colgroup')]" 
                            mode="filterNodes"
                            priority="2"/>
    <xsl:template match="text()[string-length(normalize-space()) = 0]" mode="filterNodes"/>
    <xsl:template match="xhtml:head" mode="filterNodes" priority="2"/>
</xsl:stylesheet>
