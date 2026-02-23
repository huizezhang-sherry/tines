# schema and multiverse constructor work

    Code
      str(schema)
    Output
      List of 3
       $ name : chr "HDI Example"
       $ nodes: tibble [3 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ tag          : chr [1:3] "block-scaling" "block-education" "block-combine"
        ..$ action       : chr [1:3] "variables are in different scales" "combine the school variables into one dimension" "combine the three dimensions into a single index"
        ..$ type         : chr [1:3] "constraint" "step" "step"
        ..$ decision     : chr [1:3] "apply min-max scaling to each variable" "average exp sch and avg sch" "use the geometric mean"
        ..$ justification: chr [1:3] "to put them on the same scale for combination" "the most intuitive way" "the geometric mean is more appropriate than arithmetic mean"
        ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
       $ edges: tibble [3 x 3] (S3: tbl_df/tbl/data.frame)
        ..$ from: chr [1:3] "block-scaling" "block-combine" "block-education"
        ..$ to  : chr [1:3] "block-education" "block-scaling" "block-combine"
        ..$ type: chr [1:3] "sequential" "motivated" "sequential"
        ..- attr(*, "out.attrs")=List of 2
        .. ..$ dim     : Named int [1:3] 1 1 1
        .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
        .. ..$ dimnames:List of 3
        .. .. ..$ from: chr "from=block-scaling"
        .. .. ..$ to  : chr "to=block-education"
        .. .. ..$ type: chr "type=sequential"
       - attr(*, "class")= chr "schema"

---

    Code
      str(schema2)
    Output
      List of 3
       $ name : chr "HDI Example"
       $ nodes: tibble [3 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ tag          : chr [1:3] "block-education" "block-scaling" "block-combine"
        ..$ action       : chr [1:3] "combine the school variables into one dimension" "variables are in different scales" "combine the three dimensions into a single index"
        ..$ type         : chr [1:3] "step" "constraint" "step"
        ..$ decision     : chr [1:3] "average exp sch and avg sch" "apply min-max scaling to each variable" "use the geometric mean"
        ..$ justification: chr [1:3] "the most intuitive way" "to put them on the same scale for combination" "the geometric mean is more appropriate than arithmetic mean"
        ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
       $ edges: tibble [3 x 3] (S3: tbl_df/tbl/data.frame)
        ..$ from: chr [1:3] "block-education" "block-scaling" "block-combine"
        ..$ to  : chr [1:3] "block-scaling" "block-combine" "block-scaling"
        ..$ type: chr [1:3] "sequential" "sequential" "motivated"
        ..- attr(*, "out.attrs")=List of 2
        .. ..$ dim     : Named int [1:3] 1 1 1
        .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
        .. ..$ dimnames:List of 3
        .. .. ..$ from: chr "from=block-education"
        .. .. ..$ to  : chr "to=block-scaling"
        .. .. ..$ type: chr "type=sequential"
       - attr(*, "class")= chr "schema"

---

    Code
      str(my_multiverse)
    Output
      List of 2
       $ original:List of 3
        ..$ name : chr "HDI Example"
        ..$ nodes: tibble [3 x 6] (S3: tbl_df/tbl/data.frame)
        .. ..$ tag          : chr [1:3] "block-scaling" "block-education" "block-combine"
        .. ..$ action       : chr [1:3] "variables are in different scales" "combine the school variables into one dimension" "combine the three dimensions into a single index"
        .. ..$ type         : chr [1:3] "constraint" "step" "step"
        .. ..$ decision     : chr [1:3] "apply min-max scaling to each variable" "average exp sch and avg sch" "use the geometric mean"
        .. ..$ justification: chr [1:3] "to put them on the same scale for combination" "the most intuitive way" "the geometric mean is more appropriate than arithmetic mean"
        .. ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
        ..$ edges: tibble [3 x 3] (S3: tbl_df/tbl/data.frame)
        .. ..$ from: chr [1:3] "block-scaling" "block-combine" "block-education"
        .. ..$ to  : chr [1:3] "block-education" "block-scaling" "block-combine"
        .. ..$ type: chr [1:3] "sequential" "motivated" "sequential"
        .. ..- attr(*, "out.attrs")=List of 2
        .. .. ..$ dim     : Named int [1:3] 1 1 1
        .. .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
        .. .. ..$ dimnames:List of 3
        .. .. .. ..$ from: chr "from=block-scaling"
        .. .. .. ..$ to  : chr "to=block-education"
        .. .. .. ..$ type: chr "type=sequential"
        ..- attr(*, "class")= chr "schema"
       $ reversed:List of 3
        ..$ name : chr "HDI Example"
        ..$ nodes: tibble [3 x 6] (S3: tbl_df/tbl/data.frame)
        .. ..$ tag          : chr [1:3] "block-education" "block-scaling" "block-combine"
        .. ..$ action       : chr [1:3] "combine the school variables into one dimension" "variables are in different scales" "combine the three dimensions into a single index"
        .. ..$ type         : chr [1:3] "step" "constraint" "step"
        .. ..$ decision     : chr [1:3] "average exp sch and avg sch" "apply min-max scaling to each variable" "use the geometric mean"
        .. ..$ justification: chr [1:3] "the most intuitive way" "to put them on the same scale for combination" "the geometric mean is more appropriate than arithmetic mean"
        .. ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
        ..$ edges: tibble [3 x 3] (S3: tbl_df/tbl/data.frame)
        .. ..$ from: chr [1:3] "block-education" "block-scaling" "block-combine"
        .. ..$ to  : chr [1:3] "block-scaling" "block-combine" "block-scaling"
        .. ..$ type: chr [1:3] "sequential" "sequential" "motivated"
        .. ..- attr(*, "out.attrs")=List of 2
        .. .. ..$ dim     : Named int [1:3] 1 1 1
        .. .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
        .. .. ..$ dimnames:List of 3
        .. .. .. ..$ from: chr "from=block-education"
        .. .. .. ..$ to  : chr "to=block-scaling"
        .. .. .. ..$ type: chr "type=sequential"
        ..- attr(*, "class")= chr "schema"
       - attr(*, "class")= chr [1:2] "multiverse" "list"

# validation errors remain stable

    All elements in a multiverse must be of class <schema>.
    i Arguments at positions 2 are invalid.

