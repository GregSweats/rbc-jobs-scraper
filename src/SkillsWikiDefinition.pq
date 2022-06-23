/**
 * SkillsWikiDefinition
 *
 * Find a definition for a [[Skill]] from the Web.
 * Using Wikipedia but it could be anywhere.
 * Swap out me for something else in [[Skills]]
 *
 * #DevNote RE: Wiki-style Linking
 * - Example: `...for a [[Skill]] from the Web...`
 * -  Double square brackets are for Wiki-style linking within the www.Obsidian.md vault.
 * - All the Queries source code can be **SO EASILY COPIED** by clicking on the very first item at the top of the Queries left-side panel,

 *
 * @since 2022-06-17
 */
let
    Source = Skills,
    #"Kept First Rows DEBUG" = Table.FirstN(Source,5),
    #"Added Custom" = Table.AddColumn(#"Kept First Rows DEBUG", "SummaryAPIURL", each "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=" & [SkillsList]),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "SummaryAPIResponse", each Web.Contents([SummaryAPIURL])),
    #"Filtered Hidden Files1" = Table.SelectRows(#"Added Custom1", each [Attributes]?[Hidden]? <> true),

    // #todo Is this Transform File function required?
    #"Invoke Custom Function1" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File", each #"Transform File"([SummaryAPIResponse])),
    // insert a length so we know what the largest responses are. Higher chance of a good description.
    #"Inserted Text Length" = Table.AddColumn(#"Invoke Custom Function1", "ResponseBinaryLength", each Text.Length(Text.From([SummaryAPIResponse])), Int64.Type),
    #"Sorted ResponseBinaryLength Descending" = Table.Sort(#"Inserted Text Length",{{"ResponseBinaryLength", Order.Descending}}),
    #"Renamed Transform File to Response" = Table.RenameColumns(#"Sorted Rows1",{{"Transform File", "Response"}}),
    #"Removed Columns1" = Table.RemoveColumns(#"Renamed Columns",{"SummaryAPIResponse"}),
    #"Expanded Response" = Table.ExpandTableColumn(#"Removed Columns1", "Response", {"Name", "Value"}, {"Response.Name", "Response.Value"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded Response", each ([Response.Name] = "query")),
    #"Expanded Response.Value" = Table.ExpandRecordColumn(#"Filtered Rows", "Response.Value", {"normalized", "pages"}, {"Response.Value.normalized", "Response.Value.pages"}),
    #"Removed Columns2" = Table.RemoveColumns(#"Expanded Response.Value",{"Response.Name", "Response.Value.normalized"}),
    #"Parsed JSON" = Table.AddColumn(
        #"Removed Columns2",
        "ParsedJSON",
        each Json.Document([SummaryAPIResponse])[query] ?? null
    ),
    #"Expanded ParsedJSON" = Table.ExpandRecordColumn(#"Parsed JSON", "ParsedJSON", {"normalized", "pages"}, {"ParsedJSON.normalized", "ParsedJSON.pages"}),
    #"Expanded ParsedJSON.normalized" = Table.ExpandListColumn(#"Expanded ParsedJSON", "ParsedJSON.normalized"),
    #"Renamed Columns1" = Table.RenameColumns(#"Expanded ParsedJSON.normalized",{{"ParsedJSON.normalized", "apiStyledSkillName"}}),
    #"Grab Corrected Name" = Table.TransformColumns(
        #"Renamed Columns1",
        {
          {
            "apiStyledSkillName",
            // Get [apiStyledSkillName][to]
            each [to]
          }
        }
    ),
    #"Transform Record with Unique Key to Definition" = Table.TransformColumns(
        /*
        #Tricky #EILI5

        - `ParsedJSON.pages` is a single record.,
        - Each Record has a single [Field](https://docs.microsoft.com/en-us/powerquery-m/record-functions)
        - Each Field appears to be a different number.
        - Likely unique number.
        - Pretend that number is `1086547` (value for `Test automation` #maybe)
        - We could then get the value as `[Parsed][1086547]`
        - We are in `Table.TransformColumn` from above.
        - Below is the function we want to run on the column specified above this huge comment.
        - In that function, `_` refers to the Column value.
        - That value is.... the Record again!
        - So, we use `Record.FieldNames(_)` to get a List with the FieldName, should just be one.
        - Then use `List.First({ 1086547 })` to get the FieldName (finally).
        - Finally, use `_[108654]`, the array reference syntax #NotSureOfWording
        - That retrieves the next chunk of data we can decode to get the definition.
        - Phew
        -
      */
      #"Grab Corrected Name",
      {
        {
          "ParsedJSON.pages",

          // #debug by just setting this to `_` and seeing what the value is.
          // each _
          // each Record.FieldNames(_)
          each Record.FieldOrDefault(_, List.First(Record.FieldNames(_), null))
          // FieldValues(_)
          // List.First(Record.FieldNames(_))]

          /*
          each
            _[
              List.First(
                Record.FieldNames(_)
              )
            ] ?? null
          */
          // end of that chunk :)
          // #tutorial
        }
      }
    ),
    #"Removed Columns" = Table.RemoveColumns(#"Transform Record with Unique Key to Definition",{"Response.Value.pages.1060901", "Response.Value.pages.5177", "Response.Name"})

    // #"Transform Record with Unique Key to Definition"

    //#"Expanded ParsedJSON.pages" = Table.ExpandRecordColumn(#"Grab Corrected Name", "ParsedJSON.pages", {"1086547"}, {"ParsedJSON.pages.1086547"}),
    // #"ParsedJSON pages 1086547" = #"Expanded ParsedJSON.pages"{0}[ParsedJSON.pages.1086547]
in
    #"Removed Columns"