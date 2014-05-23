<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template name="main">
        <out>
            <xsl:if test="matches(unparsed-text('xmarksmall.txt'), 
                '.*a.*b.*c.*d.*e.*f.*g.*h.*i.*j.*k.*l.*m.*n.*o.*p.*q.*r.*s.*t.*u.*v.*w.*.x.*y.*z', 's')">                     
                <xsl:text>match</xsl:text>   
            </xsl:if>                             
        </out>
    </xsl:template>
</xsl:stylesheet>