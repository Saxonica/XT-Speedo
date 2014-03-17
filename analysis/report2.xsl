<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">

    <xsl:variable name="input-docs" as="document-node(element(testResults))*"
        select="collection('../results?*.xml')"/>

    <xsl:variable name="baseline">
        <testResults>
            <xsl:attribute name="driver" select="'BaselineDriver'"/>
           <!-- <xsl:attribute name="on" select="$input-docs[1]/testResults/@on"/> -->

            <xsl:for-each select="$input-docs[1]/testResults/test">
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


    <xsl:template name="main">
        <html>
<!--            <xsl:copy-of select="$baseline"/>-->
            <head>
                <title>XT-Speedo results</title>
            </head>
            <body>
                <xsl:call-template name="body"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="body">
        <xsl:for-each select="$input-docs">
            <h1>
                <xsl:value-of select="'Results for', testResults/@driver, 'at', testResults/@on"/>
            </h1>
            <xsl:variable name="tests" select="testResults/test[@run='success']"/>
            <h2>
                <xsl:value-of
                    select="'Transformation time relative to', $baseline/testResults/@driver"/>
            </h2>
            <xsl:variable name="times" as="xs:double*"
                select="testResults/test[@run='success']/@transformTime"/>
            <xsl:variable name="baseline-times" as="xs:double*"
                select="for $t in $tests return $baseline/testResults/test[@name = $t/@name]/@transformTime"/>
            <xsl:copy-of select="local:summary($times, $baseline-times)"/>
            <h2>
                <xsl:value-of
                    select="'Document build time relative to', $baseline/testResults/@driver"/>
            </h2>
            <xsl:variable name="times" as="xs:double*"
                select="testResults/test[@run='success']/@buildTime"/>
            <xsl:variable name="baseline-times" as="xs:double*"
                select="for $t in $tests return $baseline/testResults/test[@name = $t/@name]/@buildTime"/>
            <xsl:copy-of select="local:summary($times, $baseline-times)"/>
            <h2>
                <xsl:value-of select="'Compile time relative to', $baseline/testResults/@driver"/>
            </h2>
            <xsl:variable name="times" as="xs:double*"
                select="testResults/test[@run='success']/@compileTime"/>
            <xsl:variable name="baseline-times" as="xs:double*"
                select="for $t in $tests return $baseline/testResults/test[@name = $t/@name]/@compileTime"/>
            <xsl:copy-of select="local:summary($times, $baseline-times)"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:function name="local:summary">
        <xsl:param name="times" as="xs:double*"/>
        <xsl:param name="baseline-times" as="xs:double*"/>
        <p>
            <xsl:value-of select="'Average', format-number(avg(sum($times) div sum($baseline-times)), '#.###')"/>
        </p>
        <xsl:variable name="ratios" as="xs:double*"
            select="for $i in 1 to count($times) return $times[$i] div $baseline-times[$i]"/>
        <p>
            <xsl:value-of select="'Minimum', format-number(min($ratios), '#.###')"/>
        </p>
        <p>
            <xsl:value-of select="'Maximum', format-number(max($ratios), '#.###')"/>
        </p>
    </xsl:function>
</xsl:stylesheet>
