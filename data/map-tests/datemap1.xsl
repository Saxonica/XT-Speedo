<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <out>
            <xsl:variable name="date" as="map(xs:date, xs:string)">
                <xsl:map>
                    <xsl:map-entry key="xs:date('2014-01-01')" select="'Wed'"/>                            
                </xsl:map>
            </xsl:variable>
            
            <xsl:iterate select="0 to 51">
                <xsl:param name="date2" select="$date" as="map(xs:date, xs:string)"/>                                 
                <xsl:next-iteration>
                    <xsl:with-param name="date2" select="map:new(($date2, 
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P1D') := 'Thu'},
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P2D') := 'Fri'},
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P3D') := 'Sat'},
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P4D') := 'Sun'},
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P5D') := 'Mon'},
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P6D') := 'Tue'},
                        map{xs:date('2014-01-01') + .*xs:dayTimeDuration('P7D') + xs:dayTimeDuration('P7D') := 'Wed'}))"/>
                </xsl:next-iteration>
                <xsl:on-completion>
                    <xsl:for-each select="map:keys($date2)">
                        <result date="{.}" day="{$date2(.)}"/>
                    </xsl:for-each>
                    <final keys="{count(map:keys($date2))}"/>
                    <last-day-of-year day="{$date2(xs:date('2014-12-31'))}"/>
                </xsl:on-completion>
            </xsl:iterate>
                   
        </out>
    </xsl:template>
    
</xsl:stylesheet>