exec load_dim_tiempo;
select * from ordenes_star.dim_tiempo;

select * from ordenes_stage.stg_dim_geografia;
SELECT  GEOGRAFIA_IDW, CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW
FROM  ordenes_stage.STG_DIM_GEOGRAFIA
MINUS
SELECT  GEOGRAFIA_IDW, CITY, REGION, POSTALCODE, COUNTRY, USER_DWH, CREATED_DW, UPDATED_DW
FROM ordenes_star.DIM_GEOGRAFIA
;

exec load_dim_geografia;
select * from ordenes_star.dim_geografia;

exec load_dim_products;
select * from ordenes_star.dim_products;


exec load_dim_shippers;
select * from ordenes_star.dim_shippers;

exec load_dim_customers;
select * from ordenes_star.dim_customers;

exec load_dim_employees;
select * from ordenes_star.dim_employees;

exec load_fact_orders('19950101','30000101');
select * from ordenes_star.fact_orders;

commit;