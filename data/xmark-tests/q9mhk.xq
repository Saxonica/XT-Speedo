(: Q9. List the names of persons and the names of the items they bought
--     in Europe.  (joins person, closed\_auction, item) :)

declare function local:f($root as document-node(element(site)), $t as element(closed_auction)) as element(item)*{
   $root/site/regions/europe/item[$t/itemref/@item = ./@id]
};

<xsl:function...>
 <xsl:param...>
 <xsl:param...>
 <xsl:sequence select...>
 </xsl:function>

declare function local:g($root as document-node(element(site)), $p as element(person) as element(item)* {
for $t in $root/site/closed_auctions/closed_auction[$p/@id = ./buyer/@person]
             return <item> {local:f($root, $t)/name} </item>
};

<xsl:function...>
 <xsl:param...>
 <xsl:param...>
 <xsl:for-each select="$root/site/closed_auctions/closed_auction[$p/@id = ./buyer/@person]">
   <item>
   <xsl:sequence select="local:f($root, $t)/name"/>
   </item>


for $p in /site/people/person
let $a := local:g(/, $p)
return <person name="{$p/name}">{ $a }</person>

