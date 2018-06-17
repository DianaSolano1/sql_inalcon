insert into t_APU values ('0000','Concreto de 4000 psi a todo costo.',4,0,0,1);
insert into t_APU values (' ',' ',4,0,0,0);
select * from t_APU;

insert into t_presupuesto_general (id_APU,item) values (1,1);
select * from t_presupuesto_general;

insert into t_subpresupuesto (id_APU,id_presupuesto,item,cantidad) values (2,1,1,3);
select * from t_subpresupuesto;

insert into t_detalle_subpresupuesto values (2,1,3,1,1),(2,1,3,2,5),(2,1,3,6,7);
select * from t_detalle_subpresupuesto;