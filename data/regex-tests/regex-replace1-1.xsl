<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template name="main">
        <out>
            <xsl:value-of select="replace(unparsed-text('xmark1.txt'), '([0-9]+)/([0-9]+)/([0-9]{4})', '$3-$1-$2')"/>       
        </out>
    </xsl:template>
</xsl:stylesheet>