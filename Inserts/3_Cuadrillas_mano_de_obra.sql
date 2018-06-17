select * from t_legal;

insert into t_cuadrilla values (2,24,9);
select * from t_cuadrilla;

insert into t_rango values ('Oficial'),('Ayudante');
select * from t_rango;

insert into t_jornal_empleado values (1,1,'INSTALACIONES BASICAS',1,40),(1,2,'AYUDANTE ELECTRICO',0,36);
select * from t_jornal_empleado;

insert into t_cuadrilla_detalle values (2,1,'Cuadrilla 1 Of.',1,0), 
										(3,1,'Cuadrzilla Demoliciones - 2 Ayud.',0,2), 
										(3,1,'Cuadrilla 1 Of. + 1 Ayud.',1,1);
select * from t_cuadrilla_detalle;


