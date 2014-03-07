<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Test case based on a bug report from Gunther Rademacher, see https://saxonica.plan.io/issues/1740 -->
    
    <xsl:template match="/">
        <out>
            <xsl:variable name="n" as="xs:integer" select="xs:integer(*)"/>
            <xsl:variable name="x" as="xs:integer*" select="for $i in 1 to $n return 1"/>
            <xsl:value-of select="sum(for $i in 1 to $n return $x[$i][1])"/>
        </out>
    </xsl:template>
</xsl:stylesheet>