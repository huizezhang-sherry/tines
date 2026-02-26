gen_code <- function(object, code, alt_object, provider = "gemini", file_path){



}





prompt_code <- function(new_schema, old_schema, old_code){

  prompt <- "You are a helpful assistant for a data analyst. "

  if (is.null(old_code)){
    # no old code, just the new schema. Doesn't matter whether the old schema is there or not, the prompt is the same
    prompt <- paste0(prompt, "You will be given two versions of an analysis schema (outline the steps in the analysis). Please generate the R code that realises the new schema.")
  } else{
    # old code and new schema
    if (is.null(old_schema)){
      # old code and new schema, but no old schema. This is a bit weird, but we can still generate the prompt
      prompt <- paste0(prompt, "You will be given an analysis schema (outline the steps in the analysis) and an relevant R code for a similar type of analysis (but not exect). Please modify the existing R code accordingly to match the analysis schema")
    } else{
      # old code, old schema, and new schema
      prompt <- paste0(prompt, "You will be given two versions of an analysis schema (outline the steps in the analysis), and the corresponding R code code that realises the analysis. The first schema and code represent the old version, while the second schema represents the new version. Please modify the existing R code accordingly to match the second text outline.")
    }
  }

  prompt <- paste0(prompt, " Write the code in an R file and annotate with relevant comments. Do not start with markdown blocks or backticks.")

  prompt
}


