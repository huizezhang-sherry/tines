# prompt_gen_code wording remains stable (snapshot)

    Code
      prompt_gen_code(print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nNo data file is specified - if data loading is required, use a sensible placeholder or note it in a comment. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks."

---

    Code
      prompt_gen_code(data = "inst/football.csv", print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nA DATA section is provided. This is the entry point for the entire pipeline - start the script by loading this data. Do NOT generate, simulate, or create any dummy or synthetic data under any circumstances. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks.\n\n=== DATA ===\n\nThe data should be imported from the file: `inst/football.csv`. Use `readr::read_csv(\"inst/football.csv\")` (or the appropriate reader) to load it."

---

    Code
      prompt_gen_code(data = "tines::football", print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nA DATA section is provided. This is the entry point for the entire pipeline - start the script by loading this data. Do NOT generate, simulate, or create any dummy or synthetic data under any circumstances. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks.\n\n=== DATA ===\n\nThe data is available as a built-in package dataset: `tines::football`. Load it with `data(football, package = \"tines\")` or reference it directly."

---

    Code
      prompt_gen_code(schema = example_hdi(), print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nNo data file is specified - if data loading is required, use a sensible placeholder or note it in a comment. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks.\n\n=== SCHEMA ===\n\n- id: step-scaling\n  objective: variables are in different scales\n  decision: apply min-max scaling to each variable\n  rationale: to put them on the same scale for combination\n- id: step-education\n  objective: combine the school variables into one dimension\n  decision: average exp sch and avg sch\n  rationale: the most intuitive way\n- id: step-combine\n  objective: combine the three dimensions into a single index\n  decision: use the geometric mean\n  rationale: the geometric mean is more appropriate than arithmetic mean\n"

