--select * from t_unidades;

insert into t_experiencia values ('P7 06-04'),('P8 03-01'),('T6'),('T3'),(' ');
select * from t_experiencia;

insert into t_costo_personal values (1,1,1,40,23),
									(2,2,2,100,23),
									(3,3,1,100,23),
									(4,4,1,100,23);
insert into t_costo_personal values (5,5,1,40,23);
select * from t_costo_personal;

insert into t_costo_directo values (2,'Equipos de Topografia',1,100,23,5500000),
									(2,'Alquiler de Oficina',1,100,23,1500000),
									(2,'Vehículo Camioneta 4x 4',2,100,23,3000000),
									(2,'Viaticos y Pasajes Aereos',1,60,23,5000000);
select * from t_costo_directo;