WITH orderinfo AS (
	    SELECT 
		oproc.ORDER_PROC_ID											AS 'OrderID',
		oproc.PROC_ID												AS 'ProcID',
		oproc.AUTHRZING_PROV_ID										AS 'AuthorizingProvID',
		ZCRefPT.NAME												AS 'Authorizing Provider Source',
		oproc.TECHNOLOGIST_ID										AS 'TechnologistID',
		oproc.ORDER_STATUS_C										AS 'Order Status Code',
		ZCOrderS.NAME												AS 'Order Status',
		oproc.LAB_STATUS_C											AS 'Lab Status Code',
		ZCLab.NAME													AS 'Lab Status',
		oproc.ORDER_TYPE_C											AS 'Order Type Code',
		ZCOrderS.NAME												AS 'Order Type',
		oproc.RADIOLOGY_STATUS_C									AS 'Radiology Status Code',
		ZCRadioS.NAME												AS 'Radiology Status',
		oproc.ORDER_CLASS_C											AS 'Order Class Code',
		ZCOrderC.NAME												AS 'Order Class',
		oproc.ABNORMAL_YN                                           AS 'Abnormal Result YN',


		CONVERT(datetime,oproc.ORDER_INST)							AS 'Order Time',
		CONVERT(datetime,oproc.PROC_BGN_TIME)						AS 'Exam Begin Time',
		CONVERT(datetime,oproc.PROC_END_TIME)						AS 'Exam End Time',
		CONVERT(date,oproc.PROC_BGN_TIME)							AS 'Exam Begin Date',
		CONVERT(date,oproc.PROC_END_TIME)							AS 'Exam End Date',
		CONVERT(time,oproc.PROC_END_TIME)							AS 'Exam End Time2',
		CONVERT(time,oproc.PROC_BGN_TIME)							AS 'Exam Begin Time2',

		CASE 
		WHEN PROC_BGN_TIME IS NULL
			THEN 0
			ELSE 1 
		END															AS 'Exam Begin Time Flag',
		CASE
		WHEN PROC_END_TIME IS NULL
			THEN 0
			ELSE 1
		END															AS 'Exam End Time Flag',

		CONVERT(date,ORDERING_DATE)									AS 'Order Date',

		eap.PROC_NAME												AS 'Procedure Name',
		eap.PROC_CODE												AS 'Procedure Code',
		eap.PROC_CAT_ID												AS 'ProcCatID',
		cat.PROC_CAT_NAME											AS 'Procedure Category',

		oproc2.ORDER_SOURCE_C										AS 'Order Source Code',
		ZCOSource.NAME												AS 'Order Source',

		opinfo.PAT_ENC_CSN_ID										AS 'OrdPatCsnID',
		opinfo.PARENT_ORDER_ID										AS 'ParentOrderID',
		opinfo.ORD_LOGIN_DEP_ID										AS 'OrderDeptID',
		opinfo.PAT_CONTACT_DEP_ID									AS 'OrderPatContactDeptID',

		patenc.PAT_ID												AS 'OrdPatID',
		CONVERT(date, patenc.CONTACT_DATE)							AS 'Order Contact Date',

		ZCPatC.NAME													AS 'Order Patient Class',
		omet.ORDERING_USER_ID										AS 'OrderUserID',
		orcase.CASE_ID												AS 'CaseID',          
		orcase.LINE													AS 'Case Line',

		apsrl.LINE													AS 'OrderAppt Line',
		apsrl.APPTS_SCHEDULED										AS 'ApptID',
		patenc.APPT_SERIAL_NO										AS 'ApptSerialID',
		patenc.PAT_ENC_CSN_ID										AS 'ApptPatCsnID',
		patenc.HSP_ACCOUNT_ID										AS 'HardID',
		patenc.PAT_ID												AS 'ApptPatID',
		patenc.DEPARTMENT_ID										AS 'ApptDeptID',
		cDep.DEPARTMENT_NAME										AS 'Appt Department',
		cDep.SPECIALTY												AS 'Appt Specialty',
		cDep.REV_LOC_ID												AS 'ApptLocID',
		patenc.VISIT_PROV_ID										AS 'VisitProvID',
		cSer.PROV_NAME												AS 'Appt ModalApity',
		ZCModT.NAME													AS 'Modality',
		CONVERT(date,patenc.CONTACT_DATE)							AS 'Appt Contact Date',
		patenc.APPT_STATUS_C										AS 'Appt Status Code',
		ZCApptS.NAME												AS 'Appt Status',
		CONVERT(datetime,patenc.APPT_TIME)                          AS 'Appt Time',
		ZCPatC.NAME													AS 'Appt Patient Class',
		
		patinfo.EVENT_ID											AS 'EventID'
		
											
	

	FROM ORDER_PROC oproc
		LEFT JOIN CLARITY_EAP eap
			ON oproc.PROC_ID = eap.PROC_ID
		
		INNER JOIN (
			SELECT 
			PROC_CAT_ID,
			PROC_CAT_NAME

			FROM EDP_PROC_CAT_INFO edp

			WHERE left(edp.PROC_CAT_NAME,3) = 'IMG' AND left(edp.PROC_CAT_NAME,6) <> 'IMG OB' 
		) cat
			ON cat.PROC_CAT_ID = eap.PROC_CAT_ID
		
		LEFT JOIN CLARITY_SER cSer										  
			ON cSer.PROV_ID = oproc.AUTHRZING_PROV_ID
		
		LEFT JOIN ZC_MODALITY_TYPE ZCModT								  
			ON ZCModT.MODALITY_TYPE_C = cSer.MODALITY_TYPE_C
		
		LEFT JOIN ZC_REF_PROV_TYPE ZCRefPT								  
			ON ZCRefPT.REF_PROV_TYPE_C = cSer.REFERRAL_SOURCE_TYPE_C
		
		LEFT JOIN ZC_ORDER_STATUS ZCOrderS								  
			ON ZCOrderS.ORDER_STATUS_C = oproc.ORDER_STATUS_C
		
		LEFT JOIN ZC_LAB_STATUS ZCLab									  
			ON ZCLab.LAB_STATUS_C = oproc.LAB_STATUS_C
		
		LEFT JOIN ZC_ORDER_TYPE ZCOrderT								  
			ON ZCOrderT.ORDER_TYPE_C = oproc.ORDER_TYPE_C
		
		LEFT JOIN ZC_RADIOLOGY_STS ZCRadioS								  
			ON ZCRadioS.RADIOLOGY_STATUS_C = oproc.RADIOLOGY_STATUS_C
		
		LEFT JOIN ZC_ORDER_CLASS ZCOrderC							      
			ON ZCOrderC.ORDER_CLASS_C = oproc.ORDER_CLASS_C
		
		LEFT JOIN ORDER_PROC_2 oproc2                                     
			ON oproc2.ORDER_PROC_ID = oproc.ORDER_PROC_ID
		
		LEFT JOIN ZC_ORDER_SOURCE ZCOSource									
			ON ZCOSource.ORDER_SOURCE_C = oproc2.ORDER_SOURCE_C
	-- Ordering Contact --
		
		LEFT JOIN ORDER_PARENT_INFO opinfo                                
			ON opinfo.ORDER_ID = oproc.ORDER_PROC_ID 
		
		LEFT JOIN PAT_ENC patenc                                          
			ON patenc.PAT_ENC_CSN_ID = opinfo.PAT_ENC_CSN_ID
		
		LEFT JOIN CLARITY_DEP cDep
			ON cDep.DEPARTMENT_ID = patenc.DEPARTMENT_ID
		
		LEFT JOIN ZC_APPT_STATUS ZCApptS
			ON ZCApptS.APPT_STATUS_C = patenc.APPT_STATUS_C
		
		LEFT JOIN PAT_ENC_2 patenc2                                       
			ON patenc2.PAT_ENC_CSN_ID = patenc.PAT_ENC_CSN_ID -- Or opinfo
		
		LEFT JOIN ZC_PAT_CLASS ZCPatC
			ON ZCPatC.ADT_PAT_CLASS_C = patenc2.ADT_PAT_CLASS_C 
		
		LEFT JOIN ORDER_METRICS omet                                      
			ON omet.ORDER_ID = opinfo.ORDER_ID
	-- Cases --
		
		LEFT JOIN OR_CASE_ORDER_IDS orcase                                
			ON orcase.ORDER_ID = opinfo.ORDER_ID
		
		LEFT JOIN OR_CASE orc                                             
			ON orc.OR_CASE_ID = orcase.CASE_ID
	-- Appointment Contact --
		
		LEFT JOIN ORD_APPT_SRL_NUM apsrl                                  -- One to many -- Separate CTE    
			ON apsrl.ORDER_PROC_ID = oproc.ORDER_PROC_ID
	-- Events --	

		LEFT JOIN ED_IEV_PAT_INFO patinfo								  -- One to many
			ON patinfo.PAT_CSN = oproc.PAT_ENC_CSN_ID
		
		WHERE CONVERT(date, PROC_END_TIME) >= '4-1-2017'
)
,
eventinfo AS (

	SELECT 
		EVENT_ID,
		MAX(EVENT_TIME) AS 'Check In Time' 

	FROM ED_IEV_EVENT_INFO evinfo
	WHERE EVENT_TYPE = '600'
	GROUP BY EVENT_ID
) 
SELECT *
FROM orderinfo
LEFT JOIN eventinfo														    -- Multiple Event_ID and Check In Time per OrderID
		ON eventinfo.EVENT_ID = EVENT_ID











/*LEFT JOIN ED_IEV_PAT_INFO patinfo
	ON patinfo.EVENT_ID = orderinfo
LEFT JOIN ED_IEV_EVENT_INFO evinfo
	ON evinfo.*/
-- Appointment Contact --
/*WITH Ord AS (
	SELECT *
	FROM ORD_APPT_SRL_NUM
)
	SELECT 
		ORDER_PROC_ID,
		LINE,
		APPTS_SCHEDULED
	FROM ORD_APPT_SRL_NUM;

WITH Appt AS (
	SELECT *
	FROM PAT_ENC
)
	SELECT 
		patenc.APPT_SERIAL_NO,
		patenc.PAT_ENC_CSN_ID,
		patenc.HSP_ACCOUNT_ID,
		patenc.PAT_ID,
		patenc.DEPARTMENT_ID,
		patenc.VISIT_PROV_ID,
		CONVERT(date, patenc.CONTACT_DATE),
		patenc.APPT_STATUS_C,
		CONVERT(time, patenc.APPT_TIME),

		patenc2.ADT_PAT_CLASS_C
	FROM PAT_ENC patenc
	LEFT JOIN PAT_ENC_2 patenc2
		ON patenc2.PAT_ENC_CSN_ID =patenc.PAT_ENC_CSN_ID;

-- Events --
WITH EvPat AS (
	SELECT *
	FROM ED_IEV_PAT_INFO
)
	SELECT 
		edpat.EVENT_ID,
		edpat.PAT_CSN,

		CONVERT(date,MAX(edevent.EVENT_TIME)) AS Date MAX(EVENT_TIME) AS Max_Event
	FROM ED_IEV_PAT_INFO edpat
	LEFT JOIN ED_IEV_EVENT_INFO edevent 
		ON edevent.EVENT_ID = edpat.EVENT_ID
		WHERE EVENT_TYPE = '600' 
		GROUP BY edpat.EVENT_ID*/