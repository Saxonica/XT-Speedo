<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
       
    <!-- Q1.Return the name of the person with ID `person0'
    registered in North America. -->
    
    <!--
    for    $b in /site/people/person[@id="person0"]
    return $b/name
    -->
    
    <xsl:output encoding="utf-8"/>
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">
        <xsl:for-each select="people/person[@id='person0']">
            <xsl:copy-of select="name"/>                                    
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>