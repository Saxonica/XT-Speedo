<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template name="main">
        <out>
            <xsl:analyze-string select="unparsed-text('xmark4.txt')" regex="mailto:(.*)(\s)">
                <xsl:matching-substring>
                    <email>
                        <xsl:value-of select="regex-group(1)"/>
                    </email>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </out>        
    </xsl:template>
</xsl:stylesheet>