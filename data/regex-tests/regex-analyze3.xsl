<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"        
    version="2.0">
        
    <xsl:template match="@*|node()" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" priority="2">
        <xsl:analyze-string select="." regex="\w+">
            <xsl:matching-substring>
                <xsl:value-of select="replace(replace(., '^the$', 'a'), '^The$', 'A')"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:stylesheet>