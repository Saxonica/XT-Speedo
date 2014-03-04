<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2013 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                    xmlns:oxygen="http://www.oxygenxml.com/functions"
                    exclude-result-prefixes="oxygen"
                    version="2.0">
    
    <xsl:import href="../../functions.xsl"/>
    
    <!-- URL of folder with indexterm files. -->
    <xsl:param name="TEMPFOLDER"/>
    
    <!-- List of files with indexterms. -->
    <xsl:param name="FILELIST"/>
    
    <xsl:template match="/">
        <xsl:variable name="terms">
            <xsl:analyze-string select="unparsed-text(oxygen:makeURL($FILELIST))" regex="\n">
                <xsl:non-matching-substring>
                    <xsl:variable name="INDEXFILE_URL" select="oxygen:makeURL(concat($TEMPFOLDER, '/', ., '.indexterms'))"/>
                    <xsl:message>Collecting indexterms from <xsl:value-of select="$INDEXFILE_URL"/></xsl:message>
                    <xsl:copy-of select="document($INDEXFILE_URL)/*/*"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <index xmlns="http://www.oxygenxml.com/ns/webhelp/index">
            <xsl:call-template name="mergeIndexterms">
                <xsl:with-param name="terms" select="$terms/*"/>
            </xsl:call-template>
        </index>
    </xsl:template>

    <xsl:template name="mergeIndexterms">
        <xsl:param name="terms"/>
        <xsl:for-each-group select="$terms" group-by="upper-case(@name)">
            <xsl:sort select="current-grouping-key()" order="ascending"/>
            <term name="{normalize-space(@name)}" xmlns="http://www.oxygenxml.com/ns/webhelp/index">
                <xsl:for-each select="current-group()/@target">
                    <xsl:sort select="." order="ascending"/>
                    <target><xsl:value-of select="."/></target>
                </xsl:for-each>
                <xsl:call-template name="mergeIndexterms">
                    <xsl:with-param name="terms" select="current-group()/*"/>
                </xsl:call-template>
          </term>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>