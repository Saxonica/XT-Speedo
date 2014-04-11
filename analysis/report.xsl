<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">
    <xsl:include href="driver-module2.xsl"/>

    <xsl:variable name="input-docs" as="document-node(element(testResults))*"
        select="collection('../results/selection?*.xml')"/>

    <xsl:variable name="computed-baseline">
        <testResults>
            <xsl:attribute name="driver" select="'BaselineDriver'"/>
            <!-- <xsl:attribute name="on" select="$input-docs[1]/testResults/@on"/> -->

            <xsl:for-each select="$input-docs[1]/testResults/test"> <!-- List of tests not necessarily complete. -->
                <test>
                    <xsl:variable name="test-build-time" as="xs:double*"
                        select="$input-docs/testResults/test[@run='success'][@name=current()/@name]/@buildTime"/>
                    <xsl:variable name="baseline-build-time"
                        select="format-number(avg($test-build-time), '#.###')"/>
                    <xsl:variable name="test-compile-time" as="xs:double*"
                        select="$input-docs/testResults/test[@run='success'][@name=current()/@name]/@compileTime"/>
                    <xsl:variable name="baseline-compile-time"
                        select="format-number(avg($test-compile-time), '#.###')"/>
                    <xsl:variable name="test-transform-time" as="xs:double*"
                        select="$input-docs/testResults/test[@run='success'][@name=current()/@name]/@transformTime"/>
                    <xsl:variable name="baseline-transform-time"
                        select="format-number(avg($test-transform-time), '#.###')"/>
                    <xsl:attribute name="name" select="./@name"/>
                    <xsl:attribute name="buildTime" select="$baseline-build-time"/>
                    <xsl:attribute name="compileTime" select="$baseline-compile-time"/>
                    <xsl:attribute name="transformTime" select="$baseline-transform-time"/>
                </test>
            </xsl:for-each>
        </testResults>
    </xsl:variable>
    
    <xsl:variable name="input-baseline" select="$input-docs[testResults/@baseline='yes'][1]"/>       
        
    <xsl:variable name="baseline" select="if (exists($input-baseline)) then $input-baseline else $computed-baseline"/>
         
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
                format-dateTime($input-docs[1]/testResults/@on, '[H]:[m]:[s] on [D] [MNn] [Y]')"/>
        </h1>
        <table id="overview">
            <thead>
                <th/>
                <xsl:choose>
                    <xsl:when test="$baseline/testResults/@driver='BaselineDriver'">
                        <th colspan="3"> Times relative to average times across all drivers <br/> (smaller values represent faster times) 
                        </th>
                    </xsl:when>
                    <xsl:otherwise>
                        <th colspan="3"> Times relative to <xsl:value-of select="$baseline/testResults/@driver"/> driver <br/> (smaller values represent faster times) 
                        </th>
                    </xsl:otherwise>
                </xsl:choose>                
            </thead>
            <thead>
                <th>Driver</th>
                <th width="180px">Transform</th>
                <th width="180px">Build</th>
                <th width="180px">Compile</th>
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
                            select="for $t in $tests return testResults/test[@name = $t]/@transformTime"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTime"/>
                        <xsl:copy-of select="local:summary2($times, $baseline-times)"/>
                    </td>
                    <td>
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@buildTime"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@buildTime"/>
                        <xsl:copy-of select="local:summary2($times, $baseline-times)"/>
                    </td>
                    <td>
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@compileTime"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@compileTime"/>
                        <xsl:copy-of select="local:summary2($times, $baseline-times)"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>


    <xsl:function name="local:summary2">
        <xsl:param name="times" as="xs:double*"/>
        <xsl:param name="baseline-times" as="xs:double*"/>
        <xsl:value-of select="format-number(avg(sum($times) div sum($baseline-times)), '0.0##')"/>
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
