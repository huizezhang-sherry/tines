# extract_schema generates valid YAML schema

    Code
      cat(readLines(output_file), sep = "\n")
    Output
      meta:
        type: schema
      nodes:
      - id: operationalize_age
        fork: how to operationalize the age of participants
        type: step
        path: calculate age by subtracting birth year from the fixed year 2012
        justification: Not specified in the text.
        inputs: [birthday]
        outputs: [calculated_age]
        confidence: LOW
        clarification_question: The text mentions subtracting 'birth year', but the dataset summary includes 'birthday'. Should the year be extracted from the 'birthday' column, or is there a different column representing birth year that should be used?
      - id: operationalize_skin_tone
        fork: how to represent the skin tone measure for analysis
        type: step
        path: use the skin tone rating directly as a 1-5 scale
        justification: Not specified in the text.
        inputs: [skin_tone, rater1, rater2]
        outputs: [skin_tone_final]
        confidence: LOW
        clarification_question: The text mentions a single 'Skin tone' rating, but the dataset lists 'skin_tone', 'rater1', and 'rater2'. Which column(s) should be used as the input for the skin tone measure? If 'rater1' and 'rater2' are the inputs, how should they be combined?
      edges:
      - from: operationalize_age
        to: operationalize_skin_tone
        type: sequential

---

    Code
      yaml_parsed
    Output
      $meta
      $meta$type
      [1] "schema"
      
      
      $nodes
      $nodes[[1]]
      $nodes[[1]]$id
      [1] "operationalize_age"
      
      $nodes[[1]]$fork
      [1] "how to operationalize the age of participants"
      
      $nodes[[1]]$type
      [1] "step"
      
      $nodes[[1]]$path
      [1] "calculate age by subtracting birth year from the fixed year 2012"
      
      $nodes[[1]]$justification
      [1] "Not specified in the text."
      
      $nodes[[1]]$inputs
      [1] "birthday"
      
      $nodes[[1]]$outputs
      [1] "calculated_age"
      
      $nodes[[1]]$confidence
      [1] "LOW"
      
      $nodes[[1]]$clarification_question
      [1] "The text mentions subtracting 'birth year', but the dataset summary includes 'birthday'. Should the year be extracted from the 'birthday' column, or is there a different column representing birth year that should be used?"
      
      
      $nodes[[2]]
      $nodes[[2]]$id
      [1] "operationalize_skin_tone"
      
      $nodes[[2]]$fork
      [1] "how to represent the skin tone measure for analysis"
      
      $nodes[[2]]$type
      [1] "step"
      
      $nodes[[2]]$path
      [1] "use the skin tone rating directly as a 1-5 scale"
      
      $nodes[[2]]$justification
      [1] "Not specified in the text."
      
      $nodes[[2]]$inputs
      [1] "skin_tone" "rater1"    "rater2"   
      
      $nodes[[2]]$outputs
      [1] "skin_tone_final"
      
      $nodes[[2]]$confidence
      [1] "LOW"
      
      $nodes[[2]]$clarification_question
      [1] "The text mentions a single 'Skin tone' rating, but the dataset lists 'skin_tone', 'rater1', and 'rater2'. Which column(s) should be used as the input for the skin tone measure? If 'rater1' and 'rater2' are the inputs, how should they be combined?"
      
      
      
      $edges
      $edges[[1]]
      $edges[[1]]$from
      [1] "operationalize_age"
      
      $edges[[1]]$to
      [1] "operationalize_skin_tone"
      
      $edges[[1]]$type
      [1] "sequential"
      
      
      

# prompt_extract_schema formats correctly

    Code
      cat(result)
    Output
      You are an expert methodologist and data pipeline architect. I will provide a text describing a multiverse analysis and a summary of the actual dataset being used.
      
      === YOUR TASK === 
      
       Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      === RULES === 
      
      1. THEORY EXTRACTION: For each node, extract:
      
         - 'id': A unique snake_case identifier.
      
         - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.
      
         - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.
      
         - 'rationale': WHY that decision (the path) was made, extracted from the text.
      
      2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').
      
      3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.
      
      4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.
      
      5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). If the text abstracts a step and you cannot confidently match it to specific dataset columns, set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact columns to use. If HIGH, output 'null'.
      
      6. Output ONLY valid YAML without markdown formatting.
      
      === REQUIRED YAML STRUCTURE EXAMPLE ===
      
      meta:
        type: schema
      nodes:
      - fork: variables are in different scales
        type: constraint
        path: apply min-max scaling to each variable
        justification: to put them on the same scale for combination
        id: step-scaling
        confidence: high
      - fork: combine the school variables into one dimension
        type: step
        path: average exp sch and avg sch
        justification: the most intuitive way
        id: step-education
        confidence: low
      edges:
      - from: step-scaling
        to: step-education
        type: sequential
      
      === DATASET SUMMARY ===
      
      var1
      
      === METHODOLOGY TEXT ===
      
      Some methodology text. You are an expert methodologist and data pipeline architect. I will provide a text describing a multiverse analysis and a summary of the actual dataset being used.
      
      === YOUR TASK === 
      
       Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      === RULES === 
      
      1. THEORY EXTRACTION: For each node, extract:
      
         - 'id': A unique snake_case identifier.
      
         - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.
      
         - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.
      
         - 'rationale': WHY that decision (the path) was made, extracted from the text.
      
      2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').
      
      3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.
      
      4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.
      
      5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). If the text abstracts a step and you cannot confidently match it to specific dataset columns, set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact columns to use. If HIGH, output 'null'.
      
      6. Output ONLY valid YAML without markdown formatting.
      
      === REQUIRED YAML STRUCTURE EXAMPLE ===
      
      meta:
        type: schema
      nodes:
      - fork: variables are in different scales
        type: constraint
        path: apply min-max scaling to each variable
        justification: to put them on the same scale for combination
        id: step-scaling
        confidence: high
      - fork: combine the school variables into one dimension
        type: step
        path: average exp sch and avg sch
        justification: the most intuitive way
        id: step-education
        confidence: low
      edges:
      - from: step-scaling
        to: step-education
        type: sequential
      
      === DATASET SUMMARY ===
      
      var2
      
      === METHODOLOGY TEXT ===
      
      Some methodology text. You are an expert methodologist and data pipeline architect. I will provide a text describing a multiverse analysis and a summary of the actual dataset being used.
      
      === YOUR TASK === 
      
       Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      === RULES === 
      
      1. THEORY EXTRACTION: For each node, extract:
      
         - 'id': A unique snake_case identifier.
      
         - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.
      
         - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.
      
         - 'rationale': WHY that decision (the path) was made, extracted from the text.
      
      2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').
      
      3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.
      
      4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.
      
      5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). If the text abstracts a step and you cannot confidently match it to specific dataset columns, set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact columns to use. If HIGH, output 'null'.
      
      6. Output ONLY valid YAML without markdown formatting.
      
      === REQUIRED YAML STRUCTURE EXAMPLE ===
      
      meta:
        type: schema
      nodes:
      - fork: variables are in different scales
        type: constraint
        path: apply min-max scaling to each variable
        justification: to put them on the same scale for combination
        id: step-scaling
        confidence: high
      - fork: combine the school variables into one dimension
        type: step
        path: average exp sch and avg sch
        justification: the most intuitive way
        id: step-education
        confidence: low
      edges:
      - from: step-scaling
        to: step-education
        type: sequential
      
      === DATASET SUMMARY ===
      
      var3
      
      === METHODOLOGY TEXT ===
      
      Some methodology text.

