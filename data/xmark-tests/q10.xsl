<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <!-- Q10. List all persons according to their interest;
         use French markup in the result. -->
    
    <!--    
        for $i in distinct-values(
        /site/people/person/profile/interest/@category)
        let $p := for    $t in /site/people/person
        where  $t/profile/interest/@category = $i
        return <personne>
        <statistiques>
        <sexe>{ $t/profile/gender }</sexe>
        <age>{ $t/profile/age }</age>
        <education>{ $t/profile/education}</education>
        <revenu>{ $t/profile/@income } </revenu>
        </statistiques>
        <coordonnees>
        <nom>{ $t/name }</nom>,
        <rue>{ $t/address/street }</rue>
        <ville>{ $t/address/city }</ville>
        <pays>{ $t/address/country }</pays>
        <reseau>
        <courrier>{ $t/emailaddress }</courrier>
        <pagePerso>{ $t/homepage }</pagePerso>
        </reseau>
        </coordonnees>
        <cartePaiement>{ $t/creditcard }</cartePaiement>    
        </personne>
        return <categorie>
        <id>{ $i }</id>
        { $p }
        </categorie>
    -->
    
    <xsl:output encoding="utf-8"/>       
    
    <xsl:template match="/"> 
        <out>
            <xsl:apply-templates/>           
        </out>
    </xsl:template> 
    
    <xsl:template match="site">        
        <xsl:for-each-group select="people/person" group-by="profile/interest/@category">
            <categorie>
                <id>
                    <xsl:value-of select="current-grouping-key()"/>
                </id>
                <xsl:for-each select="current-group()">
                    <personne>
                        <statistiques>
                            <sexe><xsl:value-of select="./profile/gender"/></sexe>
                            <age><xsl:value-of select="./profile/age"/></age>
                            <education><xsl:value-of select="./profile/education"/></education>
                            <revenu><xsl:value-of select="./profile/@income"/></revenu>
                        </statistiques>
                        <coordonnees>
                            <nom><xsl:value-of select="./name"/></nom>,
                            <rue><xsl:value-of select="./address/street"/></rue>
                            <ville><xsl:value-of select="./address/city"/></ville>
                            <pays><xsl:value-of select="./address/country"/></pays>
                            <reseau>
                                <courrier><xsl:value-of select="./emailaddress"/></courrier>
                                <pagePerso><xsl:value-of select="./homepage"/></pagePerso>
                            </reseau>
                        </coordonnees>
                        <cartePaiement><xsl:value-of select="./creditcard"/></cartePaiement>    
                    </personne>
                </xsl:for-each>
            </categorie>   
        </xsl:for-each-group>
    </xsl:template>
    
</xsl:stylesheet>