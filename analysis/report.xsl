<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">
    <xsl:include href="driver-module.xsl"/>

    <xsl:variable name="input-docs" as="document-node(element(testResults))*"
        select="collection('../results/selection?*.xml')"/>
       
    <xsl:variable name="input-baseline" select="$input-docs[testResults/@baseline='yes'][1]"/>       
        
    <xsl:variable name="baseline" select="if (exists($input-baseline)) then $input-baseline else $input-docs[1]"/>
         
    <xsl:template name="main">
        <html>
            <!--            <xsl:copy-of select="$baseline"/>-->
            <head>
                <link rel="stylesheet" type="text/css" href="reportstyle.css"/>
                <title>XT-Speedo results</title>
            </head>
            <body>
                <xsl:call-template name="body"/>
            </body>
        </html>
        <xsl:for-each select="$input-docs">
            <xsl:result-document href="{testResults/@driver}.html">
                <xsl:call-template name="driver-page">
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="input-doc" select="."/>
                </xsl:call-template>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="body">
        <h1>
            <xsl:value-of select="'Overview of results at', 
                format-dateTime($baseline/testResults/@on, '[H]:[m]:[s] on [D] [MNn] [Y]')"/>
        </h1>
        <table id="overview">
            <thead>
                <th/>
                <th colspan="3"> Times relative to <xsl:value-of select="$baseline/testResults/@driver"/> driver <br/> (smaller values represent faster times) 
                </th>                           
            </thead>
            <thead>
                <th>Driver</th>
                <th width="180px">File to file transform</th>
                <th width="180px">Tree to tree transform</th>
                <th width="180px">Stylesheet compile</th>
            </thead>
            <xsl:for-each select="$input-docs">
                <tr>
                    <td>
                        <a href="{testResults/@driver}.html">
                            <xsl:value-of select="testResults/@driver"/>
                        </a>
                    </td>                    
                    <xsl:variable name="tests" select="testResults/test[@run='success']/@name[. = $baseline/testResults/test[@run='success']/@name]"/>
                    <td>                        
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@transformTimeFileToFile"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeFileToFile"/>
                        <xsl:copy-of select="local:summary($times, $baseline-times)"/>
                    </td>
                    <td>
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                        <xsl:copy-of select="local:summary($times, $baseline-times)"/>
                    </td>
                    <td>
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@compileTime"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@compileTime"/>
                        <xsl:copy-of select="local:summary($times, $baseline-times)"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>


    <xsl:function name="local:summary">
        <xsl:param name="times" as="xs:double*"/>
        <xsl:param name="baseline-times" as="xs:double*"/>
        <xsl:value-of select="format-number(sum($times) div sum($baseline-times), '0.0##')"/>
        <p class="minmax">
            <xsl:variable name="ratios" as="xs:double*"
                select="for $i in 1 to count($times) return $times[$i] div $baseline-times[$i]"/>
            <xsl:value-of select="'min =', format-number(min($ratios), '0.0##')"/>
            <xsl:value-of select="', max =', format-number(max($ratios), '0.0##')"/>
            <!--<xsl:for-each select="1 to count($times)">
                <xsl:value-of select="'-\-', format-number($ratios[current()], '0.0##')"/>
            </xsl:for-each>-->            
        </p>
    </xsl:function>

</xsl:stylesheet>
