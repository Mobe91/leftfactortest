package com.comp.leftfactortest;

import com.comp.leftfactortest.parser.JPQLSelectExpressionLexer;
import com.comp.leftfactortest.parser.JPQLSelectExpressionParser;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.junit.Test;

public class LeftfactorTest {
    @Test
    public void testLeftFactor(){
        String expression = "CONCAT(CONCAT(buyerParty.name,CASE WHEN LENGTH(COALESCE(CONCAT(COALESCE(CONCAT(NULLIF(CONCAT(CASE WHEN LENGTH(COALESCE(buyerParty.zip,'')) > 0 OR LENGTH(COALESCE(buyerParty.city,'')) > 0 THEN COALESCE(CONCAT(NULLIF(buyerParty.street,''),', '),'') ELSE COALESCE(buyerParty.street,'') END,CASE WHEN LENGTH(COALESCE(buyerParty.city,'')) > 0 THEN COALESCE(CONCAT(NULLIF(buyerParty.zip,''),' '),'') ELSE COALESCE(buyerParty.zip,'') END,COALESCE(buyerParty.city,'')),''),' - '),''),CASE WHEN LENGTH(COALESCE(buyerParty.region.name,'')) > 0 THEN COALESCE(CONCAT(COALESCE(NULLIF(buyerParty.countryEntry.name,''),NULLIF(buyerParty.country,'')),' / '),'') ELSE COALESCE(buyerParty.countryEntry.name,buyerParty.country,'') END,COALESCE(buyerParty.region.name,'')),'')) > 0 THEN ': ' ELSE '' END),COALESCE(CONCAT(COALESCE(CONCAT(NULLIF(CONCAT(CASE WHEN LENGTH(COALESCE(buyerParty.zip,'')) > 0 OR LENGTH(COALESCE(buyerParty.city,'')) > 0 THEN COALESCE(CONCAT(NULLIF(buyerParty.street,''),', '),'') ELSE COALESCE(buyerParty.street,'') END,CASE WHEN LENGTH(COALESCE(buyerParty.city,'')) > 0 THEN COALESCE(CONCAT(NULLIF(buyerParty.zip,''),' '),'') ELSE COALESCE(buyerParty.zip,'') END,COALESCE(buyerParty.city,'')),''),' - '),''),CASE WHEN LENGTH(COALESCE(buyerParty.region.name,'')) > 0 THEN COALESCE(CONCAT(COALESCE(NULLIF(buyerParty.countryEntry.name,''),NULLIF(buyerParty.country,'')),' / '),'') ELSE COALESCE(buyerParty.countryEntry.name,buyerParty.country,'') END,COALESCE(buyerParty.region.name,'')),''))";
        JPQLSelectExpressionLexer l = new JPQLSelectExpressionLexer(new ANTLRInputStream(expression));
        CommonTokenStream tokens = new CommonTokenStream(l);
        JPQLSelectExpressionParser p = new JPQLSelectExpressionParser(tokens, true);
        ParserRuleContext ctx = p.parseSimpleExpression();
    }
}
