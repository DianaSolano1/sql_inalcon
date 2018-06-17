select * from t_cliente;
select * from t_cargo_sueldo;
--select * from t_empleado;

insert into t_AIU values (1);
select * from t_AIU;

insert into t_gastos_campos_oficinas values (1,'Servicicios Públicos',2500000,30,22),
											(1,'Comunicaciones',1800000,20,22),
											(1,'Arriendo Oficina',3000000,40,22);
select * from t_gastos_campos_oficinas;

insert into t_impuestos values (1,'Retención en la Fuente 2% del Vr del Contrato sin IVA',2),
								(1,'Impuesto a la Renta',1.5),
								(1,'Impuesto Pro Universidad del Pacifico.',0.5);
select * from t_impuestos;


insert into t_gastos_legales (id_AIU,descripcion,valores) values (1,'Otros Impuestos',6000000);
insert into t_gastos_legales (id_AIU,descripcion,valores) values (1,'Otros Gastos de Trabajo Personal Administrativo - (Contabilidad)',95183000);
insert into t_gastos_legales (id_AIU,descripcion,valores) values (1,'Pago de Impuestos y Estampillas (Contribución + Estampillas sobre Costo Directo)',216805080),
																	(1,'Garantía única de cumplimiento y Responsabilidad Civil Extracontractual',67917732),
																	(1,'Elaboración Propuesta, incluye gastos visita y Garantía de Seriedad',135835464)
select * from t_gastos_legales;

insert into t_rol_cargo values ('Personal Profesional'),
								('Personal Técnico');
select * from t_rol_cargo;

insert into t_cargo_sueldo values (1,'Director de Interventoría. Prof Cat 2',8134962),
								(1,'Residente de Interventoría Prof Cat 5',5272014),
								(2,'Inspector de Interventoría',1668466),
								(2,'Topógrafo Auxiliar',1881124),
								(1,'Auxiliar de Ingeniería',2199582);
select * from t_cargo_sueldo;

insert into t_gastos_personal values (1,1,1,1.7,8134962,100,22),
									(1,5,2,1.7,6865362,100,22);
insert into t_gastos_personal values (1,3,2,1.7,2199582,100,22);
select * from t_gastos_personal;

insert into t_admin_imprevistos values (1,'Imprevistos',1,0),
										(1,'Utilidad sin deducir impuestos sobre la Renta. 6% del Costo Directo',6,0);
insert into t_admin_imprevistos (id_AIU,descripcion,sn_administra) values (1,'Administración',1);
select * from t_admin_imprevistos;