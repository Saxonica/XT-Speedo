<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xsl xhtml e f">
    
    <xsl:import href="filterNodes.xsl"/>
    <xsl:import href="wrapGlobalText.xsl"/>
    <xsl:import href="nestedSections.xsl"/>
    <xsl:import href="nestedLists.xsl"/>
    <xsl:import href="filterAndSetNamespace.xsl"/>
    <xsl:include href="xhtml2db5.xsl"/>
    
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
    
    <xsl:param name="folderOfPasteTargetXml"/>
    
    <!-- 
      The context where the generated fragment will be inserted. 
      This parameter lists the local names, starting with the root up to the context element. 
     -->   
    <xsl:param name="context.path.names" select="''"/>
    <xsl:param name="context.path.names.sequence" 
                        select="tokenize($context.path.names, $context.item.separator)"/>
    
    <!-- 
      The context where the generated fragment will be inserted. 
      This parameter lists the namespaces, starting with the root up to the context element. 
     -->   
    <xsl:param name="context.path.uris" select="''"/>
    <xsl:param name="context.path.uris.sequence" 
                        select="tokenize($context.path.uris, $context.item.separator)"/>
    
    <!-- 
      The item separator.
    -->
    <xsl:param name="context.item.separator" select="','"/>
    
    <!-- Helper variables. -->
    <xsl:variable name="context.path.last.name" select="tokenize($context.path.names, $context.item.separator)[last()]"/>
    <xsl:variable name="context.path.last.uri" select="tokenize($context.path.uris, $context.item.separator)[last()]"/>

    <xsl:template match="/">
        <!--
        <xsl:message>======== folderOfPasteTargetXml: <xsl:value-of select="$folderOfPasteTargetXml"/></xsl:message>
        <xsl:message>======== context.path.names: <xsl:value-of select="$context.path.names"/></xsl:message>
        <xsl:message>======== context.path.uris: <xsl:value-of select="$context.path.uris"/></xsl:message>
        <xsl:message>======== context.item.separator: <xsl:value-of select="$context.item.separator"/></xsl:message>
        -->

        <!-- Transform MS Word titles to H1 elements. -->
        <xsl:variable name="processedFilterNodes">
            <xsl:apply-templates mode="filterNodes"/>
        </xsl:variable>
        
        <!--<xsl:message>111111111  <xsl:copy-of select="$processedFilterNodes"/></xsl:message>
        <xsl:result-document href="output-filterNodes.xml">
            <xsl:copy-of select="$processedFilterNodes"/>
        </xsl:result-document>-->
        
        
        <!-- Wrap all text from global level (xhtml:body) in xhtml:p elements. -->
        <xsl:variable name="processedWrapGlobalText">
            <xsl:apply-templates select="$processedFilterNodes" mode="wrapGlobalText"/>
        </xsl:variable>
        
        <!--<xsl:message>222222222  <xsl:copy-of select="$processedWrapGlobalText"/></xsl:message>
        <xsl:result-document href="output-wrapGlobalText.xml">
            <xsl:copy-of select="$processedWrapGlobalText"/>
        </xsl:result-document>-->
        
        
        <!-- Transform list of header and para elements to nested sections. -->
        <xsl:variable name="processedSections">
            <xsl:apply-templates select="$processedWrapGlobalText" mode="nestedSections"/>
        </xsl:variable>
        
       <!-- <xsl:message>333333333  <xsl:copy-of select="$processedSections"/></xsl:message>
        <xsl:result-document href="output-sections.xml">
            <xsl:copy-of select="$processedSections"/>
        </xsl:result-document>-->
        
        
        <!-- Transform list of para elements from MS Word to nested lists.-->
        <xsl:variable name="processedLists">
            <xsl:apply-templates select="$processedSections" mode="nestedLists"/>
        </xsl:variable>
        
        <!--<xsl:message>444444444   <xsl:copy-of select="$processedLists"/></xsl:message>
        <xsl:result-document href="output-lists.xml">
            <xsl:copy-of select="$processedLists"/>
        </xsl:result-document>-->
        

        <xsl:variable name="processedNamespace">
            <xsl:apply-templates select="$processedLists" mode="setNamespace"/>
        </xsl:variable>
        
        
        <!--<xsl:message>555555555
            <xsl:copy-of select="$processedNamespace"/>
        </xsl:message>
        <xsl:result-document href="output-namespace.xml">
            <xsl:copy-of select="$processedNamespace"/>
        </xsl:result-document>-->
        
        
        <!-- Generate content for current Author framework. -->
        <xsl:apply-templates select="$processedNamespace/*"/>
    </xsl:template>
</xsl:stylesheet>