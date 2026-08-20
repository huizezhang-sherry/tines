# prompt_gen_code wording remains stable (snapshot)

    Code
      prompt_gen_code(print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nNo data file is specified - if data loading is required, use a sensible placeholder or note it in a comment. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next as defined by the inputs and outputs. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks."

---

    Code
      prompt_gen_code(data = "inst/football.csv", print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nA DATA section is provided. This is the entry point for the entire pipeline - start the script by loading this data. Do NOT generate, simulate, or create any dummy or synthetic data under any circumstances. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next as defined by the inputs and outputs. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks.\n\n=== DATA ===\n\nThe data should be imported from the file: `inst/football.csv`. Use `readr::read_csv(\"inst/football.csv\")` (or the appropriate reader) to load it."

---

    Code
      prompt_gen_code(data = "tines::football", print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nA DATA section is provided. This is the entry point for the entire pipeline - start the script by loading this data. Do NOT generate, simulate, or create any dummy or synthetic data under any circumstances. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next as defined by the inputs and outputs. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks.\n\n=== DATA ===\n\nThe data is available as a built-in package dataset: `tines::football`. Load it with `data(football, package = \"tines\")` or reference it directly."

---

    Code
      prompt_gen_code(schema = example_schema(), print = FALSE)
    Output
      [1] "You are an expert R programmer. Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\nNo data file is specified - if data loading is required, use a sensible placeholder or note it in a comment. Your task is to write a complete, working R script that implements this pipeline step-by-step. Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next as defined by the inputs and outputs. Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks.\n\n=== SCHEMA ===\n\nid:\n- step-scaling\n- step-education\n- step-combine\nfork:\n- variables are in different scales\n- combine the school variables into one dimension\n- combine the three dimensions into a single index\npath:\n- apply min-max scaling to each variable\n- average exp sch and avg sch\n- use the geometric mean\nrationale:\n- to put them on the same scale for combination\n- the most intuitive way\n- the geometric mean is more appropriate than arithmetic mean\ninputs:\n- .na\n- .na\n- .na\noutputs:\n- .na\n- .na\n- .na\nsource_schema:\n- .na\n- .na\n- .na\n"

