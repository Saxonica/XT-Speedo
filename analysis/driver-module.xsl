<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">

    <xsl:template name="driver-page">
        <xsl:param name="input-doc"/>
        <xsl:param name="baseline"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="reportstyle.css"/>
                <title>XT-Speedo <xsl:value-of select="testResults/@driver"/> results</title>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="'Results for', testResults/@driver, 'at', 
                        format-dateTime(testResults/@on, '[H]:[m]:[s] on [D] [MNn] [Y]')"/>
                </h1>
                <p>
                    <a href="report.html">Back to overview</a>
                </p>    
                <table>
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
                        <th>Test</th>
                        <th width="120px">Transform</th>
                        <th width="120px">Build</th>
                        <th width="120px">Compile</th>
                    </thead>
                    <xsl:for-each select="./testResults/test">
                        <xsl:variable name="test-name" as="xs:string" select="./@name"/>
                        <tr>
                            <td>
                                <xsl:value-of select="$test-name"/>
                            </td>
                            <xsl:choose>
                                <xsl:when test="./@run = 'success'">
                                    <td>
                                        <xsl:value-of 
                                            select="format-number(./@transformTime div $baseline/testResults/test[@name = $test-name]/@transformTime, '0.0##')"/>
                                    </td>
                                    <td>
                                        <xsl:value-of 
                                            select="format-number(./@buildTime div $baseline/testResults/test[@name = $test-name]/@buildTime, '0.0##')"/>
                                    </td>
                                    <td>
                                        <xsl:value-of 
                                            select="format-number(./@compileTime div $baseline/testResults/test[@name = $test-name]/@compileTime, '0.0##')"/>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td colspan="3" bgcolor="red">
                                        <xsl:value-of select="./@run"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:for-each>

                </table>
            </body>
        </html>                   
    </xsl:template>

    
</xsl:stylesheet>