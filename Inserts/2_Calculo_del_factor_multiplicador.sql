insert into t_factor_base values ('A','SALARIO BASICO (NOMINA TOTAL MENSUAL)',100),
									('B','PRESTACIONES SOCIALES',21.83);
insert into t_factor_base (item,nombre) values ('C','COSTOS INDIRECTOS');
select * from t_factor_base;

insert into t_factor_subitem values (3,'C1','GASTOS GENERALES',15.00),(3,'C2','IMPUESTOS, PERFECCIONAMIENTO',13.25);
insert into t_factor_subitem (id_factor_base) values (2);
select * from t_factor_subitem;

insert into t_factor_detalle values (3,'Prima Anual',8.33), (3,'Cesantias Anual',8.33), (3,'Intereses Sobre Cesantia (12%)',1),
									(1,'Gastos de Personal Tecnico no Facturable',1), (1,'Gastos de Administracion',5),
									(2,'Garantia Unica de Cumplimiento',1.5), (2,'Industria y Comercio',1.25);
select * from t_factor_detalle;