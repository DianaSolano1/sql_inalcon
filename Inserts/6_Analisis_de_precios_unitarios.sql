--select * from t_unidades;
--select * from t_productos;
--select * from t_cuadrilla;

insert into t_apu values ('0001','Mortero 1:4',1,5,5,1), 
							('0002','Concreto de 3000 psi a todo costo.',1,5,5,0);
select * from t_apu;

insert into t_apu_equipo values (1,1,1,1);
insert into t_apu_equipo values (2,2,1.4,1);
select * from t_apu_equipo;

insert into t_apu_material values (1,1,1);
insert into t_apu_material values (2,2,1.4);
select * from t_apu_material;


insert into t_apu_transporte_material values (1,1,16,0);
insert into t_apu_transporte_material values (2,2,21.4,0);
select * from t_apu_transporte_material;

insert into t_apu_mano_obra values (1,1,4);
insert into t_apu_mano_obra values (1,1,3);
select * from t_apu_mano_obra;