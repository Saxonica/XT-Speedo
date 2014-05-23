<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template name="main">
        <out>            
            <xsl:analyze-string select="unparsed-text('xmark1.txt')" regex="\n(([0-9]{{4}}\s){{3}}[0-9]{{4}})">
                <xsl:matching-substring>
                    <card>
                        <xsl:value-of select="regex-group(1)"/>
                    </card>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </out>
    </xsl:template>
</xsl:stylesheet>