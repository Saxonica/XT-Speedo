<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">

    <xsl:variable name="input-docs" as="document-node(element(testResults))*"
        select="collection('../results?*.xml')"/>
    <xsl:variable name="baseline" as="document-node(element(testResults))" select="$input-docs[1]"/>
    <xsl:template name="main">
        <html>
            <head>
                <title>XT-Speedo results</title>
            </head>
            <body>
                <xsl:call-template name="body"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="body">
        <xsl:for-each select="$input-docs except $baseline">
            <h1>
                <xsl:value-of select="'Results for', testResults/@driver, 'at', testResults/@on"/>
            </h1>
            <xsl:variable name="tests" select="testResults/test"/>
            <h2>
                <xsl:value-of
                    select="'Transformation time relative to', $baseline/testResults/@driver"/>
            </h2>
            <xsl:variable name="ratios" as="xs:double*"
                select="for $t in $tests return $t/@transformTime div $baseline/testResults/test [@name = $t/@name]/@transformTime"/>
            <xsl:copy-of select="local:summary($ratios)"/>
            <h2>
                <xsl:value-of
                    select="'Document build time relative to', $baseline/testResults/@driver"/>
            </h2>
            <xsl:variable name="ratios" as="xs:double*"
                select="for $t in $tests return $t/@buildTime div $baseline/testResults/test [@name = $t/@name]/@buildTime"/>
            <xsl:copy-of select="local:summary($ratios)"/>
            <h2>
                <xsl:value-of select="'Compile time relative to', $baseline/testResults/@driver"/>
            </h2>
            <xsl:variable name="ratios" as="xs:double*"
                select="for $t in $tests return $t/@compileTime div $baseline/testResults/test [@name = $t/@name]/@compileTime"/>
            <xsl:copy-of select="local:summary($ratios)"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:function name="local:summary">
        <xsl:param name="ratios" as="xs:double*"/>
        <p>
            <xsl:value-of select="'Average', format-number(avg($ratios), '#.###')"/>
        </p>
        <p>
            <xsl:value-of select="'Minimum', format-number(min($ratios), '#.###')"/>
        </p>
        <p>
            <xsl:value-of select="'Maximum', format-number(max($ratios), '#.###')"/>
        </p>
    </xsl:function>
</xsl:stylesheet>
