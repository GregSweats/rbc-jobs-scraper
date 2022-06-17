/**
 * JobsWithDetailsSlim
 *
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


