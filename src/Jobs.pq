/**
 * Jobs
 *
 * @since 2022-06-17
*/
let
    Source = jsonResponse,
    RBC_JOB_URL_BASE = "https://jobs.rbc.com/ca/en/job/",
    jobs = Source[jobs],
    #"Converted to Table" = Table.FromList(
        jobs, Splitter.SplitByNothing(), null, null, ExtraValues.Error
    ),
    #"Expanded Column1" = Table.ExpandRecordColumn(
        #"Converted to Table", "Column1", {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}, {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}
    ),
    #"Extracted Values" = Table.TransformColumns(
        #"Expanded Column1", {"ml_skills", each Text.Combine(List.Transform(_, Text.From), ","), type text}
    ),
    #"Extracted Values1" = Table.TransformColumns(
        #"Extracted Values", {"multi_location", each Text.Combine(List.Transform(_, Text.From), ";"), type text}
    ),
    #"Changed Type" = Table.TransformColumnTypes(
        #"Extracted Values1",{{"postedDate", type datetimezone}}
    ),
    #"Extracted Values2" = Table.TransformColumns(
        #"Changed Type", {"multi_category", each Text.Combine(List.Transform(_, Text.From), ";"), type text}
    ),
    #"Sorted Rows" = Table.Sort(
        #"Extracted Values2",{{"postedDate", Order.Ascending}}
    ),
    #"Added Custom" = Table.AddColumn(
        #"Sorted Rows",
        "PublicURL",
        each RBC_JOB_URL_BASE & [jobId]
    ),
    #"Reordered Columns" = Table.ReorderColumns(
        #"Added Custom",
        {"title", "cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply", "PublicURL"}
    ),
    #"Sorted Rows1" = Table.Sort(
        #"Reordered Columns",
        {
            {"postedDate", Order.Ascending}
        }
    )
in
    #"Sorted Rows1"