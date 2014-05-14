<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local"
    xmlns:xlink="http://www.w3.org/1999/xlink">

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
                    <xsl:value-of
                        select="'Results for', testResults/@driver, 'at', 
                        format-dateTime(testResults/@on, '[H]:[m]:[s] on [D] [MNn] [Y]')"
                    />
                </h1>
                <h3> Comparing performance to baseline driver <xsl:value-of
                        select="$baseline/testResults/@driver"/>
                </h3>
                <p>
                    <a href="report.html">Back to overview</a>
                </p>

                <xsl:variable name="tests"
                    select="testResults/test[@run='success']/@name[. = $baseline/testResults/test[@run='success']/@name]"/>

                <xsl:if test="not($baseline is .)">
                    
                    <!--File to file transform-->
                    <xsl:variable name="times" as="xs:double*"
                        select="for $t in $tests return testResults/test[@name = $t]/@transformTimeFileToFile"/>
                    <xsl:variable name="baseline-times" as="xs:double*"
                        select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeFileToFile"/>
                    <h4> Chart: <xsl:value-of select="testResults/@driver"/> file to file transform
                        speeds relative to <xsl:value-of select="$baseline/testResults/@driver"/>
                    </h4>                    
                    <xsl:copy-of select="local:chart($times, $baseline-times, $tests)"/>                    

                    <!--Tree to tree transform-->
                    <xsl:variable name="times" as="xs:double*"
                        select="for $t in $tests return testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                    <xsl:variable name="baseline-times" as="xs:double*"
                        select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeTreeToTree"/>                    
                    <xsl:choose>
                        <xsl:when test="not(every $t in $times satisfies string($t) eq 'NaN')">
                            <h4> Chart: <xsl:value-of select="testResults/@driver"/> tree to tree transform
                                speeds relative to <xsl:value-of select="$baseline/testResults/@driver"/>
                            </h4>
                            <xsl:copy-of select="local:chart($times, $baseline-times, $tests)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <h4> No <xsl:value-of select="testResults/@driver"/> tree to tree transform times are available.
                            </h4>                            
                        </xsl:otherwise>
                    </xsl:choose>             

                    <!--Stylesheet compile-->
                    <xsl:variable name="times" as="xs:double*"
                        select="for $t in $tests return testResults/test[@name = $t]/@compileTime"/>
                    <xsl:variable name="baseline-times" as="xs:double*"
                        select="for $t in $tests return $baseline/testResults/test[@name = $t]/@compileTime"/>
                    <h4> Chart: <xsl:value-of select="testResults/@driver"/> stylesheet compile
                        speeds relative to <xsl:value-of select="$baseline/testResults/@driver"/>
                    </h4>
                    <xsl:copy-of select="local:chart($times, $baseline-times, $tests)"/>

                    <br/>
                    <br/>
                </xsl:if>

                <table id="driver">
                    <thead>
                        <th/>
                        <th colspan="6"> Times relative to <xsl:value-of
                                select="$baseline/testResults/@driver"/> driver <br/> (smaller
                            values represent faster times) <p class="actual"> Actual times (in
                                milliseconds)</p>
                        </th>
                    </thead>
                    <thead>
                        <th>Test</th>
                        <th width="120px" colspan="2">File to file transform</th>
                        <th width="120px" colspan="2">Tree to tree transform</th>
                        <th width="120px" colspan="2">Stylesheet compile</th>
                    </thead>
                    <xsl:for-each select="./testResults/test">
                        <xsl:variable name="test-name" as="xs:string" select="./@name"/>
                        <tr>
                            <td>
                                <xsl:value-of select="$test-name"/>
                            </td>
                            <xsl:choose>
                                <xsl:when test="./@run = 'success'">
                                    <td width="60px">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeFileToFile div $baseline/testResults/test[@name = $test-name]/@transformTimeFileToFile, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px" class="actual">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeFileToFile, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeTreeToTree div $baseline/testResults/test[@name = $test-name]/@transformTimeTreeToTree, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px" class="actual">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeTreeToTree, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px">
                                        <xsl:value-of
                                            select="format-number(./@compileTime div $baseline/testResults/test[@name = $test-name]/@compileTime, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px" class="actual">
                                        <xsl:value-of
                                            select="format-number(./@compileTime, '0.0##')"/>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td colspan="6" bgcolor="red">
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

    
    <xsl:function name="local:percentile" as="xs:double">
        <xsl:param name="input" as="xs:double*"/>
        <xsl:param name="percent" as="xs:double"/>
        <xsl:variable name="sorted-input" as="xs:double*">
            <xsl:perform-sort select="$input[. ne 0 and string(.) ne 'NaN']">
                <xsl:sort select="."/>
            </xsl:perform-sort>
        </xsl:variable>
        <xsl:sequence
            select="($sorted-input[round(count($sorted-input)*$percent div 100)], $sorted-input[1], 1.1)[1]"
        />
    </xsl:function>


    <xsl:function name="local:chart">
        <xsl:param name="times" as="xs:double*"/>
        <xsl:param name="baseline-times" as="xs:double*"/>
        <xsl:param name="tests" as="xs:string*"/>
        <xsl:variable name="ratios" as="xs:double*"
            select="for $i in 1 to count($times) return $times[$i] div $baseline-times[$i]"/>
        <xsl:variable name="max-95" select="local:percentile($ratios,95)"/>
        <xsl:variable name="min-5" select="local:percentile($ratios,5)"/>
        <xsl:variable name="range-min5-max95" 
            select="(if ($max-95 > 1) then (($max-95 - 1)) else (0)) + (if ($min-5 > 1) then (0) else (((1 div $min-5) - 1)))"/>
        <xsl:variable name="range-factor"
            select="(if ($max-95 > 1) then (($max-95 - 1) + $range-min5-max95*0.1) else (0)) + (if ($min-5 > 1) then (0) else (((1 div $min-5) - 1) + $range-min5-max95*0.1))"/>
        <xsl:variable name="baseline-axis"
            select="if ($max-95 > 1) then (($max-95 - 1) + $range-min5-max95*0.1) else (0)"/>
        <xsl:variable name="scale-factor" select="120 div $range-factor"/> 
        <!--<p>
            number of tests: <xsl:value-of select="count($ratios)"/>, 
            max-95: <xsl:value-of select="format-number($max-95, '0.0#')"/>, 
            min-5: <xsl:value-of select="format-number($min-5, '0.0#')"/>, 
            range min5 to max95: <xsl:value-of select="format-number($range-min5-max95, '0.0#')"/>, 
            range factor: <xsl:value-of select="format-number($range-factor, '0.0#')"/>, 
            baseline axis to top of range: <xsl:value-of select="format-number($baseline-axis, '0.0#')"/>
        </p>-->
                
        <svg width="{count($ratios)*10 + 160}" height="160" viewBox="0 0 {count($ratios)*10 + 150} 160" >
            <!--Boundary and borders-->
            <!--<line x1="0" y1="1" x2="{count($ratios)*10 + 150}" y2="1" style="stroke:blue; stroke-width:1"/>
            <line x1="0" y1="20" x2="{count($ratios)*10 + 150}" y2="20" style="stroke:blue; stroke-width:1"/>
            <line x1="0" y1="140" x2="{count($ratios)*10 + 150}" y2="140" style="stroke:blue; stroke-width:1"/>
            <line x1="0" y1="159" x2="{count($ratios)*10 + 150}" y2="159" style="stroke:blue; stroke-width:1"/>-->
            <!--Baseline-->
            <line x1="30" y1="{$baseline-axis*$scale-factor + 20}" x2="{count($ratios)*10 + 45}"
                y2="{$baseline-axis*$scale-factor + 20}" style="stroke:black; stroke-width:1"/>
            <text x="0" y="{$baseline-axis*$scale-factor + 24}" font-size="12px">1</text>
            <!--Gridlines-->
            <xsl:for-each select="1 to 4">
                <xsl:variable name="gridline"
                    select="if ($range-factor ge 4) then (current()*round($range-factor div 4)) 
                    else (if ($range-factor le 1) then (current() div 4) 
                    else (if ($range-factor le 2) then (current() div 2) else (current())))"/>
                <xsl:if test="$gridline le $baseline-axis">                    
                    <line x1="30" y1="{($baseline-axis - $gridline)*$scale-factor + 20}"
                        x2="{count($ratios)*10 + 45}"
                        y2="{($baseline-axis - $gridline)*$scale-factor + 20}"
                        style="stroke:grey; stroke-width:1"/>
                    <text x="0" y="{($baseline-axis - $gridline)*$scale-factor + 24}" font-size="12px">
                        <xsl:value-of select="$gridline + 1"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="1 to 4">
                <xsl:variable name="line"
                    select="if ($range-factor ge 4) then (current()*round($range-factor div 4)) 
                    else (if ($range-factor le 1) then (current() div 4) 
                    else (if ($range-factor le 2) then (current() div 2) else (current())))"/>
                <xsl:if test="$line le $range-factor - $baseline-axis">                    
                    <line x1="30" y1="{($baseline-axis + $line)*$scale-factor + 20}"
                        x2="{count($ratios)*10 + 45}"
                        y2="{($baseline-axis + $line)*$scale-factor + 20}"
                        style="stroke:grey; stroke-width:1"/>
                    <text x="0" y="{($baseline-axis + $line)*$scale-factor + 24}" font-size="12px">
                        <xsl:value-of select="format-number(1 div ($line + 1), '.0##')"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
            <!--Bars-->
            <xsl:for-each select="1 to count($ratios)">
                <xsl:if test="string($ratios[current()]) ne 'NaN'">
                    <xsl:choose>                        
                        <xsl:when
                            test="(($ratios[current()] ge 1) and ($ratios[current()] - 1 le $baseline-axis)) 
                            or (($ratios[current()] le 1) and ($ratios[current()] ne 0) and ((1 div $ratios[current()]) - 1 le $range-factor - $baseline-axis))">
                            <rect x="{current()*10 + 30}"
                                y="{if ($ratios[current()] > 1) then (($baseline-axis - ($ratios[current()] - 1))*$scale-factor + 20) else ($baseline-axis*$scale-factor + 20)}"
                                width="5"
                                height="{if ($ratios[current()] > 1) then (($ratios[current()] - 1)*$scale-factor) else (((1 div $ratios[current()]) - 1)*$scale-factor)}"
                                style="fill:#c1cede; stroke-width:1; stroke:#3D5B96"
                                title="{$tests[current()]}: relative time = {format-number($ratios[current()], '0.0##')}"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <rect x="{current()*10 + 30}"
                                y="{if ($ratios[current()] > 1) then (20) else ($baseline-axis*$scale-factor + 20)}"
                                width="5"
                                height="{if ($ratios[current()] > 1) then ($baseline-axis*$scale-factor) else (($range-factor - $baseline-axis)*$scale-factor)}"
                                style="fill:#3D5B96; stroke-width:1; stroke:#3D5B96"
                                title="{$tests[current()]}: relative time = {format-number($ratios[current()], '0.0##')}"
                            />
                            <xsl:choose>
                                <xsl:when test="$ratios[current()] > 1">
                                    <polygon points="{current()*10 + 29},{20} {current()*10 + 32.5},{17} {current()*10 + 36},{20}"
                                        style="fill:#3D5B96; stroke-width:1; stroke:#3D5B96"
                                        title="{$tests[current()]}: relative time = {format-number($ratios[current()], '0.0##')}"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <polygon points="{current()*10 + 29},{$range-factor*$scale-factor + 20} {current()*10 + 32.5},{$range-factor*$scale-factor + 23} {current()*10 + 36},{$range-factor*$scale-factor + 20}"
                                        style="fill:#3D5B96; stroke-width:1; stroke:#3D5B96"
                                        title="{$tests[current()]}: relative time = {format-number($ratios[current()], '0.0##')}"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
            <!--Labels-->
            <xsl:if test="$baseline-axis + 0.3*$range-factor le $range-factor">
                <text x="{count($ratios)*10 + 60 + 30}"
                    y="{$baseline-axis*$scale-factor + 24 + 30}" font-size="12px"
                    >Faster</text>
                <line x1="{count($ratios)*10 + 60 + 20}" 
                    y1="{$baseline-axis*$scale-factor + 20 + 15}"
                    x2="{count($ratios)*10 + 60 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 + 50}"
                    style="stroke:black; stroke-width:1"/>
                <line x1="{count($ratios)*10 + 60 + 20}" 
                    y1="{$baseline-axis*$scale-factor + 20 + 50}"
                    x2="{count($ratios)*10 + 60 - 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 + 50 - 8}"
                    style="stroke:black; stroke-width:1"/>         
                <line x1="{count($ratios)*10 + 60 + 20}" 
                    y1="{$baseline-axis*$scale-factor + 20 + 50}"
                    x2="{count($ratios)*10 + 60 + 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 + 50 - 8}"
                    style="stroke:black; stroke-width:1"/> 
            </xsl:if>
            <xsl:if test="$baseline-axis - 0.3*$range-factor ge 0">
                <text x="{count($ratios)*10 + 60 + 30}"
                    y="{$baseline-axis*$scale-factor + 24 - 30}" font-size="12px"
                    >Slower</text>
                <line x1="{count($ratios)*10 + 60 + 20}" 
                    y1="{$baseline-axis*$scale-factor + 20 - 15}"
                    x2="{count($ratios)*10 + 60 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 - 50}"
                    style="stroke:black; stroke-width:1"/>
                <line x1="{count($ratios)*10 + 60 + 20}" 
                    y1="{$baseline-axis*$scale-factor + 20 - 50}"
                    x2="{count($ratios)*10 + 60 - 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 - 50 + 8}"
                    style="stroke:black; stroke-width:1"/>         
                <line x1="{count($ratios)*10 + 60 + 20}" 
                    y1="{$baseline-axis*$scale-factor + 20 - 50}"
                    x2="{count($ratios)*10 + 60 + 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 - 50 + 8}"
                    style="stroke:black; stroke-width:1"/> 
            </xsl:if> 
            <text x="{count($ratios)*10 + 60}" y="{$baseline-axis*$scale-factor + 24}"
                font-size="12px">Baseline speed</text>
        </svg>
    </xsl:function>    


</xsl:stylesheet>
