<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q6. How many items are listed on all continents? -->
    
    <!--    
        for    $b in (:document("auction.xml"):)/site/regions/*
        return count ($b//item)
    -->
         
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="regions/*">
            <itemCount>
                <xsl:value-of select="count(.//item)"/>  
            </itemCount>
        </xsl:for-each>     
    </xsl:template>
    
</xsl:stylesheet>