parser grammar JPQLSelectExpressionParser;

options {
	tokenVocab = JPQLSelectExpressionLexer;
}

@parser::members {
private boolean allowOuter = false;
private boolean allowCaseWhen = false;
public JPQLSelectExpressionParser(TokenStream input, boolean allowCaseWhen){
       this(input);
       this.allowCaseWhen = allowCaseWhen;
}

}

parseOrderByClause : state_field_path_expression EOF
                   | general_path_element EOF
                   | key_value_expression EOF
                   ;

parsePath : state_field_path_expression EOF
          | general_path_element EOF
          ;

parseSimpleExpression : single_valued_path_expression
                       | scalar_expression
                       | aggregate_expression
                       ;

parseSimpleSubqueryExpression
@init{
      allowOuter = true;
}
    : simple_subquery_expression EOF
    ;

parseScalarExpression
    : scalar_expression;

parseArithmeticExpression
    : arithmetic_expression;

parseStringExpression
    : string_expression;

parseCaseOperandExpression
    : case_operand;

simple_subquery_expression : scalar_expression
                           | aggregate_expression
                           | single_valued_path_expression
                           ;
 
key_value_expression : name=KEY '('collection_valued_path_expression')'
                     | name=VALUE '('collection_valued_path_expression')'
                     ;

 single_valued_path_expression 
     : name=ENTRY '('collection_valued_path_expression')' //# EntryFunction
     | key_value_expression //#KeyValueExpression
     | state_field_path_expression
     | general_path_element
     ;
  
 general_path_element : identifier
                      | array_expression
                      ;
 
 //TODO: allow only in certain clauses??
 array_expression : identifier '[' arithmetic_expression ']'
                  ;
      
 general_subpath : general_path_element('.'general_path_element)*
                 ;

 state_field_path_expression : path
                             | {allowOuter == true}? outer_expression
                             ;

  path : general_subpath'.'general_path_element
      ;
  
 collection_valued_path_expression : general_path_element
                                   | path
                                   ;

 aggregate_expression : funcname=( AVG | MAX | MIN | SUM | COUNT) '('(distinct=DISTINCT)? aggregate_argument ')'  # AggregateExpression
                      | funcname=COUNT '(' Star_operator ')' # CountStar
                      ;
 
 aggregate_argument : general_path_element
                    | path
                    ;

 scalar_expression @leftfactor{state_field_path_expression}
                   : arithmetic_expression
                   | string_expression
                   | enum_expression
                   | datetime_expression
                   | boolean_expression
                   | coalesce_expression
                   | nullif_expression
                   | type_discriminator // entity_type_expression
                   | identifier // entity_type_expression
                   | Input_parameter // entity_type_expression
                   | case_expression
                   ;
 
 outer_expression : Outer_function '(' single_valued_path_expression  ')'
                  ;

 arithmetic_expression : arithmetic_term # ArithmeticExpressionTerm
                       | arithmetic_expression op=( '+' | '-' ) arithmetic_term # ArithmeticExpressionPlusMinus
                       ;

 arithmetic_term : arithmetic_factor # ArithmeticTermFactor
                 | term=arithmetic_term op=( '*' | '/' ) factor=arithmetic_factor # ArithmeticMultDiv
                 ;

 arithmetic_factor : signum=( '+' | '-' )? arithmetic_primary;

 arithmetic_primary : state_field_path_expression # ArithmeticPrimary
                    | general_path_element # ArithmeticPrimary
                    | Numeric_literal # ArithmeticPrimary
                    | '('arithmetic_expression')' # ArithmeticPrimaryParanthesis
                    | Input_parameter # ArithmeticPrimary
                    | LENGTH '('string_expression')' # Functions_returning_numerics_default
                    | LOCATE '('string_expression',' string_expression (',' arithmetic_expression)? ')' # Functions_returning_numerics_default
                    | ABS '('arithmetic_expression')' # Functions_returning_numerics_default
                    | SQRT '('arithmetic_expression')' # Functions_returning_numerics_default
                    | MOD '('arithmetic_expression',' arithmetic_expression')' # Functions_returning_numerics_default
                    | SIZE '('collection_valued_path_expression')' # Functions_returning_numerics_size
                    | INDEX '('collection_valued_path_expression')' # Functions_returning_numerics_default
                    | aggregate_expression # ArithmeticPrimary
                    | case_expression # ArithmeticPrimary
                    | function_invocation # ArithmeticPrimary
                    ;

 string_expression : state_field_path_expression
                   | general_path_element
                   | String_literal
                   | Input_parameter 
                   | CONCAT '('string_expression',' string_expression (',' string_expression)*')' //# StringFunction
                   | SUBSTRING '('string_expression',' arithmetic_expression (',' arithmetic_expression)?')' //# StringFunction
                   | TRIM '('((LEADING | TRAILING | BOTH)? (trim_character)? FROM)? string_expression')' //# TrimFunction
                   | LOWER '('string_expression')' //# StringFunction
                   | UPPER '('string_expression')' //# StringFunction
                   | aggregate_expression 
                   | case_expression 
                   | function_invocation
                   ;

 datetime_expression : state_field_path_expression
                     | general_path_element
                     | Input_parameter 
                     | CURRENT_DATE
                     | CURRENT_TIME
                     | CURRENT_TIMESTAMP
                     | aggregate_expression 
                     | case_expression 
                     | function_invocation 
                     | literal_temporal
                     ;

 boolean_expression : state_field_path_expression 
                    | general_path_element
                    | Boolean_literal 
                    | Input_parameter 
                    | case_expression 
                    | function_invocation
                    ;

 enum_expression : state_field_path_expression 
                 | general_path_element
                 | enum_literal 
                 | Input_parameter 
                 | case_expression 
                 ;
 
 enum_literal : ENUM '(' path ')'
              ;

 entity_expression : state_field_path_expression
                   | identifier // simple_entity_expression
                   | Input_parameter // simple_entity_expression
                   ;

 type_discriminator : TYPE '(' type_discriminator_arg ')';
 
 type_discriminator_arg : Input_parameter 
                        | state_field_path_expression 
                        | general_path_element
                        ;

 function_invocation : FUNCTION '(' String_literal (',' args+=function_arg)*')';

 function_arg : literal
              | state_field_path_expression 
              | Input_parameter 
              | scalar_expression
              ;

 case_expression : coalesce_expression
                 | nullif_expression
                 | {allowCaseWhen == true}? general_case_expression     //for entity view extension only
                 | {allowCaseWhen == true}? simple_case_expression     //for entity view extension only
                 ;

coalesce_expression : COALESCE '('scalar_expression (',' scalar_expression)+')'
                    ;

nullif_expression : NULLIF '('scalar_expression',' scalar_expression')'
                  ;

 literal
     : Boolean_literal
     | enum_literal   
     | Numeric_literal
     | String_literal
     ;

 literal_temporal 
     : Date_literal 
     | Time_literal 
     | Timestamp_literal
     ;

 trim_character : String_literal
                | Input_parameter
                ; 
 /* conditional expression stuff for case when in entity view extension */
 conditional_expression : conditional_term # ConditionalExpression
                        | conditional_expression or=OR conditional_term # ConditionalExpression_or
                        ;

 conditional_term : conditional_factor # ConditionalTerm
                  | conditional_term and=AND conditional_factor # ConditionalTerm_and
                  ;

 conditional_factor : (not=NOT)? conditional_primary
                    ;

 conditional_primary : simple_cond_expression # ConditionalPrimary_simple
                     | '('conditional_expression')' # ConditionalPrimary
                     ;

 simple_cond_expression : comparison_expression |
                            between_expression |
                            like_expression |
                            in_expression |
                            null_comparison_expression |
                            empty_collection_comparison_expression |
                            collection_member_expression |
                        ;

 between_expression : expr=arithmetic_expression (not=NOT)? BETWEEN bound1=arithmetic_expression AND bound2=arithmetic_expression # BetweenArithmetic
                    | expr=string_expression (not=NOT)? BETWEEN bound1=string_expression AND bound2=string_expression # BetweenString
                    | expr=datetime_expression (not=NOT)? BETWEEN bound1=datetime_expression AND bound2=datetime_expression # BetweenDatetime
                    ;

 in_expression : (state_field_path_expression | type_discriminator) (not=NOT)? IN ( '(' inItems+=literal (',' inItems+=literal)* ')' | param=Input_parameter | '(' param=Input_parameter ')' )
               ;

 like_expression : string_expression (not=NOT)? LIKE pattern_value (ESCAPE escape_character)?
                 ;
 
 pattern_value : String_literal
               | Input_parameter
               ;
 
 escape_character : Character_literal
                  | Input_parameter
                  ;

 null_comparison_expression : (single_valued_path_expression | Input_parameter) IS (not=NOT)? NULL
                            ;

 empty_collection_comparison_expression : collection_valued_path_expression Empty_function
                                        ;

 collection_member_expression : entity_or_value_expression (not=NOT)? Member_of_function collection_valued_path_expression
                              ;

 entity_or_value_expression : state_field_path_expression
                            | simple_entity_or_value_expression 
                            | general_path_element
                            ;

 simple_entity_or_value_expression : identifier 
                                   | Input_parameter 
                                   | literal
                                   ;
 
 comparison_expression : left=string_expression comparison_operator right=string_expression # ComparisonExpression_string
                       | left=boolean_expression op=equality_comparison_operator right=boolean_expression # ComparisonExpression_boolean
                       | left=enum_expression op=equality_comparison_operator right=enum_expression # ComparisonExpression_enum
                       | left=datetime_expression comparison_operator right=datetime_expression # ComparisonExpression_datetime
                       | left=entity_expression op=equality_comparison_operator right=entity_expression # ComparisonExpression_entity
                       | left=arithmetic_expression comparison_operator right=arithmetic_expression # ComparisonExpression_arithmetic
                       ;
 
 equality_comparison_operator : '=' # EqPredicate
                              | Not_equal_operator # NeqPredicate
                              ;
 
 comparison_operator : equality_comparison_operator # EqOrNeqPredicate
                     | '>' # GtPredicate
                     | '>=' # GePredicate
                     | '<' # LtPredicate
                     | '<=' # LePredicate
                     ;
 
 general_case_expression : caseTerminal=CASE (when_clause)+ elseTerminal=ELSE scalar_expression endTerminal=END
                         ;

 when_clause : whenTerminal=WHEN conditional_expression thenTerminal=THEN scalar_expression
             ;

 simple_case_expression : caseTerminal=CASE case_operand simple_when_clause (simple_when_clause)* elseTerminal=ELSE scalar_expression endTerminal=END
                        ;

 simple_when_clause : whenTerminal=WHEN scalar_expression thenTerminal=THEN scalar_expression
                    ;
 
 case_operand : state_field_path_expression
              | type_discriminator
              ;

 keyword : KEY
        | VALUE
        | ENTRY
        | AVG
        | SUM
        | MAX
        | MIN
        | COUNT
        | DISTINCT
        | ENUM
        | TYPE
        | LENGTH
        | LOCATE
        | ABS
        | SQRT
        | MOD
        | INDEX
        | CURRENT_DATE
        | CURRENT_TIME
        | CURRENT_TIMESTAMP
        | CONCAT
        | SUBSTRING
        | TRIM
        | LOWER
        | UPPER
        | FROM
        | LEADING
        | TRAILING
        | BOTH
        | FUNCTION
        | COALESCE
        | NULLIF
        | NOT
        | OR
        | AND
        | BETWEEN
        | IN
        | LIKE
        | ESCAPE
        | IS
        | NULL
        | CASE
        | ELSE
        | END
        | WHEN
        | THEN
        | SIZE
        | Empty_function
        | Member_of_function
        | Outer_function
        ;
 
 identifier : Identifier
            | keyword
            ;
             