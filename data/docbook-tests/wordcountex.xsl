<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
<xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <wordcount>
            <xsl:for-each-group group-by="." select="for $w in //text()/tokenize(., '\W+')[.!=''] return lower-case($w)">
            <xsl:sort select="count(current-group())" order="descending"/>
                <word word="{current-grouping-key()}"
                    frequency="{count(current-group())}"/>
            </xsl:for-each-group>
       </wordcount>
    </xsl:template>
</xsl:stylesheet>