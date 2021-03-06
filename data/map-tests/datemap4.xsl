<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template name="formatDate">
        <xsl:param name="dateTime"/>
        <xsl:variable name="month" select="substring-before($dateTime, '/')"/>
        <xsl:variable name="day" select="substring-before(substring-after($dateTime, '/'), '/')"/>
        <xsl:variable name="year" select="substring-after(substring-after($dateTime, '/'), '/')"/>
        <xsl:sequence select="xs:date(concat($year, '-', $month, '-', $day))"/>
    </xsl:template>
    
    <xsl:template match="/">
        <out>
            <xsl:variable name="dates" as="map(xs:date, xs:string)">
                <xsl:map>                
                    <xsl:for-each select="//item//date">
                        <xsl:variable name="itemDate">
                            <xsl:call-template name="formatDate">
                                <xsl:with-param name="dateTime" select="."/>                            
                            </xsl:call-template>
                        </xsl:variable>                  
                        <xsl:map-entry key="xs:date($itemDate)" select="xs:string(ancestor::item[last()]/@id)"/>                    
                    </xsl:for-each>
                    <xsl:for-each select="//closed_auction//date">
                        <xsl:variable name="closedAuctionDate">
                            <xsl:call-template name="formatDate">
                                <xsl:with-param name="dateTime" select="."/>                            
                            </xsl:call-template>
                        </xsl:variable>                  
                        <xsl:map-entry key="xs:date($closedAuctionDate)" select="xs:string(preceding-sibling::itemref/@item)"/>                    
                    </xsl:for-each>
                </xsl:map>
            </xsl:variable>                     
            
            <year2000 size="{count(map:keys($dates)[year-from-date(.) = 2000])}"/>
            
            <xsl:iterate select="map:keys($dates)[year-from-date(.) = 2000]">
                <xsl:param name="dates2" select="$dates" as="map(xs:date, xs:string)"/>   
                <xsl:next-iteration>
                    <xsl:with-param name="dates2" select="map:new(($dates2, map{. + xs:dayTimeDuration('P1D') := concat($dates2(.), '2000')}))"/>                    
                </xsl:next-iteration>  
                <xsl:on-completion>
                    <map-size initial="{map:size($dates)}" final="{map:size($dates2)}"/>                    
                </xsl:on-completion>
            </xsl:iterate>
            
        </out>
    </xsl:template>
    
</xsl:stylesheet>
