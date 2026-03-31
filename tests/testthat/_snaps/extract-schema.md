# extract_schema generates valid YAML schema

    Code
      cat(readLines(output_file), sep = "\n")
    Output
      nodes:
        - id: calculate_age
          fork: How to operationalize participant age?
          path: Calculate age by subtracting birth year from a fixed year (2012).
          rationale: Not specified in the text.
          status: DRAFT
          inputs: [birth_year]
          outputs: [age]
          confidence: LOW
          clarification_question: The methodology describes calculating age from "birth year", but this column is not in the provided dataset summary. Which column should be used as the input for this calculation?
      

---

    Code
      yaml_parsed
    Output
      $nodes
      $nodes[[1]]
      $nodes[[1]]$id
      [1] "calculate_age"
      
      $nodes[[1]]$fork
      [1] "How to operationalize participant age?"
      
      $nodes[[1]]$path
      [1] "Calculate age by subtracting birth year from a fixed year (2012)."
      
      $nodes[[1]]$rationale
      [1] "Not specified in the text."
      
      $nodes[[1]]$status
      [1] "DRAFT"
      
      $nodes[[1]]$inputs
      [1] "birth_year"
      
      $nodes[[1]]$outputs
      [1] "age"
      
      $nodes[[1]]$confidence
      [1] "LOW"
      
      $nodes[[1]]$clarification_question
      [1] "The methodology describes calculating age from \"birth year\", but this column is not in the provided dataset summary. Which column should be used as the input for this calculation?"
      
      
      

# prompt_extract_schema formats correctly

    Code
      cat(result)
    Output
      You are an expert methodologist and data pipeline architect. I will provide a text describing a multiverse analysis and a summary of the actual dataset being used.
      
      YOUR TASK: Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      RULES:
      1. THEORY EXTRACTION: For each node, extract:
         - 'id': A unique snake_case identifier.
         - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.
         - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.
         - 'rationale': WHY that decision (the path) was made, extracted from the text.
         - 'status': default to 'DRAFT'.
      2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').
      3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.
      4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.
      5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). If the text abstracts a step and you cannot confidently match it to specific dataset columns, set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact columns to use. If HIGH, output 'null'.
      6. Output ONLY valid YAML without markdown formatting.=== REQUIRED YAML STRUCTURE EXAMPLE ===
      meta:
        type: schema
      nodes:
      - fork: variables are in different scales
        type: constraint
        path: apply min-max scaling to each variable
        justification: to put them on the same scale for combination
        tag: block-scaling
        status: VERIFIED
        confidence: high- fork: combine the school variables into one dimension
        type: step
        path: average exp sch and avg sch
        justification: the most intuitive way
        tag: block-education
        status: DRAFT
        confidence: lowedges:
      - from: block-scaling
        to: block-education
        type: sequential
      
      === DATASET SUMMARY ===
      var1
      
      === METHODOLOGY TEXT ===
      Some methodology text. You are an expert methodologist and data pipeline architect. I will provide a text describing a multiverse analysis and a summary of the actual dataset being used.
      
      YOUR TASK: Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      RULES:
      1. THEORY EXTRACTION: For each node, extract:
         - 'id': A unique snake_case identifier.
         - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.
         - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.
         - 'rationale': WHY that decision (the path) was made, extracted from the text.
         - 'status': default to 'DRAFT'.
      2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').
      3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.
      4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.
      5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). If the text abstracts a step and you cannot confidently match it to specific dataset columns, set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact columns to use. If HIGH, output 'null'.
      6. Output ONLY valid YAML without markdown formatting.=== REQUIRED YAML STRUCTURE EXAMPLE ===
      meta:
        type: schema
      nodes:
      - fork: variables are in different scales
        type: constraint
        path: apply min-max scaling to each variable
        justification: to put them on the same scale for combination
        tag: block-scaling
        status: VERIFIED
        confidence: high- fork: combine the school variables into one dimension
        type: step
        path: average exp sch and avg sch
        justification: the most intuitive way
        tag: block-education
        status: DRAFT
        confidence: lowedges:
      - from: block-scaling
        to: block-education
        type: sequential
      
      === DATASET SUMMARY ===
      var2
      
      === METHODOLOGY TEXT ===
      Some methodology text. You are an expert methodologist and data pipeline architect. I will provide a text describing a multiverse analysis and a summary of the actual dataset being used.
      
      YOUR TASK: Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      RULES:
      1. THEORY EXTRACTION: For each node, extract:
         - 'id': A unique snake_case identifier.
         - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.
         - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.
         - 'rationale': WHY that decision (the path) was made, extracted from the text.
         - 'status': default to 'DRAFT'.
      2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').
      3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.
      4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.
      5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). If the text abstracts a step and you cannot confidently match it to specific dataset columns, set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact columns to use. If HIGH, output 'null'.
      6. Output ONLY valid YAML without markdown formatting.=== REQUIRED YAML STRUCTURE EXAMPLE ===
      meta:
        type: schema
      nodes:
      - fork: variables are in different scales
        type: constraint
        path: apply min-max scaling to each variable
        justification: to put them on the same scale for combination
        tag: block-scaling
        status: VERIFIED
        confidence: high- fork: combine the school variables into one dimension
        type: step
        path: average exp sch and avg sch
        justification: the most intuitive way
        tag: block-education
        status: DRAFT
        confidence: lowedges:
      - from: block-scaling
        to: block-education
        type: sequential
      
      === DATASET SUMMARY ===
      var3
      
      === METHODOLOGY TEXT ===
      Some methodology text.

