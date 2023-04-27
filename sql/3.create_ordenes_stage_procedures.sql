--------------------------------------------------------
--  DDL for Procedure LOAD_DIM_CUSTOMERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_DIM_CUSTOMERS" IS

  -- VARIABLES GENERALES
--DECLARE 
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_DIM_CUSTOMERS';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO

  -- VARIABLES DEL PROCESO

  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO



    FOR V_REG IN ( SELECT
                        CUSTOMER_IDW, CUSTOMER_ID, NAME, CONTACT_NAME, CONTACT_TITLE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, PHONE, FAX, CURRENT_FLAG, START_DATE, END_DATE
                        -- CREATED_DW, UPDATED_DW, USER_DW
                   FROM STG_DIM_customers
                   MINUS
                   SELECT 
                        CUSTOMER_IDW, CUSTOMER_ID, NAME, CONTACT_NAME, CONTACT_TITLE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, PHONE, FAX, CURRENT_FLAG, START_DATE, END_DATE
                        -- CREATED_DW, UPDATED_DW, USER_DW
                   FROM ordenes_star.DIM_CUSTOMERS)
LOOP

         IF V_REG.CUSTOMER_IDW != -99999 THEN

            UPDATE  ordenes_star.DIM_CUSTOMERS
            SET  
                CUSTOMER_ID = V_REG.CUSTOMER_ID, 
                NAME = V_REG.NAME, 
                CONTACT_NAME =  V_REG.CONTACT_NAME, 
                CONTACT_TITLE = V_REG.CONTACT_TITLE, 
                ADDRESS = V_REG.ADDRESS, 
                CITY = V_REG.CITY, 
                REGION = V_REG.REGION, 
                POSTALCODE = V_REG.POSTALCODE, 
                COUNTRY = V_REG.COUNTRY, 
                PHONE = V_REG.PHONE, 
                FAX = V_REG.FAX, 
                CURRENT_FLAG = V_REG.CURRENT_FLAG
            WHERE CUSTOMER_IDW = V_REG.CUSTOMER_IDW       ;

            COMMIT;
            V_TOTAL_DIFERENCIAS := V_TOTAL_DIFERENCIAS+1;
       END IF;

END LOOP ;



/************ SI NO EXISTE DIFERENCIAS SIGNIFICA QUE EXISTEN NUEVOS REGISTROS ***/
    INSERT /*+ NOLOGGING APPEND */ INTO ordenes_star.DIM_CUSTOMERS 
    (
        -- CUSTOMER_IDW, 
        CUSTOMER_ID, NAME, CONTACT_NAME, CONTACT_TITLE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, PHONE, FAX, CURRENT_FLAG, START_DATE, END_DATE, CREATED_DW, UPDATED_DW, USER_DW)
    SELECT 
        -- CUSTOMER_IDW, 
        CUSTOMER_ID, NAME, CONTACT_NAME, CONTACT_TITLE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, PHONE, FAX, CURRENT_FLAG, START_DATE, END_DATE, 
           CREATED_DW, UPDATED_DW, USER_DW
    FROM STG_DIM_CUSTOMERS
    WHERE CUSTOMER_IDW = -99999;
    V_CANT_REG := SQL%ROWCOUNT; 
    COMMIT;

  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' ESTA OK ACTUALIZADOS :'||V_TOTAL_DIFERENCIAS ||' NUEVOS : ' ||V_CANT_REG;
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_DIM_EMPLOYEES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_DIM_EMPLOYEES" IS

  -- VARIABLES GENERALES
--DECLARE 
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_DIM_EMPLOYEES';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
  V_VFILENAME        VARCHAR2(30);
  V_FONO_SMS         VARCHAR2(10) := 'XXXXX';

  -- VARIABLES DEL PROCESO

  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO


    FOR V_REG IN ( 
        SELECT DISTINCT 
            EMPLOYEE_IDW, EMPLOYEE_ID, LAST_NAME, FIRST_NAME, TITLE, TITLE_OF_COURTESY, BIRTH_DATE, HIRE_DATE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, HOME_PHONE, EXTENSION, NOTES, REPORTS_TO, CREATED_DW, UPDATED_DW, USER_DW
        FROM  ordenes_stage.STG_DIM_EMPLOYEES
        MINUS
        SELECT DISTINCT
            EMPLOYEE_IDW, EMPLOYEE_ID, LAST_NAME, FIRST_NAME, TITLE, TITLE_OF_COURTESY, BIRTH_DATE, HIRE_DATE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, HOME_PHONE, EXTENSION, NOTES, REPORTS_TO, CREATED_DW, UPDATED_DW, USER_DW
        FROM ordenes_star.DIM_EMPLOYEES
    )
LOOP


      IF V_REG.EMPLOYEE_IDW != -99999 THEN

        UPDATE  ordenes_star.DIM_EMPLOYEES
        SET  
            -- EMPLOYEE_ID, 
            LAST_NAME = V_REG.LAST_NAME, 
            FIRST_NAME = V_REG.FIRST_NAME, 
            TITLE = V_REG.TITLE, 
            TITLE_OF_COURTESY = V_REG.TITLE_OF_COURTESY, 
            BIRTH_DATE = V_REG.BIRTH_DATE, 
            HIRE_DATE = V_REG.HIRE_DATE, 
            ADDRESS = V_REG.ADDRESS, 
            CITY = V_REG.CITY, 
            REGION = V_REG.REGION, 
            POSTALCODE = V_REG.POSTALCODE, 
            COUNTRY = V_REG.COUNTRY, 
            HOME_PHONE = V_REG.HOME_PHONE, 
            EXTENSION = V_REG.EXTENSION, 
            NOTES = V_REG.NOTES, 
            REPORTS_TO = V_REG.REPORTS_TO,
            USER_DW  = V_REG.USER_DW,
            UPDATED_DW = V_REG.UPDATED_DW
          WHERE EMPLOYEE_IDW = V_REG.EMPLOYEE_IDW ;
        COMMIT;
    V_TOTAL_DIFERENCIAS := V_TOTAL_DIFERENCIAS+1;
    END IF ;

END LOOP ;

    INSERT INTO ordenes_star.DIM_EMPLOYEES
    (
        -- EMPLOYEE_IDW, 
        EMPLOYEE_ID, LAST_NAME, FIRST_NAME, TITLE, TITLE_OF_COURTESY, BIRTH_DATE, HIRE_DATE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, HOME_PHONE, EXTENSION, NOTES, REPORTS_TO, CREATED_DW, UPDATED_DW, USER_DW
    )
    SELECT 
       -- EMPLOYEE_IDW, 
       EMPLOYEE_ID, LAST_NAME, FIRST_NAME, TITLE, TITLE_OF_COURTESY, BIRTH_DATE, HIRE_DATE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, HOME_PHONE, EXTENSION, NOTES, REPORTS_TO, CREATED_DW, UPDATED_DW, USER_DW
    FROM ordenes_stage.STG_DIM_EMPLOYEES
    WHERE EMPLOYEE_IDW = -99999;

    V_CANT_REG := SQL%ROWCOUNT;
    COMMIT;


  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' ESTA OK ACTUALIZADOS :'||V_TOTAL_DIFERENCIAS ||' NUEVOS : ' ||V_CANT_REG;
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;
     RAISE;

END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_DIM_GEOGRAFIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_DIM_GEOGRAFIA" IS

  -- VARIABLES GENERALES
--DECLARE 
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'ETL_DIM_GEOGRAFIA';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
  V_VFILENAME        VARCHAR2(30);
  V_FONO_SMS         VARCHAR2(10) := 'XXXXX';

  -- VARIABLES DEL PROCESO

  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO


    FOR V_REG IN ( 
        SELECT  GEOGRAFIA_IDW, CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW
        FROM  ordenes_stage.STG_DIM_GEOGRAFIA
        MINUS
        SELECT  GEOGRAFIA_IDW, CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW
        FROM ordenes_star.DIM_GEOGRAFIA
    )
LOOP


      IF V_REG.GEOGRAFIA_IDW != -99999 THEN

        UPDATE  ordenes_star.DIM_GEOGRAFIA
        SET  CITY = V_REG.CITY
            ,REGION = V_REG.REGION
            ,POSTALCODE = V_REG.POSTALCODE
            ,COUNTRY = V_REG.COUNTRY
            ,USER_DWH = V_REG.USER_DWH
            ,UPDATED_DW = V_REG.UPDATED_DW
          WHERE GEOGRAFIA_IDW = V_REG.GEOGRAFIA_IDW ;
        COMMIT;
    V_TOTAL_DIFERENCIAS := V_TOTAL_DIFERENCIAS+1;
    END IF ;

END LOOP ;

    INSERT INTO ordenes_star.DIM_GEOGRAFIA 
    (CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW)
    SELECT CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW
    FROM ordenes_stage.STG_DIM_GEOGRAFIA
    WHERE GEOGRAFIA_IDW = -99999;

    V_CANT_REG := SQL%ROWCOUNT;
    COMMIT;


  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' ESTA OK ACTUALIZADOS :'||V_TOTAL_DIFERENCIAS ||' NUEVOS : ' ||V_CANT_REG;
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;
     RAISE;


END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_DIM_PRODUCTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_DIM_PRODUCTS" IS

  -- VARIABLES GENERALES
--DECLARE 
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_DIM_PRODUCTS';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
  V_VFILENAME        VARCHAR2(30);
  V_FONO_SMS         VARCHAR2(10) := 'XXXXX';

  -- VARIABLES DEL PROCESO

  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO


    FOR V_REG IN ( 
        SELECT DISTINCT 
            PRODUCT_IDW,
            PRODUCT_ID,
            NAME,
            QUANTITY_PER_UNIT,
            UNIT_PRICE,
            UNITS_IN_STOCK,
            UNITS_ON_ORDER,
            REORDER_LEVEL,
            DISCONTINUED,
            CATEGORY_ID,
            CATEGORY_NAME,
            CATEGORY_DESCRIPTION,
            SUPPLIER_ID,
            SUPPLIER_NAME,
            SUPPLIER_CONTACT,
            SUPPLIER_TITLE,
            ADDRESS,
            CITY,
            REGION,
            POSTALCODE,
            COUNTRY,
            PHONE,
            FAX,
            USER_DW, 
            CREATED_DW, 
            UPDATED_DW
        FROM  ordenes_stage.STG_DIM_PRODUCTS
        MINUS
        SELECT DISTINCT
            PRODUCT_IDW,
            PRODUCT_ID,
            NAME,
            QUANTITY_PER_UNIT,
            UNIT_PRICE,
            UNITS_IN_STOCK,
            UNITS_ON_ORDER,
            REORDER_LEVEL,
            DISCONTINUED,
            CATEGORY_ID,
            CATEGORY_NAME,
            CATEGORY_DESCRIPTION,
            SUPPLIER_ID,
            SUPPLIER_NAME,
            SUPPLIER_CONTACT,
            SUPPLIER_TITLE,
            ADDRESS,
            CITY,
            REGION,
            POSTALCODE,
            COUNTRY,
            PHONE,
            FAX,
            USER_DW, 
            CREATED_DW, 
            UPDATED_DW
        FROM ordenes_star.DIM_PRODUCTS
    )
LOOP


      IF V_REG.PRODUCT_IDW != -99999 THEN

        UPDATE  ordenes_star.DIM_PRODUCTS
        SET  PRODUCT_ID = V_REG.PRODUCT_ID,
            NAME = V_REG.NAME,
            QUANTITY_PER_UNIT = V_REG.QUANTITY_PER_UNIT,
            UNIT_PRICE = V_REG.UNIT_PRICE,
            UNITS_IN_STOCK = V_REG.UNITS_IN_STOCK,
            UNITS_ON_ORDER = V_REG.UNITS_ON_ORDER,
            REORDER_LEVEL = V_REG.REORDER_LEVEL,
            DISCONTINUED = V_REG.DISCONTINUED,
            CATEGORY_ID = V_REG.CATEGORY_ID,
            CATEGORY_NAME = V_REG.CATEGORY_NAME,
            CATEGORY_DESCRIPTION = V_REG.CATEGORY_DESCRIPTION,
            SUPPLIER_ID = V_REG.SUPPLIER_ID,
            SUPPLIER_NAME = V_REG.SUPPLIER_NAME,
            SUPPLIER_CONTACT = V_REG.SUPPLIER_CONTACT,
            SUPPLIER_TITLE = V_REG.SUPPLIER_TITLE,
            ADDRESS = V_REG.ADDRESS,
            CITY = V_REG.CITY,
            REGION = V_REG.REGION,
            POSTALCODE = V_REG.POSTALCODE,
            COUNTRY = V_REG.COUNTRY,
            PHONE = V_REG.PHONE,
            FAX = V_REG.FAX,
            USER_DW  = V_REG.USER_DW,
            UPDATED_DW = V_REG.UPDATED_DW
          WHERE PRODUCT_IDW = V_REG.PRODUCT_IDW ;
        COMMIT;
    V_TOTAL_DIFERENCIAS := V_TOTAL_DIFERENCIAS+1;
    END IF ;

END LOOP ;

    INSERT INTO ordenes_star.DIM_PRODUCTS
    (
        -- PRODUCT_IDW,
        PRODUCT_ID,
        NAME,
        QUANTITY_PER_UNIT,
        UNIT_PRICE,
        UNITS_IN_STOCK,
        UNITS_ON_ORDER,
        REORDER_LEVEL,
        DISCONTINUED,
        CATEGORY_ID,
        CATEGORY_NAME,
        CATEGORY_DESCRIPTION,
        SUPPLIER_ID,
        SUPPLIER_NAME,
        SUPPLIER_CONTACT,
        SUPPLIER_TITLE,
        ADDRESS,
        CITY,
        REGION,
        POSTALCODE,
        COUNTRY,
        PHONE,
        FAX,
        USER_DW, 
        CREATED_DW, 
        UPDATED_DW
    )
    SELECT 
        -- PRODUCT_IDW,
        PRODUCT_ID,
        NAME,
        QUANTITY_PER_UNIT,
        UNIT_PRICE,
        UNITS_IN_STOCK,
        UNITS_ON_ORDER,
        REORDER_LEVEL,
        DISCONTINUED,
        CATEGORY_ID,
        CATEGORY_NAME,
        CATEGORY_DESCRIPTION,
        SUPPLIER_ID,
        SUPPLIER_NAME,
        SUPPLIER_CONTACT,
        SUPPLIER_TITLE,
        ADDRESS,
        CITY,
        REGION,
        POSTALCODE,
        COUNTRY,
        PHONE,
        FAX,
        USER_DW, 
        CREATED_DW, 
        UPDATED_DW
    FROM ordenes_stage.STG_DIM_PRODUCTS
    WHERE PRODUCT_IDW = -99999;

    V_CANT_REG := SQL%ROWCOUNT;
    COMMIT;


  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' ESTA OK ACTUALIZADOS :'||V_TOTAL_DIFERENCIAS ||' NUEVOS : ' ||V_CANT_REG;
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;
     RAISE;

END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_DIM_SHIPPERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_DIM_SHIPPERS" IS

  -- VARIABLES GENERALES
--DECLARE 
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'ETL_DIM_GEOGRAFIA';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
  V_VFILENAME        VARCHAR2(30);
  V_FONO_SMS         VARCHAR2(10) := 'XXXXX';

  -- VARIABLES DEL PROCESO

  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO


    FOR V_REG IN ( 
        SELECT DISTINCT SHIPPER_IDW, SHIPPER_ID, NAME, PHONE, USER_DW, CREATED_DW, UPDATED_DW
        FROM  ordenes_stage.STG_DIM_SHIPPERS
        MINUS
        SELECT DISTINCT SHIPPER_IDW, SHIPPER_ID, NAME, PHONE, USER_DW, CREATED_DW, UPDATED_DW
        FROM ordenes_star.DIM_SHIPPERS
    )
LOOP


      IF V_REG.SHIPPER_IDW != -99999 THEN

        UPDATE  ordenes_star.DIM_SHIPPERS
        SET  SHIPPER_ID = V_REG.SHIPPER_ID
            ,NAME = V_REG.NAME
            ,PHONE = V_REG.PHONE
            ,USER_DW = V_REG.USER_DW
            ,UPDATED_DW = V_REG.UPDATED_DW
          WHERE SHIPPER_IDW = V_REG.SHIPPER_IDW ;
        COMMIT;
    V_TOTAL_DIFERENCIAS := V_TOTAL_DIFERENCIAS+1;
    END IF ;

END LOOP ;

    INSERT INTO ordenes_star.DIM_SHIPPERS
    (SHIPPER_ID, NAME, PHONE, USER_DW, CREATED_DW, UPDATED_DW)
    SELECT SHIPPER_ID, NAME, PHONE, USER_DW, CREATED_DW, UPDATED_DW
    FROM ordenes_stage.STG_DIM_SHIPPERS
    WHERE SHIPPER_IDW = -99999;

    V_CANT_REG := SQL%ROWCOUNT;
    COMMIT;


  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' ESTA OK ACTUALIZADOS :'||V_TOTAL_DIFERENCIAS ||' NUEVOS : ' ||V_CANT_REG;
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;
     RAISE;

END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_DIM_TIEMPO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_DIM_TIEMPO" IS

  -- VARIABLES GENERALES
--DECLARE
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'ETL_DIM_TIEMPO';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO 	   	 VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
    -- VARIABLES DEL PROCESO

  v_total_diferencias	 NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO


    -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ordenes_stage.ETL_DIM_TIEMPO';
    INSERT /*+ NOLOGGING APPEND */ 
    INTO ordenes_star.DIM_TIEMPO 
    (FECHA, DIA, DIA_SEMANA_CORTO, DIA_SEMANA, DIA_LABORAL, DIA_FERIADO, SEMANA_MES, SEMANA_ANIO, MES, MES_CADENA, PERIODO, TRIMESTRE, SEMESTRE, ANIO, USER_DW, CREATED_DW, UPDATED_DW)
    SELECT 
        FECHA, 
        DIA, 
        DIA_SEMANA_CORTO, 
        DIA_SEMANA, 
        DIA_LABORAL, 
        DIA_FERIADO, 
        SEMANA_MES, 
        SEMANA_ANIO, 
        MES, 
        MES_CADENA, 
        PERIODO, 
        TRIMESTRE, 
        SEMESTRE, 
        ANIO, 
        USER_DW, 
        CREATED_DW, 
        UPDATED_DW
    FROM ordenes_stage.STG_DIM_TIEMPO;

    V_CANT_REG:= SQL%ROWCOUNT;
    COMMIT;



  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
             		   v_fec_inicio,
                       v_fec_fin,
		        	   v_comentario,
		   			   v_cant_reg,
	  	        	   v_correcto )
					   ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_FACT_ORDERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_FACT_ORDERS" (PI_FECHA_INICIAL VARCHAR2, PI_FECHA_FINAL VARCHAR2)  IS

  -- VARIABLES GENERALES
--DECLARE
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_FACT_ORDERS';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO

  -- VARIABLES DEL PROCESO
  V_FECHA_INICIO DATE;
  V_FECHA_FIN DATE;
  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  V_FECHA_INICIO :=TO_DATE(PI_FECHA_INICIAL,'YYYYMMDD');
  V_FECHA_FIN    :=TO_DATE(PI_FECHA_FINAL,'YYYYMMDD');
  -- CODIGO DEL PROCESO

--   EXECUTE IMMEDIATE 'TRUNCATE TABLE  STAR.FACT_VENTA PARTITION(P20191019)  '
    DELETE FROM ordenes_star.fact_orders
    WHERE ORDER_DATE BETWEEN V_FECHA_INICIO AND V_FECHA_FIN;
    commit;
-- EXECUTE IMMEDIATE ('ALTER TABLE FACT_VENTAS TRUNCATE PARTITION P' || PI_FECHA_INICIAL ) ; 
    INSERT /*+ NOLOGGING APPEND*/ INTO 
    ordenes_star.fact_orders 
    (
        ORDER_DATE, USER_DW, CREATED_DW, UPDATED_DW, REQUIRED_DATE, SHIPPED_DATE, SHIP_VIA, SHIP_NAME, UNIT_PRICE, QUANTITY, DISCOUNT, CUSTOMER_IDW, EMPLOYEE_IDW, PRODUCT_IDW, SHIPPER_IDW, GEOGRAFIA_IDW
    )
    SELECT ORDER_DATE, USER_DW, CREATED_DW, UPDATED_DW, REQUIRED_DATE, SHIPPED_DATE, SHIP_VIA, SHIP_NAME, UNIT_PRICE, QUANTITY, DISCOUNT, CUSTOMER_IDW, EMPLOYEE_IDW, PRODUCT_IDW, SHIPPER_IDW, GEOGRAFIA_IDW
    FROM STG_FACT_ORDERS;

    V_CANT_REG:= SQL%ROWCOUNT;
    COMMIT;

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;



END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_DIM_CUSTOMERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_DIM_CUSTOMERS" IS

  -- VARIABLES GENERALES
--DECLARE 
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_DIM_CUSTOMERS';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
    -- VARIABLES DEL PROCESO

  v_total_diferencias    NUMBER(10) := 0;

BEGIN
  v_fec_inicio := SYSDATE;

  -- CODIGO DEL PROCESO


    EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_DIM_CUSTOMERS';

    INSERT INTO STG_DIM_CUSTOMERS 
    (
        CUSTOMER_IDW, CUSTOMER_ID, NAME, CONTACT_NAME, CONTACT_TITLE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, PHONE, FAX, CURRENT_FLAG, START_DATE, END_DATE, CREATED_DW, UPDATED_DW, USER_DW
    )
    SELECT 
        NVL(g.CUSTOMER_IDW, -99999) AS CUSTOMER_IDW, 
        NVL(p.CUSTOMERID, -99999) CUSTOMER_ID, 
        p.COMPANYNAME, 
        p.CONTACTNAME, 
        p.CONTACTTITLE, 
        p.ADDRESS, 
        p.CITY, 
        p.REGION, 
        p.POSTALCODE, 
        p.COUNTRY, 
        p.PHONE, 
        p.FAX, 
        1 CURRENT_FLAG, 
        SYSDATE START_DATE, 
        SYSDATE END_DATE, 
        SYSDATE CREATED_DW, 
        SYSDATE UPDATED_DW, 
        Sys_Context('USERENV','OS_USER') USER_DW
    from ordenes.customers p
    LEFT JOIN ordenes_star.DIM_CUSTOMERS g ON 
            NVL(p.CUSTOMERID, -99999) = NVL(g.CUSTOMER_ID, -99999)
    ;

     V_CANT_REG := SQL%ROWCOUNT;
    COMMIT;




  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
                       v_fec_inicio,
                       v_fec_fin,
                       v_comentario,
                       v_cant_reg,
                       v_correcto )
                       ;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
                          v_fec_inicio,
                          v_fec_fin,
                          v_comentario,
                          v_cant_reg,
                          v_correcto )
                          ;
     COMMIT  ;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_DIM_EMPLOYEES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_DIM_EMPLOYEES" IS
    V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_DIM_EMPLOYEES';
    V_FEC_INICIO       DATE;
    V_FEC_FIN          DATE;
    V_COMENTARIO       VARCHAR2(255);
    V_CANT_REG         NUMBER(10)  := 0;
    V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO

    v_total_diferencias    NUMBER(10) := 0;

BEGIN
    v_fec_inicio := SYSDATE;

    -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ordenes_stage.STG_DIM_SHIPPERS';
    INSERT INTO ordenes_stage.STG_DIM_EMPLOYEES
    (   
        EMPLOYEE_IDW, EMPLOYEE_ID, LAST_NAME, FIRST_NAME, TITLE, TITLE_OF_COURTESY, BIRTH_DATE, HIRE_DATE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY, HOME_PHONE, EXTENSION, NOTES, REPORTS_TO, CREATED_DW, UPDATED_DW, USER_DW
    )
    SELECT distinct
        NVL(g.EMPLOYEE_IDW, -99999) AS EMPLOYEE_IDW,
        p.EMPLOYEEID, 
        p.LASTNAME, 
        p.FIRSTNAME, 
        p.TITLE, 
        p.TITLEOFCOURTESY, 
        p.BIRTHDATE, 
        p.HIREDATE, 
        p.ADDRESS, 
        p.CITY, 
        p.REGION, 
        p.POSTALCODE, 
        p.COUNTRY, 
        p.HOMEPHONE, 
        p.EXTENSION, 
        p.NOTES, 
        p.REPORTSTO,
        SYSDATE CREATED_DW,
        SYSDATE UPDATED_DW,
        Sys_Context('USERENV','OS_USER') USER_DW
    -- SELECT *
    FROM ordenes.EMPLOYEES  p
        LEFT JOIN ordenes_star.DIM_EMPLOYEES g ON 
            NVL(p.EMPLOYEEID, -99999) = NVL(g.EMPLOYEE_ID, -99999)
    ;

    V_CANT_REG:= SQL%ROWCOUNT;
    COMMIT;

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_INSERTAR_INFO_PROC(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_INSERTAR_INFO_PROC(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;
     RAISE;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_DIM_GEOGRAFIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_DIM_GEOGRAFIA" IS
    V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_DIM_GEOGRAFIA';
    V_FEC_INICIO       DATE;
    V_FEC_FIN          DATE;
    V_COMENTARIO       VARCHAR2(255);
    V_CANT_REG         NUMBER(10)  := 0;
    V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO

    v_total_diferencias    NUMBER(10) := 0;

BEGIN
    v_fec_inicio := SYSDATE;

    -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ordenes_stage.PRE_STG_GEOGRAFIA';

    -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ordenes_stage.STG_DIM_GEOGRAFIA';

    INSERT INTO ordenes_stage.PRE_STG_GEOGRAFIA
    (CITY, REGION, POSTALCODE, COUNTRY)
    select distinct 
        CITY,
        REGION, 
        POSTALCODE,
        COUNTRY
    from ordenes.customers
    union
    select distinct 
        CITY,
        REGION, 
        POSTALCODE,
        COUNTRY
    from ordenes.employees
    union
    select distinct 
        SHIPCITY,
        SHIPREGION, 
        SHIPPOSTALCODE,
        SHIPCOUNTRY
    from ordenes.orders
    union
    select distinct 
        CITY,
        REGION, 
        POSTALCODE,
        COUNTRY
    from ordenes.suppliers;
    COMMIT;


    INSERT INTO ordenes_stage.STG_DIM_GEOGRAFIA
    (GEOGRAFIA_IDW, CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW)
    SELECT distinct
        NVL(g.GEOGRAFIA_IDW, -99999) AS GEOGRAFIA_IDW,
        NVL(p.CITY, 'DEFAULT'),
        NVL(p.REGION, 'DEFAULT'),
        NVL(p.POSTALCODE, 'DEFAULT'),
        NVL(p.COUNTRY, 'DEFAULT'),
        Sys_Context('USERENV','OS_USER') USER_DWH,
        SYSDATE CREATED_DW,
        SYSDATE UPDATED_DW
    FROM ordenes_stage.PRE_STG_GEOGRAFIA p
        LEFT JOIN ordenes_star.DIM_GEOGRAFIA g ON NVL(p.CITY, 'DEFAULT') = NVL(g.CITY, 'DEFAULT')
            AND NVL(p.REGION, 'DEFAULT') = NVL(g.REGION, 'DEFAULT')
            AND NVL(p.POSTALCODE, 'DEFAULT') = NVL(g.POSTALCODE, 'DEFAULT')
            AND NVL(p.COUNTRY, 'DEFAULT') = NVL(g.COUNTRY, 'DEFAULT')
    ;

    V_CANT_REG:= SQL%ROWCOUNT;
    COMMIT;

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_DIM_PRODUCTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_DIM_PRODUCTS" IS
    V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_DIM_PRODUCTS';
    V_FEC_INICIO       DATE;
    V_FEC_FIN          DATE;
    V_COMENTARIO       VARCHAR2(255);
    V_CANT_REG         NUMBER(10)  := 0;
    V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO

    v_total_diferencias    NUMBER(10) := 0;

BEGIN
    v_fec_inicio := SYSDATE;

    -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ordenes_stage.STG_DIM_SHIPPERS';
    INSERT INTO ordenes_stage.PRE_STG_PRODUCTS
    (   PRODUCT_ID,
        NAME,
        QUANTITY_PER_UNIT,
        UNIT_PRICE,
        UNITS_IN_STOCK,
        UNITS_ON_ORDER,
        REORDER_LEVEL,
        DISCONTINUED,
        CATEGORY_ID,
        CATEGORY_NAME,
        CATEGORY_DESCRIPTION,
        SUPPLIER_ID,
        SUPPLIER_NAME,
        SUPPLIER_CONTACT,
        SUPPLIER_TITLE,
        ADDRESS,
        CITY,
        REGION,
        POSTALCODE,
        COUNTRY,
        PHONE,
        FAX
    )
    SELECT 
        P.PRODUCTID PRODUCT_ID,
        P.PRODUCTNAME NAME,
        P.QUANTITYPERUNIT QUANTITY_PER_UNIT,
        P.UNITPRICE UNIT_PRICE,
        P.UNITSINSTOCK UNITS_IN_STOCK,
        P.UNITSONORDER UNITS_ON_ORDER,
        P.REORDERLEVEL REORDER_LEVEL,
        P.DISCONTINUED,
        C.CATEGORYID CATEGORY_ID,
        C.CATEGORYNAME CATEGORY_NAME,
        C.DESCRIPTION CATEGORY_DESCRIPTION,
        S.SUPPLIERID SUPPLIER_ID,
        S.COMPANYNAME SUPPLIER_NAME,
        S.CONTACTNAME SUPPLIER_CONTACT,
        S.CONTACTTITLE SUPPLIER_TITLE,
        S.ADDRESS,
        S.CITY,
        S.REGION,
        NVL(S.POSTALCODE, 'DEFAULT'),
        S.COUNTRY,
        S.PHONE,
        S.FAX
    FROM ORDENES.PRODUCTS P
        LEFT JOIN ORDENES.CATEGORIES C ON P.CATEGORYID = C.CATEGORYID
        LEFT JOIN ORDENES.SUPPLIERS S ON P.SUPPLIERID = S.SUPPLIERID
    ;


    INSERT INTO ordenes_stage.STG_DIM_PRODUCTS
    (   
        PRODUCT_IDW,
        PRODUCT_ID,
        NAME,
        QUANTITY_PER_UNIT,
        UNIT_PRICE,
        UNITS_IN_STOCK,
        UNITS_ON_ORDER,
        REORDER_LEVEL,
        DISCONTINUED,
        CATEGORY_ID,
        CATEGORY_NAME,
        CATEGORY_DESCRIPTION,
        SUPPLIER_ID,
        SUPPLIER_NAME,
        SUPPLIER_CONTACT,
        SUPPLIER_TITLE,
        ADDRESS,
        CITY,
        REGION,
        POSTALCODE,
        COUNTRY,
        PHONE,
        FAX,
        USER_DW, 
        CREATED_DW, 
        UPDATED_DW
    )
    SELECT distinct
        NVL(g.PRODUCT_IDW, -99999) AS PRODUCT_IDW,
        P.PRODUCT_ID,
        P.NAME,
        P.QUANTITY_PER_UNIT,
        P.UNIT_PRICE,
        P.UNITS_IN_STOCK,
        P.UNITS_ON_ORDER,
        P.REORDER_LEVEL,
        P.DISCONTINUED,
        P.CATEGORY_ID,
        P.CATEGORY_NAME,
        P.CATEGORY_DESCRIPTION,
        P.SUPPLIER_ID,
        P.SUPPLIER_NAME,
        P.SUPPLIER_CONTACT,
        P.SUPPLIER_TITLE,
        P.ADDRESS,
        P.CITY,
        P.REGION,
        NVL(P.POSTALCODE, 'DEFAULT'),
        P.COUNTRY,
        P.PHONE,
        P.FAX,
        Sys_Context('USERENV','OS_USER') USER_DWH,
        SYSDATE CREATED_DW,
        SYSDATE UPDATED_DW
    -- SELECT *
    FROM ordenes_stage.PRE_STG_PRODUCTS  p
        LEFT JOIN ordenes_star.DIM_PRODUCTS g ON 
            NVL(p.PRODUCT_ID, -99999) = NVL(g.PRODUCT_ID, -99999)
            AND  NVL(p.CATEGORY_ID, -99999) = NVL(g.CATEGORY_ID, -99999)
            AND  NVL(p.SUPPLIER_ID, -99999) = NVL(g.SUPPLIER_ID, -99999)
    ;

    V_CANT_REG:= SQL%ROWCOUNT;
    COMMIT;

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;
     RAISE;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_DIM_SHIPPERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_DIM_SHIPPERS" IS
    V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_DIM_SHIPPERS';
    V_FEC_INICIO       DATE;
    V_FEC_FIN          DATE;
    V_COMENTARIO       VARCHAR2(255);
    V_CANT_REG         NUMBER(10)  := 0;
    V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO

    v_total_diferencias    NUMBER(10) := 0;

BEGIN
    v_fec_inicio := SYSDATE;

    -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ordenes_stage.STG_DIM_SHIPPERS';

    INSERT INTO ordenes_stage.STG_DIM_SHIPPERS
    (SHIPPER_IDW, SHIPPER_ID, NAME, PHONE, USER_DW, CREATED_DW, UPDATED_DW)
    SELECT distinct
        NVL(g.SHIPPER_IDW, -99999) AS SHIPPER_IDW,
        NVL(p.SHIPPERID, -99999),
        NVL(p.COMPANYNAME, 'DEFAULT'),
        NVL(p.PHONE, 'DEFAULT'),
        Sys_Context('USERENV','OS_USER') USER_DWH,
        SYSDATE CREATED_DW,
        SYSDATE UPDATED_DW
    -- SELECT *
    FROM ordenes.SHIPPERS  p
        LEFT JOIN ordenes_star.DIM_SHIPPERS g ON 
            NVL(p.SHIPPERID, -99999) = NVL(g.SHIPPER_ID, -99999)
            AND NVL(p.COMPANYNAME, 'DEFAULT') = NVL(g.NAME, 'DEFAULT')
            AND NVL(p.PHONE, 'DEFAULT') = NVL(g.PHONE, 'DEFAULT')
    ;

    V_CANT_REG:= SQL%ROWCOUNT;
    COMMIT;

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso,
             			  v_fec_inicio,
                    	  v_fec_fin,
		        		  v_comentario,
		   				  v_cant_reg,
	  	        		  v_correcto )
						  ;
     COMMIT	 ;
END;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_DIM_TIEMPO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_DIM_TIEMPO" 
 as
    V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_DIM_TIEMPO';
    V_FEC_INICIO       DATE;
    V_FEC_FIN          DATE;
    V_COMENTARIO       VARCHAR2(255);
    V_CANT_REG         NUMBER(10)  := 0;
    V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
    V_VFILENAME        VARCHAR2(30);
    V_FECHA_MIN DATE;
    V_FECHA_MAX DATE;
    V_COUNT number;
    v_cantidad_dias number;

begin
    v_fec_inicio := SYSDATE;
    v_count:=0 ;

    select 
        max(orderdate) + 1 fecha_max ,
        min(orderdate) fecha_min ,
        max(orderdate) - min(orderdate) cantidad_dias
    INTO V_FECHA_MAX, V_FECHA_MIN, v_cantidad_dias
    from ordenes.orders; 


    FOR V_COUNT IN 0..v_cantidad_dias
    LOOP

        INSERT INTO ordenes_stage.STG_DIM_TIEMPO
        (FECHA, DIA, DIA_SEMANA_CORTO, DIA_SEMANA, DIA_LABORAL, DIA_FERIADO, SEMANA_MES, SEMANA_ANIO, MES, MES_CADENA, PERIODO, TRIMESTRE, SEMESTRE, ANIO, USER_DW, CREATED_DW, UPDATED_DW)
        select 
             trunc(V_FECHA_MIN + V_COUNT) fecha
            ,to_number(to_char(V_FECHA_MIN + V_COUNT,'dd')) dia
            ,substr(to_char(V_FECHA_MIN + V_COUNT,'Day'),1,3) dia_semana_corto
            ,to_char(V_FECHA_MIN + V_COUNT,'Day') dia_semena
            ,DECODE( substr(to_char(V_FECHA_MIN + V_COUNT+1,'Day'),1,3),'Sun','No','Sat','No','Si') dia_laboral
            ,decode(trunc(V_FECHA_MIN + V_COUNT)+10 , to_date('20130501','yyyymmdd'),'Si','No') dia_feriado 
            ,to_number(to_char(V_FECHA_MIN + V_COUNT,'w')) semana_mes
            ,to_number(to_char(V_FECHA_MIN + V_COUNT,'iW')) semana_anio
            ,to_number(to_char(V_FECHA_MIN + V_COUNT,'mm')) mes
            ,to_char(V_FECHA_MIN + V_COUNT,'Mon') mes_cadena
            ,to_char(V_FECHA_MIN + V_COUNT,'yyyymm') periodo
            ,to_char(V_FECHA_MIN + V_COUNT,'Q') trimestre
            , to_char(V_FECHA_MIN + V_COUNT,'Q') semestre
            ,to_number(to_char(V_FECHA_MIN + V_COUNT,'yyyy')) anio
            , SYS_CONTEXT('USERENV','OS_USER')
            , SYSDATE
            , SYSDATE
        from  dual;
        commit; 

    END LOOP;
 -- FIN CODIGO DEL PROCESO
    v_fec_fin    := SYSDATE;
    v_comentario := 'EL PROCESO '||v_nombre_proceso;
    v_correcto   := 'S';
    P_Insertar_Info_Proc(
        v_nombre_proceso,
        v_fec_inicio,
        v_fec_fin,
        v_comentario,
        v_cant_reg,
        v_correcto );
  COMMIT;

exception when others then 

    v_fec_fin    := V_FECHA_MIN + V_COUNT;
    v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
    P_Insertar_Info_Proc(
        v_nombre_proceso,
        v_fec_inicio,
        v_fec_fin,
        v_comentario,
        v_cant_reg,
        v_correcto );
    COMMIT  ;
end;

/
--------------------------------------------------------
--  DDL for Procedure LOAD_STG_FACT_ORDERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."LOAD_STG_FACT_ORDERS" (PI_FECHA_INICIAL VARCHAR2, PI_FECHA_FINAL VARCHAR2)
   IS
 -- VARIABLES GENERALES
  V_NOMBRE_PROCESO   VARCHAR2(30):= 'LOAD_STG_FACT_ORDERS';
  V_FEC_INICIO       DATE;
  V_FEC_FIN          DATE;
  V_COMENTARIO       VARCHAR2(255);
  V_CANT_REG         NUMBER(10)  := 0;
  V_CORRECTO         VARCHAR2(1) := 'N'; -- INDICADOR DE QUE SI EL PROCESO ESTA CORRECTO O NO
  v_total_diferencias    NUMBER(10) := 0;

V_FECHA_INICIO DATE;
  V_FECHA_FIN DATE;

BEGIN
  v_fec_inicio := SYSDATE;
  -- CODIGO DEL PROCESO
  V_FECHA_INICIO :=TO_DATE(PI_FECHA_INICIAL,'YYYYMMDD');
  V_FECHA_FIN    :=TO_DATE(PI_FECHA_FINAL,'YYYYMMDD');

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_FACT_ORDERS';
INSERT /*+NOLOGGING  APPEND*/  INTO STG_FACT_ORDERS 
(
    ORDER_DATE, USER_DW, CREATED_DW, UPDATED_DW, REQUIRED_DATE, SHIPPED_DATE, SHIP_VIA, SHIP_NAME, UNIT_PRICE, QUANTITY, DISCOUNT, CUSTOMER_IDW, EMPLOYEE_IDW, PRODUCT_IDW, SHIPPER_IDW, GEOGRAFIA_IDW
)
SELECT  
    o.ORDERDATE, 
    SYS_CONTEXT('USERENV','OS_USER'), 
    SYSDATE, 
    SYSDATE, 
    o.REQUIREDDATE, 
    o.SHIPPEDDATE, 
    o.SHIPVIA SHIP_VIA, 
    o.SHIPNAME SHIP_NAME, 
    od.UNITPRICE, 
    od.QUANTITY, 
    od.DISCOUNT, 
    NVL(e.customer_IDW, -99999), 
    NVL(e.EMPLOYEE_IDW, -99999), 
    NVL(p.PRODUCT_IDW, -99999), 
    s.SHIPPER_IDW, 
    g.GEOGRAFIA_IDW
FROM ordenes.orders o
    left join ordenes.orderdetails od ON o.orderid = od.orderid
    left join ordenes_star.dim_geografia g ON o.shipcity = g.city
    left join ordenes_star.dim_shippers s ON o.shipvia = s.shipper_id
    left join ordenes_star.dim_products p on od.productid = p.product_id
    left join ordenes_star.dim_employees e on o.employeeid = e.employee_id
    left join ordenes_star.dim_customers e on o.customerid = e.customer_id
WHERE ORDERDATE BETWEEN V_FECHA_INICIO AND V_FECHA_FIN +0.999999
;


/*
UNION ALL 
SELECT NVL((SELECT IDW_PRODUCTOS FROM STAR.DIM_PRODUCTOS  P
                WHERE P.ID_PRESENTACION = V.ID_PRESENTACION),-1) IDW_PRODUCTO
              ,-1 IDW_GEOGRAFIA
              ,-1  IDW_CLIENTE,
                TO_CHAR(FECHA ,'HH24') IDW_HORA, TRUNC(FECHA) FECHA, 1 IDW_TIPOVENTA -- TIENDA 
                , TO_CHAR(FECHA,'YYYYMM') PERIODO, FECHA,0  IMPORTE_VENTA
                    , 0 COSTO_VENTA ,0  CANTIDAD,STOCK_UNIDADES,STOCK_PESOS
                    ,SYSDATE FECHA_CARGA, 'FT', 'DIST'
 FROM DISTRIBUIDOR.STOCK V
WHERE FECHA BETWEEN PI_FECHA_INICIAL AND PI_FECHA_FINAL +0.999999 ;
*/
  V_CANT_REG:= SQL%ROWCOUNT;
 COMMIT;





  -- FIN CODIGO DEL PROCESO

  v_fec_fin    := SYSDATE;
  v_comentario := 'EL PROCESO '||v_nombre_proceso||' CULMINO SATISFACTORIAMENTE ';
  v_correcto   := 'S';

  P_Insertar_Info_Proc(v_nombre_proceso,v_fec_inicio,v_fec_fin,v_comentario,v_cant_reg,v_correcto );
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     v_fec_fin    := SYSDATE;
     v_comentario :=  ('ERROR AL ACTUALIZAR '||v_nombre_proceso||' '||SQLCODE||' '||SQLERRM);
     P_Insertar_Info_Proc(v_nombre_proceso, v_fec_inicio,v_fec_fin,v_comentario,v_cant_reg,v_correcto);
     COMMIT;
     RAISE;
END;

/
--------------------------------------------------------
--  DDL for Procedure P_INSERTAR_INFO_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ORDENES_STAGE"."P_INSERTAR_INFO_PROC" 
(
    V_NOMBRE_PROCESO LOG_DE_PROCESOS.NOMBRE_PROCESO%TYPE,
    V_FEC_INICIO  LOG_DE_PROCESOS.FEC_INICIO%TYPE,
    V_FEC_FIN     LOG_DE_PROCESOS.FEC_FIN%TYPE,
    V_COMENTARIO  LOG_DE_PROCESOS.COMENTARIO%TYPE,
    V_CANT_REG    LOG_DE_PROCESOS.CANT_REG%TYPE,
    V_CORRECTO    LOG_DE_PROCESOS.CORRECTO%TYPE
)
AS
BEGIN
    INSERT INTO ordenes_stage.LOG_DE_PROCESOS VALUES
    (
        V_NOMBRE_PROCESO,
        V_FEC_INICIO,
        V_FEC_FIN,
        V_COMENTARIO,
        V_CANT_REG,
        V_CORRECTO
    );
    COMMIT
    ;
END
;

/