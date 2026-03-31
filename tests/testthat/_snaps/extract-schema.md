# extract_schema generates valid YAML schema

    Code
      cat(readLines(output_file), sep = "\n")
    Output
      nodes:
        - id: calculate_age
          fork: "How to operationalize the age of participants?"
          path: "Calculate age by subtracting birth year from the reference year 2012."
          rationale: "Not specified in text."
          status: "DRAFT"
          inputs: [birthday]
          outputs: [age_calculated]
          confidence: LOW
          clarification_question: "The text specifies 'birth year' but the dataset summary provides 'birthday'. Does the 'birthday' column contain only the year, or is it a full date from which the year must be extracted first?"
        - id: define_skin_tone_scale
          fork: "How to operationalize skin tone?"
          path: "Skin tone is measured using a 1-5 rating scale."
          rationale: "Not specified in text."
          status: "DRAFT"
          inputs: [skin_tone]
          outputs: [skin_tone_validated]
          confidence: MEDIUM
          clarification_question: "The text states 'Skin tone was rated' and the dataset includes 'rater1', 'rater2', and 'skin_tone'. Is the 'skin_tone' column a raw variable or is it derived from an aggregation of 'rater1' and 'rater2'?"
      

---

    Code
      yaml_parsed
    Output
      $nodes
      $nodes[[1]]
      $nodes[[1]]$id
      [1] "calculate_age"
      
      $nodes[[1]]$fork
      [1] "How to operationalize the age of participants?"
      
      $nodes[[1]]$path
      [1] "Calculate age by subtracting birth year from the reference year 2012."
      
      $nodes[[1]]$rationale
      [1] "Not specified in text."
      
      $nodes[[1]]$status
      [1] "DRAFT"
      
      $nodes[[1]]$inputs
      [1] "birthday"
      
      $nodes[[1]]$outputs
      [1] "age_calculated"
      
      $nodes[[1]]$confidence
      [1] "LOW"
      
      $nodes[[1]]$clarification_question
      [1] "The text specifies 'birth year' but the dataset summary provides 'birthday'. Does the 'birthday' column contain only the year, or is it a full date from which the year must be extracted first?"
      
      
      $nodes[[2]]
      $nodes[[2]]$id
      [1] "define_skin_tone_scale"
      
      $nodes[[2]]$fork
      [1] "How to operationalize skin tone?"
      
      $nodes[[2]]$path
      [1] "Skin tone is measured using a 1-5 rating scale."
      
      $nodes[[2]]$rationale
      [1] "Not specified in text."
      
      $nodes[[2]]$status
      [1] "DRAFT"
      
      $nodes[[2]]$inputs
      [1] "skin_tone"
      
      $nodes[[2]]$outputs
      [1] "skin_tone_validated"
      
      $nodes[[2]]$confidence
      [1] "MEDIUM"
      
      $nodes[[2]]$clarification_question
      [1] "The text states 'Skin tone was rated' and the dataset includes 'rater1', 'rater2', and 'skin_tone'. Is the 'skin_tone' column a raw variable or is it derived from an aggregation of 'rater1' and 'rater2'?"
      
      
      

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
      
         - 'status': default to 'DRAFT'.
      
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
      
      === YOUR TASK === 
      
       Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      === RULES === 
      
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
      
      6. Output ONLY valid YAML without markdown formatting.
      
      === REQUIRED YAML STRUCTURE EXAMPLE ===
      
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
      
      === YOUR TASK === 
      
       Extract a chronological list of methodological decisions (nodes) AND map the exact data flow (inputs/outputs) for each node simultaneously.
      
      === RULES === 
      
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
      
      6. Output ONLY valid YAML without markdown formatting.
      
      === REQUIRED YAML STRUCTURE EXAMPLE ===
      
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

