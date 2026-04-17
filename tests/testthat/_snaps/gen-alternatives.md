# prompt_alternatives wording remains stable (snapshot)

    Code
      prompt_alternatives(step = "clean-missing-data", print = FALSE)
    Output
      [1] "You are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify \"Forking Paths\" -- alternative analytical choices that are equally valid but distinct from the current approach.\n\n=== DEFINITIONS ===\n\nThe schema provided to you consists of steps with:\n\n- **ACTION**: The goal of the step (What needs to be done).\n\n- **DECISION**: The specific implementation chosen (How it is done).\n\n- **JUSTIFICATION**: The reasoning behind that decision.\n\n- **ID**: The unique identifier for the step (kebab-case).\n\n=== TASK ===\n\nFocus specifically on the step tagged: \"clean-missing-data\".\nYour goal is to generate 3 distinct, valid alternatives for this step.\n\nFor each alternative:\n1. **Keep the same ACTION** (the goal remains constant).\n\n2. **Change the DECISION** to a different but methodologically sound approach.\n\n3. **Provide a new JUSTIFICATION** explaining why this alternative is valid.\n\n4. **Create a new ID** that reflects the new decision (must be kebab-case).\n\n=== OUTPUT FORMAT ===\n\nPlease output the result in **strictly valid YML format**.\n\n**Crucial Formatting Rules:**\n\n1. Include a `meta` section at the top with `type: alternative` and the `step`.\n\n2. Output strictly valid YML. All text values (decision, justification) must be enclosed in double quotes (\"). Do not use block styles (| or >). Do not wrap lines or insert \\n characters within the quotes; keep the text as a single continuous string.\n\n3. Do not include markdown code fences (like ```yml) or conversational text. Just the raw YML.\n\n=== REQUIRED YML STRUCTURE EXAMPLE ===\n\nmeta:\n  type: tines_alternative\n  step: clean-missing-data\nalternatives:\n  - id: step-new-method-name\n    action: Repeat the original action\n    decision: \"Description of the new decision...\"\n    justification: \"This is the reasoning for why this alternative is valid.\"\n  - id: step-another-method\n    ...\n"

---

    Code
      prompt_alternatives(step = "my-target-block", n = 2, print = FALSE)
    Output
      [1] "You are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify \"Forking Paths\" -- alternative analytical choices that are equally valid but distinct from the current approach.\n\n=== DEFINITIONS ===\n\nThe schema provided to you consists of steps with:\n\n- **ACTION**: The goal of the step (What needs to be done).\n\n- **DECISION**: The specific implementation chosen (How it is done).\n\n- **JUSTIFICATION**: The reasoning behind that decision.\n\n- **ID**: The unique identifier for the step (kebab-case).\n\n=== TASK ===\n\nFocus specifically on the step tagged: \"my-target-block\".\nYour goal is to generate 2 distinct, valid alternatives for this step.\n\nFor each alternative:\n1. **Keep the same ACTION** (the goal remains constant).\n\n2. **Change the DECISION** to a different but methodologically sound approach.\n\n3. **Provide a new JUSTIFICATION** explaining why this alternative is valid.\n\n4. **Create a new ID** that reflects the new decision (must be kebab-case).\n\n=== OUTPUT FORMAT ===\n\nPlease output the result in **strictly valid YML format**.\n\n**Crucial Formatting Rules:**\n\n1. Include a `meta` section at the top with `type: alternative` and the `step`.\n\n2. Output strictly valid YML. All text values (decision, justification) must be enclosed in double quotes (\"). Do not use block styles (| or >). Do not wrap lines or insert \\n characters within the quotes; keep the text as a single continuous string.\n\n3. Do not include markdown code fences (like ```yml) or conversational text. Just the raw YML.\n\n=== REQUIRED YML STRUCTURE EXAMPLE ===\n\nmeta:\n  type: tines_alternative\n  step: my-target-block\nalternatives:\n  - id: step-new-method-name\n    action: Repeat the original action\n    decision: \"Description of the new decision...\"\n    justification: \"This is the reasoning for why this alternative is valid.\"\n  - id: step-another-method\n    ...\n"

---

    Code
      prompt_alternatives(step = "my-target-block", print = TRUE)
    Output
      You are an expert Data Analyst and Methodologist. You are reviewing
      an analysis schema to identify "Forking Paths" -- alternative
      analytical choices that are equally valid but distinct from the
      current approach.
      
      === DEFINITIONS ===
      
      The schema provided to you consists of steps with:
      
      - **ACTION**: The goal of the step (What needs to be done).
      
      - **DECISION**: The specific implementation chosen (How it is done).
      
      - **JUSTIFICATION**: The reasoning behind that decision.
      
      - **ID**: The unique identifier for the step (kebab-case).
      
      === TASK ===
      
      Focus specifically on the step tagged: "my-target-block". Your goal
      is to generate 3 distinct, valid alternatives for this step.
      
      For each alternative: 1. **Keep the same ACTION** (the goal remains
      constant).
      
      2. **Change the DECISION** to a different but methodologically sound
      approach.
      
      3. **Provide a new JUSTIFICATION** explaining why this alternative is
      valid.
      
      4. **Create a new ID** that reflects the new decision (must be
      kebab-case).
      
      === OUTPUT FORMAT ===
      
      Please output the result in **strictly valid YML format**.
      
      **Crucial Formatting Rules:**
      
      1. Include a `meta` section at the top with `type: alternative` and
      the `step`.
      
      2. Output strictly valid YML. All text values (decision,
      justification) must be enclosed in double quotes ("). Do not use
      block styles (| or >). Do not wrap lines or insert \n characters
      within the quotes; keep the text as a single continuous string.
      
      3. Do not include markdown code fences (like ```yml) or
      conversational text. Just the raw YML.
      
      === REQUIRED YML STRUCTURE EXAMPLE ===
      
      meta: type: tines_alternative step: my-target-block alternatives: -
      id: step-new-method-name action: Repeat the original action decision:
      "Description of the new decision..."  justification: "This is the
      reasoning for why this alternative is valid."  - id:
      step-another-method ...

# expand_tines

    Code
      expand_tines(base_schema, alts)
    Output
      A multiverse with 4 schemas:
        original: (3 steps)
        step-mixed-effects-logistic-model: (3 steps)
        step-probit-regression-model: (3 steps)
        step-bayesian-logistic-model: (3 steps)

---

    Code
      expand_tines(base_schema, tmp_file)
    Output
      A multiverse with 4 schemas:
        original: (3 steps)
        step-mixed-effects-logistic-model: (3 steps)
        step-probit-regression-model: (3 steps)
        step-bayesian-logistic-model: (3 steps)

---

    Target step "step-logistic-model" not found in the base schema.

---

    Code
      expand_tines(multiverse, alts)
    Output
      A multiverse with 4 schemas:
        original: (3 steps)
        reversed: (3 steps)
        original.step-arithmetic-mean: (3 steps)
        reversed.step-arithmetic-mean: (3 steps)

