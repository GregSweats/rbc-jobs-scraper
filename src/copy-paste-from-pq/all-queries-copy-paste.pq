// RBC_DETAIL_URL_BASE
"https://jobs.rbc.com/ca/en/job/" meta [IsParameterQuery=true, Type="Any", IsParameterQueryRequired=true]

// SKILLS_API_URL_BASE
"https://fr.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=" meta [IsParameterQuery=true, List={"https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=", "https://fr.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles="}, DefaultValue="https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=", Type="Text", IsParameterQueryRequired=true]

// SKILLS_MIN_COUNT_FOR_LOOKUP
2 meta [IsParameterQuery=true, Type="Number", IsParameterQueryRequired=true]

// JobsExtractorJsonResponse
let
    Source = Json.Document(File.Contents("C:\Users\GregStevens\OneDrive - Dalyle\projects\rbc-jobs-scraper\job-search-results\New_Request-1655486320222.json")),
    eagerLoadRefineSearch = Source[eagerLoadRefineSearch],
    data = eagerLoadRefineSearch[data]
in
    data

// JobsExtractorJsonResponseExpanded
/**
 * @since 2022-06-17
 *
 */
let
    Source = JobsExtractorJsonResponse,
    // referencing base url below so it shows up in the "Applied Steps" navigator. Easier debugging, more chance of glancing at it and seeing a wrong value while developing/using.
    RBC_JOB_URL_BASE = RBC_JOB_URL_BASE,
    jobs = Source[jobs],
    #"Converted to Table" = Table.FromList(
        jobs, Splitter.SplitByNothing(), null, null, ExtraValues.Error
    ),
    #"Expanded Column1" = Table.ExpandRecordColumn(
        #"Converted to Table", "Column1", {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}, {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}
    )

in
    #"Expanded Column1"

// Jobs
/**
 * Jobs
 *
 * @since 2022-06-17
*/
let
    Source = JobsExtractorJsonResponseExpanded,
    #"Extracted Values" = Table.TransformColumns(
        Source, {"ml_skills", each Text.Combine(List.Transform(_, Text.From), ","), type text}
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

// Jobs (3)
let
    /*
    Source = Json.Document(File.Contents("C:\Users\GregStevens\OneDrive - Dalyle\projects\rbc-scrape-power-query-2022-06-15\insomnia-rbc\jobs-from-post-1655351852934.json")),
    eagerLoadRefineSearch = Source[eagerLoadRefineSearch],
    data = eagerLoadRefineSearch[data],
    */
    // Sorce = Jobs (Firewall Error with Web.Parts)
    data = JobsExtractorJsonResponse,
    jobs = data[jobs],
    #"Converted to Table" = Table.FromList(jobs, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}, {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}),
    #"Extracted Values" = Table.TransformColumns(#"Expanded Column1", {"ml_skills", each Text.Combine(List.Transform(_, Text.From), ","), type text}),
    #"Extracted Values1" = Table.TransformColumns(#"Extracted Values", {"multi_location", each Text.Combine(List.Transform(_, Text.From), ";"), type text}),
    #"Changed Type" = Table.TransformColumnTypes(#"Extracted Values1",{{"postedDate", type datetimezone}}),
    #"Extracted Values2" = Table.TransformColumns(#"Changed Type", {"multi_category", each Text.Combine(List.Transform(_, Text.From), ";"), type text}),
    #"Sorted Rows" = Table.Sort(#"Extracted Values2",{{"postedDate", Order.Ascending}}),
    //
    #"Added PublicURL" = Table.AddColumn(#"Sorted Rows", "PublicURL", each "https://jobs.rbc.com/ca/en/job/" & [jobId]),

    /* !!! important !!!
        Make an HTTP Request to the Public Career Page.
        Parse the results of that.
        Required to get an APPLICATION DEADLINE DATE.

        todo: #someday If it can be retrieved from the original Jobs JSON search results instead, that would be sweeet.
        Invoke Web.Contents on the [PublicURL]
    */
    #"Added WebContents" = Table.AddColumn(#"Added PublicURL",
        "WebContents",
        each Web.Contents([PublicURL])
    ),
    // Parse the Response from Web.Content
    // Separate step for debugging.
    // todo: does it call the webpage more than once? #research #experiment #lab
    #"Added WebPage by Parsing WebContents" = Table.AddColumn(
        #"Added WebContents",
        "WebPage",
        each Web.Page([WebContents])
    ),
    // important end

    #"Reordered Columns" = Table.ReorderColumns(
        #"Added WebPage by Parsing WebContents",
        {"WebPage", "WebContents", "jobId", "cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"})
in
    #"Reordered Columns"

// Jobs (4) RemoveExpandHtml
/**
 * Jobs (4) RemoveExpandHTML
 *
 * @since 2022-06-17
*/
let
    Source = #"Jobs (3)",
    #"Removed Other Columns" = Table.SelectColumns(Source,{"WebPage", "jobId"}),
    #"Expanded WebContents" = Table.ExpandTableColumn(#"Removed Other Columns", "WebPage", {"Caption", "Source", "ClassName", "Id", "Data"}, {"Caption", "Source", "ClassName", "Id", "Data"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded WebContents",{{"Data", "HTML"}}),
    #"Expanded HTML" = Table.ExpandTableColumn(#"Renamed Columns", "HTML", {"Kind", "Name", "Children", "Text"}, {"HTML.Kind", "HTML.Name", "HTML.Children", "HTML.Text"}),
    #"Expanded HTML.Children" = Table.ExpandTableColumn(#"Expanded HTML", "HTML.Children", {"Kind", "Name", "Children", "Text"}, {"HTML.Children.Kind", "HTML.Children.Name", "HTML.Children.Children", "HTML.Children.Text"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expanded HTML.Children",{{"HTML.Children.Children", "HEAD.Children"}}),
    #"Expanded HEAD.Children" = Table.ExpandTableColumn(#"Renamed Columns1", "HEAD.Children", {"Kind", "Name", "Children", "Text"}, {"HEAD.Children.Kind", "HEAD.Children.Name", "HEAD.Children.Children", "HEAD.Children.Text"})
in
    #"Expanded HEAD.Children"

// Jobs (5) ExtractPhAppScriptSrcFromHtmlHead
let
    Source = #"Jobs (4) RemoveExpandHtml",
    #"Reordered Columns" = Table.ReorderColumns(Source,{"jobId", "HEAD.Children.Children", "Caption", "Source", "ClassName", "Id", "HTML.Kind", "HTML.Name", "HTML.Children.Kind", "HTML.Children.Name", "HEAD.Children.Kind", "HEAD.Children.Name", "HEAD.Children.Text", "HTML.Children.Text", "HTML.Text"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Reordered Columns",{"HEAD.Children.Children", "jobId"}),
    #"Reordered Columns1" = Table.ReorderColumns(#"Removed Other Columns",{"jobId", "HEAD.Children.Children"}),
    #"Expanded HEAD.Children.Children" = Table.ExpandTableColumn(#"Reordered Columns1", "HEAD.Children.Children", {"Kind", "Name", "Children", "Text"}, {"HEAD.Children.Children.Kind", "HEAD.Children.Children.Name", "HEAD.Children.Children.Children", "HEAD.Children.Children.Text"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded HEAD.Children.Children", each Text.StartsWith([HEAD.Children.Children.Text], " /*<!--*/ var phApp = phApp || "))
in
    #"Filtered Rows"

// Jobs (6) TransformPhAppSrcToJson
let
    Source = #"Jobs (5) ExtractPhAppScriptSrcFromHtmlHead",
    #"Split Column by Delimiter" = Table.SplitColumn(Source, "HEAD.Children.Children.Text", Splitter.SplitTextByDelimiter("||", QuoteStyle.None), {"HEAD.Children.Children.Text.1", "HEAD.Children.Children.Text.2"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Split Column by Delimiter",{"jobId", "HEAD.Children.Children.Text.2", "HEAD.Children.Children.Kind", "HEAD.Children.Children.Name", "HEAD.Children.Children.Children", "HEAD.Children.Children.Text.1"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Reordered Columns",{"jobId", "HEAD.Children.Children.Text.2"}),
    #"Split Column by Delimiter2" = Table.SplitColumn(#"Removed Other Columns", "HEAD.Children.Children.Text.2", Splitter.SplitTextByEachDelimiter({";"}, QuoteStyle.None, false), {"HEAD.Children.Children.Text.2.1", "HEAD.Children.Children.Text.2.2"}),
    #"Split Column by Delimiter3" = Table.SplitColumn(#"Split Column by Delimiter2", "HEAD.Children.Children.Text.2.2", Splitter.SplitTextByEachDelimiter({"="}, QuoteStyle.None, false), {"HEAD.Children.Children.Text.2.2.1", "HEAD.Children.Children.Text.2.2.2"}),
    #"Split Column by Delimiter1" = Table.SplitColumn(#"Split Column by Delimiter3", "HEAD.Children.Children.Text.2.2.2", Splitter.SplitTextByEachDelimiter({";"}, QuoteStyle.None, true), {"HEAD.Children.Children.Text.2.2.2.1", "HEAD.Children.Children.Text.2.2.2.2"}),
    #"Inserted Parsed JSON" = Table.AddColumn(#"Split Column by Delimiter1", "JSON", each Json.Document([HEAD.Children.Children.Text.2.2.2.1])),
    #"Split Column by Delimiter4" = Table.SplitColumn(#"Inserted Parsed JSON", "HEAD.Children.Children.Text.2.2.2.1", Splitter.SplitTextByEachDelimiter({"; phApp."}, QuoteStyle.None, false), {"HEAD.Children.Children.Text.2.2.2.1.1", "HEAD.Children.Children.Text.2.2.2.1.2"}),
    #"Inserted Parsed JSON1" = Table.AddColumn(#"Split Column by Delimiter4", "JSON.1", each Json.Document([HEAD.Children.Children.Text.2.2.2.1.1])),
    #"Reordered Columns1" = Table.ReorderColumns(#"Inserted Parsed JSON1",{"JSON.1", "jobId", "HEAD.Children.Children.Text.2.1", "HEAD.Children.Children.Text.2.2.1", "HEAD.Children.Children.Text.2.2.2.1.1", "HEAD.Children.Children.Text.2.2.2.1.2", "HEAD.Children.Children.Text.2.2.2.2", "JSON"})
in
    #"Reordered Columns1"

// JobsTablePhDataExpanded
let
    Source = #"Jobs (6) TransformPhAppSrcToJson",
    #"Removed Other Columns" = Table.SelectColumns(Source,{"JSON.1", "jobId"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Other Columns",{"jobId", "JSON.1"}),
    #"Renamed Columns" = Table.RenameColumns(#"Reordered Columns",{{"JSON.1", "PhData"}}),
    #"Expanded PhData" = Table.ExpandRecordColumn(#"Renamed Columns", "PhData", {"fyfTokenStatus", "jobDetail", "jobwidgetsettings", "siteConfig", "categoryContentV2", "caasLazyLoadWidgetVersions", "getRegionLocales", "flashParams"}, {"fyfTokenStatus", "jobDetail", "jobwidgetsettings", "siteConfig", "categoryContentV2", "caasLazyLoadWidgetVersions", "getRegionLocales", "flashParams"}),
    #"Reordered Columns1" = Table.ReorderColumns(#"Expanded PhData",{"jobDetail", "jobId", "fyfTokenStatus", "jobwidgetsettings", "siteConfig", "categoryContentV2", "caasLazyLoadWidgetVersions", "getRegionLocales", "flashParams"}),
    #"Removed Other Columns1" = Table.SelectColumns(#"Reordered Columns1",{"jobDetail", "jobId"}),
    #"Expanded jobDetail" = Table.ExpandRecordColumn(#"Removed Other Columns1", "jobDetail", {"data"}, {"jobDetail.data"}),
    #"Expanded jobDetail.data" = Table.ExpandRecordColumn(#"Expanded jobDetail", "jobDetail.data", {"job", "isMultiLocationEnabled", "multiLocationFieldName", "multiLocationValues"}, {"job", "isMultiLocationEnabled", "multiLocationFieldName", "multiLocationValues"}),
    #"Expanded job" = Table.ExpandRecordColumn(#"Expanded jobDetail.data", "job", {"cityState", "country", "subCategory", "additionalFields", "ml_skills", "companyName", "postalCode", "ml_title", "hasPrimaryQuestionnaire", "payRateCA", "source", "type", "jobRequisitionId", "structureData", "descriptionTeaser", "jobFamily", "hasSupplementaryInternalQuestionnaire", "state", "atsCountry", "sector", "jobUpdatedDate", "visibilityType", "ml_skills_global", "siteType", "longitude", "secondaryQuestionnaireId", "ats", "isDerived", "uniqueValue", "uniqueKey", "internalCategoryId", "latlong", "payRate", "jobUniqueIdentifier", "lastUpdatedTrack", "descriptionFR", "multi_category", "stateCountry", "reqId", "jobId", "supInternalQuestionnarieName", "refNum", "ml_domains", "jobUpdated", "userType", "ml_country", "descriptionHashKey", "primaryLocaleCategory", "supQuestionnarieName", "city", "latitude", "visibilityLocale", "workHours", "hasSecondaryQuestionnaire", "description", "multi_location", "postingEndDate", "locale", "title", "ml_skills_mapping", "platform", "jobSeqNo", "postedDate", "ml_highlight", "dateCreated", "storeLocation", "hasSupplementaryQuestionnaire", "locationId", "supInternalQuestionnarieId", "cityStateCountry", "jobType", "linkedinCompanyProfile", "hashKey", "address", "jobPostingSiteId", "isTranslated", "parentRefNum", "ml_language_fullform", "cmsJobId", "platform1", "jobVisibility", "primaryQuestionnaireId", "applyUrl", "careerLevel", "frTitle", "isCritical", "jobFamilyId", "location", "cityCountry", "category", "mapQueryLocation", "ml_Description", "externalApply", "supQuestionnarieId"}, {"job.cityState", "job.country", "job.subCategory", "job.additionalFields", "job.ml_skills", "job.companyName", "job.postalCode", "job.ml_title", "job.hasPrimaryQuestionnaire", "job.payRateCA", "job.source", "job.type", "job.jobRequisitionId", "job.structureData", "job.descriptionTeaser", "job.jobFamily", "job.hasSupplementaryInternalQuestionnaire", "job.state", "job.atsCountry", "job.sector", "job.jobUpdatedDate", "job.visibilityType", "job.ml_skills_global", "job.siteType", "job.longitude", "job.secondaryQuestionnaireId", "job.ats", "job.isDerived", "job.uniqueValue", "job.uniqueKey", "job.internalCategoryId", "job.latlong", "job.payRate", "job.jobUniqueIdentifier", "job.lastUpdatedTrack", "job.descriptionFR", "job.multi_category", "job.stateCountry", "job.reqId", "job.jobId", "job.supInternalQuestionnarieName", "job.refNum", "job.ml_domains", "job.jobUpdated", "job.userType", "job.ml_country", "job.descriptionHashKey", "job.primaryLocaleCategory", "job.supQuestionnarieName", "job.city", "job.latitude", "job.visibilityLocale", "job.workHours", "job.hasSecondaryQuestionnaire", "job.description", "job.multi_location", "job.postingEndDate", "job.locale", "job.title", "job.ml_skills_mapping", "job.platform", "job.jobSeqNo", "job.postedDate", "job.ml_highlight", "job.dateCreated", "job.storeLocation", "job.hasSupplementaryQuestionnaire", "job.locationId", "job.supInternalQuestionnarieId", "job.cityStateCountry", "job.jobType", "job.linkedinCompanyProfile", "job.hashKey", "job.address", "job.jobPostingSiteId", "job.isTranslated", "job.parentRefNum", "job.ml_language_fullform", "job.cmsJobId", "job.platform1", "job.jobVisibility", "job.primaryQuestionnaireId", "job.applyUrl", "job.careerLevel", "job.frTitle", "job.isCritical", "job.jobFamilyId", "job.location", "job.cityCountry", "job.category", "job.mapQueryLocation", "job.ml_Description", "job.externalApply", "job.supQuestionnarieId"}),
    #"Extracted Values" = Table.TransformColumns(#"Expanded job", {"job.ml_skills", each Text.Combine(List.Transform(_, Text.From), ","), type text})
in
    #"Extracted Values"

// JobsTablePhDataExpandedReordered
let
    Source = JobsTablePhDataExpanded,
    #"Reordered Columns" = Table.ReorderColumns(Source,{"job.ml_Description", "job.description", "job.primaryQuestionnaireId", "job.secondaryQuestionnaireId", "job.descriptionFR", "job.postingEndDate", "job.jobFamily", "job.hashKey", "job.platform1", "job.jobFamilyId", "job.frTitle", "job.primaryLocaleCategory", "job.descriptionTeaser", "job.ml_skills", "job.cityState", "job.country", "job.subCategory", "job.additionalFields", "job.companyName", "job.postalCode", "job.ml_title", "job.hasPrimaryQuestionnaire", "job.payRateCA", "job.source", "job.type", "job.jobRequisitionId", "job.structureData", "job.hasSupplementaryInternalQuestionnaire", "job.state", "job.atsCountry", "job.sector", "job.jobUpdatedDate", "job.visibilityType", "job.ml_skills_global", "job.siteType", "job.longitude", "job.ats", "job.isDerived", "job.uniqueValue", "job.uniqueKey", "job.internalCategoryId", "job.latlong", "job.payRate", "job.jobUniqueIdentifier", "job.lastUpdatedTrack", "job.multi_category", "job.stateCountry", "job.reqId", "job.jobId", "job.supInternalQuestionnarieName", "job.refNum", "job.ml_domains", "job.jobUpdated", "job.userType", "job.ml_country", "job.descriptionHashKey", "job.supQuestionnarieName", "job.city", "job.latitude", "job.visibilityLocale", "job.workHours", "job.hasSecondaryQuestionnaire", "job.multi_location", "job.locale", "job.title", "job.ml_skills_mapping", "job.platform", "job.jobSeqNo", "job.postedDate", "job.ml_highlight", "job.dateCreated", "job.storeLocation", "job.hasSupplementaryQuestionnaire", "job.locationId", "job.supInternalQuestionnarieId", "job.cityStateCountry", "job.jobType", "job.linkedinCompanyProfile", "job.address", "job.jobPostingSiteId", "job.isTranslated", "job.parentRefNum", "job.ml_language_fullform", "job.cmsJobId", "job.jobVisibility", "job.applyUrl", "job.careerLevel", "job.isCritical", "job.location", "job.cityCountry", "job.category", "job.mapQueryLocation", "job.externalApply", "job.supQuestionnarieId", "isMultiLocationEnabled", "multiLocationFieldName", "multiLocationValues", "jobId"})
in
    #"Reordered Columns"

// JobsWithDetails
let
    Source = JobsTablePhDataExpandedReordered,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"job.ml_Description", "job.description", "job.primaryQuestionnaireId", "job.secondaryQuestionnaireId", "job.descriptionFR", "job.postingEndDate", "job.jobFamily", "job.hashKey", "job.platform1", "job.jobFamilyId", "job.frTitle", "job.primaryLocaleCategory", "job.descriptionTeaser", "job.ml_skills", "job.cityState", "job.country", "job.subCategory", "job.additionalFields", "job.payRateCA", "job.source", "job.type", "job.jobRequisitionId", "job.structureData", "job.hasSupplementaryInternalQuestionnaire", "job.sector", "job.jobUpdatedDate", "job.ml_skills_global", "job.longitude", "job.latlong", "job.payRate", "job.reqId", "job.jobId", "job.jobUpdated", "job.latitude", "job.workHours", "job.ml_skills_mapping", "job.postedDate", "job.dateCreated", "job.isTranslated", "job.applyUrl", "job.careerLevel", "job.isCritical", "job.externalApply", "job.supQuestionnarieId", "jobId"}),
    #"Renamed Columns" = Table.RenameColumns(
        #"Removed Other Columns",
        {
            { "job.ml_Description", "ml_Description" },
            { "job.description", "description" },
            { "job.primaryQuestionnaireId", "primaryQuestionnaireId" },
            { "job.secondaryQuestionnaireId", "secondaryQuestionnaireId" },
            { "job.descriptionFR", "descriptionFR" },
            { "job.postingEndDate", "postingEndDate" },
            { "job.jobFamily", "jobFamily" },
            { "job.hashKey", "hashKey" },
            { "job.platform1", "platform1" },
            { "job.jobFamilyId", "jobFamilyId" },
            { "job.frTitle", "frTitle" },
            { "job.primaryLocaleCategory", "primaryLocaleCategory" },
            { "job.descriptionTeaser", "descriptionTeaser" },
            { "job.ml_skills", "jml_skills" },
            { "job.cityState", "cityState" },
            { "job.country", "country" },
            { "job.subCategory", "subCategory" },
            { "job.additionalFields", "additionalFields" },
            { "job.payRateCA", "payRateCA" },
            { "job.source", "source" },
            { "job.type", "type" },
            { "job.jobRequisitionId", "jobRequisitionId" },
            { "job.structureData", "structureData" },
            { "job.hasSupplementaryInternalQuestionnaire", "hasSupplementaryInternalQuestionnaire" },
            { "job.sector", "sector" },
            { "job.jobUpdatedDate", "jobUpdatedDate" },
            { "job.ml_skills_global", "job.mskills_global" },
            { "job.longitude", "longitude" },
            { "job.latlong", "latlong" },
            { "job.payRate", "payRate" },
            { "job.reqId", "reqId" },
            // already exists { "job.jobId", "jobId" },
            { "job.jobUpdated", "jobUpdated" },
            { "job.latitude", "latitude" },
            { "job.workHours", "workHours" },
            { "job.ml_skills_mapping", "job.mskills_mapping" },
            { "job.postedDate", "postedDate" },
            { "job.dateCreated", "dateCreated" },
            { "job.isTranslated", "isTranslated" },
            { "job.applyUrl", "applyUrl" },
            { "job.careerLevel", "careerLevel" },
            { "job.isCritical", "isCritical" },
            { "job.externalApply", "externalApply" },
            { "job.supQuestionnarieId", "supQuestionnarieId" }
        }
    ),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"postingEndDate", type date}}),
    #"Sorted Rows" = Table.Sort(#"Changed Type",{{"postingEndDate", Order.Ascending}}),
    #"Inserted Text Before Delimiter" = Table.AddColumn(#"Sorted Rows", "detailUrl", each Text.BeforeDelimiter([applyUrl], "/apply"), type text),
    #"Added rbcDetailUrl" = Table.AddColumn(#"Inserted Text Before Delimiter", "Custom", each RBC_DETAIL_URL_BASE & [jobId]),
    #"Renamed Columns1" = Table.RenameColumns(#"Added rbcDetailUrl",{{"Custom", "rbcDetailUrl"}})
in
    #"Renamed Columns1"

// JobsWithDetailsSlim
/**
 * @since 2022-06-17
*/
let
    Source = JobsWithDetails,
    #"Reordered Columns" = Table.ReorderColumns(
        Source,{"ml_Description", "postingEndDate", "primaryQuestionnaireId", "secondaryQuestionnaireId", "descriptionFR", "jobFamily", "hashKey", "platform1", "jobFamilyId", "frTitle", "primaryLocaleCategory", "descriptionTeaser", "jml_skills", "cityState", "country", "subCategory", "additionalFields", "payRateCA", "source", "type", "jobRequisitionId", "structureData", "hasSupplementaryInternalQuestionnaire", "sector", "jobUpdatedDate", "job.mskills_global", "longitude", "latlong", "payRate", "reqId", "job.jobId", "jobUpdated", "latitude", "workHours", "job.mskills_mapping", "postedDate", "dateCreated", "isTranslated", "applyUrl", "careerLevel", "isCritical", "externalApply", "supQuestionnarieId", "jobId"}
    ),
    #"Removed Columns" = Table.RemoveColumns(
        #"Reordered Columns",{"description", "externalApply", "isTranslated", "job.mskills_mapping", "latlong", "additionalFields", "source", "structureData", "sector", "job.mskills_global", "reqId", "jobRequisitionId"}
    ),
    #"Changed Type" = Table.TransformColumnTypes(
        #"Removed Columns",{{"jobUpdatedDate", type datetimezone}, {"jobUpdated", type datetimezone}, {"postedDate", type datetimezone}, {"dateCreated", type datetimezone}}
    ),
    #"Inserted Age" = Table.AddColumn(
        #"Changed Type", "DaysUntilEnd", each [postingEndDate] - Date.From(DateTime.LocalNow()) , type duration
    ),
    #"Reordered Columns1" = Table.ReorderColumns(
        #"Inserted Age",{"jobId", "DaysUntilEnd", "ml_Description", "postingEndDate", "primaryQuestionnaireId", "secondaryQuestionnaireId", "descriptionFR", "platform1", "jobFamily", "jobFamilyId", "hashKey", "frTitle", "primaryLocaleCategory", "descriptionTeaser", "jml_skills", "cityState", "country", "subCategory", "payRateCA", "type", "hasSupplementaryInternalQuestionnaire", "jobUpdatedDate", "longitude", "payRate", "job.jobId", "jobUpdated", "latitude", "workHours", "postedDate", "dateCreated", "careerLevel", "isCritical", "supQuestionnarieId", "detailUrl", "applyUrl"}
    ),
    #"Removed Columns1" = Table.RemoveColumns(
        #"Reordered Columns1",{"job.jobId"}
    ),
    #"Reordered Columns2" = Table.ReorderColumns(
        #"Removed Columns1",{"DaysUntilEnd", "jobId", "frTitle", "ml_Description", "postingEndDate", "primaryQuestionnaireId", "secondaryQuestionnaireId", "descriptionFR", "platform1", "jobFamily", "jobFamilyId", "hashKey", "primaryLocaleCategory", "descriptionTeaser", "jml_skills", "cityState", "country", "subCategory", "payRateCA", "type", "hasSupplementaryInternalQuestionnaire", "jobUpdatedDate", "longitude", "payRate", "jobUpdated", "latitude", "workHours", "postedDate", "dateCreated", "careerLevel", "isCritical", "supQuestionnarieId", "detailUrl", "applyUrl"
    })
in
    #"Reordered Columns2"

// multi_location_array
let
    Source = JobsExtractorJsonResponse,
    jobs = Source[jobs],
    #"Converted to Table" = Table.FromList(jobs, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}, {"cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "title", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply"}),
    #"Extracted Values" = Table.TransformColumns(#"Expanded Column1", {"ml_skills", each Text.Combine(List.Transform(_, Text.From), ","), type text}),
    #"Extracted Values1" = Table.TransformColumns(#"Extracted Values", {"multi_location", each Text.Combine(List.Transform(_, Text.From), ";"), type text}),
    #"Changed Type" = Table.TransformColumnTypes(#"Extracted Values1",{{"postedDate", type datetimezone}}),
    #"Extracted Values2" = Table.TransformColumns(#"Changed Type", {"multi_category", each Text.Combine(List.Transform(_, Text.From), ";"), type text}),
    #"Sorted Rows" = Table.Sort(#"Extracted Values2",{{"postedDate", Order.Ascending}}),
    #"Added Custom" = Table.AddColumn(#"Sorted Rows", "PublicURL", each "https://jobs.rbc.com/ca/en/job/" & [jobId]),
    #"Reordered Columns" = Table.ReorderColumns(#"Added Custom",{"title", "cityState", "country", "subCategory", "city", "ml_skills", "latitude", "type", "multi_location", "locale", "multi_location_array", "jobSeqNo", "postedDate", "descriptionTeaser", "dateCreated", "state", "cityStateCountry", "visibilityType", "siteType", "longitude", "address", "isMultiCategory", "multi_category", "reqId", "jobId", "badge", "jobVisibility", "isMultiLocation", "applyUrl", "multi_category_array", "location", "ml_job_parser", "category", "externalApply", "PublicURL"}),
    #"Sorted Rows1" = Table.Sort(#"Reordered Columns",{{"postedDate", Order.Ascending}}),
    multi_location_array1 = #"Sorted Rows1"{12}[multi_location_array],
    multi_location_array2 = multi_location_array1{0}
in
    multi_location_array2

// job description
let
    Source = JobsTablePhDataExpandedReordered,
    #"job description1" = Source{5}[job.description]
in
    #"job description1"

// Jobs_Skills
let
    Source = JobsExtractorJsonResponseExpanded,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"ml_skills", "title", "jobId"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"title", type text}, {"jobId", type text}}),
    #"Reordered Columns" = Table.ReorderColumns(#"Changed Type",{"jobId", "title", "ml_skills"}),
    #"Renamed Columns" = Table.RenameColumns(#"Reordered Columns",{{"ml_skills", "SkillsList"}}),
    #"Expanded SkillsList" = Table.ExpandListColumn(#"Renamed Columns", "SkillsList"),
    #"Changed Type1" = Table.TransformColumnTypes(#"Expanded SkillsList",{{"SkillsList", type text}})
in
    #"Changed Type1"

// Skills
let
    Source = Jobs_Skills,
    #"Removed Other Columns1" = Table.SelectColumns(Source,{"SkillsList"}),
    #"Grouped Rows" = Table.Group(#"Removed Other Columns1", {"SkillsList"}, {{"Count", each Table.RowCount(_), Int64.Type}}),
    #"Sorted Rows" = Table.Sort(#"Grouped Rows",{{"Count", Order.Descending}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Sorted Rows",{{"SkillsList", type text}})
in
    #"Changed Type"

// SkillsDefinitionFromAPI
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
    MAX_ROWS = 0,

    // Set API_URL as a parameter. Can use fr.wikipedia.org or whatever language you like....in theory
    // Imaine a sales person, or tech, with anote languae, able to mapskill to their native language, then to the foreign languag and map/PowerPivot them together next to each other?!
    // This may actually do some good.
    // Also the Executives, the Managers, canquick lookup terms.
    //API_URL = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles="
    API_URL = SKILLS_API_URL_BASE,
    #"Kept First Rows DEBUG" = if MAX_ROWS = 0 then Table.SelectRows(Source, each [Count] > SKILLS_MIN_COUNT_FOR_LOOKUP) else Table.FirstN(Source,5),
    #"Added API Request URL" = Table.AddColumn(#"Kept First Rows DEBUG", "SummaryAPIURL", each API_URL & [SkillsList]),
    #"Added APIResponse" = Table.AddColumn(#"Added API Request URL", "ApiResponse", each Web.Contents([SummaryAPIURL])),
    // #"Filtered Hidden Files1" = Table.SelectRows(#"Added APIResponse", each [Attributes]?[Hidden]? <> true),
    // insert a length so we know what the largest responses are. Higher chance of a good description.
    #"Inserted Text Length" = Table.AddColumn(#"Added APIResponse", "ResponseBinaryLength", each Text.Length(Text.From([ApiResponse])), Int64.Type),
    #"Sorted ResponseBinaryLength Descending" = Table.Sort(#"Inserted Text Length",{{"ResponseBinaryLength", Order.Descending}}),


// #todo Is this Transform File function required?
    // #"Invoke Transform File" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File", each #"Transform File"([SummaryAPIResponse])),
     #"Parsed JSON" = Table.AddColumn(
        #"Sorted ResponseBinaryLength Descending",
        "ParsedJSON",
        each Json.Document([ApiResponse])[query] ?? null
        // `..[query] ?? null` (tenary operator) above is for if that field is undefined, errors out, etc
    ),

    #"Renamed Transform File to Response" = Table.RenameColumns(#"Parsed JSON",{{"ParsedJSON", "Response"}}),




    // #"Removed Columns1" = Table.RemoveColumns(#"Renamed Transform File to Response",{"SummaryAPIResponse"}),
    #"Expanded Response" = Table.ExpandTableColumn(#"Renamed Transform File to Response", "Response", {"Name", "Value"}, {"Response.Name", "Response.Value"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded Response", each ([Response.Name] = "query")),
    #"Expanded Response.Value" = Table.ExpandRecordColumn(#"Filtered Rows", "Response.Value", {"normalized", "pages"}, {"Response.Value.normalized", "Response.Value.pages"}),
    #"Removed Columns2" = Table.RemoveColumns(#"Expanded Response.Value",{"Response.Name", "Response.Value.normalized"}),

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
    #"Transform Record with Unique Key to Definition" = Table.TransformColumns(
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
    #"Expanded ParsedJSON.pages" = Table.ExpandRecordColumn(#"Transform Record with Unique Key to Definition", "ParsedJSON.pages", {"title", "extract"}, {"title", "extract"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded ParsedJSON.pages",{{"title", "ResponseTitle"}, {"extract", "ResponseExtract"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"ApiResponse"})
in
    #"Removed Columns"

// Sample File
let
    Source = Skills,
    #"Added Custom" = Table.AddColumn(Source, "SummaryAPIURL", each "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=" & [SkillsList]),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "SummaryAPIResponse", each Web.Contents([SummaryAPIURL])),
    Navigation1 = #"Added Custom1"{0}[SummaryAPIResponse]
in
    Navigation1

// Parameter1
#"Sample File" meta [IsParameterQuery=true, BinaryIdentifier=#"Sample File", Type="Binary", IsParameterQueryRequired=true]

// Transform File
let
    Source = (Parameter1 as binary) => let
        Source = Json.Document(Parameter1),
        #"Converted to Table1" = Record.ToTable(Source)
    in
        #"Converted to Table1"
in
    Source