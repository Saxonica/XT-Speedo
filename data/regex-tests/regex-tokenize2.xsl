<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
        
    <xsl:template match="site">
        <out>
            <xsl:for-each select="//item[//payment]">
                <xsl:copy-of select="current()/name"/>
                <payment>
                    <xsl:for-each select="tokenize(current()//payment, ',\s*')">
                        <type>
                            <xsl:value-of select="."/>
                        </type>                        
                    </xsl:for-each>
                </payment>                
            </xsl:for-each>
        </out>
    </xsl:template>
</xsl:stylesheet>