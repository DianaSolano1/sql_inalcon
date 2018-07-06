insert into t_unidad values ('m3'), ('meses'), ('km'), ('l');
select * from t_unidad

insert into t_procedencia values ('--'), ('Cotización'), ('Lista Oficial'), ('Criterio');
select * from t_procedencia

insert into t_legal values ('Iva',GETDATE(),10),('Salario',GETDATE(),800000.00);
select * from t_legal

insert into t_producto values (4,1,1,'EMULSIÓN ASFÁLTICA CRR-1',3100,0);
insert into t_producto values (1,2,1,'ARENA LAVADA DE RÍO',74500,1), (4,1,1,'AGUA',50,1);
select * from t_producto