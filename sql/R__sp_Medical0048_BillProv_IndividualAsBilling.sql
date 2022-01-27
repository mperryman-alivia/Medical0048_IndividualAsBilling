CREATE OR ALTER PROCEDURE [dbo].[sp_Medical0048_BillProv_IndividualAsBilling] @querystring nvarchar(max)

AS
BEGIN

-- 730048656    WENDY MARIE WRIGHT-BELL    730086886    ANNA  HASTINGS
DROP TABLE IF EXISTS #Medical0048_BillProv_TempMedClaim
CREATE TABLE #Medical0048_BillProv_TempMedClaim (
	[ClaimSeq] [int] NOT NULL,
	[sec_organization_id] [nvarchar](64) NOT NULL,
	[sec_tenant_id] [nvarchar](36) NOT NULL,
	[at_ai_sched_proc_exec_id] [varchar](255) NULL
)ON [PRIMARY] 

DECLARE @Query nvarchar(max)
SET @Query  = CONCAT(
'
INSERT INTO #Medical0048_BillProv_TempMedClaim
SELECT [ClaimSeq]
	,t.[sec_organization_id]
	,t.[sec_tenant_id]
	,[at_ai_sched_proc_exec_id]
from (',
 @querystring, ') t 

INNER JOIN dbo.ALIV_ProviderFile rp
 ON t.RenderingProviderAnalyticsID = rp.ProviderAnalyticsID
	AND rp.ProviderEntityType = ''Individual''
		AND t.sec_organization_id = rp.sec_organization_id
			AND t.sec_tenant_id = rp.sec_tenant_id

 INNER JOIN dbo.ALIV_ProviderFile bp
 ON t.BillingProviderAnalyticsID = bp.ProviderAnalyticsID
	AND bp.ProviderEntityType = ''Individual''
		AND t.sec_organization_id = bp.sec_organization_id
			AND t.sec_tenant_id = bp.sec_tenant_id
				AND bp.ProviderFirstName IS NOT NULL
					AND bp.ProviderLastName IS NOT NULL

 WHERE UncoveredServiceFlag = ''0''
 AND AmountPaid > 0
 AND RenderingProviderAnalyticsID <> BillingProviderAnalyticsID
 AND t.ClaimForm = ''CMS-1500''
 AND t.MCOFlag = ''0''
 -- AND t.ManualExclusionFlag = ''0''
	 ')
EXEC(@Query)

DECLARE @ExecutionID varchar(255) = (SELECT TOP 1  at_ai_sched_proc_exec_id from #Medical0048_BillProv_TempMedClaim)

-- Checks to see if data already exists in this table with the same execution ID to ensure no redundant computation is done
DECLARE @ExecutionCheck int = (
	SELECT COUNT(*) FROM (
		SELECT TOP 1 at_ai_sched_proc_exec_id 
		FROM dbo.[Medical0048_IndividualAsBilling_AtRiskClaims]
		WHERE at_ai_sched_proc_exec_id = @ExecutionID) a
	)


IF @ExecutionCheck = 0
BEGIN

	CREATE CLUSTERED INDEX IX_ClaimSeq ON #Medical0048_BillProv_TempMedClaim (ClaimSeq, sec_organization_id, sec_tenant_id)

	INSERT INTO dbo.[Medical0048_IndividualAsBilling_AtRiskClaims]
	SELECT AmountPaid AmountAtRisk
		,cl.[ClaimSeq]
		,[ClaimICN]
		,[ClaimLineNumber]
		,[ClaimForm]
		,[ClaimTypeCode]
		,[ClaimTypeDescription]
		,[ClaimBillType]
		,[AmountPaid]
		,[AmountAllowed]
		,[AmountCharged]
		,[AmountMedicare]
		,[AmountTotCOB]
		,[AmountCopay]
		,[AmountDeductible]
		,[AmountCoinsurance]
		,[AmountOOP]
		,[AmountHSA]
		,[PricingMethodCode]
		,[PricingMethodDescription]
		,[SystemPricingMethod]
		,[ContractID]
		,[CheckNumber]
		,[PrimaryExternalPayerID]
		,[PrimaryExternalPayerName]
		,[ReceivedDate]
		,[AdjudicationDate]
		,[PaidDate]
		,[ServiceFromDate]
		,[ServiceToDate]
		,[ServiceID]
		,[ProcedureCode]
		,[ProcedureDescription]
		,[ProcedureNumberOfUnits]
		,[ProcedureMod_1]
		,[ProcedureMod_2]
		,[ProcedureMod_3]
		,[ProcedureMod_4]
		,[VisitID]
		,[VisitStartDate]
		,[VisitEndDate]
		,[LevelOfCareCode]
		,[LevelOfCareDescription]
		,[SystemLevelOfCare]
		,[ClaimLengthOfStay]
		,[ClaimNumberOfDaysPaid]
		,[ClaimNonCoveredDays]
		,[VisitLengthOfStay]
		,[VisitNumberOfDaysPaid]
		,[VisitNonCoveredDays]
		,[TypeOfServiceCode]
		,[TypeOfServiceDescription]
		,[PlaceOfServiceCode]
		,[PlaceOfServiceDescription]
		,[LocationID]
		,[LocationZipCode]
		,[LocationCountyCode]
		,[LocationCountyDescription]
		,[LocationUrbanRural]
		,[MemberDistanceToLocation]
		,[PriorAuthorizationSeq]
		,[PriorAuthorizationNumber]
		,[MCOFlag]
		,[MCOAnalyticsID]
		,[MCOName]
		,[MCORegionCode]
		,[MCORegionDescription]
		,[MCOClaimICN]
		,[MCOClaimLineNumber]
		,[MCOPaidDate]
		,[ACOFlag]
		,[ACOAnalyticsID]
		,[ACOName]
		,[CrossoverFlag]
		,[EPSDTFlag]
		,[LineOfBusiness_Level1Code]
		,[LineOfBusiness_Level1Description]
		,[LineOfBusiness_Level2Code]
		,[LineOfBusiness_Level2Description]
		,[LineOfBusiness_Level3Code]
		,[LineOfBusiness_Level3Description]
		,[LineOfBusiness_Level4Code]
		,[LineOfBusiness_Level4Description]
		,[PlanCode]
		,[PlanDescription]
		,[ProductCode]
		,[ProductDescription]
		,[NetworkTypeCode]
		,[NetworkTypeDescription]
		,[SystemNetworkType]
		,[InNetworkFlag]
		,[SystemRuleset]
		,[DiagnosisCodeType]
		,[PrimaryDiagnosisCode]
		,[PrimaryDiagnosisDescription]
		,[SecondaryDiagnosisCode]
		,[SecondaryDiagnosisDescription]
		,[RenderingProviderAnalyticsID]
		,[RenderingProviderAnalyticsIDType]
		,[RenderingProviderAnalyticsPeerGroup]
		,[RenderingProviderAnalyticsPeerGroupType]
		,[RenderingProviderID]
		,[RenderingProviderNPI]
		,[RenderingProviderName]
		,[RenderingProviderTaxonomyCode]
		,[RenderingProviderTypeCode]
		,[RenderingProviderTypeDescription]
		,[RenderingProviderSpecialtyCode]
		,[RenderingProviderSpecialtyDescription]
		,[BillingProviderAnalyticsID]
		,[BillingProviderAnalyticsIDType]
		,[BillingProviderAnalyticsPeerGroup]
		,[BillingProviderAnalyticsPeerGroupType]
		,[BillingProviderID]
		,[BillingProviderNPI]
		,[BillingProviderCCN]
		,[BillingProviderName]
		,[BillingProviderTaxonomyCode]
		,[BillingProviderTypeCode]
		,[BillingProviderTypeDescription]
		,[BillingProviderSpecialtyCode]
		,[BillingProviderSpecialtyDescription]
		,[BillingProviderAddressFirstLine]
		,[BillingProviderAddressSecondLine]
		,[BillingProviderCity]
		,[BillingProviderState]
		,[BillingProviderZipCode]
		,[BillingProviderTIN]
		,[BillingProviderEmail]
		,[BillingProviderFax]
		,[AttendingProviderAnalyticsID]
		,[AttendingProviderAnalyticsIDType]
		,[AttendingProviderAnalyticsPeerGroup]
		,[AttendingProviderAnalyticsPeerGroupType]
		,[AttendingProviderID]
		,[AttendingProviderNPI]
		,[AttendingProviderName]
		,[AttendingProviderTaxonomyCode]
		,[AttendingProviderTypeCode]
		,[AttendingProviderTypeDescription]
		,[AttendingProviderSpecialtyCode]
		,[AttendingProviderSpecialtyDescription]
		,[ReferringProviderAnalyticsID]
		,[ReferringProviderAnalyticsIDType]
		,[ReferringProviderAnalyticsPeerGroup]
		,[ReferringProviderAnalyticsPeerGroupType]
		,[ReferringProviderID]
		,[ReferringProviderNPI]
		,[ReferringProviderName]
		,[ReferringProviderTaxonomyCode]
		,[ReferringProviderTypeCode]
		,[ReferringProviderTypeDescription]
		,[ReferringProviderSpecialtyCode]
		,[ReferringProviderSpecialtyDescription]
		,[ReferringProviderZipCode]
		,[MemberDistanceToReferringProvider]
		,[MemberAnalyticsID]
		,[MemberAnalyticsIDType]
		,[MemberMonthID]
		,[SubscriberID]
		,[PersonID]
		,[CardholderID]
		,[MemberID]
		,[MemberMedicaidID]
		,[MemberMedicareID]
		,[MemberName]
		,[MemberFirstName]
		,[MemberLastName]
		,[MemberAge]
		,[MemberGender]
		,[MemberRelationshipCode]
		,[MemberRelationshipDescription]
		,[MemberDOB]
		,[MemberDOD]
		,[MemberAddressFirstLine]
		,[MemberAddressSecondLine]
		,[MemberCity]
		,[MemberState]
		,[MemberZipCode]
		,[MemberCountyCode]
		,[MemberCountyDescription]
		,[MemberPhone]
		,[MemberEmail]
		,[MemberEmployerID]
		,[MemberEmployerName]
		,[MemberGroupID]
		,[MemberGroupName]
		,[MemberSubGroupID]
		,[MemberSubGroupName]
		,[MemberClassID]
		,[MemberClassName]
		,[MemberAidCategoryCode]
		,[MemberAidCategoryDescription]
		,[MemberEligibilityCategoryCode]
		,[MemberEligibilityCategoryDescription]
		,[MemberPCPAnalyticsID]
		,[MemberPCPName]
		,[MemberHealthRiskFlag]
		,[YearOfService]
		,[YearQuarter]
		,[YearMonth]
		,[location_address]
		,[location_latitude]
		,[location_longitude]
		,[member_address]
		,[member_latitude]
		,[member_longitude]
		,ar.[sec_organization_id]
		,ar.[sec_tenant_id]
		,'Medical' [AliviaBenefitLine]
		,'0048' [AliviaModelID]
		,'Individual As Billing Provider' [AliviaModelName]
		,@ExecutionID at_ai_sched_proc_exec_id
	FROM #Medical0048_BillProv_TempMedClaim ar 

	INNER JOIN dbo.ALIV_MedicalClaimLineApproved cl
	ON ar.ClaimSeq = cl.ClaimSeq
		AND ar.sec_organization_id = cl.sec_organization_id
			AND ar.sec_tenant_id = cl.sec_tenant_id
	
	LEFT JOIN ai_claims_tracker.dbo.tracked_claims tc
	ON ar.ClaimSeq = tc.claim_seq
		/*
			Uncomment after claims tracker supports multi-tenancy

			AND ar.sec_organization_id = tc.sec_organization_id
				AND ar.sec_tenant_id = tc.sec_tenant_id
		*/

	WHERE tc.claim_seq IS NULL

	INSERT INTO dbo.ALIV_AtRiskClaims
	SELECT ClaimSeq
		,ClaimICN
		,ClaimForm
		,AmountAtRisk
		,RenderingProviderAnalyticsID
		,BillingProviderAnalyticsID
		,AttendingProviderAnalyticsID
		,ReferringProviderAnalyticsID
		,NULL [PrescriberAnalyticsID]
		,NULL [PharmacyAnalyticsID]
		,MemberAnalyticsID [MemberAnalyticsID]
		,MCOAnalyticsID
		,ACOAnalyticsID
		,'1' [RenderingProviderFlag]
		,'1' [BillingProviderFlag]
		,'0' [AttendingProviderFlag]
		,'0' [ReferringProviderFlag]
		,'0' [PrescriberFlag]
		,'0' [PharmacyFlag]
		,'0' [MemberFlag]
		,'0' [MCOFlag]
		,'0' [ACOFlag]
		,'ALIV_MedicalClaimLineApproved' [SourceTable]
		,[AliviaBenefitLine]
		,[AliviaModelID]
		,[AliviaModelName]
		,[sec_organization_id]
		,[sec_tenant_id]
		,@ExecutionID
	FROM [dbo].[Medical0048_IndividualAsBilling_AtRiskClaims] ar

	WHERE ar.at_ai_sched_proc_exec_id = @ExecutionID

END

INSERT INTO dbo.[Medical0048_IndividualAsBilling_BillProvMetrics]
SELECT cl.BillingProviderAnalyticsID
	,MAX(BillingProviderName) BillingProviderName
	,MAX(BillingProviderAnalyticsPeerGroup) BillingProviderAnalyticsPeerGroup
	,SUM(AmountAtRisk) AmountAtRisk
	,SUM(CASE WHEN MCOFlag = '1' THEN AmountAtRisk ELSE 0 END) AmountAtRiskMCO
	,SUM(CASE WHEN MCOFlag = '0' THEN AmountAtRisk ELSE 0 END) AmountAtRiskFFS
	,COUNT(DISTINCT ProcedureCode) NumberProcedures
	,COUNT(DISTINCT MemberAnalyticsID) NumberMembers
	,COUNT(DISTINCT CONCAT(ClaimICN, 'Line_', ClaimLineNumber)) NumberClaimsAtRisk
	,COUNT(DISTINCT RenderingProviderAnalyticsID) NumberRenderingProviders
	,1.0 * COUNT(DISTINCT CONCAT(ClaimICN, 'Line_', ClaimLineNumber)) / COUNT(DISTINCT MemberAnalyticsID) AverageNumberClaimsAtRiskPerMember
	,cl.sec_organization_id
	,cl.sec_tenant_id
	,@ExecutionID at_ai_sched_proc_exec_id
FROM dbo.[Medical0048_IndividualAsBilling_AtRiskClaims] cl

WHERE cl.at_ai_sched_proc_exec_id = @ExecutionID
AND cl.BillingProviderAnalyticsID <> 'ERROR'

GROUP BY cl.BillingProviderAnalyticsID, cl.sec_organization_id, cl.sec_tenant_id

END