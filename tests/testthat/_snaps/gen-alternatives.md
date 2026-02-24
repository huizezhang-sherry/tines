# prompt_alternatives wording remains stable (snapshot)

    Code
      prompt_alternatives(block = "clean-missing-data")
    Output
      [1] "### Role\nYou are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify \"Forking Paths\" -- alternative analytical choices that are equally valid but distinct from the current approach.\n\n### Definitions\nThe schema provided to you consists of blocks with:\n- **ACTION**: The goal of the block (What needs to be done).\n- **DECISION**: The specific implementation chosen (How it is done).\n- **JUSTIFICATION**: The reasoning behind that decision.\n- **TAG**: The unique identifier for the block (kebab-case).\n\n### Task\nFocus specifically on the block tagged: \"clean-missing-data\".\nYour goal is to generate 3 distinct, valid alternatives for this block.\n\nFor each alternative:\n1.  **Keep the same ACTION** (the goal remains constant).\n2.  **Change the DECISION** to a different but methodologically sound approach.\n3.  **Provide a new JUSTIFICATION** explaining why this alternative is valid.\n4.  **Create a new TAG** that reflects the new decision (must be kebab-case).\n\n### Output Format\nPlease output the result in **strictly valid YAML format**.\n\n**Crucial Formatting Rules:**\n1.  Include a `meta` section at the top with `type: vista_alternative` and the `target_block`.\n2.  Output strictly valid YAML.\nFormatting Rule: All text values (decision, justification) must be enclosed in double quotes (\"). Do not use block styles (| or >). Do not wrap lines or insert \n characters within the quotes; keep the text as a single continuous string.\"\n3.  Do not include markdown code fences (like ```yaml) or conversational text. Just the raw YAML.\n\n### Example Output Structure\nmeta:\n  type: tines_alternative\n  block: clean-missing-data\nalternatives:\n  - tag: block-new-method-name\n    action: Repeat the original action\n    decision: Description of the new decision...\n    justification: |\n      This is the first line of the reasoning.\n      This is the second line, making it easy to read.\n  - tag: block-another-method\n    ..."

---

    Code
      prompt_alternatives("my-target-block", n = 2)
    Output
      [1] "### Role\nYou are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify \"Forking Paths\" -- alternative analytical choices that are equally valid but distinct from the current approach.\n\n### Definitions\nThe schema provided to you consists of blocks with:\n- **ACTION**: The goal of the block (What needs to be done).\n- **DECISION**: The specific implementation chosen (How it is done).\n- **JUSTIFICATION**: The reasoning behind that decision.\n- **TAG**: The unique identifier for the block (kebab-case).\n\n### Task\nFocus specifically on the block tagged: \"my-target-block\".\nYour goal is to generate 2 distinct, valid alternatives for this block.\n\nFor each alternative:\n1.  **Keep the same ACTION** (the goal remains constant).\n2.  **Change the DECISION** to a different but methodologically sound approach.\n3.  **Provide a new JUSTIFICATION** explaining why this alternative is valid.\n4.  **Create a new TAG** that reflects the new decision (must be kebab-case).\n\n### Output Format\nPlease output the result in **strictly valid YAML format**.\n\n**Crucial Formatting Rules:**\n1.  Include a `meta` section at the top with `type: vista_alternative` and the `target_block`.\n2.  Output strictly valid YAML.\nFormatting Rule: All text values (decision, justification) must be enclosed in double quotes (\"). Do not use block styles (| or >). Do not wrap lines or insert \n characters within the quotes; keep the text as a single continuous string.\"\n3.  Do not include markdown code fences (like ```yaml) or conversational text. Just the raw YAML.\n\n### Example Output Structure\nmeta:\n  type: tines_alternative\n  block: my-target-block\nalternatives:\n  - tag: block-new-method-name\n    action: Repeat the original action\n    decision: Description of the new decision...\n    justification: |\n      This is the first line of the reasoning.\n      This is the second line, making it easy to read.\n  - tag: block-another-method\n    ..."

---

    Code
      prompt_alternatives("my-target-block", print = TRUE)
    Output
      ### Role
      You are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify "Forking Paths" -- alternative analytical choices that are equally valid but distinct from the current approach.
      
      ### Definitions
      The schema provided to you consists of blocks with:
      - **ACTION**: The goal of the block (What needs to be done).
      - **DECISION**: The specific implementation chosen (How it is done).
      - **JUSTIFICATION**: The reasoning behind that decision.
      - **TAG**: The unique identifier for the block (kebab-case).
      
      ### Task
      Focus specifically on the block tagged: "my-target-block".
      Your goal is to generate 3 distinct, valid alternatives for this block.
      
      For each alternative:
      1.  **Keep the same ACTION** (the goal remains constant).
      2.  **Change the DECISION** to a different but methodologically sound approach.
      3.  **Provide a new JUSTIFICATION** explaining why this alternative is valid.
      4.  **Create a new TAG** that reflects the new decision (must be kebab-case).
      
      ### Output Format
      Please output the result in **strictly valid YAML format**.
      
      **Crucial Formatting Rules:**
      1.  Include a `meta` section at the top with `type: vista_alternative` and the `target_block`.
      2.  Output strictly valid YAML.
      Formatting Rule: All text values (decision, justification) must be enclosed in double quotes ("). Do not use block styles (| or >). Do not wrap lines or insert 
       characters within the quotes; keep the text as a single continuous string."
      3.  Do not include markdown code fences (like ```yaml) or conversational text. Just the raw YAML.
      
      ### Example Output Structure
      meta:
        type: tines_alternative
        block: my-target-block
      alternatives:
        - tag: block-new-method-name
          action: Repeat the original action
          decision: Description of the new decision...
          justification: |
            This is the first line of the reasoning.
            This is the second line, making it easy to read.
        - tag: block-another-method
          ...

