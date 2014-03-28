<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- Q20. Group customers by their
         income and output the cardinality of each group. -->
    
    <!--    
        <result>
        <preferred>
         {count ((:document("auction.xml"):)/site/people/person/profile[@income >= 100000])}
        </preferred>
        <standard>
         {count ((:document("auction.xml"):)/site/people/person/profile[@income < 100000
                                                             and @income >= 30000])}
        </standard>
        <challenge> 
         {count ((:document("auction.xml"):)/site/people/person/profile[@income < 30000])}
        </challenge>
        <na>
         {count (for    $p in (:document("auction.xml"):)/site/people/person
                where  empty($p/profile/@income)
                return $p)}
        </na>
        </result>
    -->
    
    <xsl:output encoding="utf-8" method="xml" indent="yes"/>
       
    <xsl:template match="site">        
        <result>
            <preferred>
                <xsl:value-of select="count(people/person/profile[@income &gt;= 100000])"/>
            </preferred>
            <standard>
                <xsl:value-of select="count(people/person/profile[@income &lt; 100000 and @income &gt;= 30000])"/>
            </standard>
            <challenge>
                <xsl:value-of select="count(people/person/profile[@income &lt; 30000])"/>
            </challenge>
            <na>
                <xsl:value-of select="count(people/person[not(profile/@income)])"/>
            </na>
        </result>        
    </xsl:template>    
    
</xsl:stylesheet>